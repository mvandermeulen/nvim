# GitGit Advanced Parsing Integration ⏳ In Progress

**Objective**: Integrate advanced text chunking, tree-sitter code analysis, and markdown extraction functionality from archived code into the current `gitgit.py` implementation.

**Status**: Text chunking and tree-sitter enhancement complete, markdown extraction complete.

**Requirements**:
1. All changes must comply with documentation standards in `/docs/memory_bank/`
2. Preserve functionality of existing CLI interface
3. Maintain backward compatibility with current API
4. Implement comprehensive error handling and validation
5. Add detailed documentation for new features

## Overview

The current `gitgit.py` implementation performs basic file concatenation and code analysis, but lacks sophisticated text processing capabilities. The goal is to create an enhanced version that provides highly optimized repository information that LLM agents can easily query while preserving all important structural relationships.

The archived code in `_archive/gitgit/` contains advanced functionalities that can significantly enhance GitGit:

1. **Text Chunking**: Smart, token-aware text chunking that preserves document structure
2. **Tree-Sitter Analysis**: Comprehensive code parameter extraction including types and annotations
3. **Markdown Extraction**: Structure-preserving markdown parsing with section hierarchy support

These enhancements will significantly improve the quality of code summaries by preserving context and structure throughout the analysis process.

## Key Requirements Clarifications

1. **Output Format**: 
   - Primary output remains a single markdown file (like current implementation)
   - Individual markdown files should be stored in a separate directory before concatenation
   - Each section must have a UUID field to enable targeting individual sections for database insertion

2. **CLI Interface**:
   - Keep parameters minimal to avoid confusing agents
   - Advanced functionality (tree-sitter, chunking) should be built-in by default
   - Focus on core usability for agents

3. **Organization**:
   - Preserve file/folder structure from sparse download
   - Maintain section hierarchy within each file
   - Follow patterns from markdown_extractor and text_chunker examples

4. **Future Integration**:
   - Will eventually use FastAPI with MCP (using fastapi_mcp_sse pattern)
   - Current implementation should support future API development

## Implementation Tasks

### Task 1: Text Chunking Integration ⏳ Almost Complete

**Implementation Steps**:
- [ ] 1.1. Create a new module `text_chunker.py` with skeleton and docstrings
- [ ] 1.2. Implement basic token counting compatibility layer
- [ ] 1.3. Add verification code to test token counting against examples
- [ ] 1.4. Git commit working token counting module
- [ ] 1.5. Implement section detection for hierarchical document representation
- [ ] 1.6. Add verification for section detection with example documents
- [ ] 1.7. Git commit working section detection
- [ ] 1.8. Implement chunk generation with metadata preservation
- [ ] 1.9. Add verification for chunking with example large documents
- [ ] 1.10. Git commit working chunking functionality
- [x] 1.11. Modify `concat_and_summarize()` in `gitgit.py` to use the new functionality
- [x] 1.12. Verify integration works with example repositories
- [x] 1.13. Git commit integrated functionality
- [x] 1.14. Add comprehensive documentation with examples

**Technical Specifications**:
- Preserve token counting compatibility with existing implementation
- Ensure chunking respects model context limits
- Maintain metadata across all chunks
- Add configurable chunking strategies
- Maximum chunk size should be configurable (default: 500 tokens)
- Minimum chunk overlap should be configurable (default: 100 tokens)

**Verification Method**:
- JSON output showing token counts for example documents with comparison to expected counts
- Rich table showing section detection results with the following columns:
  - Section ID
  - Section Title
  - Level
  - Parent Section ID
  - Token Count
- Concrete examples of chunk boundaries with metadata using real documents from python-arango
- Command-line verification that humans can run independently with expected outputs clearly documented
- Detailed error reporting that shows exactly what failed and how it differs from expected
- Self-validating `if __name__ == "__main__"` block that compares against expected fixture data

**Acceptance Criteria**:
- Text is chunked in a way that preserves document structure
- All chunks maintain relevant context and metadata
- Validation confirms expected output structure
- Documentation clearly explains chunking behavior

