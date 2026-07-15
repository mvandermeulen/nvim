import os
import shutil
import subprocess
import typer
from typing import List, Optional, Dict, Any
import litellm
import json
import tiktoken
from loguru import logger
import textwrap
from markitdown import MarkItDown
from dotenv import find_dotenv, load_dotenv
from pydantic import BaseModel, ValidationError
from tenacity import retry, stop_after_attempt, wait_exponential
from complexity.gitgit.utils.initialize_litellm_cache import initialize_litellm_cache
from complexity.gitgit.utils.json_utils import clean_json_string, json_to_markdown
from complexity.gitgit.chunking import TextChunker, count_tokens_with_tiktoken, hash_string
from complexity.gitgit.parser import extract_code_metadata, extract_code_metadata_from_file, get_language_by_extension
from complexity.gitgit.markdown import parse_markdown, verify_markdown_parsing

# Import error handling and enhanced logging system
try:
    from complexity.gitgit.integration import (
        ErrorHandler, ErrorSource, ErrorSeverity, 
        safe_execute, global_error_handler,
        HAVE_ERROR_HANDLER
    )
except ImportError:
    logger.warning("Error handler not available, falling back to standard error handling")
    HAVE_ERROR_HANDLER = False

# Import enhanced logging and workflow tracking if available
try:
    from complexity.gitgit.integration import (
        EnhancedLogger, ComponentType, LogLevel,
        get_logger, safely_execute,
        WorkflowLogger, track_workflow, track_step,
        RepositoryWorkflow, track_repo_cloning, track_repo_chunking, track_repo_summarization,
        HAVE_ENHANCED_LOGGING
    )
except ImportError:
    logger.warning("Enhanced logging not available, falling back to standard logging")
    HAVE_ENHANCED_LOGGING = False

load_dotenv()
initialize_litellm_cache()

# Define the RepoSummary pydantic model
class RepoSummary(BaseModel):
    """Model for repository summary data returned by LLM"""
    summary: str
    table_of_contents: List[str]
    key_sections: Optional[List[Dict[str, str]]] = None
    
    model_config = {
        "arbitrary_types_allowed": True
    }

# We now use language mappings from complexity.gitgit.parser.tree_sitter_utils

app = typer.Typer(help="A CLI utility for sparse cloning, summarizing, and LLM-based documentation of GitHub repositories.")

# We're now importing count_tokens_with_tiktoken from complexity.gitgit.chunking

# We now import extract_code_metadata from complexity.gitgit.parser

def interactive_file_selection(repo_url: str) -> tuple[Optional[List[str]], Optional[List[str]]]:
    """
    Placeholder for interactive file/directory selection (browser-based or VS Code-integrated).
    
    Args:
        repo_url (str): GitHub repository URL.
    
    Returns:
        tuple: (files, dirs) selected by the user (currently returns None, None).
    
    Note:
        Future implementation will use a Flask/FastAPI web app or VS Code extension
        to allow users to browse and select files/directories via GitHub API or repository tree view.
    """
    logger.info("Interactive file selection is not yet implemented.")
    return None, None

def sparse_clone(repo_url: str, extensions: List[str], clone_dir: str, files: Optional[List[str]] = None, dirs: Optional[List[str]] = None):
    """
    Sparse clone a repository with specified extensions, files, or directories.
    
    Args:
        repo_url: Repository URL to clone
        extensions: List of file extensions to include
        clone_dir: Directory to clone to
        files: Specific files to include
        dirs: Specific directories to include
        
    Returns:
        bool: True if successful, False otherwise
    """
    try:
        # Use standard implementation directly for now
        # as workflow tracking and error handling seem problematic
        return _sparse_clone_standard(repo_url, extensions, clone_dir, files, dirs)
        
        # Original implementation with conditionals
        # Use workflow tracking if available
        #if HAVE_ENHANCED_LOGGING:
        #    return _sparse_clone_with_workflow_tracking(repo_url, extensions, clone_dir, files, dirs)
        # Use error handler if available, otherwise use standard try/except
        #elif HAVE_ERROR_HANDLER:
        #    return _sparse_clone_with_error_handler(repo_url, extensions, clone_dir, files, dirs)
        #else:
        #    return _sparse_clone_standard(repo_url, extensions, clone_dir, files, dirs)
    except Exception as e:
        logger.error(f"Sparse clone failed: {e}")
        return False


@track_repo_cloning
def _sparse_clone_with_workflow_tracking(repo_url: str, extensions: List[str], clone_dir: str, 
                                        files: Optional[List[str]] = None, 
                                        dirs: Optional[List[str]] = None,
                                        repo_workflow=None):
    """
    Sparse clone implementation with workflow tracking and detailed logging.
    
    Args:
        repo_url: Repository URL to clone
        extensions: List of file extensions to include
        clone_dir: Directory to clone to
        files: Specific files to include
        dirs: Specific directories to include
        repo_workflow: Repository workflow tracker (injected by decorator)
        
    Returns:
        List[str]: List of files found after cloning
    """
    # Use error handler if available
    handler = global_error_handler if HAVE_ERROR_HANDLER else None
    
    # Clean up existing directory if it exists
    def clean_directory():
        if os.path.exists(clone_dir):
            shutil.rmtree(clone_dir)
        os.makedirs(clone_dir, exist_ok=True)
    
    if repo_workflow:
        clean_dir_result = repo_workflow.workflow_logger.safely_run_step(
            clean_directory,
            "Clean target directory",
            ComponentType.DIRECTORY,
            {"clone_dir": clone_dir},
            recoverable=False
        )
        
        if not clean_dir_result:
            return []
    else:
        clean_directory()
    
    # Initialize git repository
    def git_init():
        subprocess.run(['git', 'init'], cwd=clone_dir, check=True)
    
    if repo_workflow:
        init_result = repo_workflow.workflow_logger.safely_run_step(
            git_init,
            "Initialize git repository",
            ComponentType.REPOSITORY,
            {"clone_dir": clone_dir},
            recoverable=False
        )
        
        if not init_result:
            return []
    else:
        git_init()
    
    # Add remote
    def add_remote():
        subprocess.run(['git', 'remote', 'add', 'origin', repo_url], cwd=clone_dir, check=True)
    
    if repo_workflow:
        remote_result = repo_workflow.workflow_logger.safely_run_step(
            add_remote,
            "Add git remote",
            ComponentType.REPOSITORY,
            {"repo_url": repo_url},
            recoverable=False
        )
        
        if not remote_result:
            return []
    else:
        add_remote()
    
    # Configure sparse checkout
    def config_sparse_checkout():
        subprocess.run(['git', 'config', 'core.sparseCheckout', 'true'], cwd=clone_dir, check=True)
    
    if repo_workflow:
        config_result = repo_workflow.workflow_logger.safely_run_step(
            config_sparse_checkout,
            "Configure sparse checkout",
            ComponentType.REPOSITORY,
            recoverable=False
        )
        
        if not config_result:
            return []
    else:
        config_sparse_checkout()
    
    # Create sparse checkout file
    def create_sparse_patterns():
        sparse_patterns = []
        if files or dirs:
            if files:
                sparse_patterns.extend([f"{f}" for f in files])
            if dirs:
                sparse_patterns.extend([f"{d.rstrip('/')}/**/*" for d in dirs])
        else:
            for ext in extensions:
                sparse_patterns.append(f'**/*.{ext}')
                sparse_patterns.append(f'/*.{ext}')
        
        sparse_file = os.path.join(clone_dir, '.git', 'info', 'sparse-checkout')
        with open(sparse_file, 'w') as f:
            f.write('\n'.join(sparse_patterns) + '\n')
        
        return sparse_patterns
    
    if repo_workflow:
        patterns = repo_workflow.workflow_logger.safely_run_step(
            create_sparse_patterns,
            "Create sparse checkout patterns",
            ComponentType.FILE_SYSTEM,
            {"extensions": extensions, "files": files, "dirs": dirs},
            recoverable=False
        )
        
        if not patterns:
            return []
    else:
        create_sparse_patterns()
    
    # Pull repository
    def pull_repo():
        subprocess.run(['git', 'pull', '--depth=1', 'origin', 'HEAD'], cwd=clone_dir, check=True)
    
    if repo_workflow:
        pull_result = repo_workflow.workflow_logger.safely_run_step(
            pull_repo,
            "Pull repository",
            ComponentType.REPOSITORY,
            {"repo_url": repo_url},
            recoverable=False
        )
        
        if not pull_result:
            return []
    else:
        pull_repo()
    
    # Return list of files found
    return debug_print_files(clone_dir, extensions, files, dirs)

