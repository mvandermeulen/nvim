"""
Text Summarizer Module for GitGit

Purpose:
    Provides efficient text summarization using LLM with configurable chunk sizes,
    overlap, and validation against expected outputs. Handles long text via MapReduce.
"""

import sys
import json
import asyncio
import uuid
from typing import Dict, Any, Optional, List, Tuple, Union
from difflib import SequenceMatcher
from pathlib import Path

from loguru import logger
from tenacity import retry, wait_exponential, stop_after_attempt, retry_if_exception
from pydantic import BaseModel, Field
import litellm
from litellm import completion
from litellm.types.utils import ModelResponse as LiteLLMResponse

# Import error handling and enhanced logging if available
try:
    from complexity.gitgit.integration import (
        ErrorHandler, ErrorSource, ErrorSeverity, 
        safe_execute, global_error_handler,
        HAVE_ERROR_HANDLER,
        EnhancedLogger, ComponentType, LogLevel,
        get_logger, safely_execute,
        WorkflowLogger, track_workflow, track_step,
        RepositoryWorkflow, track_repo_cloning, track_repo_chunking, track_repo_summarization,
        HAVE_ENHANCED_LOGGING
    )
except ImportError:
    logger.warning("Error handler and enhanced logging not available, falling back to standard error handling")
    HAVE_ERROR_HANDLER = False
    HAVE_ENHANCED_LOGGING = False

try:
    import nltk
    nltk_available = True
except ImportError:
    logger.warning("NLTK library not found. Basic sentence splitting will be used.")
    nltk_available = False

import torch
import numpy as np
try:
    from sentence_transformers import SentenceTransformer, util
    transformers_available = True
except ImportError:
    logger.warning("SentenceTransformer library not found. Embedding validation will not be available.")
    transformers_available = False

try:
    import openai
    openai_available = True
except ImportError:
    logger.warning("OpenAI library not found. OpenAI embedding provider will not be available.")
    openai_available = False
    openai = None

# Import utilities from gitgit
from complexity.gitgit.chunking import count_tokens_with_tiktoken
from complexity.gitgit.utils.json_utils import clean_json_string

# --- Model Classes ---
class ModelMessage(BaseModel):
    """Message from an LLM response"""
    role: str = Field(default="assistant")
    content: str = Field(default="")

    model_config = {
        "arbitrary_types_allowed": True
    }

class ModelChoice(BaseModel):
    """Single choice from an LLM response"""
    message: ModelMessage
    index: int = Field(default=0)
    finish_reason: str = Field(default="stop")
    
    model_config = {
        "arbitrary_types_allowed": True
    }

class CustomStreamWrapper(BaseModel):
    """Wrapper for streamed responses"""
    choices: List[ModelChoice] = Field(default_factory=list)
    id: str = Field(default="")
    
    model_config = {
        "arbitrary_types_allowed": True
    }

class ModelResponse(BaseModel):
    """Response from an LLM call"""
    id: str = Field(default="")
    choices: List[ModelChoice] = Field(default_factory=list)
    
    model_config = {
        "arbitrary_types_allowed": True
    }

    @classmethod
    def from_stream_wrapper(cls, wrapper: CustomStreamWrapper) -> "ModelResponse":
        """Convert a stream wrapper to a ModelResponse"""
        return cls(
            id=wrapper.id,
            choices=wrapper.choices
        )

# --- Embedding Model Management ---
local_embedding_model = None # For SentenceTransformer instance

def get_local_embedding_model(model_name: str):
    """Loads the local SentenceTransformer model if not already loaded."""
    global local_embedding_model
    # Check if the correct model is already loaded
    if local_embedding_model is None or getattr(local_embedding_model, '_model_name', None) != model_name:
        logger.info(f"Loading local embedding model: {model_name}...")
        device = 'cuda' if torch.cuda.is_available() else 'cpu'
        try:
            local_embedding_model = SentenceTransformer(model_name, device=device)
            setattr(local_embedding_model, '_model_name', model_name) # Store model name for checking
            logger.info(f"Local embedding model loaded successfully on {device}.")
        except Exception as e:
            logger.warning(f"Failed to load local model on {device}: {e}. Trying CPU...")
            local_embedding_model = SentenceTransformer(model_name, device='cpu')
            setattr(local_embedding_model, '_model_name', model_name)
            logger.info("Local embedding model loaded successfully on CPU.")
    return local_embedding_model