### Task 2: Tree-Sitter Enhancement ⏳ Almost Complete

**Implementation Steps**:
- [x] 2.1. Create expanded language mappings module based on `_archive/gitgit/tree_sitter_utils.py`
- [x] 2.2. Add verification for language detection with example files
- [x] 2.3. Git commit language mapping enhancements
- [x] 2.4. Enhance parameter extraction to include types and default values
- [x] 2.5. Add verification for parameter extraction with example code
- [x] 2.6. Git commit parameter extraction enhancements
- [x] 2.7. Improve docstring extraction across languages
- [x] 2.8. Add verification for docstring extraction with examples
- [x] 2.9. Git commit docstring extraction enhancements
- [x] 2.10. Implement robust error handling with fallbacks
- [x] 2.11. Verify error handling with malformed code examples
- [x] 2.12. Git commit error handling improvements
- [x] 2.13. Integrate enhancements with main workflow
- [x] 2.14. Create comprehensive documentation with examples

**Technical Specifications**:
- Use tree-sitter to extract detailed code structure
- Handle parameter types, defaults, and docstrings
- Support multiple programming languages (minimum: Python, JavaScript, TypeScript, Java, Go, Ruby)
- Provide fallback mechanisms for parsing failures
- Extract function and class relationships where possible
- Track line numbers and positions for better context

**Verification Method**:
- JSON output showing detected languages for example files with comparison to expected results
- Rich table showing extracted parameters with the following columns:
  - Function Name
  - Parameter Name
  - Parameter Type
  - Default Value
  - Required/Optional
  - Expected vs. Actual (✓ or ✗)
- Rich table showing docstrings associated with functions using real code examples from python-arango
- Log output demonstrating error handling with concrete malformed code examples
- Command-line verification script that anyone can run independently
- Detailed failure reports showing expected vs. actual values for each mismatch
- Self-validating `if __name__ == "__main__"` block with comprehensive test fixtures

**Acceptance Criteria**:
- Enhanced language support compared to current implementation
- Type annotations are correctly extracted and preserved
- Docstrings are properly associated with their functions
- Error handling gracefully manages parsing failures

### Task 3: Markdown Extraction Upgrade ✅ Completed

**Implementation Steps**:
- [x] 3.1. Create a new module `markdown_extractor.py` with skeleton and docstrings
- [x] 3.2. Implement basic markdown parsing with markdown-it-py
- [x] 3.3. Add verification for basic parsing with example markdown
- [x] 3.4. Git commit basic markdown parsing
- [x] 3.5. Implement section hierarchy tracking
- [x] 3.6. Add verification for section hierarchy with examples
- [x] 3.7. Git commit section hierarchy tracking
- [x] 3.8. Implement code block association with descriptions
- [x] 3.9. Add verification for code block association
- [x] 3.10. Git commit code block association functionality
- [x] 3.11. Implement section title cleaning and normalization
- [x] 3.12. Add verification for cleaning with example markdown
- [x] 3.13. Git commit cleaning and normalization
- [x] 3.14. Implement section hash generation (following markdown_extractor approach)
- [x] 3.15. Add verification for section hashes with example markdown
- [x] 3.16. Git commit hash implementation
- [x] 3.17. Integrate markdown extraction with main workflow
- [x] 3.18. Create comprehensive documentation with examples

**Technical Specifications**:
- Use markdown-it-py for parsing
- Maintain hierarchical section structure
- Preserve relationships between text and code blocks
- Clean and normalize content for consistency
- Track line numbers and positions for better context
- Extract metadata from frontmatter if present
- Generate stable hashes for each section using the markdown_extractor approach (not UUID4)
- Store intermediate parsed markdown files in a separate directory before concatenation

**Verification Method**:
- Rich table showing detected sections with hierarchy from real markdown files in python-arango, displaying:
  - Section ID
  - Section Hash
  - Section Title
  - Level
  - Parent Section ID
  - Line Range
  - Verification Status (✓ or ✗)