def _sparse_clone_with_error_handler(repo_url: str, extensions: List[str], clone_dir: str, files: Optional[List[str]] = None, dirs: Optional[List[str]] = None):
    """Sparse clone implementation with error handling."""
    handler = global_error_handler
    
    # Clean up existing directory if it exists
    def clean_directory():
        if os.path.exists(clone_dir):
            shutil.rmtree(clone_dir)
        os.makedirs(clone_dir, exist_ok=True)
    
    success = safe_execute(
        clean_directory,
        handler,
        ErrorSource.DIRECTORY,
        file_path=clone_dir,
        context={"operation": "cleanup"},
        recoverable=False
    )
    
    if not success:
        return False
    
    # Initialize git repository
    def git_init():
        subprocess.run(['git', 'init'], cwd=clone_dir, check=True)
    
    success = safe_execute(
        git_init,
        handler,
        ErrorSource.REPOSITORY,
        file_path=clone_dir,
        context={"operation": "init"},
        recoverable=False
    )
    
    if not success:
        return False
    
    # Add remote
    def add_remote():
        subprocess.run(['git', 'remote', 'add', 'origin', repo_url], cwd=clone_dir, check=True)
    
    success = safe_execute(
        add_remote,
        handler,
        ErrorSource.REPOSITORY,
        file_path=clone_dir,
        context={"operation": "add_remote", "repo_url": repo_url},
        recoverable=False
    )
    
    if not success:
        return False
    
    # Configure sparse checkout
    def config_sparse_checkout():
        subprocess.run(['git', 'config', 'core.sparseCheckout', 'true'], cwd=clone_dir, check=True)
    
    success = safe_execute(
        config_sparse_checkout,
        handler,
        ErrorSource.REPOSITORY,
        file_path=clone_dir,
        context={"operation": "config_sparse"},
        recoverable=False
    )
    
    if not success:
        return False
    
    # Create sparse checkout file
    def create_sparse_patterns():
        sparse_patterns = []
        if files or dirs:
            if files:
                sparse_patterns.extend([f"{f}" for f in files])
            if dirs:
                sparse_patterns.extend([f"{d.rstrip('/')}/**/*" for d in dirs])
        else:
            for ext in extensions:
                sparse_patterns.append(f'**/*.{ext}')
                sparse_patterns.append(f'/*.{ext}')
        
        sparse_file = os.path.join(clone_dir, '.git', 'info', 'sparse-checkout')
        with open(sparse_file, 'w') as f:
            f.write('\n'.join(sparse_patterns) + '\n')
    
    success = safe_execute(
        create_sparse_patterns,
        handler,
        ErrorSource.FILE_SYSTEM,
        file_path=os.path.join(clone_dir, '.git', 'info', 'sparse-checkout'),
        context={"operation": "create_sparse_patterns"},
        recoverable=False
    )
    
    if not success:
        return False
    
    # Pull repository
    def pull_repo():
        subprocess.run(['git', 'pull', '--depth=1', 'origin', 'HEAD'], cwd=clone_dir, check=True)
    
    success = safe_execute(
        pull_repo,
        handler,
        ErrorSource.REPOSITORY,
        file_path=clone_dir,
        context={"operation": "pull", "repo_url": repo_url},
        recoverable=False
    )
    
    return success

def _sparse_clone_standard(repo_url: str, extensions: List[str], clone_dir: str, files: Optional[List[str]] = None, dirs: Optional[List[str]] = None):
    """Standard sparse clone implementation without specialized error handling."""
    if os.path.exists(clone_dir):
        shutil.rmtree(clone_dir)
    os.makedirs(clone_dir, exist_ok=True)

    subprocess.run(['git', 'init'], cwd=clone_dir, check=True)
    subprocess.run(['git', 'remote', 'add', 'origin', repo_url], cwd=clone_dir, check=True)
    subprocess.run(['git', 'config', 'core.sparseCheckout', 'true'], cwd=clone_dir, check=True)

    sparse_patterns = []
    if files or dirs:
        if files:
            sparse_patterns.extend([f"{f}" for f in files])
        if dirs:
            sparse_patterns.extend([f"{d.rstrip('/')}/**/*" for d in dirs])
    else:
        for ext in extensions:
            sparse_patterns.append(f'**/*.{ext}')
            sparse_patterns.append(f'/*.{ext}')
    
    sparse_file = os.path.join(clone_dir, '.git', 'info', 'sparse-checkout')
    with open(sparse_file, 'w') as f:
        f.write('\n'.join(sparse_patterns) + '\n')

    subprocess.run(['git', 'pull', '--depth=1', 'origin', 'HEAD'], cwd=clone_dir, check=True)
    return True

def save_to_root(root_dir: str, filename: str, content: str):
    with open(os.path.join(root_dir, filename), "w", encoding="utf-8") as f:
        f.write(content)

def build_tree(root_dir):
    tree_lines = []
    for dirpath, dirnames, filenames in os.walk(root_dir):
        rel_dir = os.path.relpath(dirpath, root_dir)
        indent = "" if rel_dir == "." else "    " * rel_dir.count(os.sep)
        tree_lines.append(f"{indent}{os.path.basename(dirpath) if rel_dir != '.' else '.'}/")
        for filename in sorted(filenames):
            tree_lines.append(f"{indent}    {filename}")
    return "\n".join(tree_lines)

