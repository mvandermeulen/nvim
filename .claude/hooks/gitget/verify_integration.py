"""
Verification script for GitGit integration.

This script verifies that all components of GitGit work together correctly,
including text chunking, tree-sitter code analysis, and markdown extraction.
"""

import os
import sys
import json
import tempfile
import argparse
from pathlib import Path
from typing import Dict, List, Any, Optional, Set
from loguru import logger
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.tree import Tree as RichTree

from complexity.gitgit.integration_api import (
    process_repository,
    ProcessingOptions,
    ProcessingResult
)


def verify_directory_structure(result: ProcessingResult) -> bool:
    """
    Verify that the correct directory structure was created.
    
    Args:
        result: Processing result
        
    Returns:
        True if verification passed, False otherwise
    """
    console = Console()
    console.print("\n[bold blue]Verifying Directory Structure...[/bold blue]")
    
    paths = [
        result.summary_path,
        result.digest_path,
        result.tree_path
    ]
    
    if result.chunks_path:
        paths.append(result.chunks_path)
        
    if result.llm_summary_path:
        paths.append(result.llm_summary_path)
    
    # Check if all paths exist
    all_exist = True
    table = Table(title="Output File Verification")
    table.add_column("File Type", style="cyan")
    table.add_column("Path", style="green")
    table.add_column("Exists", style="magenta")
    table.add_column("Size (bytes)", style="yellow")
    
    for path in paths:
        if path:
            exists = os.path.exists(path)
            all_exist = all_exist and exists
            size = os.path.getsize(path) if exists else 0
            
            file_type = os.path.basename(path).split(".")[0].upper()
            table.add_row(
                file_type,
                path,
                "[green]✓[/green]" if exists else "[red]✗[/red]",
                str(size)
            )
    
    console.print(table)
    
    if all_exist:
        console.print("[green]✓ Directory structure verification passed[/green]")
        return True
    else:
        console.print("[red]✗ Directory structure verification failed[/red]")
        return False


def verify_chunks(result: ProcessingResult) -> bool:
    """
    Verify that chunks were created correctly.
    
    Args:
        result: Processing result
        
    Returns:
        True if verification passed, False otherwise
    """
    console = Console()
    console.print("\n[bold blue]Verifying Chunks...[/bold blue]")
    
    if not result.chunks_path or not os.path.exists(result.chunks_path):
        console.print("[red]✗ Chunks file not found[/red]")
        return False
    
    try:
        with open(result.chunks_path, "r", encoding="utf-8") as f:
            chunks = json.load(f)
    except Exception as e:
        console.print(f"[red]✗ Error loading chunks file: {e}[/red]")
        return False
    
    # Check if chunks were created
    if not chunks:
        console.print("[yellow]⚠ No chunks created[/yellow]")
        return True
    
    # Verify basic chunk structure
    chunk_verification = True
    required_fields = [
        "file_path", "code", "section_id", "code_token_count"
    ]
    
    missing_fields = {}
    for i, chunk in enumerate(chunks):
        for field in required_fields:
            if field not in chunk:
                chunk_verification = False
                if i not in missing_fields:
                    missing_fields[i] = []
                missing_fields[i].append(field)
    
    if missing_fields:
        console.print("[red]✗ Some chunks are missing required fields:[/red]")
        for chunk_idx, fields in missing_fields.items():
            console.print(f"  Chunk {chunk_idx}: Missing {', '.join(fields)}")
        return False
    
    # Show chunk statistics
    file_counts = {}
    for chunk in chunks:
        file_path = chunk["file_path"]
        if file_path in file_counts:
            file_counts[file_path] += 1
        else:
            file_counts[file_path] = 1
    
    table = Table(title=f"Chunk Statistics ({len(chunks)} chunks)")
    table.add_column("File", style="cyan")
    table.add_column("Chunk Count", style="green")
    table.add_column("Average Tokens", style="yellow")
    
    for file_path, count in file_counts.items():
        file_chunks = [c for c in chunks if c["file_path"] == file_path]
        avg_tokens = sum(c["code_token_count"] for c in file_chunks) / len(file_chunks)
        table.add_row(
            file_path,
            str(count),
            f"{avg_tokens:.1f}"
        )
    
    console.print(table)
    
    if chunk_verification:
        console.print("[green]✓ Chunk verification passed[/green]")
        return True
    else:
        console.print("[red]✗ Chunk verification failed[/red]")
        return False


