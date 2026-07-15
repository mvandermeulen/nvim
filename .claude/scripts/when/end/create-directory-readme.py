#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# ///

import json
import sys
import re
from pathlib import Path
import sys
from subprocess import PIPE, STDOUT, Popen
from signal import signal, SIGALRM, SIG_DFL, SIG_IGN, alarm
from shutil import which
from dataclasses import dataclass, field
from jinja2 import Template
from loguru import logger

__author__ = "Mark van der Meulen"
__status__ = "Testing/Unstable"
__script_name__ = "generate_module_docs"

log_file = Path().home().joinpath('.local', 'logs', 'scripts', f'{__script_name__}.log')
logger.remove()
logger.add(log_file, format="{time} {level} {message}", level="INFO")



def debug_log(status: bool | None, message: str | list[str]) -> bool:
  if status:
    if isinstance(message, list):
      for msg in message:
        logger.info(msg)
    else:
      logger.info(message)
  return True


class Signal(Exception):
  """
  This exception is raise by the signal handler.
  """
  pass


class Timeout(Exception):
  """
  This exception is raised when the command exceeds the defined timeout
  duration and the command is killed.
  """
  def __init__(self, cmd: str, timeout: int):
    super().__init__()
    self.cmd: str = cmd
    self.timeout: int = timeout

  def __str__(self):
    return "Command '%s' timed out after %d second(s)." % \
      (self.cmd, self.timeout)


class Retcode(Exception):
  """
  This exception is raise when a command exits with a non-zero exit status.
  """
  def __init__(self, cmd: str, retcode: int, output: str | None = None):
    super().__init__()
    self.cmd: str = cmd
    self.returncode: int = retcode
    self.output: str = output if output is not None else ""

  def __str__(self):
    return "Command '%s' returned non-zero exit status %d" % \
      (self.cmd, self.returncode)


def alarm_handler(signum, frame):
  raise Signal



def execute(cmd: str, timeout: int | None = None):
  """
  Execute a command in the default shell. If a timeout is defined the command
  will be killed if the timeout is exceeded and an exception will be raised.
  Inputs:
    cmd     (str): Command to execute
    timeout (int): Command timeout in seconds
  Outputs:
    output (str): STDOUT/STDERR
  """
  # Define the timeout signal
  if timeout is not None:
    signal(SIGALRM, alarm_handler)
    _ = alarm(timeout)

  try:
    # Execute the command and wait for the subprocess to terminate
    # STDERR is redirected to STDOUT
    phandle = Popen(cmd, shell=True, stdout=PIPE, stderr=STDOUT)

    # Read the stdout/sterr buffers and retcode
    output, _ = phandle.communicate()
    retcode = phandle.poll()
  except Signal:
    # Kill the running process
    phandle.kill()
    raise Timeout(cmd=cmd, timeout=timeout)
  except:
    raise
  else:
    # Possible race condition where alarm isn't disabled in time
    alarm(0)

  # Raise an exception if the command exited with non-zero exit status
  if retcode:
    raise Retcode(cmd, retcode, output=output)

  return output


def find_binary_location(binary_name):
  """
  Determines the full path to a binary executable.

  Args:
    binary_name: The name of the binary executable (e.g., "python", "ls").

  Returns:
    The full path to the binary if found, otherwise None.
  """
  return which(binary_name)



@dataclass
class UserExecutableConfig:
  name: str
  path: Path = field(init=False)

  def __post_init__(self):
    self.path = Path(which(self.name) or '').resolve()
    if not self.path.exists():
      raise FileNotFoundError(f'Executable {self.name} not found in PATH.')


@dataclass
class UserCommandVars:
  vars: dict[str, str | int | bool | float | None] = field(default_factory=dict)