@track_repo_chunking
def concat_and_summarize(root_dir, extensions, files: Optional[List[str]] = None, dirs: Optional[List[str]] = None, code_metadata: bool = False, max_chunk_tokens: int = 500, chunk_overlap: int = 100, enhanced_markdown: bool = True, repo_workflow=None):
    """
    Enhanced version of concat_and_summarize that uses advanced text processing techniques.
    
    This function processes files in the specified repository directory and generates:
    1. A structured digest that preserves document organization
    2. A summary of the repository
    3. A tree representation of the repository structure
    
    For markdown files, it can use an enhanced parser that extracts section hierarchy
    and associates code blocks with their descriptions.
    
    Args:
        root_dir: Root directory of the repository
        extensions: List of file extensions to include
        files: Optional list of specific files to include
        dirs: Optional list of directories to include
        code_metadata: Whether to extract and include code metadata
        max_chunk_tokens: Maximum tokens per chunk (default: 500)
        chunk_overlap: Minimum token overlap between chunks (default: 100)
        enhanced_markdown: Whether to use enhanced markdown extraction (default: True)
        
    Returns:
        Tuple of (summary, tree, digest)
    """
    # Initialize collections
    digest_parts = []
    chunked_files = []
    file_count = 0
    total_bytes = 0
    files_list = []
    all_chunks = []
    requested_paths = set(files or []) | {os.path.join(d, f) for d in (dirs or []) for f in os.listdir(os.path.join(root_dir, d)) if os.path.isfile(os.path.join(root_dir, d, f))}
    
    # Create text chunker
    chunker = TextChunker(max_tokens=max_chunk_tokens, min_overlap=chunk_overlap)
    
    # Helper function to get language from extension
    # Use get_language_by_extension from our parser module
    def get_language(ext):
        return get_language_by_extension(f"file.{ext}")
    
    # Function to process a single file
    def process_file(path, relpath):
        nonlocal file_count, total_bytes
        
        file_count += 1
        files_list.append(relpath)
        
        # Read file content
        with open(path, encoding="utf-8", errors="replace") as f:
            content = f.read()
        
        total_bytes += len(content.encode("utf-8"))
        
        # Create repo link (using file:// for local files)
        repo_link = "file://" + os.path.abspath(root_dir)
        
        # For markdown/text files, use the appropriate parser
        ext = os.path.splitext(relpath)[1].lstrip('.')
        if ext.lower() == "md" and enhanced_markdown:
            logger.info(f"Parsing markdown file with enhanced parser: {relpath}")
            # Use our enhanced markdown parser
            extracted_sections = parse_markdown(path, repo_link)
            
            # Create chunks from extracted sections
            for section in extracted_sections:
                # Create a chunk for each section
                chunk = {
                    "file_path": relpath,
                    "repo_link": repo_link,
                    "extraction_date": section["extraction_date"],
                    "code_line_span": section["section_line_span"],
                    "description_line_span": section["section_line_span"],
                    "code": section["content"],
                    "code_type": "markdown",
                    "description": section["section_title"],
                    "code_token_count": count_tokens_with_tiktoken(section["content"]),
                    "description_token_count": count_tokens_with_tiktoken(section["section_title"]),
                    "embedding_code": None,
                    "embedding_description": None,
                    "code_metadata": {},
                    "section_id": section["section_id"],
                    "section_path": section["section_path"],
                    "section_hash_path": section["section_hash_path"],
                    "code_blocks": section.get("code_blocks", []),
                    "section_level": section["section_level"],
                    "section_number": section["section_number"],
                }
                all_chunks.append(chunk)
            
            # Create a condensed representation for the digest
            digest_parts.append("="*48)
            digest_parts.append(f"File: {relpath} (parsed into {len(extracted_sections)} sections)")
            digest_parts.append("="*48)
            
            # Include first section as preview
            if extracted_sections:
                first_section = extracted_sections[0]
                section_content = first_section["content"]
                digest_parts.append(section_content[:500] + "..." if len(section_content) > 500 else section_content)
                digest_parts.append(f"\n[Markdown file parsed into {len(extracted_sections)} sections with hierarchical structure]\n")
            else:
                digest_parts.append(content)
            
            digest_parts.append("")
        elif ext.lower() == "md" or ext.lower() in ["rst", "txt"]:
            logger.info(f"Chunking text file: {relpath}")
            chunks = chunker.chunk_text(content, repo_link, relpath)
            all_chunks.extend(chunks)
            
            # Create a condensed representation for the digest
            digest_parts.append("="*48)
            digest_parts.append(f"File: {relpath} (chunked into {len(chunks)} parts)")
            digest_parts.append("="*48)
            
            # Include first chunk as preview
            if chunks:
                first_chunk = chunks[0]
                digest_parts.append(first_chunk["code"][:500] + "..." if len(first_chunk["code"]) > 500 else first_chunk["code"])
                digest_parts.append(f"\n[File chunked into {len(chunks)} parts with consistent section IDs]\n")
            else:
                digest_parts.append(content)
            
            digest_parts.append("")
        else:
            # Regular file handling for non-text files
            digest_parts.append("="*48)
            digest_parts.append(f"File: {relpath}")
            digest_parts.append("="*48)
            digest_parts.append(content)
            digest_parts.append("")
        
        # Add code metadata if requested
        if code_metadata:
            # Extract detailed code metadata using our enhanced parser
            metadata = extract_code_metadata_from_file(path)
            if metadata["tree_sitter_success"]:
                digest_parts.append(f"Metadata (JSON):")
                digest_parts.append(json.dumps(metadata, indent=2))
                digest_parts.append("")
                
                # Also add metadata to chunks if this file was chunked
                for chunk in [c for c in all_chunks if c["file_path"] == relpath]:
                    chunk["code_metadata"] = metadata
    
    # Process specified files and directories
    if files or dirs:
        for path in requested_paths:
            full_path = os.path.join(root_dir, path)
            if os.path.exists(full_path) and os.path.isfile(full_path):
                relpath = os.path.relpath(full_path, root_dir)
                process_file(full_path, relpath)
            else:
                logger.warning(f"Requested path not found: {path}")
    else:
        # Process files by extension
        for ext in extensions:
            for dirpath, _, filenames in os.walk(root_dir):
                for filename in sorted(filenames):
                    if filename.lower().endswith(f".{ext.lower()}"):
                        path = os.path.join(dirpath, filename)
                        relpath = os.path.relpath(path, root_dir)
                        process_file(path, relpath)
    
    # Save chunks directory
    chunks_dir = os.path.join(root_dir, "chunks")
    os.makedirs(chunks_dir, exist_ok=True)
    
    # Save all chunks to JSON files
    if all_chunks:
        logger.info(f"Saving {len(all_chunks)} chunks to {chunks_dir}")
        chunks_file = os.path.join(chunks_dir, "all_chunks.json")
        with open(chunks_file, "w", encoding="utf-8") as f:
            json.dump(all_chunks, f, indent=2)
    
    # Create digest from parts
    digest = "\n".join(digest_parts)
    tree = build_tree(root_dir)
    
    # Create summary
    estimated_tokens = count_tokens_with_tiktoken(digest, model="gemini-2.5-pro-preview-03-25")
    chunk_count = len(all_chunks)
    summary = (
        f"Directory: {root_dir}\n"
        f"Files analyzed: {file_count}\n"
        f"Total bytes: {total_bytes}\n"
        f"Estimated tokens: {estimated_tokens}\n"
        f"Chunks created: {chunk_count}\n"
        f"Files included:\n" + "\n".join(files_list)
    )
    
    return summary, tree, digest