- JSON output showing code blocks with associated descriptions compared to expected output
- Side-by-side examples of cleaned section titles vs. original text with expected results
- Visual representation of parsed markdown structure using actual files
- Command-line verification script with detailed output anyone can run and verify
- Comparison against fixture data with detailed error reporting for mismatches
- Self-validating `if __name__ == "__main__"` block with comprehensive test cases

**Acceptance Criteria**:
- Markdown structure is correctly preserved
- Section hierarchy is maintained in the output
- Code blocks are properly associated with their descriptions
- Unicode content is correctly normalized

### Task 4: Integration and Testing ⏳ In Progress

**Implementation Steps**:
- [x] 4.1. Create an integration plan for combining all components
- [x] 4.2. Update dependencies in `pyproject.toml` with researched packages
- [ ] 4.3. Create directory structure for storing intermediate parsed files
- [ ] 4.4. Implement integration points in main workflow
- [ ] 4.5. Add verification for integrated functionality
- [ ] 4.6. Git commit integrated workflow
- [ ] 4.7. Create comprehensive error handling for the integrated system
- [ ] 4.8. Add detailed logging for complex workflows
- [ ] 4.9. Test backward compatibility with existing CLI
- [ ] 4.10. Git commit final integration with error handling
- [x] 4.11. Create test fixtures for automated testing
- [ ] 4.12. Create comprehensive documentation for enhanced features
- [ ] 4.13. Tag the completion of the integration phase
- [x] 4.14. Add --output parameter to GitGit CLI to allow specifying custom output directory

**Technical Specifications**:
- Test all enhancements against representative code samples
- Maintain backward compatibility with existing API
- Ensure proper error handling throughout
- Document all new functionality
- Create a single, unified workflow that leverages all enhancements
- Store intermediate parsed files in a structured directory
- Use minimal CLI parameters to keep interface simple for agents
- Ensure the implementation will support future FastAPI/MCP integration
- Implement --output parameter for custom output directory specification

**Verification Method**:
- End-to-end tests with python-arango repository showing concrete before/after results
- CLI command execution with exact expected output documented for human verification
- Error injection tests with specific examples to verify error handling
- Performance comparison with original implementation using metrics table
- Detailed verification script anyone can run that shows exactly what passes/fails
- Comparison against fixture data with precise error reporting for any discrepancies
- Self-validating `if __name__ == "__main__"` block that runs the entire verification suite
- Rich tables showing integrated results
- Test custom output directory functionality with the new --output parameter

**Testing Requirements** (see `/docs/memory_bank/CLAUDE_TEST_REQUIREMENTS.md`):
- Tests MUST use ACTUAL code and repositories (python-arango, minimal-readme)
- NO mocking of core functionality - test real behavior with real data
- Fixtures must contain REAL expected outputs from running the code
- Each test must verify SPECIFIC expected values (not generic assertions)
- Tests must include realistic error cases with concrete expected error messages
- Tests must actually fail when the underlying functionality breaks

**Acceptance Criteria**:
- All functionality works together seamlessly
- Existing CLI interface continues to work as expected
- Error messages are clear and actionable
- Documentation comprehensively covers new features
- --output parameter correctly redirects all output files to the specified directory

### Task 5: Performance Optimization ⏳ Not Started

**Implementation Steps**:
- [ ] 5.1. Create performance profiling infrastructure
- [ ] 5.2. Run baseline performance tests with large repositories
- [ ] 5.3. Identify bottlenecks in processing workflow
- [ ] 5.4. Implement caching for repeated operations
- [ ] 5.5. Verify caching effectiveness with performance tests
- [ ] 5.6. Git commit caching improvements
- [ ] 5.7. Optimize tree-sitter queries
- [ ] 5.8. Verify query optimization with performance tests
- [ ] 5.9. Git commit query optimizations
- [ ] 5.10. Implement parallelization where appropriate
- [ ] 5.11. Verify parallelization benefits with performance tests
- [ ] 5.12. Git commit parallelization improvements
- [ ] 5.13. Document performance characteristics and resource usage
- [ ] 5.14. Create final performance verification suite
- [ ] 5.15. Create git tag for completed optimization phase