@dataclass
class UserCommandTemplate:
  name: str
  cmd: str
  description: str = ''
  example: str = ''
  fmt: bool = False
  j2: bool = False
  parse_tmux: bool = False
  auto_parse: bool = False
  auto_fmt: bool = False
  capture_output: bool = False
  timeout: int | None = None

  def __post_init__(self):
    if not self.cmd:
      raise ValueError('Command template cannot be empty.')
    if self.auto_parse and '#{' in self.cmd and '}' in self.cmd:
      self.parse_tmux = True
      # At the moment this is unused. We need to determine the context in which to run the tmux display-message command
      # TODO: implement context detection
    if self.auto_fmt:
      if '{{ ' in self.cmd and '}}' in self.cmd:
        self.j2 = True
        self.fmt = True
      if '#{' in self.cmd and '}' in self.cmd:
        self.fmt = True




@dataclass
class UserCommand:
  bin: str | UserExecutableConfig
  t: dict[str, str | int | bool | float | None] | UserCommandTemplate
  vars: dict[str, str | int | bool | float | None] | UserCommandVars = field(default_factory=dict)
  cmd: str = field(init=False)

  def __post_init__(self):
    if self.vars and isinstance(self.vars, dict):
      self.vars = UserCommandVars(self.vars)
    if not isinstance(self.bin, UserExecutableConfig):
      self.bin = UserExecutableConfig(self.bin)
    if isinstance(self.t, dict):
      self.t = UserCommandTemplate(**self.t)
    if self.t.fmt:
      _v = self.vars.vars.copy()
      _v.update({'bin': str(self.bin.path)})
      if self.t.j2:
        self.cmd = Template(self.t.cmd).render(_v)
      else:
        self.cmd = self.t.cmd.format(**_v)


DIRECTORY_NAME_REGEX = re.compile(r'^(?:.*/)?([^/]+?)/?$')

def get_directory_name_from_path(path: str) -> str | None:
  match = DIRECTORY_NAME_REGEX.match(path)
  if match:
    return match.group(1)
  return None


def generate_directory_tree(path: str, depth: int | None = None) -> str:
  _depth = depth if depth is not None else 1
  try:
    cmd = UserCommand(
      bin=UserExecutableConfig('eza'),
      t={
        'cmd': f'-T -L {_depth} --all --header {path}',
      },
    )
    output = execute(cmd.cmd, timeout=10)
    return output.decode('utf-8').strip()
  except Exception as e:
    logger.error(f"Error generating directory tree: {e}")
    return ""

def get_python_code_content(path: Path | str) -> dict[str, str]:
  # rg -I -t py -d 1 --json --sort path -N "(class|def|async def) (.*)"
  code_contents = {}
  p = Path(path)
  if p.is_dir():
    for file in p.rglob('*.py'):
      try:
        with file.open('r', encoding='utf-8') as f:
          code_contents[str(file.relative_to(p))] = f.read()
      except Exception as e:
        logger.error(f"Error reading file {file}: {e}")
  return code_contents

DIRECTORY_STRUCTURE_TEMPLATE="## Structure\n\n```\n{{ directory_tree }}\n```\n\n"

README_DOC_TEMPLATE="# {{ directory_name }}\n\n"

def get_content_for_readme(path: str) -> str:
  directory_name = get_directory_name_from_path(path) or "Directory"
  directory_tree = generate_directory_tree(path, depth=2)

  readme_content = README_DOC_TEMPLATE.replace("{{ directory_name }}", directory_name)
  structure_content = DIRECTORY_STRUCTURE_TEMPLATE.replace("{{ directory_tree }}", directory_tree)

  return readme_content + structure_content




def main(path: str | None = None):
  if path:
  try:
    input_data = json.load(sys.stdin)

    sys.exit(0)

  except json.JSONDecodeError:
    # Gracefully handle JSON decode errors
    sys.exit(0)
  except Exception:
    # Handle Any other errors gracefully
    sys.exit(0)


if __name__ == "__main__":
  if len(sys.argv) > 1 and sys.argv[1]:
    main(path=sys.argv[1])
  else:
    main()