def debug_print_files(clone_dir, extensions, files: Optional[List[str]] = None, dirs: Optional[List[str]] = None):
    found = []
    if files or dirs:
        requested_paths = set(files or []) | {os.path.join(d, f) for d in (dirs or []) for f in os.listdir(os.path.join(clone_dir, d)) if os.path.isfile(os.path.join(clone_dir, d, f))}
        for path in requested_paths:
            full_path = os.path.join(clone_dir, path)
            if os.path.exists(full_path):
                found.append(os.path.relpath(full_path, clone_dir))
    else:
        for ext in extensions:
            for root, _, files in os.walk(clone_dir):
                for file in files:
                    if file.lower().endswith(f'.{ext.lower()}'):
                        found.append(os.path.relpath(os.path.join(root, file), clone_dir))
    return found

@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=4, max=10))
@track_repo_summarization
def llm_summarize(
    digest_path: str,
    summary_path: str,
    model: str = "gemini-2.5-pro-preview-03-25",
    google_vertex_project: str = "gen-lang-client-0870473940",
    google_vertex_location: str = "us-central1",
    output_format: str = "markdown",
    repo_workflow=None
):
    import tempfile
    import asyncio
    from markitdown import MarkItDown
    
    # Import the advanced summarizer
    try:
        from complexity.gitgit.llm_summarizer import summarize_text
        advanced_summarizer_available = True
        logger.info("Using advanced LLM summarizer for repository summarization")
    except ImportError:
        advanced_summarizer_available = False
        logger.warning("Advanced LLM summarizer not available, falling back to standard method")

    with open(digest_path, "r", encoding="utf-8") as f:
        digest_text = f.read()
    
    # Log digest stats if workflow tracking is available
    if repo_workflow:
        digest_size = len(digest_text.encode('utf-8'))
        digest_tokens = count_tokens_with_tiktoken(digest_text, model=model)
        repo_workflow.workflow_logger.log_data(
            {
                "digest_size_bytes": digest_size,
                "digest_tokens": digest_tokens,
                "model": model
            },
            level=LogLevel.INFO,
            source=ComponentType.LLM,
            description="Preparing LLM request"
        )
        repo_workflow.workflow_logger.complete_step("Read repository digest")

    system_prompt = (
        "You are an expert technical documentation summarizer. "
        "You are also a JSON validator. You will only output valid JSON. "
        "When summarizing, incorporate any code metadata (e.g., function names, parameters, docstrings) provided."
    )
    
    # Define our custom summarization prompt
    final_summary_prompt = (
        "Analyze the following repository content, including code metadata where available. "
        "Extract the key concepts, functionalities, and structure. Then generate a structured JSON "
        "response with the following fields:\n"
        "- summary: A concise, clear summary of the repository for technical users, highlighting key functions.\n"
        "- table_of_contents: An ordered list of file or section names that represent the structure of the repository.\n"
        "- key_sections: A list of the most important files or sections, with a 1-2 sentence description for each.\n\n"
        "Format your response as valid JSON, and only output the JSON."
    )
    
    user_prompt = textwrap.dedent(f"""
        Given the following repository content, including code metadata where available, return a JSON object with:
        - summary: A concise, clear summary of the repository for technical users, highlighting key functions if metadata is present.
        - table_of_contents: An ordered list of file or section names that represent the structure of the repository.
        - key_sections: (optional) A list of the most important files or sections, with a 1-2 sentence description for each.

        Format your response as valid JSON. Only output the JSON.

        Repository content:
        {digest_text}
    """)

    try:
        # Use advanced summarizer if available
        if advanced_summarizer_available:
            logger.info(f"Using advanced text summarizer with {model} model...")
            
            # Configure the advanced summarizer
            config = {
                "model": model,
                "temperature": 0.7,
                "context_limit_threshold": 6000,  # Handle larger context since we're using Gemini
                "chunk_size": 5500,               # Larger chunks for repository digest
                "overlap_size": 3,                # Slightly more overlap for better continuity
                "final_summary_prompt": final_summary_prompt,
                "google_vertex_project": google_vertex_project,
                "google_vertex_location": google_vertex_location
            }
            
            # Run the async summarization in the event loop
            summary_content = asyncio.run(summarize_text(digest_text, config))
            
            # Process the content to ensure it's valid JSON
            try:
                # First check if the output is already valid JSON (the advanced summarizer should return structured JSON)
                parsed_json = json.loads(summary_content)
                content = parsed_json
            except json.JSONDecodeError:
                # If not valid JSON, clean it (handle the case where the model returned markdown or explanations)
                content = clean_json_string(summary_content, return_dict=True)
        else:
            # Log LLM request start with standard approach
            if repo_workflow:
                prompt_tokens = count_tokens_with_tiktoken(system_prompt + user_prompt, model=model)
                repo_workflow.log_llm_request(model, prompt_tokens, len(user_prompt))
            
            # Use standard litellm approach
            response = litellm.completion(
                model=model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt}
                ],
                google_vertex_project=google_vertex_project,
                google_vertex_location=google_vertex_location,
            )
            
            # Complete the LLM request step if workflow tracking is available
            if repo_workflow:
                repo_workflow.workflow_logger.complete_step("Process content with LLM")
            
            if hasattr(response, "choices"):
                content_text = response.choices[0].message.content
            elif isinstance(response, str):
                content_text = response
            else:
                content_text = str(response)

            content = clean_json_string(content_text, return_dict=True)

        # Validate against our model and save
        try:
            parsed = RepoSummary.model_validate(content)
            summary_json = json.dumps(parsed.model_dump(), indent=2, ensure_ascii=False)
        except (json.JSONDecodeError, ValidationError) as e:
            logger.error(f"Failed to parse or validate LLM output: {e}")
            summary_json = json.dumps({"error": "Failed to parse or validate LLM output", "raw": str(content)})

        if output_format == "json":
            with open(summary_path, "w", encoding="utf-8") as f:
                f.write(summary_json)
            logger.info(f"LLM summary saved to {summary_path} (JSON format)")
            
            # Log completion if workflow tracking is available
            if repo_workflow:
                repo_workflow.workflow_logger.log_data(
                    {"summary_path": summary_path, "format": "json"},
                    level=LogLevel.SUCCESS,
                    source=ComponentType.LLM,
                    description="LLM summary saved"
                )
                repo_workflow.workflow_logger.complete_step("Save LLM summary")
        else:
            with tempfile.NamedTemporaryFile("w+", suffix=".json", delete=False) as tmp_json:
                tmp_json.write(summary_json)
                tmp_json_path = tmp_json.name

            try:
                markdown_content = json_to_markdown(parsed.model_dump())
                with open(summary_path, "w", encoding="utf-8") as f:
                    f.write(markdown_content)
                    logger.info(f"LLM summary saved to {summary_path} (Markdown format)")
                
                # Log completion if workflow tracking is available
                if repo_workflow:
                    repo_workflow.workflow_logger.log_data(
                        {"summary_path": summary_path, "format": "markdown"},
                        level=LogLevel.SUCCESS,
                        source=ComponentType.LLM,
                        description="LLM summary saved"
                    )
                    repo_workflow.workflow_logger.complete_step("Save LLM summary")
            finally:
                os.remove(tmp_json_path)

    except Exception as e:
        logger.error(f"LLM summarization failed: {e}")
        with open(summary_path, "w", encoding="utf-8") as f:
            f.write(json.dumps({"error": str(e)}))
        raise

