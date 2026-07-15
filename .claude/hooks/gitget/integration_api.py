"""
Integration API for GitGit Repository Analysis.

This module provides a unified API for integrating all GitGit components:
- Text chunking
- Tree-sitter code analysis
- Markdown extraction

The integration API provides a high-level interface for processing repositories
with all enhanced features.
"""

import os
import json
import shutil
import subprocess
from pathlib import Path
from typing import Dict, List, Any, Optional, Tuple, Union, Set
from loguru import logger
from pydantic import BaseModel, Field

from complexity.gitgit.chunking import TextChunker, count_tokens_with_tiktoken
from complexity.gitgit.parser import extract_code_metadata_from_file, get_language_by_extension
from complexity.gitgit.markdown import parse_markdown
from complexity.gitgit.repo_directory_manager import RepositoryDirectoryManager, create_repo_directory_structure


class ProcessingOptions(BaseModel):
    """
    Options for repository processing.
    """
    # Chunking options
    chunk_text: bool = Field(True, description="Whether to use text chunking")
    max_chunk_tokens: int = Field(500, description="Maximum tokens per chunk")
    chunk_overlap: int = Field(100, description="Overlap between chunks")
    
    # Markdown options
    enhanced_markdown: bool = Field(True, description="Whether to use enhanced markdown extraction")
    
    # Code metadata options
    code_metadata: bool = Field(False, description="Whether to extract code metadata")
    
    # Summary options
    summary: bool = Field(False, description="Whether to generate an LLM summary")
    llm_model: str = Field("gemini-2.5-pro-preview-03-25", description="LLM model to use for summaries")
    
    # Logging options
    verbose: bool = Field(False, description="Whether to enable verbose logging")


class ProcessingResult(BaseModel):
    """
    Result of repository processing.
    """
    file_count: int = Field(0, description="Number of files processed")
    total_bytes: int = Field(0, description="Total bytes processed")
    estimated_tokens: int = Field(0, description="Estimated tokens in digest")
    chunk_count: int = Field(0, description="Number of chunks created")
    files_processed: List[str] = Field([], description="List of processed files")
    summary_path: Optional[str] = Field(None, description="Path to summary")
    digest_path: Optional[str] = Field(None, description="Path to digest")
    tree_path: Optional[str] = Field(None, description="Path to tree")
    chunks_path: Optional[str] = Field(None, description="Path to chunks")
    llm_summary_path: Optional[str] = Field(None, description="Path to LLM summary")


def sparse_clone(
    repo_url: str,
    clone_dir: str,
    extensions: List[str],
    files: Optional[List[str]] = None,
    dirs: Optional[List[str]] = None
) -> None:
    """
    Sparse clone a repository with specified filters.
    
    Args:
        repo_url: Repository URL
        clone_dir: Directory to clone into
        extensions: File extensions to include
        files: Specific files to include
        dirs: Specific directories to include
    """
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


def build_tree(root_dir: str) -> str:
    """
    Build a tree representation of the repository.
    
    Args:
        root_dir: Root directory of the repository
        
    Returns:
        Tree representation
    """
    tree_lines = []
    for dirpath, dirnames, filenames in os.walk(root_dir):
        rel_dir = os.path.relpath(dirpath, root_dir)
        indent = "" if rel_dir == "." else "    " * rel_dir.count(os.sep)
        tree_lines.append(f"{indent}{os.path.basename(dirpath) if rel_dir != '.' else '.'}/")
        for filename in sorted(filenames):
            tree_lines.append(f"{indent}    {filename}")
    return "\n".join(tree_lines)