**Technical Specifications**:
- Measure performance impact of enhancements
- Implement caching for expensive operations
- Optimize queries and processing workflows
- Document resource requirements
- Target maximum memory usage increase of 25% over original implementation
- Target maximum processing time increase of 20% over original implementation

**Verification Method**:
- Performance metrics table comparing before/after with columns and actual measurements:
  - Operation
  - Original Time (ms)
  - Enhanced Time (ms)
  - Difference (%)
  - Memory Usage Original (MB)
  - Memory Usage Enhanced (MB)
  - Difference (%)
- Memory usage graphs for different repository sizes with concrete measurements
- Processing time comparison for different file types with specific benchmarks
- Resource utilization visualization with actual data
- Runnable benchmarking script that others can independently verify
- Detailed comparison reports that show exactly what improved/degraded
- Self-validating `if __name__ == "__main__"` block that runs performance tests

**Acceptance Criteria**:
- Enhanced functionality performs within acceptable limits
- Memory usage remains reasonable (max 25% increase)
- Large repositories can be processed efficiently
- Performance characteristics are well-documented

## Usage Table

| Command / Function | Description | Example Usage | Expected Output |
|-------------------|-------------|---------------|-----------------|
| `text_chunk()` | Chunks text while preserving structure | `text_chunk(content, max_tokens=500)` | List of chunks with metadata |
| `extract_code_metadata()` | Extracts detailed code info | `extract_code_metadata('file.py', 'python')` | Dict with functions, params, types |
| `parse_markdown()` | Parses markdown with hierarchy | `parse_markdown(md_content)` | Structured dict with sections |
| `analyze` CLI | Analyzes a repository with enhanced features | `gitgit analyze https://github.com/user/repo` | Enhanced summary with structure |
| `analyze --code-metadata` | Analyzes with detailed code extraction | `gitgit analyze --code-metadata https://github.com/user/repo` | Summary with code structure |
| `analyze --exts md,py` | Analyzes specific file types | `gitgit analyze --exts md,py https://github.com/user/repo` | Summary of markdown and Python files |
| `analyze --max-chunk-tokens 1000` | Customizes token limit per chunk | `gitgit analyze --max-chunk-tokens 1000 https://github.com/user/repo` | Summary with larger chunks |
| `analyze --chunk-overlap 200` | Customizes overlap between chunks | `gitgit analyze --chunk-overlap 200 https://github.com/user/repo` | Summary with more context overlap |
| `analyze --no-chunk-text` | Disables text chunking | `gitgit analyze --no-chunk-text https://github.com/user/repo` | Summary without chunking |
| `analyze --output` | Specifies custom output directory | `gitgit analyze --output /custom/path https://github.com/user/repo` | Output saved to /custom/path |

## Example Usage

```bash
# Basic usage with default chunking (500 tokens per chunk, 100 token overlap)
python -m complexity.gitgit.gitgit analyze https://github.com/arangodb/python-arango

# Analyze with larger chunks for more context
python -m complexity.gitgit.gitgit analyze https://github.com/arangodb/python-arango --max-chunk-tokens 1000 --chunk-overlap 200

# Focus on Python files with code metadata extraction
python -m complexity.gitgit.gitgit analyze https://github.com/arangodb/python-arango --exts py --code-metadata

# Analyze specific files with LLM summary
python -m complexity.gitgit.gitgit analyze https://github.com/arangodb/python-arango --files README.md,docs/index.rst --summary

# Analyze repository with custom output directory
python -m complexity.gitgit.gitgit analyze https://github.com/arangodb/python-arango --output /path/to/output
```

## Output Structure

The enhanced GitGit now outputs:

1. **SUMMARY.txt** - Basic information about the repository analysis
2. **DIGEST.txt** - Content of all analyzed files (with chunking info for chunked files)
3. **TREE.txt** - File structure of the repository
4. **chunks/all_chunks.json** - JSON file containing all chunks with metadata, including:
   - Section IDs and hierarchies
   - File paths and line spans
   - Token counts
   - Extraction dates
   - Code metadata (when --code-metadata is used)
5. **LLM_SUMMARY.txt** - LLM-generated summary (when --summary is used)

## Version Control Plan

- **Initial Commit**: Before starting any implementation (document task plan)
- **Function Commits**: After each function is verified to work
- **Task Commits**: Upon completion of each major task
- **Phase Tags**: After completing text chunking, tree-sitter, markdown, integration, and optimization phases
- **Rollback Strategy**: Git reset to last working commit if implementation has errors

### Changelog Management

After completing each major phase:

1. Update `src/complexity/gitgit/CHANGELOG.md` with detailed information about:
   - New features and functionality added
   - Changes to existing components
   - Fixed issues or bugs
   - Upcoming planned features

2. Use the following format for changelog entries:
   ```markdown
   ## [VERSION] - YYYY-MM-DD
   ### Added
   - New feature 1
   - New feature 2
   
   ### Changed
   - Modified component 1
   - Modified component 2
   
   ### Fixed
   - Issue 1
   - Issue 2
   ```

3. Commit the changelog update along with the phase tag

## Resources

**Package Research**:
- `tree-sitter` and `tree-sitter-languages` - Research latest versions and compatibility
- `markdown-it-py` for markdown parsing - Verify best practices and extensions
- `tiktoken` for token counting - Confirm compatibility with different models
- `rich` for table visualization and verification output
- Any additional dependencies needed - Research before adding

**Integration Strategy**:
- Follow Local Editable Install approach from `INTEGRATION_STRATEGY.md`
- Allow direct imports between modules
- Avoid code duplication
- Simplify debugging across components

## Progress Tracking

- Start date: 2025-05-03
- Current phase: Integration and Testing (Next Phase)
- Completed phases: Text Chunking, Tree-Sitter Enhancement, Markdown Extraction
- Next phases: Integration and Testing, Performance Optimization
- Expected completion: [TBD]
- Completion criteria: All validation checks pass, documentation is complete

### Phase Completion Status

1. **Text Chunking Integration**: ✅ Completed (2025-05-03)
   - Implementation: Complete
   - Documentation: Complete
   - Git commits and tags: `text-chunking-v1.0`
   - Changelog: Updated in `CHANGELOG.md` v1.0.0

2. **Tree-Sitter Enhancement**: ✅ Completed (2025-05-03)
   - Implementation: Complete
   - Documentation: Complete
   - Git commits and tags: c8ef4ce
   - Changelog: Updated

3. **Markdown Extraction Upgrade**: ✅ Completed (2025-05-03)
   - Implementation: Complete
   - Documentation: Complete
   - Git commits and tags: f5c468e
   - Changelog: Needs update

## Context Management

When context length is running low during implementation, use the following approach to compact and resume work:

1. Issue the `/compact` command to create a concise summary of current progress
2. The summary will include:
   - Which tasks are completed/in-progress/pending
   - Current focus and status
   - Known issues or blockers
   - Next steps to resume work
   
3. **Resuming Work**:
   - Issue `/resume` to show the current status and continue implementation
   - All completed tasks will be marked accordingly 
   - Work will continue from the last in-progress item

**Example Compact Summary Format**:
```
COMPACT SUMMARY:
Completed: Text Chunking (Tasks 1.1-1.7)
In Progress: Section Detection (Task 1.8)
Pending: Tree-Sitter, Markdown, Integration, Performance tasks
Issues: None currently
Next steps: Complete chunk generation with metadata preservation
```

---

This task document serves as a memory reference for implementation progress. Update status emojis and checkboxes as tasks are completed to maintain continuity across work sessions.