@app.callback(invoke_without_command=True)
def callback(ctx: typer.Context):
    """Main callback function for the GitGit CLI."""
    if ctx.invoked_subcommand is None:
        # If no subcommand is provided, show help
        typer.echo(ctx.get_help())

@app.command()
def analyze(
    repo_url: Optional[str] = typer.Argument(
        None,
        help="GitHub repository URL to analyze (e.g. https://github.com/arangodb/python-arango)."
    ),
    extensions: str = typer.Option(
        "md,rst", "--exts", "-e",
        help="Comma-separated list of file extensions to include (e.g. py,md,txt). Ignored if --files or --dirs is provided."
    ),
    files: Optional[str] = typer.Option(
        None, "--files",
        help="Comma-separated list of specific file paths to include (e.g. README.md,src/main.py)."
    ),
    dirs: Optional[str] = typer.Option(
        None, "--dirs",
        help="Comma-separated list of directories to include (e.g. docs/,src/)."
    ),
    output: Optional[str] = typer.Option(
        None, "--output", "-o",
        help="Custom output directory path. If not specified, output will be saved to repos/{repo_name}_sparse."
    ),
    summary: bool = typer.Option(
        False, "--summary",
        help="If set, generate an LLM-based summary of the repository digest."
    ),
    code_metadata: bool = typer.Option(
        False, "--code-metadata",
        help="If set, extract function metadata (names, parameters, docstrings) from code files."
    ),
    chunk_text: bool = typer.Option(
        True, "--chunk-text/--no-chunk-text",
        help="If set, use advanced text chunking for markdown and text files."
    ),
    enhanced_markdown: bool = typer.Option(
        True, "--enhanced-markdown/--simple-markdown",
        help="If set, use enhanced markdown extraction with section hierarchy and code block association."
    ),
    max_chunk_tokens: int = typer.Option(
        500, "--max-chunk-tokens",
        help="Maximum number of tokens per chunk (default: 500)."
    ),
    chunk_overlap: int = typer.Option(
        100, "--chunk-overlap",
        help="Number of tokens to overlap between chunks (default: 100)."
    ),
    llm_model: Optional[str] = typer.Option(
        "gemini-2.5-pro-preview-03-25", "--llm-model",
        help="LLM model name for LiteLLM (default: gemini-2.5-pro-preview-03-25)."
    ),
    vertex_ai_service_account: Optional[str] = typer.Option(
        None, "--vertex-ai-service-account", "--service-account",
        help="Path to VertexAI service account JSON file for authenticating with VertexAI."
    ),
    use_advanced_summarizer: bool = typer.Option(
        True, "--advanced-summarizer/--basic-summarizer", 
        help="If set, use the advanced text summarizer with MapReduce and token management. Otherwise use basic summarizer."
    ),
    context_limit_threshold: int = typer.Option(
        6000, "--context-limit-threshold",
        help="Maximum tokens before switching to chunked summarization (default: 6000)."
    ),
    debug: bool = typer.Option(
        False, "--debug",
        help="Use hardcoded debug parameters instead of CLI input."
    ),
):
    """
    Analyze a GitHub repository by sparse cloning, summarizing, and optionally generating an LLM-based summary.
    
    This command processes the specified repository using advanced text chunking to preserve document
    structure and section relationships. It creates stable section identifiers for database integration,
    splits text into appropriately sized chunks, and generates comprehensive metadata.

    Examples:
        python gitgit.py analyze https://github.com/arangodb/python-arango --exts md,rst
        python gitgit.py analyze https://github.com/arangodb/python-arango --files README.md,docs/index.rst
    """
    # Make sure we have a repo URL unless in debug mode
    if not repo_url and not debug:
        typer.echo("Error: Repository URL is required.")
        raise typer.Exit(code=1)
    
    main(
        repo_url=repo_url,
        extensions=extensions,
        files=files,
        dirs=dirs,
        output=output,
        debug=debug,
        summary=summary,
        code_metadata=code_metadata,
        chunk_text=chunk_text,
        enhanced_markdown=enhanced_markdown,
        max_chunk_tokens=max_chunk_tokens,
        chunk_overlap=chunk_overlap,
        llm_model=llm_model,
        vertex_ai_service_account=vertex_ai_service_account,
        use_advanced_summarizer=use_advanced_summarizer,
        context_limit_threshold=context_limit_threshold,
    )

@track_workflow("GitGit Analysis Workflow")
def main(
    repo_url: str = "https://github.com/arangodb/python-arango",
    extensions: str = "md,rst",
    files: Optional[str] = None,
    dirs: Optional[str] = None,
    output: Optional[str] = None,
    debug: bool = False,
    summary: bool = False,
    code_metadata: bool = False,
    chunk_text: bool = True,
    enhanced_markdown: bool = True,
    max_chunk_tokens: int = 500,
    chunk_overlap: int = 100,
    llm_model: str = "gemini-2.5-pro-preview-03-25",
    vertex_ai_service_account: Optional[str] = None,
    use_advanced_summarizer: bool = True,
    context_limit_threshold: int = 6000,
    workflow_logger: Optional[WorkflowLogger] = None
):
    """
    Enhanced analysis workflow for a GitHub repository with advanced text processing.

    - Sparse clones the repository and fetches only specified files, directories, or files with the specified extensions.
    - Uses enhanced markdown extraction for .md files with section hierarchy and code block association.
    - Processes other text files using the TextChunker to preserve document structure and section relationships.
    - Creates stable section identifiers for database integration.
    - Stores chunked files with metadata in a separate directory.
    - Concatenates and summarizes the content.
    - Optionally extracts code metadata (function names, parameters, docstrings).
    - Optionally generates an LLM-based summary using the specified model.

    Args:
        repo_url (str): GitHub repository URL.
        extensions (str): Comma-separated file extensions to include.
        files (str): Comma-separated specific file paths to include.
        dirs (str): Comma-separated directories to include.
        output (str): Custom output directory path. If not specified, output will be saved to repos/{repo_name}_sparse.
        debug (bool): Use hardcoded debug parameters.
        summary (bool): Generate LLM summary if True.
        code_metadata (bool): Extract code metadata if True.
        chunk_text (bool): Use advanced text chunking for text files.
        enhanced_markdown (bool): Use enhanced markdown extraction with section hierarchy and code blocks.
        max_chunk_tokens (int): Maximum tokens per chunk (default: 500).
        chunk_overlap (int): Minimum token overlap between chunks (default: 100).
        llm_model (str): LLM model name for summarization.
        workflow_logger: WorkflowLogger instance (injected by decorator).

    Usage Example:
        main("https://github.com/arangodb/python-arango", "md,rst,py", files="README.md", 
             summary=True, code_metadata=True, chunk_text=True, enhanced_markdown=True, 
             max_chunk_tokens=500, chunk_overlap=100, llm_model="gpt-4o")
    """
    # Calculate total steps for tracking
    total_steps = 3  # clone, process, summarize (if requested)
    if summary:
        total_steps += 1
    
    # Set total steps if workflow logger is available
    if workflow_logger:
        workflow_logger.set_total_steps(total_steps)
        workflow_logger.log_data(
            {
                "repo_url": repo_url,
                "extensions": extensions,
                "files": files,
                "dirs": dirs,
                "summary": summary,
                "code_metadata": code_metadata,
                "chunk_text": chunk_text,
                "enhanced_markdown": enhanced_markdown,
                "use_advanced_summarizer": use_advanced_summarizer,
                "context_limit_threshold": context_limit_threshold
            },
            level=LogLevel.INFO,
            source=ComponentType.INTEGRATION,
            description="Starting GitGit analysis workflow"
        )
    
    # Use enhanced logging if available
    if HAVE_ENHANCED_LOGGING:
        return _main_with_enhanced_logging(
            repo_url, extensions, files, dirs, output, debug, summary,
            code_metadata, chunk_text, enhanced_markdown, max_chunk_tokens,
            chunk_overlap, llm_model, vertex_ai_service_account,
            use_advanced_summarizer, context_limit_threshold, workflow_logger
        )
    # Use error handler if available
    elif HAVE_ERROR_HANDLER:
        handler = global_error_handler
        return _main_with_error_handler(
            repo_url, extensions, files, dirs, output, debug, summary,
            code_metadata, chunk_text, enhanced_markdown, max_chunk_tokens,
            chunk_overlap, llm_model, handler, vertex_ai_service_account,
            use_advanced_summarizer, context_limit_threshold
        )
    else:
        return _main_standard(
            repo_url, extensions, files, dirs, output, debug, summary,
            code_metadata, chunk_text, enhanced_markdown, max_chunk_tokens,
            chunk_overlap, llm_model, vertex_ai_service_account,
            use_advanced_summarizer, context_limit_threshold
        )


