# GitGit Changelog

## [1.2.0] - 2025-05-03
### Added - Markdown Extraction Upgrade
- New `markdown` module with enhanced document parsing functionality
- Hierarchical section extraction preserving document structure
- Detailed code block association with descriptions
- Section title cleaning and normalization
- Stable section identifiers with SHA256 hashing
- Line position tracking for better document context
- Rich test verification script (`test_markdown_extractor.py`)
- CLI parameter for enhanced markdown extraction:
  - `--enhanced-markdown/--simple-markdown` to toggle advanced parsing
- Integration with main GitGit workflow
- Comprehensive documentation in `markdown/README.md`

### Changed
- Updated `concat_and_summarize()` function to use markdown extraction for `.md` files
- Enhanced CLI interface with new markdown extraction parameter
- Improved handling of multiple file types

## [1.1.0] - 2025-05-03
### Added - Tree-Sitter Enhancement
- New `parser` module with comprehensive code analysis functionality
- Support for 100+ programming languages through tree-sitter integration
- Detailed parameter extraction including types, defaults, and requirements
- Improved docstring extraction across multiple language formats
- Rich test and verification with sample code from various languages
- Fallback mechanisms for unsupported language features
- Line number tracking for better code positioning
- Integration with main GitGit workflow

## [1.0.0] - 2025-05-03
### Added - Text Chunking Integration
- New `chunking` module with `TextChunker` class for intelligent document processing
- Smart text chunking preserving document structure and hierarchies
- Section detection for markdown documents
- Stable section identifiers using SHA256 hashing
- Token-aware chunking with configurable limits
- Metadata preservation across document chunks
- Comprehensive test verification script (`test_chunker.py`)
- CLI parameters for customizing chunking behavior:
  - `--chunk-text/--no-chunk-text` to toggle chunking
  - `--max-chunk-tokens` to set maximum tokens per chunk
  - `--chunk-overlap` to set overlap between chunks
- JSON output for chunks with metadata in `chunks/all_chunks.json`
- Improved documentation with examples and usage guidelines

### Changed
- Enhanced `concat_and_summarize()` function to use text chunking
- Updated CLI interface with new chunking parameters
- Improved token counting with robust fallbacks

### Fixed
- Handling of oversized content by implementing word-level chunking
- Fallback mechanisms for missing dependencies (spaCy, tiktoken)

## [Upcoming]
### Planned Features
- Integration and Testing phase to combine all components
- Performance optimization for large repositories
- Integration with database systems