def get_openai_embedding(text: str, model_name: str) -> List[float]:
    """Gets a single embedding from OpenAI."""
    # Check for API key
    import os
    OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY")
    if not openai_available or not openai or not OPENAI_API_KEY:
        raise RuntimeError("OpenAI provider selected, but library or API key is not available.")
    
    try:
        client = openai.OpenAI(api_key=OPENAI_API_KEY)
        response = client.embeddings.create(model=model_name, input=text)
        return response.data[0].embedding
    except Exception as e:
        logger.error(f"OpenAI API error: {e}")
        # Re-raise the exception to be handled by the caller
        raise RuntimeError(f"OpenAI API call failed: {e}")

async def generate_embeddings(texts: List[str], embedding_config: Dict[str, Any]) -> List[List[float]]:
    """Generates embeddings using the configured provider."""
    provider = embedding_config.get("provider", "local") # Default to local
    embeddings = []

    if provider == "local":
        if not transformers_available:
            raise ValueError("Local embedding provider selected, but SentenceTransformer is not available.")
            
        model_name = embedding_config.get("local_model", "nomic-ai/modernbert-embed-base")
        model = get_local_embedding_model(model_name)
        # Add prefix for modernbert if it's the selected local model
        if "modernbert" in model_name:
             texts_to_embed = [f"search_document: {text}" for text in texts]
             logger.debug("Added 'search_document:' prefix for ModernBERT.")
        else:
             texts_to_embed = texts
        # Run encode in a separate thread as it can be CPU/GPU intensive
        embeddings = await asyncio.to_thread(model.encode, texts_to_embed)
        embeddings = embeddings.tolist() # Convert numpy array to list
    elif provider == "openai":
        if not openai_available:
             raise ValueError("OpenAI provider selected, but library or API key is unavailable.")
        model_name = embedding_config.get("openai_model", "text-embedding-ada-002")
        logger.info(f"Using OpenAI embedding model: {model_name}")
        # Use asyncio.gather for potential concurrency with OpenAI API calls
        tasks = [asyncio.to_thread(get_openai_embedding, text, model_name) for text in texts]
        try:
            results = await asyncio.gather(*tasks)
            embeddings = list(results)
        except RuntimeError as e:
             logger.error(f"Failed to get OpenAI embeddings: {e}")
             raise ValueError(f"Failed to generate OpenAI embeddings: {e}")
    else:
        raise ValueError(f"Unsupported embedding provider: {provider}")

    # Basic validation
    if not embeddings or len(embeddings) != len(texts):
         raise ValueError("Failed to generate embeddings for all input texts.")

    return embeddings

# --- LLM Call Handling ---
def should_retry_call(exception: BaseException) -> bool:
    """Determine if an exception should trigger a retry based on status code."""
    # Check for both attributes since litellm exceptions might be structured differently
    status_code = getattr(exception, "status_code", None) or getattr(exception, "code", None)
    if not status_code:
        logger.debug(f"No status code found in exception: {type(exception)}")
        return False
    # Retry on rate limits and server errors
    should_retry = status_code in [429] or (500 <= status_code < 600)
    if should_retry:
        logger.info(f"Will retry due to status code {status_code}")
    return should_retry

