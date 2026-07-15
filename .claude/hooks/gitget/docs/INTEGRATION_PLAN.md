# GitGit Integration Plan

## Overview

This document outlines the plan for integrating the three major components we've developed:

1. **Text Chunking** (`chunking` module)
2. **Tree-Sitter Enhancement** (`parser` module)
3. **Markdown Extraction** (`markdown` module)

The goal is to create a unified workflow that leverages all enhancements while maintaining backward compatibility and ensuring proper error handling throughout.

## Component Relationships

```
                 ┌─────────────────┐
                 │                 │
                 │    gitgit.py    │
                 │  Main Workflow  │
                 │                 │
                 └────────┬────────┘
                          │
            ┌─────────────┴─────────────┐
            │                           │
  ┌─────────▼─────────┐      ┌──────────▼───────────┐
  │                   │      │                      │
  │ concat_and_       │      │ extract_code_        │
  │ summarize()       │      │ metadata()           │
  │                   │      │                      │
  └─────────┬─────────┘      └──────────┬───────────┘
            │                           │
 ┌──────────┼───────────┐    ┌──────────▼───────────┐
 │          │           │    │                      │
 │ ┌────────▼────────┐ │    │    parser module      │
 │ │                 │ │    │  tree_sitter_utils.py │
 │ │  chunking       │ │    │                      │
 │ │  text_chunker.py│ │    └──────────────────────┘
 │ │                 │ │
 │ └────────┬────────┘ │
 │          │          │
 │ ┌────────▼────────┐ │
 │ │                 │ │
 │ │  markdown       │ │
 │ │  markdown_      │ │
 │ │  extractor.py   │ │
 │ │                 │ │
 │ └─────────────────┘ │
 │                     │
 └─────────────────────┘
```

## Integration Strategy

### 1. Directory Structure

Create a more organized directory structure:
- `/chunks`: Store chunked text files
- `/parsed`: Store parsed markdown files
- `/metadata`: Store extracted code metadata
- `/output`: Final output files (DIGEST.txt, SUMMARY.txt, etc.)

### 2. Unified API

Create a unified API in the main workflow:

```python
def process_repository(
    repo_url: str,
    output_dir: str,
    extensions: List[str] = None,
    files: List[str] = None,
    dirs: List[str] = None,
    options: Dict[str, Any] = None
) -> Dict[str, Any]:
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
        Dict with processing results
    """
```

This unified API will:
1. Clone the repository
2. Process files based on their type
3. Generate unified output

### 3. File Type Processing

Handle files based on their type:

| File Type | Primary Processor | Fallback |
|-----------|-------------------|----------|
| .md       | markdown_extractor | text_chunker |
| .py, .js, etc. | tree_sitter_utils | Simple concatenation |
| Other text | text_chunker | Simple concatenation |
| Non-text | Skip | Skip |

### 4. CLI Enhancements

Enhance the CLI with unified options:

```
gitgit analyze <repo_url> [options]
```

Options:
- `--exts` - File extensions to include
- `--files` - Specific files to include
- `--dirs` - Specific directories to include
- `--output` - Custom output directory path
- `--enhanced-markdown/--simple-markdown` - Toggle enhanced markdown extraction
- `--chunk-text/--no-chunk-text` - Toggle text chunking
- `--code-metadata/--no-code-metadata` - Toggle code metadata extraction
- `--max-chunk-tokens` - Maximum tokens per chunk
- `--chunk-overlap` - Overlap between chunks
- `--summary` - Generate LLM summary
- `--llm-model` - LLM model to use for summarization

Note: The `--output` parameter was added to allow specifying a custom output directory for GitGit analysis results instead of the default `repos/{repo_name}_sparse` location.

### 5. Error Handling Strategy

Implement a robust error handling strategy:

1. **Modular Error Handling** - Each module has its own error handling
2. **Cascading Fallbacks** - If enhanced processing fails, fall back to simpler methods
3. **Detailed Logging** - Log all errors with context for troubleshooting
4. **User Feedback** - Provide clear error messages to users

## Implementation Sequence

1. ✅ Create an integration plan for combining all components
2. ✅ Add `--output` parameter to GitGit CLI for custom output directory
3. ⏩ Update dependencies in `pyproject.toml`
4. ⏳ Create the enhanced directory structure
5. ⏳ Implement the unified API in `gitgit.py`
6. ⏳ Update remaining CLI options for unified access
7. ⏳ Implement comprehensive error handling
8. ⏳ Add detailed logging
9. ⏳ Test backward compatibility
10. ⏳ Create test fixtures for automated testing
11. ⏳ Update documentation

Legend:
- ✅ Completed
- ⏩ In Progress
- ⏳ Planned

## Testing Strategy

1. **End-to-End Tests**:
   - Process python-arango repository
   - Verify results against expected outputs
   - ✅ Test custom output directory functionality with --output parameter

2. **Component Tests**:
   - Test each component separately
   - Ensure proper input/output contracts
   - ✅ Created tests for DirectoryManager

3. **Error Injection Tests**:
   - Deliberately cause errors in each component
   - Verify graceful error handling and fallbacks
   - ✅ Created error handling tests with test_error_handling_real.py

4. **Performance Tests**:
   - Compare processing time with original implementation
   - Monitor memory usage

5. **CLI Compatibility Tests**:
   - Run with original CLI parameters
   - Verify backward compatibility
   - ✅ Fixed CLI integration tests to use actual CLI parameters

## Verification Metrics

1. **Functionality**:
   - All components work together seamlessly
   - No regressions in existing functionality
   - New features work as expected

2. **Error Handling**:
   - All errors are caught and handled appropriately
   - Fallbacks work as expected
   - User receives clear error messages

3. **Performance**:
   - Processing time within acceptable limits
   - Memory usage within reasonable bounds

4. **Usability**:
   - CLI options are intuitive
   - Documentation is comprehensive

## Integration Milestones

1. **Directory Structure & CLI Enhancement**
   - ✅ Set up enhanced directory structure with DirectoryManager
   - ✅ Add `--output` parameter to GitGit CLI
   - ✅ Create tests for directory structure and CLI options

2. **Unified API**
   - ⏳ Implement unified API in `gitgit.py`
   - ⏳ Create integration_api.py with unified interfaces

3. **Error Handling**
   - ⏳ Implement comprehensive error handling
   - ⏳ Create GitGitError hierarchy
   - ✅ Initial error handling tests created

4. **Testing**
   - ✅ Create initial test fixtures
   - ✅ Fix CLI integration tests
   - ⏳ Expand test coverage

5. **Documentation**
   - ⏳ Update all documentation
   - ⏳ Create examples for users

## Dependencies Research

| Package | Purpose | Version |
|---------|---------|---------|
| tiktoken | Token counting | >=0.8.0 |
| spacy | Sentence splitting | >=3.8.4 |
| tree-sitter | Code parsing | >=0.24.0 |
| tree-sitter-languages | Language support | >=1.10.2 |
| markdown-it-py | Markdown parsing | >=3.0.0 |
| loguru | Enhanced logging | >=0.7.3 |
| rich | Terminal visualization | >=13.9.4 |
| typer | CLI interface | >=0.9.0 |

All these dependencies will be verified and updated in `pyproject.toml`.

## Future Integration

This integration plan also considers future extensions:

1. **FastAPI Integration** - Exposing functionality via REST API
2. **MCP Integration** - Multi-agent communication protocol support
3. **Database Integration** - Storing results in ArangoDB or similar databases

The unified API is designed to support these future integrations.