def verify_tree(result: ProcessingResult) -> bool:
    """
    Verify that the repository tree was created correctly.
    
    Args:
        result: Processing result
        
    Returns:
        True if verification passed, False otherwise
    """
    console = Console()
    console.print("\n[bold blue]Verifying Repository Tree...[/bold blue]")
    
    if not result.tree_path or not os.path.exists(result.tree_path):
        console.print("[red]✗ Tree file not found[/red]")
        return False
    
    try:
        with open(result.tree_path, "r", encoding="utf-8") as f:
            tree_content = f.read()
    except Exception as e:
        console.print(f"[red]✗ Error reading tree file: {e}[/red]")
        return False
    
    # Check if tree is not empty
    if not tree_content.strip():
        console.print("[red]✗ Tree is empty[/red]")
        return False
    
    # Check if files have been included in the tree
    if not any(file in tree_content for file in result.files_processed):
        console.print("[red]✗ Tree does not contain processed files[/red]")
        return False
    
    # Create a rich tree visualization
    root = RichTree("[bold]Repository Structure[/bold]")
    
    for line in tree_content.splitlines():
        if not line.strip():
            continue
        
        level = line.count("    ")
        name = line.strip()
        
        if level == 0:
            current = root.add(name)
        elif level == 1:
            current = root.children[0].add(name)
        else:
            # Find the correct parent
            parent = root.children[0]
            for _ in range(level - 1):
                if parent.children:
                    parent = parent.children[-1]
            current = parent.add(name)
    
    console.print(root)
    console.print("[green]✓ Tree verification passed[/green]")
    return True


def verify_backward_compatibility(repo_url: str, extensions: List[str]) -> bool:
    """
    Verify that the integration maintains backward compatibility.
    
    Args:
        repo_url: Repository URL
        extensions: File extensions to include
        
    Returns:
        True if verification passed, False otherwise
    """
    console = Console()
    console.print("\n[bold blue]Verifying Backward Compatibility...[/bold blue]")
    
    # Create temporary directories for new and old output
    with tempfile.TemporaryDirectory() as enhanced_dir, tempfile.TemporaryDirectory() as basic_dir:
        # Process with enhanced options
        enhanced_options = ProcessingOptions(
            chunk_text=True,
            enhanced_markdown=True,
            code_metadata=True
        )
        
        enhanced_result = process_repository(
            repo_url=repo_url,
            output_dir=enhanced_dir,
            extensions=extensions,
            options=enhanced_options
        )
        
        # Process with basic options (backward compatible)
        basic_options = ProcessingOptions(
            chunk_text=False,
            enhanced_markdown=False,
            code_metadata=False
        )
        
        basic_result = process_repository(
            repo_url=repo_url,
            output_dir=basic_dir,
            extensions=extensions,
            options=basic_options
        )
        
        # Compare results
        table = Table(title="Backward Compatibility Verification")
        table.add_column("Metric", style="cyan")
        table.add_column("Enhanced Mode", style="green")
        table.add_column("Basic Mode", style="blue")
        
        table.add_row(
            "Files Processed",
            str(enhanced_result.file_count),
            str(basic_result.file_count)
        )
        
        table.add_row(
            "Total Bytes",
            str(enhanced_result.total_bytes),
            str(basic_result.total_bytes)
        )
        
        table.add_row(
            "Chunks Created",
            str(enhanced_result.chunk_count),
            str(basic_result.chunk_count)
        )
        
        console.print(table)
        
        # Check if all files were processed in both modes
        if enhanced_result.file_count != basic_result.file_count:
            console.print("[red]✗ Different number of files processed in enhanced and basic modes[/red]")
            return False
        
        # Check if both modes generated output files
        if (not enhanced_result.summary_path or not os.path.exists(enhanced_result.summary_path) or
            not basic_result.summary_path or not os.path.exists(basic_result.summary_path)):
            console.print("[red]✗ Summary files not created in both modes[/red]")
            return False
        
        console.print("[green]✓ Backward compatibility verification passed[/green]")
        return True