def _main_with_enhanced_logging(
    repo_url: str,
    extensions: str,
    files: Optional[str],
    dirs: Optional[str],
    output: Optional[str],
    debug: bool,
    summary: bool,
    code_metadata: bool,
    chunk_text: bool,
    enhanced_markdown: bool,
    max_chunk_tokens: int,
    chunk_overlap: int,
    llm_model: str,
    vertex_ai_service_account: Optional[str] = None,
    use_advanced_summarizer: bool = True,
    context_limit_threshold: int = 6000,
    workflow_logger: Optional[WorkflowLogger] = None
):
    """Main function with enhanced logging and workflow tracking."""
    # Parse input parameters
    def parse_params():
        if debug:
            repo_url_ = "https://github.com/arangodb/python-arango"
            extensions_ = ["md", "rst"]
            files_ = None
            dirs_ = None
            logger.info(f"[DEBUG] Using hardcoded repo_url={repo_url_}, extensions={extensions_}")
        else:
            repo_url_ = repo_url
            extensions_ = [e.strip().lstrip('.') for e in extensions.split(',') if e.strip()]
            files_ = [f.strip() for f in files.split(',') if f.strip()] if files else None
            dirs_ = [d.strip() for d in dirs.split(',') if d.strip()] if dirs else None
        
        repo_name = repo_url_.rstrip('/').split('/')[-1]
        return repo_url_, extensions_, files_, dirs_, repo_name
    
    # Parse parameters with workflow tracking
    if workflow_logger:
        params = workflow_logger.safely_run_step(
            parse_params,
            "Parse input parameters",
            ComponentType.VALIDATION,
            recoverable=False
        )
    else:
        params = parse_params()
    
    repo_url_, extensions_, files_, dirs_, repo_name = params
    
    # Set up directories
    def setup_directories():
        if output:
            # Ensure output directory exists
            os.makedirs(output, exist_ok=True)
            # Append the repo name to make a subdirectory for this specific repository
            clone_dir = os.path.join(output, f"{repo_name}_sparse")
        else:
            # Default location: repos/{repo_name}_sparse
            clone_dir = f"repos/{repo_name}_sparse"
            os.makedirs(os.path.dirname(clone_dir), exist_ok=True)
        
        # Create the chunks directory in advance
        chunks_dir = os.path.join(clone_dir, "chunks")
        os.makedirs(chunks_dir, exist_ok=True)
        
        # Create logs directory if using enhanced logging
        logs_dir = os.path.join(clone_dir, "logs")
        os.makedirs(logs_dir, exist_ok=True)
        
        return clone_dir, chunks_dir, logs_dir
    
    # Set up directories with workflow tracking
    if workflow_logger:
        dirs_result = workflow_logger.safely_run_step(
            setup_directories,
            "Set up directories",
            ComponentType.DIRECTORY,
            recoverable=False
        )
    else:
        dirs_result = setup_directories()
    
    clone_dir, chunks_dir, logs_dir = dirs_result
    
    # Clone repository with workflow tracking
    logger.info(f"Sparse cloning {repo_url_} for extensions: {extensions_}, files: {files_}, dirs: {dirs_} ...")
    clone_result = sparse_clone(repo_url_, extensions_, clone_dir, files_, dirs_)
    
    if workflow_logger:
        workflow_logger.complete_step("Clone repository")
    
    if not clone_result:
        logger.error("Repository cloning failed")
        return False
    
    # Process repository with workflow tracking
    logger.info(f"Running enhanced concatenation and summary with chunking={chunk_text}...")
    
    # Choose processing options based on parameters
    if chunk_text:
        logger.info(f"Text chunking enabled with max_tokens={max_chunk_tokens}, overlap={chunk_overlap}")
        if enhanced_markdown:
            logger.info("Enhanced markdown parsing enabled")
        else:
            logger.info("Using simple markdown chunking (enhanced parsing disabled)")
            
        # Process with chunking
        result = concat_and_summarize(
            clone_dir, extensions_, files_, dirs_, code_metadata,
            max_chunk_tokens=max_chunk_tokens, 
            chunk_overlap=chunk_overlap,
            enhanced_markdown=enhanced_markdown
        )
    else:
        # Fall back to simpler processing
        logger.info("Text chunking disabled - using simple concatenation")
        result = concat_and_summarize(
            clone_dir, extensions_, files_, dirs_, code_metadata,
            max_chunk_tokens=0,  # Ignored if chunking disabled
            chunk_overlap=0,     # Ignored if chunking disabled
            enhanced_markdown=False
        )
    
    if workflow_logger:
        workflow_logger.complete_step("Process repository content")
    
    # Unpack results
    if result and isinstance(result, tuple) and len(result) >= 3:
        summary_txt, tree, content = result
        
        # Save output files to clone_dir
        save_to_root(clone_dir, "SUMMARY.txt", summary_txt)
        save_to_root(clone_dir, "DIGEST.txt", content)
        save_to_root(clone_dir, "TREE.txt", tree)
        logger.info(f"Saved SUMMARY.txt, DIGEST.txt, and TREE.txt to {clone_dir}")
        
        # Generate LLM summary if requested
        if summary:
            logger.info(f"Running LLM summarization via LiteLLM using {llm_model}...")
            
            try:
                # If a service account file was provided, set the environment variable
                if vertex_ai_service_account and os.path.exists(vertex_ai_service_account):
                    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = vertex_ai_service_account
                    logger.info(f"Using Vertex AI service account from {vertex_ai_service_account}")
                    if workflow_logger:
                        workflow_logger.log_data(
                            {"service_account": vertex_ai_service_account},
                            level=LogLevel.INFO,
                            source=ComponentType.LLM,
                            description="Using Vertex AI service account"
                        )
                
                # Call the llm_summarize function with all parameters
                llm_summarize(
                    os.path.join(clone_dir, "DIGEST.txt"),
                    os.path.join(clone_dir, "LLM_SUMMARY.txt"),
                    model=llm_model,
                    google_vertex_project="gen-lang-client-0870473940",
                    google_vertex_location="us-central1",
                    repo_workflow=repo_workflow  # Pass workflow information
                )
                
                if workflow_logger:
                    workflow_logger.complete_step("Generate LLM summary")
            except Exception as e:
                logger.error(f"LLM summarization failed: {e}")
                if workflow_logger:
                    workflow_logger.log_error(
                        e, ComponentType.LLM, 
                        "LLM summarization failed", 
                        {"model": llm_model}
                    )
    
    # Log workflow completion
    if workflow_logger:
        workflow_logger.log_data(
            {"clone_dir": clone_dir},
            level=LogLevel.SUCCESS,
            source=ComponentType.INTEGRATION,
            description="GitGit analysis completed"
        )
    
    return True