@retry(
    wait=wait_exponential(multiplier=1, min=4, max=60),
    stop=stop_after_attempt(5),
    retry=retry_if_exception(should_retry_call)
)
def reliable_completion(**kwargs: Any) -> LiteLLMResponse:
    """Make LLM completion call with robust retry handling."""
    messages = kwargs.get("messages", [])
    # Check if any message content is a list (indicating multimodal)
    is_multimodal_call = any(isinstance(msg.get("content"), list) for msg in messages)

    # For multimodal calls, ensure user content is a list
    if is_multimodal_call and "messages" in kwargs:
        # Log the structure being sent (truncated for brevity)
        logger.debug(f"Making multimodal LiteLLM API call with {len(messages)} messages")
    elif "messages" in kwargs:
        # Standard text call
        logger.debug(f"Making text LiteLLM API call with {len(messages)} messages")

    # Make the API call with a timeout
    try:
        response = completion(**kwargs, timeout=60)
    
        # Validate response
        choices = getattr(response, "choices", [])
        if not choices:
            logger.error("Empty response - no choices returned")
            raise ValueError("Empty model response - no choices returned")
        
        # Handle both regular and streaming choices
        choice = choices[0]
        content = None
        
        # Try different ways to access content based on response structure
        if hasattr(choice, "message") and hasattr(choice.message, "content"):
            content = choice.message.content
        elif hasattr(choice, "delta") and hasattr(choice.delta, "content"):
            content = choice.delta.content
        else:
            logger.error(f"Unexpected response structure: {choice}")
            raise ValueError("Could not extract content from response")
        
        if not content or not isinstance(content, str) or not content.strip():
            raise ValueError("Empty or invalid message content in response")
        
        # Create a standardized response
        message = ModelMessage(role="assistant", content=content.strip())
        model_choice = ModelChoice(message=message, finish_reason="stop")
        
        # Extract ID from response or generate one
        response_id = getattr(response, 'id', '') or str(uuid.uuid4())
        
        logger.debug(f"Got valid response with content length: {len(content)}")
        return response
        
    except Exception as e:
        logger.error(f"LiteLLM API call failed: {str(e)}")
        raise

# --- Validation Logic ---
async def validate_summary(summary: str, validation_data: Dict[str, Any], embedding_config: Dict[str, Any]) -> Tuple[bool, Dict[str, Any], Dict[str, Any]]:
    """
    Validate summary against expected results or original text.
    Returns: (passed, failures_dict, metrics_dict)
    If 'expected_summary' is same as 'input_text', assumes validation against original.
    """
    validation_failures = {}
    metrics = {} # Dictionary to store calculated metrics like similarity
    summary_lower = summary.lower()
    original_text = validation_data["input_text"]
    is_validation_against_original = validation_data.get("expected_summary") == original_text

    # --- Semantic Content Validation ---
    logger.info("Performing semantic similarity validation...")
    if not transformers_available:
        logger.warning("SentenceTransformer not available - skipping semantic validation")
        validation_failures["semantic_similarity"] = {"error": "SentenceTransformer not available"}
        return False, validation_failures, {}
        
    target_text_for_similarity = validation_data["expected_summary"] # Could be original text or a specific expected summary
    try:
        embeddings = await generate_embeddings([summary, target_text_for_similarity], embedding_config)
        if len(embeddings) != 2:
             raise ValueError(f"Expected 2 embeddings, but got {len(embeddings)}")
        # Calculate similarity using sentence_transformers util
        similarity = util.cos_sim(embeddings[0], embeddings[1]).item() # Get scalar value
        metrics["semantic_similarity"] = similarity # Store the calculated similarity
    except (ValueError, RuntimeError) as e:
         logger.error(f"Embedding generation failed during validation: {e}")
         validation_failures["embedding_generation"] = {"error": str(e)}
         # Cannot proceed with similarity check if embeddings failed
         # Return empty metrics dict on embedding failure
         return False, validation_failures, {}

    # Determine threshold based on validation type
    default_threshold = 0.6 if is_validation_against_original else 0.7
    threshold = validation_data["expected_properties"].get("semantic_similarity_threshold", default_threshold)
    logger.debug(f"Semantic similarity score: {similarity:.4f} (threshold: {threshold})")

    if similarity < threshold:
        validation_failures["semantic_similarity"] = {
            "expected": f">= {threshold}",
            "actual": f"{similarity:.4f}"
        }

    # --- Other Validations (Only if NOT validating against original text) ---
    if not is_validation_against_original:
        logger.info("Performing compression ratio and key concept validation...")
        # Compression ratio validation
        input_len = len(original_text.split())
        summary_len = len(summary.split())
        if input_len > 0:
            compression = summary_len / input_len
            expected_compression = validation_data["expected_properties"].get("compression_ratio")
            if expected_compression is not None:
                tolerance = 0.4 # Allow 40% deviation
                if abs(compression - expected_compression) > tolerance:
                    validation_failures["compression_ratio"] = {
                        "expected": expected_compression,
                        "actual": f"{compression:.2f}"
                    }
        else:
             logger.warning("Input text has zero length, skipping compression ratio check.")

        # Key concepts validation
        expected_concepts = validation_data["expected_properties"].get("key_concepts", [])
        if expected_concepts:
            missing_concepts = []
            for concept in expected_concepts:
                if concept.lower() not in summary_lower:
                    missing_concepts.append(concept)
            if missing_concepts:
                validation_failures["missing_concepts"] = {
                    "expected": expected_concepts,
                    "actual_missing": missing_concepts,
                    "found": [c for c in expected_concepts if c not in missing_concepts]
                }
    else:
         logger.info("Skipping compression ratio and key concept validation (validating against original text).")

    logger.debug(f"Validation failures: {validation_failures}")
    logger.debug(f"Validation metrics: {metrics}")
    return len(validation_failures) == 0, validation_failures, metrics

