# GitGit

GitGit is a CLI utility for sparse cloning, analyzing, and LLM-based documentation of GitHub repositories.

## Directory Structure

- `chunking/`: Text chunking functionality for breaking down content into manageable pieces
- `docs/`: Documentation for GitGit modules
- `markdown/`: Markdown parsing and extraction functionality
- `parser/`: Code parsing and metadata extraction using tree-sitter
- `summarizer/`: Text summarization functionality
- `tasks/`: Task-specific information for GitGit development
- `utils/`: Utility functions and helpers for GitGit
  - `directory_manager.py`: Directory management for output files
  - `enhanced_logger.py`: Enhanced logging capabilities
  - `error_handler.py`: Error handling utilities
  - `initialize_litellm_cache.py`: LiteLLM cache initialization
  - `json_utils.py`: JSON utilities for parsing and formatting
  - `log_utils.py`: Basic logging utilities
  - `workflow_logger.py`: Workflow tracking and logging
  - `workflow_tracking.py`: Workflow state tracking

## Core Features

- **Sparse Cloning**: Efficiently clone only the parts of repositories you need
- **Text Chunking**: Break down large documents into manageable chunks while preserving structure
- **Markdown Extraction**: Parse and extract structured content from markdown files
- **Code Metadata**: Extract metadata from code files using tree-sitter
- **LLM Summarization**: Generate summaries of repository content using LLMs

## Getting Started

### Installation

```bash
pip install complexity
```

### Usage

```bash
python -m complexity.gitgit.gitgit analyze https://github.com/username/repository --exts md,py,js
```

### Options

- `--exts`: Comma-separated list of file extensions to include
- `--files`: Comma-separated list of specific files to include
- `--dirs`: Comma-separated list of directories to include
- `--output`: Custom output directory
- `--summary`: Generate an LLM-based summary of the repository
- `--code-metadata`: Extract function metadata from code files
- `--chunk-text/--no-chunk-text`: Enable/disable advanced text chunking
- `--enhanced-markdown/--simple-markdown`: Enable/disable enhanced markdown extraction
- `--max-chunk-tokens`: Maximum tokens per chunk (default: 500)
- `--chunk-overlap`: Token overlap between chunks (default: 100)
- `--llm-model`: LLM model to use for summarization (default: gemini-2.5-pro-preview-03-25)

## Modules

### chunking

Text chunking functionality that preserves document structure, hierarchy, and metadata.

### markdown

Markdown parsing and extraction with support for section hierarchy, code blocks, and metadata.

### parser

Code parsing and metadata extraction using tree-sitter, supporting multiple programming languages.

### summarizer

Text summarization using various approaches, including LLM-based summarization.

### utils

Utility functions and helpers for error handling, logging, JSON operations, and more.

## Requirements

- Python 3.8 or higher
- Git CLI installed
- Optional: API keys for LLM services (for summarization)

## Development

### Running Tests

```bash
pytest tests/gitgit/
```