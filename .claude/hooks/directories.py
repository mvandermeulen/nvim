"""
Robust Hook Receiver and Management System

Directories Script
"""

from pathlib import Path
import sys






def get_log_path() -> tuple[Path, Path, Path]:
  """
  Determine log file path based on input data
  """
  id = input_data.get('cwd', os.getenv('CLAUDE_PROJECT_DIR'))
  if not id:
    if 'session_id' in input_data:
      id = input_data['session_id']
    else:
      id = f"unknown_{int(time())}"
  else:
    id = Path(id).name

  repo_dir, claude_dir = get_claude_and_repo_directories()
  rhino_share_dir = repo_dir.joinpath('.rhino', 'share')
  rhino_logs_dir = rhino_share_dir.joinpath('logs')
  rhino_logs_dir.mkdir(parents=True, exist_ok=True)
  log_path = rhino_logs_dir.joinpath(id, get_log_file_name())
  log_path.parent.mkdir(parents=True, exist_ok=True)
  return rhino_share_dir, rhino_logs_dir, log_path



class Directories:
  """
  Class to manage directory paths for the hook system.
  """

  def __init__(self):
    self.home: Path = Path.home()
    self.claude: Path = self.get_claude_directory()
    self.repo: Path = self.get_repo_directory()
    self.hooks: Path = self.get_claude_hooks_directory()
    if str(self.hooks) not in sys.path:
      sys.path.insert(0, str(self.hooks))
    self.rhino: dict[str, Path] = {}
    self.rhino['share'], self.rhino['logs'], self.rhino['state'] = self.get_rhino_directories()
    self.scripts: Path = self.get_claude_scripts_directory()
    self.docs: Path = self.get_claude_docs_directory()
    self.session: Path = self.get_claude_session_directory()
    self.planning: Path = self.get_claude_planning_directory()
    self.plans: Path = self.get_claude_plans_directory()
    self.specs: Path = self.get_claude_specs_directory()
    self.adrs: Path = self.get_claude_adr_directory()
    self.handover: Path = self.get_claude_handover_directory()
    self.db_path: Path = self.get_db_path()
    self.state_files: dict[str, Path] = {}
    self.state_files['current'], self.state_files['legacy'] = self.get_state_files()
    self.decisions_file: Path = self.get_decisions_file()
    self.current_session_file: Path = self.get_current_session_file()
    self.session_state_file: Path = self.get_session_state_file()
    self.message_count_file: Path = self.get_session_message_count_file()
    self.resume_context_file: Path = self.get_session_resume_context_file()


  def get_claude_directory(self) -> Path:
    """
    Find the .claude directory in the path hierarchy
    """
    claude_dir = Path(__file__).parent
    while claude_dir.name != '.claude':
      if claude_dir == self.home:
        raise RuntimeError("Could not find .claude directory in path hierarchy")
      claude_dir = claude_dir.parent
    return claude_dir


  def get_claude_hooks_directory(self) -> Path:
    """
    Find the .claude/hooks directory in the path hierarchy
    """
    hooks_dir = self.claude.joinpath('hooks')
    if not hooks_dir.exists():
      raise RuntimeError("Could not find hooks directory in .claude!")
    return hooks_dir


  def get_claude_scripts_directory(self) -> Path:
    """
    Find the .claude/scripts directory in the path hierarchy
    """
    scripts_dir = self.claude.joinpath('scripts')
    if not scripts_dir.exists():
      raise RuntimeError("Could not find scripts directory in .claude!")
    return scripts_dir


  def get_claude_docs_directory(self) -> Path:
    """
    Find the .claude/docs directory in the path hierarchy
    """
    docs_dir = self.claude.joinpath('docs')
    if not docs_dir.exists():
      docs_dir.mkdir(parents=True, exist_ok=True)
    return docs_dir


  def get_claude_session_directory(self) -> Path:
    """
    Find the .claude/session directory in the path hierarchy
    """
    session_dir = self.claude.joinpath('session')
    if not session_dir.exists():
      session_dir.mkdir(parents=True, exist_ok=True)
    return session_dir


  def get_claude_planning_directory(self) -> Path:
    """
    Find the .claude/docs/planning directory
    """
    planning_dir = self.get_claude_docs_directory().joinpath('planning')
    if not planning_dir.exists():
      planning_dir.mkdir(parents=True, exist_ok=True)
    return planning_dir


  def get_claude_plans_directory(self) -> Path:
    """
    Find the .claude/docs/plans directory
    """
    plans_dir = self.get_claude_docs_directory().joinpath('plans')
    if not plans_dir.exists():
      plans_dir.mkdir(parents=True, exist_ok=True)
    return plans_dir


  def get_claude_specs_directory(self) -> Path:
    """
    Find the .claude/docs/specs directory
    """
    specs_dir = self.get_claude_docs_directory().joinpath('specs')
    if not specs_dir.exists():
      specs_dir.mkdir(parents=True, exist_ok=True)
    return specs_dir


  def get_claude_adr_directory(self) -> Path:
    """
    Find the .claude/docs/adrs directory
    """
    adrs_dir = self.get_claude_docs_directory().joinpath('adrs')
    if not adrs_dir.exists():
      adrs_dir.mkdir(parents=True, exist_ok=True)
    return adrs_dir


  def get_claude_handover_directory(self) -> Path:
    """
    Find the .claude/session/handover directory
    """
    handover_dir = self.get_claude_session_directory().joinpath('handover')
    if not handover_dir.exists():
      handover_dir.mkdir(parents=True, exist_ok=True)
    return handover_dir


  def get_repo_directory(self) -> Path:
    """
    Find the repository root directory and .claude directory
    """
    repo_dir = self.claude.parent
    if not repo_dir.joinpath('.git').exists():
      raise RuntimeError("Could not find .git directory in root!")
    return repo_dir


  def get_rhino_directories(self) -> tuple[Path, Path, Path]:
    """
    Find the rhino share,logs,state directories
    """
    rhino_dir = self.get_repo_directory().joinpath('.rhino')
    share_dir = rhino_dir.joinpath('share')
    logs_dir = share_dir.joinpath('logs')
    state_dir = logs_dir.joinpath('state')
    if not state_dir.exists():
      state_dir.mkdir(parents=True, exist_ok=True)
    return share_dir, logs_dir, state_dir


  def get_db_path(self) -> Path:
    """
    Get the database path
    """
    if not 'share' in self.rhino:
      self.rhino['share'], self.rhino['logs'], self.rhino['state'] = self.get_rhino_directories()
    return self.rhino['share'].joinpath('hooks.db')


  def get_state_files(self) -> tuple[Path, Path]:
    """
    Get the current and legacy state file paths
    """
    if not 'state' in self.rhino:
      self.rhino['share'], self.rhino['logs'], self.rhino['state'] = self.get_rhino_directories()
    current_state_file = self.rhino['state'].joinpath('current.json')
    legacy_state_file = self.rhino['state'].joinpath('research-workflow-state.json')
    return current_state_file, legacy_state_file


  def get_decisions_file(self) -> Path:
    """
    Get the DECISIONS.md file path
    """
    return self.get_claude_planning_directory().joinpath('DECISIONS.md')


  def get_current_session_file(self) -> Path:
    """
    Get the current-session.yaml file path
    """
    return self.get_claude_session_directory().joinpath('current-session.yaml')


  def get_session_state_file(self) -> Path:
    """
    Get the SESSION_STATE.md file path
    """
    return self.get_claude_planning_directory().joinpath('SESSION_STATE.md')


  def get_session_message_count_file(self) -> Path:
    """
    Get the .message_count file path
    """
    return self.get_claude_session_directory().joinpath('.message_count')


  def get_session_resume_context_file(self) -> Path:
    """
    Get the resume-context.md file path
    """
    return self.get_claude_session_directory().joinpath('resume-context.md')



DIRECTORIES: Directories = Directories()