def _main_with_error_handler(
    repo_url: str,
    extensions: str,
    files: Optional[str],
    dirs: Optional[str],
    output: Optional[str],
    debug: bool,
    summary: bool,
    code_metadata: bool,
    chunk_text: bool,
    enhanced_markdown: bool,
    max_chunk_tokens: int,
    chunk_overlap: int,
    llm_model: str,
    handler: 'ErrorHandler',
    vertex_ai_service_account: Optional[str] = None,
    use_advanced_summarizer: bool = True,
    context_limit_threshold: int = 6000
):
    """Main function with comprehensive error handling."""
    # Parse input parameters
    def parse_params():
        if debug:
            repo_url_ = "https://github.com/arangodb/python-arango"
            extensions_ = ["md", "rst"]
            files_ = None
            dirs_ = None
            logger.info(f"[DEBUG] Using hardcoded repo_url={repo_url_}, extensions={extensions_}")
        else:
            repo_url_ = repo_url
            extensions_ = [e.strip().lstrip('.') for e in extensions.split(',') if e.strip()]
            files_ = [f.strip() for f in files.split(',') if f.strip()] if files else None
            dirs_ = [d.strip() for d in dirs.split(',') if d.strip()] if dirs else None
        
        repo_name = repo_url_.rstrip('/').split('/')[-1]
        return repo_url_, extensions_, files_, dirs_, repo_name
    
    params = safe_execute(
        parse_params,
        handler,
        ErrorSource.VALIDATION,
        context={"operation": "parse_parameters"},
        recoverable=False
    )
    
    if not params:
        logger.error("Failed to parse input parameters")
        return False
    
    repo_url_, extensions_, files_, dirs_, repo_name = params
    
    # Set up directories
    def setup_directories():
        if output:
            # Ensure output directory exists
            os.makedirs(output, exist_ok=True)
            # Append the repo name to make a subdirectory for this specific repository
            clone_dir = os.path.join(output, f"{repo_name}_sparse")
        else:
            # Default location: repos/{repo_name}_sparse
            clone_dir = f"repos/{repo_name}_sparse"
            os.makedirs(os.path.dirname(clone_dir), exist_ok=True)
        
        # Create the chunks directory in advance
        chunks_dir = os.path.join(clone_dir, "chunks")
        os.makedirs(chunks_dir, exist_ok=True)
        
        return clone_dir, chunks_dir
    
    dirs_result = safe_execute(
        setup_directories,
        handler,
        ErrorSource.DIRECTORY,
        context={"operation": "setup_directories"},
        recoverable=False
    )
    
    if not dirs_result:
        logger.error("Failed to set up directories")
        return False
    
    clone_dir, chunks_dir = dirs_result
    
    # Clone repository
    logger.info(f"Sparse cloning {repo_url_} for extensions: {extensions_}, files: {files_}, dirs: {dirs_} ...")
    clone_success = sparse_clone(repo_url_, extensions_, clone_dir, files_, dirs_)
    
    if not clone_success:
        logger.error("Repository cloning failed")
        return False
    
    # Check files after clone
    def check_files():
        found = debug_print_files(clone_dir, extensions_, files_, dirs_)
        logger.info(f"Files found after sparse checkout: {found}")
        return found
    
    found_files = safe_execute(
        check_files,
        handler,
        ErrorSource.FILE_SYSTEM,
        file_path=clone_dir,
        context={"operation": "check_files"}
    )
    
    if not found_files:
        logger.warning("No files found after sparse checkout")
    
    # Concatenate and summarize
    def run_summarize():
        logger.info(f"Running enhanced concatenation and summary with chunking={chunk_text}...")
        if chunk_text:
            logger.info(f"Text chunking enabled with max_tokens={max_chunk_tokens}, overlap={chunk_overlap}")
            if enhanced_markdown:
                logger.info("Enhanced markdown parsing enabled")
            else:
                logger.info("Using simple markdown chunking (enhanced parsing disabled)")
                
            return concat_and_summarize(
                clone_dir, extensions_, files_, dirs_, code_metadata,
                max_chunk_tokens=max_chunk_tokens, 
                chunk_overlap=chunk_overlap,
                enhanced_markdown=enhanced_markdown
            )
        else:
            # Fall back to the original behavior if chunking is disabled
            logger.info("Text chunking disabled - using simple concatenation")
            return concat_and_summarize(
                clone_dir, extensions_, files_, dirs_, code_metadata,
                max_chunk_tokens=0,  # This will be ignored if chunking is disabled
                chunk_overlap=0,     # This will be ignored if chunking is disabled
                enhanced_markdown=False  # Also disable enhanced markdown if chunking is disabled
            )
    
    summarize_result = safe_execute(
        run_summarize,
        handler,
        ErrorSource.CHUNKING,
        file_path=clone_dir,
        context={
            "operation": "concatenate_and_summarize",
            "chunk_text": chunk_text,
            "max_chunk_tokens": max_chunk_tokens,
            "chunk_overlap": chunk_overlap,
            "enhanced_markdown": enhanced_markdown
        }
    )
    
    if not summarize_result:
        logger.error("Concatenation and summarization failed")
        return False
    
    summary_txt, tree, content = summarize_result
    
    # Save output files
    def save_outputs():
        # Save the main output files
        save_to_root(clone_dir, "SUMMARY.txt", summary_txt)
        save_to_root(clone_dir, "DIGEST.txt", content)
        save_to_root(clone_dir, "TREE.txt", tree)
        
        logger.info(f"\nSaved SUMMARY.txt, DIGEST.txt, and TREE.txt to {clone_dir}")
        
        # Check if chunks were created
        chunks_json = os.path.join(chunks_dir, "all_chunks.json")
        if os.path.exists(chunks_json):
            logger.info(f"Chunks created and saved to {chunks_json}")
            
        return True
    
    save_success = safe_execute(
        save_outputs,
        handler,
        ErrorSource.OUTPUT,
        file_path=clone_dir,
        context={"operation": "save_output_files"}
    )
    
    if not save_success:
        logger.error("Failed to save output files")
        return False
    
    # Run LLM summarization if requested
    if summary:
        def run_llm_summary():
            logger.info(f"Running LLM summarization via LiteLLM using {llm_model}...")
            
            # If a service account file was provided, set the environment variable
            if vertex_ai_service_account and os.path.exists(vertex_ai_service_account):
                os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = vertex_ai_service_account
                logger.info(f"Using Vertex AI service account from {vertex_ai_service_account}")
            
            # Call the llm_summarize function with all parameters
            llm_summarize(
                os.path.join(clone_dir, "DIGEST.txt"),
                os.path.join(clone_dir, "LLM_SUMMARY.txt"),
                model=llm_model,
                google_vertex_project="gen-lang-client-0870473940",
                google_vertex_location="us-central1",
            )
            return True
        
        llm_success = safe_execute(
            run_llm_summary,
            handler,
            ErrorSource.LLM,
            file_path=os.path.join(clone_dir, "LLM_SUMMARY.txt"),
            context={
                "operation": "llm_summarize",
                "model": llm_model,
                "use_advanced_summarizer": use_advanced_summarizer,
                "context_limit_threshold": context_limit_threshold
            },
            recoverable=True  # LLM summarization is optional
        )
        
        if not llm_success:
            logger.warning("LLM summarization failed, but continuing with other operations")
    
    # Print error report if there were any errors
    if handler.errors:
        logger.info("Analysis completed with some errors:")
        for error in handler.errors:
            logger.info(f"- {error.source.value}: {error.message} (Recoverable: {error.recoverable})")
    else:
        logger.info("Analysis completed successfully with no errors")
    
    return True

