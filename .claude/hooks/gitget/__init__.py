"""
GitGit repository analysis and documentation system.
"""

# Set up namespace imports for cleaner organization
from complexity.gitgit.text_chunker import TextChunker, count_tokens_with_tiktoken, hash_string, SectionHierarchy

# Create 'chunking' namespace
class chunking:
    from complexity.gitgit.text_chunker import TextChunker, count_tokens_with_tiktoken, hash_string, SectionHierarchy

# Create 'parser' namespace
class parser:
    from complexity.gitgit.tree_sitter_utils import (
        extract_code_metadata,
        extract_code_metadata_from_file,
        get_language_by_extension
    )

# Create 'markdown' namespace with placeholders for the missing functions
class markdown:
    @staticmethod
    def parse_markdown(path, repo_link):
        """Placeholder for parse_markdown function"""
        raise NotImplementedError("parse_markdown function not implemented yet")
    
    @staticmethod
    def verify_markdown_parsing(parsed_sections):
        """Placeholder for verify_markdown_parsing function"""
        raise NotImplementedError("verify_markdown_parsing function not implemented yet")

# Import utility components
from complexity.gitgit.utils.error_handler import (
    ErrorHandler,
    ErrorSource,
    ErrorSeverity,
    safe_execute,
    global_error_handler,
)

from complexity.gitgit.utils.json_utils import (
    clean_json_string,
    json_to_markdown
)

# Import logging and workflow components
from complexity.gitgit.utils.enhanced_logger import (
    EnhancedLogger,
    ComponentType,
    LogLevel,
    get_logger,
    safely_execute
)

from complexity.gitgit.utils.workflow_logger import (
    WorkflowLogger,
    track_workflow, 
    track_step
)

# Create 'integration' namespace
class integration:
    from complexity.gitgit.utils.error_handler import (
        ErrorHandler,
        ErrorSource,
        ErrorSeverity,
        safe_execute,
        global_error_handler,
    )
    
    from complexity.gitgit.utils.enhanced_logger import (
        EnhancedLogger,
        ComponentType,
        LogLevel,
        get_logger,
        safely_execute
    )
    
    from complexity.gitgit.utils.workflow_logger import (
        WorkflowLogger,
        track_workflow, 
        track_step
    )
    
    # Feature flags
    HAVE_ERROR_HANDLER = True
    HAVE_ENHANCED_LOGGING = True