def process_file(
    file_path: str,
    repo_root: str,
    repo_link: str,
    dir_manager: RepositoryDirectoryManager,
    options: ProcessingOptions,
    chunker: TextChunker
) -> Tuple[List[Dict[str, Any]], str, int]:
    """
    Process a single file based on its type.
    
    Args:
        file_path: Absolute path to the file
        repo_root: Root directory of the repository
        repo_link: Link to the repository
        dir_manager: Directory manager
        options: Processing options
        chunker: Text chunker instance
        
    Returns:
        Tuple of (chunks, digest_content, byte_count)
    """
    rel_path = os.path.relpath(file_path, repo_root)
    chunks = []
    digest_parts = []
    
    # Read file content
    try:
        with open(file_path, encoding="utf-8", errors="replace") as f:
            content = f.read()
    except Exception as e:
        logger.error(f"Error reading file {file_path}: {e}")
        return [], f"Error reading file: {e}", 0
    
    byte_count = len(content.encode("utf-8"))
    
    # Process file based on type
    ext = os.path.splitext(file_path)[1].lstrip('.')
    
    # Markdown files
    if ext.lower() == "md" and options.enhanced_markdown and options.chunk_text:
        logger.info(f"Processing markdown file with enhanced parser: {rel_path}")
        extracted_sections = parse_markdown(file_path, repo_link)
        
        # Save parsed file
        parsed_path = dir_manager.get_parsed_path(rel_path)
        with open(parsed_path, "w", encoding="utf-8") as f:
            json.dump(extracted_sections, f, indent=2, ensure_ascii=False)
        
        # Create digest
        digest_parts.append("="*48)
        digest_parts.append(f"File: {rel_path} (parsed into {len(extracted_sections)} sections)")
        digest_parts.append("="*48)
        
        # Create chunks from sections
        for section in extracted_sections:
            chunk = {
                "file_path": rel_path,
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
            chunks.append(chunk)
        
        # Include first section as preview
        if extracted_sections:
            first_section = extracted_sections[0]
            section_content = first_section["content"]
            preview = section_content[:500] + "..." if len(section_content) > 500 else section_content
            digest_parts.append(preview)
            digest_parts.append(f"\n[Markdown file parsed into {len(extracted_sections)} sections with hierarchical structure]\n")
        else:
            digest_parts.append(content)
        
        digest_parts.append("")
    
    # Text files for chunking
    elif (ext.lower() in ["md", "rst", "txt"] or ext.lower() == "") and options.chunk_text:
        logger.info(f"Chunking text file: {rel_path}")
        file_chunks = chunker.chunk_text(content, repo_link, rel_path)
        chunks.extend(file_chunks)
        
        # Save chunks
        chunk_path = dir_manager.get_chunk_path(rel_path)
        with open(chunk_path, "w", encoding="utf-8") as f:
            json.dump(file_chunks, f, indent=2, ensure_ascii=False)
        
        # Create digest
        digest_parts.append("="*48)
        digest_parts.append(f"File: {rel_path} (chunked into {len(file_chunks)} parts)")
        digest_parts.append("="*48)
        
        if file_chunks:
            first_chunk = file_chunks[0]
            preview = first_chunk["code"][:500] + "..." if len(first_chunk["code"]) > 500 else first_chunk["code"]
            digest_parts.append(preview)
            digest_parts.append(f"\n[File chunked into {len(file_chunks)} parts with consistent section IDs]\n")
        else:
            digest_parts.append(content)
        
        digest_parts.append("")
    
    # Code files
    elif options.code_metadata:
        logger.info(f"Extracting metadata from code file: {rel_path}")
        metadata = extract_code_metadata_from_file(file_path)
        
        # Save metadata
        if metadata["tree_sitter_success"]:
            metadata_path = dir_manager.get_metadata_path(rel_path)
            with open(metadata_path, "w", encoding="utf-8") as f:
                json.dump(metadata, f, indent=2, ensure_ascii=False)
        
        # Create digest
        digest_parts.append("="*48)
        digest_parts.append(f"File: {rel_path}")
        digest_parts.append("="*48)
        digest_parts.append(content)
        
        if metadata["tree_sitter_success"]:
            digest_parts.append("\nMetadata (JSON):")
            digest_parts.append(json.dumps(metadata, indent=2))
        
        digest_parts.append("")
    
    # Regular files
    else:
        logger.info(f"Processing regular file: {rel_path}")
        
        # Create digest
        digest_parts.append("="*48)
        digest_parts.append(f"File: {rel_path}")
        digest_parts.append("="*48)
        digest_parts.append(content)
        digest_parts.append("")
    
    # Join digest parts
    digest_content = "\n".join(digest_parts)
    
    return chunks, digest_content, byte_count


def process_repository(
    repo_url: str,
    output_dir: str,
    extensions: Optional[List[str]] = None,
    files: Optional[List[str]] = None,
    dirs: Optional[List[str]] = None,
    options: Optional[ProcessingOptions] = None
) -> ProcessingResult:
    """
    Process a repository with all enhancements.
    
    Args:
        repo_url: Repository URL
        output_dir: Directory to store output
        extensions: File extensions to include
        files: Specific files to include
        dirs: Specific directories to include
        options: Processing options
        
    Returns:
        Processing result
    """
    # Default values
    if extensions is None:
        extensions = ["md", "rst", "txt", "py", "js", "html", "css"]
    
    if options is None:
        options = ProcessingOptions()
    
    # Initialize result
    result = ProcessingResult()
    
    # Setup logging
    log_level = "DEBUG" if options.verbose else "INFO"
    logger.remove()
    logger.add(lambda msg: print(msg), level=log_level)
    
    # Extract repository name
    repo_name = repo_url.rstrip('/').split('/')[-1]
    clone_dir = os.path.join(output_dir, f"{repo_name}_gitgit")
    
    # Create directory manager
    dir_manager = create_repo_directory_structure(repo_name, clone_dir)
    
    # Clone repository
    logger.info(f"Sparse cloning {repo_url} for extensions: {extensions}, files: {files}, dirs: {dirs}")
    sparse_clone(repo_url, clone_dir, extensions, files, dirs)
    
    # Create text chunker
    chunker = TextChunker(
        max_tokens=options.max_chunk_tokens,
        min_overlap=options.chunk_overlap
    )
    
    # Process files
    logger.info("Processing files...")
    all_chunks = []
    digest_parts = []
    file_count = 0
    total_bytes = 0
    files_processed = []
    
    # Create repo link for local files
    repo_link = f"file://{os.path.abspath(clone_dir)}"
    
    # Function to process files based on filters
    def find_and_process_files():
        nonlocal file_count, total_bytes, files_processed
        
        requested_paths: Set[str] = set()
        
        # Handle specific files/dirs if provided
        if files or dirs:
            if files:
                requested_paths.update(files)
            if dirs:
                for d in dirs:
                    dir_path = os.path.join(clone_dir, d.rstrip('/'))
                    if os.path.exists(dir_path) and os.path.isdir(dir_path):
                        for f in os.listdir(dir_path):
                            file_path = os.path.join(d, f)
                            if os.path.isfile(os.path.join(clone_dir, file_path)):
                                requested_paths.add(file_path)
            
            # Process requested paths
            for path in requested_paths:
                full_path = os.path.join(clone_dir, path)
                if os.path.exists(full_path) and os.path.isfile(full_path):
                    rel_path = os.path.relpath(full_path, clone_dir)
                    chunks, digest, byte_count = process_file(
                        full_path, clone_dir, repo_link, dir_manager, options, chunker
                    )
                    all_chunks.extend(chunks)
                    digest_parts.append(digest)
                    file_count += 1
                    total_bytes += byte_count
                    files_processed.append(rel_path)
                else:
                    logger.warning(f"Requested path not found or not a file: {path}")
        else:
            # Process all files by extension
            for ext in extensions:
                for dirpath, _, filenames in os.walk(clone_dir):
                    for filename in sorted(filenames):
                        if filename.lower().endswith(f".{ext.lower()}"):
                            full_path = os.path.join(dirpath, filename)
                            rel_path = os.path.relpath(full_path, clone_dir)
                            chunks, digest, byte_count = process_file(
                                full_path, clone_dir, repo_link, dir_manager, options, chunker
                            )
                            all_chunks.extend(chunks)
                            digest_parts.append(digest)
                            file_count += 1
                            total_bytes += byte_count
                            files_processed.append(rel_path)
    
    # Find and process files
    find_and_process_files()
    
    # Save all chunks
    if all_chunks:
        logger.info(f"Saving {len(all_chunks)} chunks")
        chunks_file = dir_manager.get_output_path("all_chunks.json")
        with open(chunks_file, "w", encoding="utf-8") as f:
            json.dump(all_chunks, f, indent=2, ensure_ascii=False)
        result.chunks_path = str(chunks_file)
    
    # Create digest
    digest = "\n".join(digest_parts)
    digest_file = dir_manager.get_output_path("DIGEST.txt")
    with open(digest_file, "w", encoding="utf-8") as f:
        f.write(digest)
    result.digest_path = str(digest_file)
    
    # Build tree
    tree = build_tree(clone_dir)
    tree_file = dir_manager.get_output_path("TREE.txt")
    with open(tree_file, "w", encoding="utf-8") as f:
        f.write(tree)
    result.tree_path = str(tree_file)
    
    # Create summary
    estimated_tokens = count_tokens_with_tiktoken(digest, model=options.llm_model)
    summary = (
        f"Directory: {clone_dir}\n"
        f"Files analyzed: {file_count}\n"
        f"Total bytes: {total_bytes}\n"
        f"Estimated tokens: {estimated_tokens}\n"
        f"Chunks created: {len(all_chunks)}\n"
        f"Files included:\n" + "\n".join(files_processed)
    )
    summary_file = dir_manager.get_output_path("SUMMARY.txt")
    with open(summary_file, "w", encoding="utf-8") as f:
        f.write(summary)
    result.summary_path = str(summary_file)
    
    # Generate LLM summary if requested
    if options.summary:
        # This will be implemented in a future PR
        # We'd need to integrate with the llm_summarize function
        pass
    
    # Update result
    result.file_count = file_count
    result.total_bytes = total_bytes
    result.estimated_tokens = estimated_tokens
    result.chunk_count = len(all_chunks)
    result.files_processed = files_processed
    
    logger.info(f"Repository processing complete. Files: {file_count}, Chunks: {len(all_chunks)}")
    return result


if __name__ == "__main__":
    """
    Script to demonstrate and test the integration API.
    """
    import argparse
    import tempfile
    
    # Parse arguments
    parser = argparse.ArgumentParser(description="Test GitGit Integration API")
    parser.add_argument("--repo", type=str, default="https://github.com/arangodb/python-arango",
                      help="Repository URL to process")
    parser.add_argument("--exts", type=str, default="md,rst",
                      help="File extensions to include")
    parser.add_argument("--output", type=str, default=None,
                      help="Output directory")
    parser.add_argument("--verbose", action="store_true",
                      help="Enable verbose logging")
    
    args = parser.parse_args()
    
    # Create a temporary directory if no output directory specified
    temp_dir = None
    if args.output is None:
        temp_dir = tempfile.TemporaryDirectory()
        output_dir = temp_dir.name
    else:
        output_dir = args.output
    
    try:
        # Create processing options
        options = ProcessingOptions(
            chunk_text=True,
            max_chunk_tokens=500,
            chunk_overlap=100,
            enhanced_markdown=True,
            code_metadata=True,
            summary=False,
            verbose=args.verbose
        )
        
        # Process repository
        extensions = args.exts.split(",")
        result = process_repository(
            repo_url=args.repo,
            output_dir=output_dir,
            extensions=extensions,
            options=options
        )
        
        # Print result
        print("\nProcessing Results:")
        print(f"Files processed: {result.file_count}")
        print(f"Total bytes: {result.total_bytes}")
        print(f"Estimated tokens: {result.estimated_tokens}")
        print(f"Chunks created: {result.chunk_count}")
        print(f"Summary file: {result.summary_path}")
        print(f"Digest file: {result.digest_path}")
        print(f"Tree file: {result.tree_path}")
        if result.chunks_path:
            print(f"Chunks file: {result.chunks_path}")
        
    finally:
        # Clean up temporary directory if created
        if temp_dir:
            temp_dir.cleanup()