def _main_standard(
    repo_url: str,
    extensions: str,
    files: Optional[str],
    dirs: Optional[str],
    output: Optional[str],
    debug: bool,
    summary: bool,
    code_metadata: bool,
    chunk_text: bool,
    enhanced_markdown: bool,
    max_chunk_tokens: int,
    chunk_overlap: int,
    llm_model: str,
    vertex_ai_service_account: Optional[str] = None,
    use_advanced_summarizer: bool = True,
    context_limit_threshold: int = 6000,
):
    """Standard main function implementation without specialized error handling."""
    if debug:
        repo_url_ = "https://github.com/arangodb/python-arango"
        extensions_ = ["md", "rst"]
        files_ = None
        dirs_ = None
        logger.info(f"[DEBUG] Using hardcoded repo_url={repo_url_}, extensions={extensions_}")
    else:
        repo_url_ = repo_url
        extensions_ = [e.strip().lstrip('.') for e in extensions.split(',') if e.strip()]
        files_ = [f.strip() for f in files.split(',') if f.strip()] if files else None
        dirs_ = [d.strip() for d in dirs.split(',') if d.strip()] if dirs else None

    repo_name = repo_url_.rstrip('/').split('/')[-1]
    
    # Use custom output directory if provided, otherwise use default
    if output:
        # Ensure output directory exists
        os.makedirs(output, exist_ok=True)
        # Append the repo name to make a subdirectory for this specific repository
        clone_dir = os.path.join(output, f"{repo_name}_sparse")
    else:
        # Default location: repos/{repo_name}_sparse
        clone_dir = f"repos/{repo_name}_sparse"
        os.makedirs(os.path.dirname(clone_dir), exist_ok=True)

    # Create the chunks directory in advance
    chunks_dir = os.path.join(clone_dir, "chunks")
    os.makedirs(chunks_dir, exist_ok=True)

    logger.info(f"Sparse cloning {repo_url_} for extensions: {extensions_}, files: {files_}, dirs: {dirs_} ...")
    sparse_clone(repo_url_, extensions_, clone_dir, files_, dirs_)

    found_files = debug_print_files(clone_dir, extensions_, files_, dirs_)
    logger.info(f"Files found after sparse checkout: {found_files}")

    logger.info(f"Running enhanced concatenation and summary with chunking={chunk_text}...")
    if chunk_text:
        logger.info(f"Text chunking enabled with max_tokens={max_chunk_tokens}, overlap={chunk_overlap}")
        if enhanced_markdown:
            logger.info("Enhanced markdown parsing enabled")
        else:
            logger.info("Using simple markdown chunking (enhanced parsing disabled)")
            
        summary_txt, tree, content = concat_and_summarize(
            clone_dir, extensions_, files_, dirs_, code_metadata,
            max_chunk_tokens=max_chunk_tokens, 
            chunk_overlap=chunk_overlap,
            enhanced_markdown=enhanced_markdown
        )
    else:
        # Fall back to the original behavior if chunking is disabled
        logger.info("Text chunking disabled - using simple concatenation")
        summary_txt, tree, content = concat_and_summarize(
            clone_dir, extensions_, files_, dirs_, code_metadata,
            max_chunk_tokens=0,  # This will be ignored if chunking is disabled
            chunk_overlap=0,     # This will be ignored if chunking is disabled
            enhanced_markdown=False  # Also disable enhanced markdown if chunking is disabled
        )

    # Save the main output files
    save_to_root(clone_dir, "SUMMARY.txt", summary_txt)
    save_to_root(clone_dir, "DIGEST.txt", content)
    save_to_root(clone_dir, "TREE.txt", tree)

    logger.info(f"Saved SUMMARY.txt, DIGEST.txt, and TREE.txt to {clone_dir}")
    
    # Check if chunks were created
    chunks_json = os.path.join(chunks_dir, "all_chunks.json")
    if os.path.exists(chunks_json):
        logger.info(f"Chunks created and saved to {chunks_json}")
    
    if summary:
        logger.info(f"Running LLM summarization via LiteLLM using model {llm_model}...")
        try:
            # If a service account file was provided, set the environment variable
            if vertex_ai_service_account and os.path.exists(vertex_ai_service_account):
                os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = vertex_ai_service_account
                logger.info(f"Using Vertex AI service account from {vertex_ai_service_account}")
            
            # Call the llm_summarize function with all parameters
            llm_summarize(
                os.path.join(clone_dir, "DIGEST.txt"),
                os.path.join(clone_dir, "LLM_SUMMARY.txt"),
                model=llm_model,
                # Pass additional parameters
                google_vertex_project="gen-lang-client-0870473940",
                google_vertex_location="us-central1",
            )
        except Exception as e:
            logger.error(f"LLM summarization failed: {e}")
    
    return True

if __name__ == "__main__":
    app()