# --- Chunking Logic ---
def create_chunks_with_overlap(sentences: List[str], chunk_size: int, overlap_size: Optional[int]=None) -> List[List[str]]:
    """Creates chunks of sentences with overlap, handling long sentences effectively."""
    if not sentences:
        return []
    if overlap_size is None:
        overlap_size = max(1, len(sentences) // 20) # Default overlap based on sentence count
    chunks = []
    current_chunk = []
    current_chunk_tokens = 0

    # Ensure NLTK data is available
    if nltk_available:
        try:
            nltk.data.find('tokenizers/punkt')
        except LookupError:
            logger.info("Downloading NLTK 'punkt' tokenizer...")
            nltk.download('punkt', quiet=True)

    for sentence in sentences:
        sentence_tokens = count_tokens_with_tiktoken(sentence)
        # Handle sentence longer than chunk size
        if sentence_tokens > chunk_size:
            if current_chunk: # Add previous chunk if exists
                chunks.append(current_chunk)
            chunks.append([sentence]) # Long sentence becomes its own chunk
            current_chunk = []
            current_chunk_tokens = 0
            logger.warning(f"Sentence with {sentence_tokens} tokens exceeds chunk size {chunk_size}. Treating as separate chunk.")
        # If adding sentence exceeds chunk size, finalize current chunk
        elif current_chunk_tokens + sentence_tokens > chunk_size:
            if current_chunk: # Ensure chunk is not empty before adding
                 chunks.append(current_chunk)
            # Start new chunk with overlap
            start_index = max(0, len(current_chunk) - overlap_size) if overlap_size > 0 else len(current_chunk)
            current_chunk = current_chunk[start_index:]
            current_chunk_tokens = sum(count_tokens_with_tiktoken(s) for s in current_chunk)
            # Add current sentence to new chunk
            current_chunk.append(sentence)
            current_chunk_tokens += sentence_tokens
        # Otherwise, add sentence to current chunk
        else:
            current_chunk.append(sentence)
            current_chunk_tokens += sentence_tokens

    # Add the last chunk if it's not empty
    if current_chunk:
        chunks.append(current_chunk)

    logger.info(f"Created {len(chunks)} chunks.")
    return chunks

# --- Summarization Core Logic ---
async def summarize_chunk(
    chunk_text: str,
    config: Dict[str, Any],
    prompt: str,
    image_inputs: Optional[List[Dict[str, Any]]] = None, # Added optional images for final reduction
    code_metadata: Optional[str] = None # Added code metadata for final reduction context
) -> str:
     """Summarizes a single text chunk using reliable_completion."""
     model = config.get("model", "gpt-4o-mini")
     temperature = config.get("temperature", 0.7)
     # Estimate input tokens for max_tokens calculation
     input_tokens = count_tokens_with_tiktoken(chunk_text)
     # Allow slightly more tokens for chunk summaries, maybe 80%? Cap at 1000?
     max_tokens = min(max(150, int(input_tokens * 0.8)), 1000)

     logger.debug(f"Summarizing chunk ({input_tokens} tokens) with max_output={max_tokens}...")
     
     try:
         # Construct user message content including metadata if provided
         if code_metadata and image_inputs:
             # Case 1: Metadata and Images
             user_content = [
                 {"type": "text", "text": f"{code_metadata}\n\n--- Text to Summarize ---\n{chunk_text}"}
             ] + image_inputs
         elif code_metadata:
             # Case 2: Only Metadata
             user_content = f"{code_metadata}\n\n--- Text to Summarize ---\n{chunk_text}"
         elif image_inputs:
             # Case 3: Only Images
             user_content = [{"type": "text", "text": chunk_text}] + image_inputs
         else:
             # Case 4: Only Text
             user_content = chunk_text
         
         # Run the API call via reliable_completion
         response = await asyncio.to_thread(
             reliable_completion,
             model=model,
             messages=[
                 {"role": "system", "content": prompt},
                 {"role": "user", "content": user_content}
             ],
             temperature=temperature,
             max_tokens=max_tokens,
         )
         
         # Extract content from response
         choices = getattr(response, "choices", [])
         if not choices:
             raise ValueError("No choices in chunk summary response")
         
         choice = choices[0]
         content = None
         
         if hasattr(choice, "message") and hasattr(choice.message, "content"):
             content = choice.message.content
         elif hasattr(choice, "delta") and hasattr(choice.delta, "content"):
             content = choice.delta.content
         else:
             raise ValueError("Could not extract content from response")
         
         if not content or not content.strip():
             raise ValueError("Empty or whitespace-only chunk summary")
             
         summary = content.strip()
         logger.debug(f"Chunk summary ({len(summary.split())} words): {summary[:100]}...")
         return summary
     except Exception as e:
          logger.error(f"Error summarizing chunk: {e}", exc_info=True)
          # Return error message as string
          return f"Error summarizing chunk: {e}"

# --- Recursive Reduction Helper ---
async def _recursive_reduce(
    text_to_reduce: str,
    config: Dict[str, Any],
    final_summary_prompt: str,
    image_inputs: Optional[List[Dict[str, Any]]],
    code_metadata: Optional[str],
    current_depth: int = 0
) -> str:
    """
    Recursively reduces text if it exceeds context limits, otherwise summarizes.
    """
    # Get config values
    context_limit_threshold = config.get("context_limit_threshold", 3800)
    max_recursion_depth = config.get("max_recursion_depth", 3) # Added config
    chunk_size = config.get("chunk_size", 3500)
    overlap_size = config.get("overlap_size", 2)
    default_chunk_prompt = "Summarize the key points of this text segment:"
    chunk_summary_prompt = config.get("chunk_summary_prompt", default_chunk_prompt) # Needed for recursive step

    input_tokens = count_tokens_with_tiktoken(text_to_reduce)

    if input_tokens <= context_limit_threshold:
        # Base case: Text fits, perform final summarization
        logger.debug(f"Recursion depth {current_depth}: Text fits ({input_tokens} <= {context_limit_threshold}). Performing final summarization.")
        try:
            final_summary = await summarize_chunk(
                text_to_reduce,
                config,
                final_summary_prompt,
                image_inputs=image_inputs,
                code_metadata=code_metadata
            )
            return final_summary
        except Exception as e:
            logger.error(f"Final reduction summarization failed at depth {current_depth}: {e}", exc_info=True)
            raise ValueError(f"Final reduction summarization failed: {e}")
    else:
        # Recursive case: Text too long
        logger.debug(f"Recursion depth {current_depth}: Combined text too long ({input_tokens} > {context_limit_threshold}).")

        if current_depth >= max_recursion_depth:
            # Max depth reached, truncate
            logger.warning(f"Max recursion depth ({max_recursion_depth}) reached. Truncating text ({input_tokens} tokens) for final pass.")
            # Use a slightly more robust truncation based on estimated characters per token
            estimated_chars_per_token = 4 # A common estimate
            truncation_limit_chars = int(context_limit_threshold * estimated_chars_per_token)
            truncated_text = text_to_reduce[:truncation_limit_chars]
            logger.debug(f"Truncated text to approx {count_tokens_with_tiktoken(truncated_text)} tokens.")
            try:
                 # Summarize the truncated text
                 final_summary = await summarize_chunk(
                     truncated_text,
                     config,
                     final_summary_prompt,
                     image_inputs=image_inputs,
                     code_metadata=code_metadata
                 )
                 return final_summary
            except Exception as e:
                 logger.error(f"Final summarization failed after truncation at max depth {current_depth}: {e}", exc_info=True)
                 raise ValueError(f"Final summarization failed after truncation: {e}")
        else:
            # Initiate recursive reduction
            logger.debug(f"Recursive reduction initiated at depth {current_depth}. Re-chunking...")
            
            # Get sentences for chunking
            if nltk_available:
                sentences = nltk.sent_tokenize(text_to_reduce)
            else:
                # Fallback to basic splitting at periods, question marks, and exclamation points
                import re
                sentences = re.split(r'(?<=[.!?]) +', text_to_reduce)
            
            recursive_chunks = create_chunks_with_overlap(sentences, chunk_size, overlap_size)
            if not recursive_chunks:
                 logger.warning(f"Recursive chunking at depth {current_depth} resulted in zero chunks. Returning original text for this level.")
                 # Fallback: try summarizing the original text for this level, hoping it works (might fail if too long)
                 try:
                     final_summary = await summarize_chunk(
                         text_to_reduce, config, final_summary_prompt, image_inputs=image_inputs, code_metadata=code_metadata
                     )
                     return final_summary
                 except Exception as e:
                     logger.error(f"Fallback summarization failed at depth {current_depth} after empty recursive chunks: {e}", exc_info=True)
                     raise ValueError(f"Recursive reduction failed due to empty chunks and fallback failure: {e}")

            recursive_chunk_texts = [' '.join(chunk) for chunk in recursive_chunks]

            logger.info(f"Recursively summarizing {len(recursive_chunk_texts)} new chunks at depth {current_depth}...")
            recursive_summaries_results = await asyncio.gather(
                *(summarize_chunk(chunk_text, config, chunk_summary_prompt) for chunk_text in recursive_chunk_texts),
                return_exceptions=True
            )

            # Filter errors
            recursive_summaries = []
            for i, result in enumerate(recursive_summaries_results):
                 if isinstance(result, Exception):
                      logger.error(f"Error summarizing recursive chunk {i} at depth {current_depth}: {result}", exc_info=True)
                 elif isinstance(result, str) and result.startswith("Error summarizing chunk:"):
                      logger.error(f"Error string returned for recursive chunk {i} at depth {current_depth}: {result}")
                 elif isinstance(result, str):
                      recursive_summaries.append(result)
                 else:
                      logger.error(f"Unexpected result type for recursive chunk {i} at depth {current_depth}: {type(result)} - {result}")

            if not recursive_summaries:
                 raise ValueError(f"All recursive chunk summarization attempts failed at depth {current_depth}.")

            new_combined_text = "\n\n".join(recursive_summaries)
            logger.debug(f"Combined {len(recursive_summaries)} recursive summaries at depth {current_depth}. New combined tokens: {count_tokens_with_tiktoken(new_combined_text)}")

            # Recursive call
            return await _recursive_reduce(
                new_combined_text,
                config,
                final_summary_prompt,
                image_inputs,
                code_metadata,
                current_depth + 1
            )

# --- Main Summarization Function ---
async def summarize_text(
    text: str,
    config: Dict[str, Any],
    image_inputs: Optional[List[Dict[str, Any]]] = None,
    code_metadata: Optional[str] = None
) -> str:
    """
    Summarize text (and optionally images, with code metadata context) using LLM.
    Handles long text via chunking (MapReduce) and recursive reduction.
    
    Args:
        text: Input text to summarize
        config: Configuration dict with parameters:
            - model: LLM model name (default: "gpt-4o-mini")
            - temperature: Temperature for LLM (default: 0.7)
            - context_limit_threshold: Max tokens for direct summarization (default: 3800)
            - chunk_size: Max tokens per chunk (default: 3500)
            - overlap_size: Number of sentences to overlap (default: 2)
            - system_prompt: System prompt for direct summarization
            - code_system_prompt: System prompt for code summarization
            - chunk_summary_prompt: Prompt for summarizing individual chunks
            - final_summary_prompt: Prompt for final summary reduction
            - is_code_summary: Whether summarizing code (default: False)
            - max_recursion_depth: Maximum recursive reduction passes (default: 3)
        image_inputs: Optional list of image inputs for multimodal models
        code_metadata: Optional code metadata string for context
        
    Returns:
        str: Generated summary text
    """
    if not text:
        raise ValueError("Input text cannot be empty")

    model_name = config.get("model", "gpt-4o-mini")
    temperature = config.get("temperature", 0.7)
    # Define a reasonable context limit threshold
    context_limit_threshold = config.get("context_limit_threshold", 3800)
    chunk_size = config.get("chunk_size", 3500) # Size for individual chunks
    overlap_size = config.get("overlap_size", 2) # Number of sentences overlap

    input_tokens = count_tokens_with_tiktoken(text)
    logger.info(f"Input text estimated tokens: {input_tokens}")

    # --- Direct Summarization for Short Text ---
    if input_tokens <= context_limit_threshold:
        logger.info("Input text is within context limit. Summarizing directly.")
        # Choose prompt based on whether it's code
        is_code = config.get("is_code_summary", False)
        if is_code:
            default_code_prompt = "Summarize the following code, explaining its purpose, inputs, outputs, and key logic. Use the provided code structure context if available."
            system_prompt = config.get("code_system_prompt", default_code_prompt)
            if system_prompt != default_code_prompt:
                logger.info("Using custom code system prompt for direct summarization.")
            # Allow potentially longer summaries for code
            max_tokens = min(max(200, int(input_tokens * 0.7)), 800)
        else:
            default_system_prompt = "Summarize the following text concisely, preserving key information."
            system_prompt = config.get("system_prompt", default_system_prompt)
            if system_prompt != default_system_prompt:
                logger.info("Using custom system prompt for direct summarization.")
            # Adjust max_tokens calculation for better summary length
            max_tokens = min(max(100, int(input_tokens * 0.6)), 500) # Aim for 60% length, capped

        # Construct user content, potentially including metadata
        user_content = text
        if is_code and code_metadata:
            user_content = f"{code_metadata}\n\n--- Code to Summarize ---\n{text}"
            logger.debug("Prepending code metadata to user prompt for direct summarization.")

        # Format for multimodal if images are present
        if image_inputs:
            user_content_final = [{"type": "text", "text": user_content}] + image_inputs
        else:
            user_content_final = user_content

        try:
            response = await asyncio.to_thread( # Run sync reliable_completion in thread
                reliable_completion,
                model=model_name,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_content_final} # Use potentially modified user content
                ],
                temperature=temperature,
                max_tokens=max_tokens,
            )
            # Safely extract summary
            choices = getattr(response, "choices", [])
            if not choices: raise ValueError("No choices in direct summary response")
            message = getattr(choices[0], "message", None)
            if not message: raise ValueError("No message in direct summary first choice")
            summary = getattr(message, "content", "").strip()
            if not summary: raise ValueError("Empty or whitespace-only direct summary")

            output_tokens = len(summary.split())
            logger.info(
                f"Direct Summarization stats: Input={input_tokens} tokens, "
                f"Output={output_tokens} tokens, "
                f"Reduction={(1 - output_tokens/input_tokens)*100:.1f}%" if input_tokens > 0 else "N/A"
            )
            return summary
        except Exception as e:
             logger.error(f"Direct summarization failed: {e}", exc_info=True)
             raise ValueError(f"Direct summarization failed: {e}")

    # --- Chunking Summarization for Long Text (MapReduce) ---
    else:
        logger.info("Input text exceeds context limit. Using chunking (MapReduce).")

        # 1. Split into sentences
        if nltk_available:
            sentences = nltk.sent_tokenize(text)
        else:
            # Fallback to basic splitting at periods, question marks, and exclamation points
            import re
            sentences = re.split(r'(?<=[.!?]) +', text)

        # 2. Create chunks
        chunks = create_chunks_with_overlap(sentences, chunk_size, overlap_size)
        if not chunks:
             logger.warning("Text chunking resulted in zero chunks. Returning original text.")
             return text # Or raise error?
        chunk_texts = [' '.join(chunk) for chunk in chunks]

        # 3. Summarize each chunk (Map)
        # Code chunks are summarized like text chunks for the Map step
        default_chunk_prompt = "Summarize the key points of this text segment:"
        chunk_summary_prompt = config.get("chunk_summary_prompt", default_chunk_prompt)
        if chunk_summary_prompt != default_chunk_prompt:
            logger.info("Using custom chunk summary prompt.")
        # Use asyncio.gather for concurrent chunk summarization
        logger.info(f"Summarizing {len(chunk_texts)} chunks concurrently...")
        chunk_summaries_results = await asyncio.gather(
            *(summarize_chunk(chunk_text, config, chunk_summary_prompt) for chunk_text in chunk_texts),
            return_exceptions=True # Return exceptions instead of raising immediately
        )

        # Filter out errors and log them
        chunk_summaries = []
        for i, result in enumerate(chunk_summaries_results):
             if isinstance(result, Exception):
                  # Log the exception traceback for better debugging
                  logger.error(f"Error summarizing chunk {i}: {result}", exc_info=True)
             # Explicitly check if result is a string before using 'in'
             elif isinstance(result, str) and result.startswith("Error summarizing chunk:"):
                  logger.error(f"Error string returned for chunk {i}: {result}")
             elif isinstance(result, str): # Check if it's a valid string summary
                  chunk_summaries.append(result)
             else: # Handle unexpected types if necessary
                  logger.error(f"Unexpected result type for chunk {i}: {type(result)} - {result}")

        if not chunk_summaries:
             raise ValueError("All chunk summarization attempts failed.")

        # 4. Combine chunk summaries
        combined_summary_text = "\n\n".join(chunk_summaries)
        combined_tokens = count_tokens_with_tiktoken(combined_summary_text)
        logger.info(f"Combined {len(chunk_summaries)} chunk summaries. Combined tokens: {combined_tokens}")

        # 5. Reduce the combined summaries (potentially recursively)
        is_code = config.get("is_code_summary", False)
        if is_code:
            default_code_final_prompt = "Synthesize the following code segment summaries into a single, coherent explanation of the overall code's purpose and structure. Use the provided overall code structure context if available."
            # Note: we'll use 'code_system_prompt' if provided, otherwise the specific default.
            # If 'final_summary_prompt' is ALSO provided, it takes precedence for the final step even for code.
            final_summary_prompt = config.get("final_summary_prompt", config.get("code_system_prompt", default_code_final_prompt))
            if final_summary_prompt != default_code_final_prompt:
                 logger.info("Using custom final prompt (or code system prompt) for code reduction.")
        else:
            default_final_prompt = "Synthesize the following summaries into a single, coherent summary:"
            final_summary_prompt = config.get("final_summary_prompt", default_final_prompt)
            if final_summary_prompt != default_final_prompt:
                 logger.info("Using custom final summary prompt.")

        try:
            # Call the recursive reduction helper function
            final_summary = await _recursive_reduce(
                text_to_reduce=combined_summary_text,
                config=config,
                final_summary_prompt=final_summary_prompt,
                image_inputs=image_inputs, # Pass images through
                code_metadata=code_metadata, # Pass metadata through
                current_depth=0 # Start recursion depth at 0
            )
        except Exception as e:
             # Error already logged in _recursive_reduce, just re-raise with more context
             logger.error(f"Recursive reduction process failed: {e}")
             # Return combined text as fallback if LLM reduction fails
             return combined_summary_text

        output_tokens = count_tokens_with_tiktoken(final_summary)
        logger.info(
            f"Chunked Summarization stats: Input={input_tokens} tokens, "
            f"Output={output_tokens} tokens, "
            f"Reduction={(1 - output_tokens/input_tokens)*100:.1f}%" if input_tokens > 0 else "N/A"
        )
        return final_summary