def verify_error_handling(repo_url: str) -> bool:
    """
    Verify that error handling is working correctly.
    
    Args:
        repo_url: Repository URL
        
    Returns:
        True if verification passed, False otherwise
    """
    console = Console()
    console.print("\n[bold blue]Verifying Error Handling...[/bold blue]")
    
    # Test cases that should be handled gracefully
    test_cases = [
        # Invalid repository URL
        {
            "name": "Invalid Repository URL",
            "repo_url": "https://github.com/non-existent/repo",
            "extensions": ["md"],
            "options": ProcessingOptions()
        },
        # Non-existent files
        {
            "name": "Non-existent Files",
            "repo_url": repo_url,
            "extensions": ["md"],
            "files": ["non-existent-file.md"],
            "options": ProcessingOptions()
        },
        # Invalid file extension
        {
            "name": "Invalid Extension",
            "repo_url": repo_url,
            "extensions": ["xyz"],
            "options": ProcessingOptions()
        }
    ]
    
    # Run test cases
    results = []
    for test_case in test_cases:
        console.print(f"\nTesting: {test_case['name']}")
        try:
            with tempfile.TemporaryDirectory() as temp_dir:
                # Try to process with error conditions
                process_repository(
                    repo_url=test_case["repo_url"],
                    output_dir=temp_dir,
                    extensions=test_case.get("extensions"),
                    files=test_case.get("files"),
                    options=test_case["options"]
                )
                
                # If we get here, the error was handled
                console.print(f"[green]✓ {test_case['name']} - Error handled gracefully[/green]")
                results.append(True)
        except Exception as e:
            # Error not handled properly
            console.print(f"[red]✗ {test_case['name']} - Unhandled error: {e}[/red]")
            results.append(False)
    
    all_passed = all(results)
    if all_passed:
        console.print("\n[green]✓ Error handling verification passed[/green]")
    else:
        console.print("\n[red]✗ Error handling verification failed[/red]")
    
    return all_passed


def main():
    """
    Main verification script.
    """
    parser = argparse.ArgumentParser(description="Verify GitGit Integration")
    parser.add_argument("--repo", type=str, default="https://github.com/arangodb/python-arango",
                     help="Repository URL to test with")
    parser.add_argument("--exts", type=str, default="md,rst",
                     help="File extensions to include")
    parser.add_argument("--output", type=str, default=None,
                     help="Output directory")
    parser.add_argument("--full", action="store_true",
                     help="Run full verification (including error handling)")
    parser.add_argument("--verbose", action="store_true",
                     help="Enable verbose output")
    
    args = parser.parse_args()
    
    # Configure logging
    log_level = "DEBUG" if args.verbose else "INFO"
    logger.remove()
    logger.add(lambda msg: print(msg), level=log_level)
    
    console = Console()
    console.print(f"[bold blue]GitGit Integration Verification[/bold blue]")
    console.print(f"Testing repository: {args.repo}")
    console.print(f"Extensions: {args.exts}")
    
    # Create temporary directory if no output dir specified
    temp_dir = None
    if args.output:
        output_dir = args.output
    else:
        temp_dir = tempfile.TemporaryDirectory()
        output_dir = temp_dir.name
    
    try:
        # Process repository with all features enabled
        console.print("\n[bold]Processing Repository...[/bold]")
        options = ProcessingOptions(
            chunk_text=True,
            max_chunk_tokens=500,
            chunk_overlap=100,
            enhanced_markdown=True,
            code_metadata=True,
            verbose=args.verbose
        )
        
        extensions = args.exts.split(",")
        result = process_repository(
            repo_url=args.repo,
            output_dir=output_dir,
            extensions=extensions,
            options=options
        )
        
        # Run verifications
        verification_results = {
            "Directory Structure": verify_directory_structure(result),
            "Chunks": verify_chunks(result),
            "Repository Tree": verify_tree(result)
        }
        
        # Run backward compatibility check
        verification_results["Backward Compatibility"] = verify_backward_compatibility(
            args.repo, extensions
        )
        
        # Run error handling check if full verification requested
        if args.full:
            verification_results["Error Handling"] = verify_error_handling(args.repo)
        
        # Print summary
        console.print("\n[bold blue]Verification Summary[/bold blue]")
        summary_table = Table(title="Verification Results")
        summary_table.add_column("Test", style="cyan")
        summary_table.add_column("Result", style="green")
        
        for test, passed in verification_results.items():
            summary_table.add_row(
                test,
                "[green]PASSED[/green]" if passed else "[red]FAILED[/red]"
            )
        
        console.print(summary_table)
        
        # Overall result
        all_passed = all(verification_results.values())
        if all_passed:
            console.print("\n[bold green]✅ All verification tests passed[/bold green]")
            return 0
        else:
            console.print("\n[bold red]❌ Some verification tests failed[/bold red]")
            return 1
            
    finally:
        if temp_dir:
            temp_dir.cleanup()


if __name__ == "__main__":
    sys.exit(main())