# ZSH Style Guide

## Overview

### General Guidelines

- Honour the script or library's existing ZSH conventions and style.
- **General:**
  - End statements with a semicolon by default.
  - Always use `$(command)` instead of backticks.
  - Use blank lines between blocks to improve readability.
- **Indentation:**
  - Use exactly two spaces for blocks (like functions, `if`, `for`, `while`).
  - Avoid hard tabs entirely.
  - Indentation is always a maximum of two spaces. Whatever you do, don't use tabs.
  - For existing files, stay faithful to the existing indentation.
- **Limit Calls**
  - Use ZSH regular expressions rather than outsourcing to grep or other binaries.

### Conditionals

- Always use double bracket conditionals, never single.
- **Control Structures:**
  - Put `; do` and `; then` on the same line as the `while`, `for` or `if`.
  - Prefer `[[ ! -n "${RESULT}" ]] && { action; }` to if-else blocks.

### Variables

- When defining variable values, enclose in double quotes unless defining an integer.
- Always use braces to access variables (ie. `"${var}"` is good, `"$var"` is not).
- **Scope:**
  - Make variables local inside functions using `local var_name` to prevent bleeding into the global shell scope.
  - When you declare a variable that is meant to be read-only, make this explicit.
    - Use `readonly` or `declare -r` to ensure.
- **Naming:**
  - Use lowercase or snake_case for standard variables.
  - Variable names should not clobber command names, such as `dir` or `pwd`.
  - Reserve ALL_UPPERCASE specifically for constants, exported environment variables and globals.
- **Error Handling:**
  - As globals are widely used in shell, it's important to catch errors when working with them.

### Files

#### Looping through files

Loop through file contents:
```zsh
for line in "${(f)@:-$(<list.txt)}"; do echo "Item: ${line}"; done
```

**Crucial Syntax Distinctions**
Be careful not to confuse this syntax with other similar-looking shell operations:
- `**$(command)**`: Runs an executable command and returns its standard output.
- `**<(command)**`: Process substitution. It executes a command and generates a temporary named pipe file descriptor passed as an argument.
- `**=(command)**`: A specialized Zsh-only process substitution that forces the shell to output to a temporary physical file instead of a pipe.


---

### Serializing Data

```zsh
declare -A hsh deserialized; hsh=( key value )
serialized="${(j::)${(qkv@)hsh}}"
deserialized=( "${(Q@)${(z@)serialized}}" )
print ${(kv)deserialized} ▶ key value
```

- `j`-flag means join -- by spaces, in this case.
- Flags `kv` mean: keys and values, interleaving.
- Important `q`-flag means: quote. So what is obtained is each key and value quoted,
  and put into a string separated by spaces.
- `z`-flag means: split as if Zsh parser would split. So quoting (with backslashes,
  double quoting, and others) is recognized. Obtained is array `( "key" "value")` which
  is then de-quoted with:
- `Q`-flag. This yields original data, assigned to hash `deserialized`. Use this to
  e.g. implement an array of hashes.

Note: to be compatible with `setopt ksharrays`, use `[@]` instead of `(@)`, e.g.: `...( "${(Q)${(z)serialized[@]}[@]}" )`


---

### Symbolic Links and Directory Names

Symbolic links can be turned into an absolute path with:

```zsh
localabsolute_path="${PWD:A}";
```

You can skip the use of `dirname` and `basename` with:

```zsh
local dirname="${PWD:h}";
local basename="${PWD:t}";
```

### Command Execution

#### Environment Variables

When possible, use environment variables instead of shelling out to a command.

- ❌   `$(pwd)`
- ✅   `"${PWD}"`

#### Pipelines

If a pipeline all fits on one line, it should be on one line.

Example (good, fits on one line):
```zsh
command1 | command2
```

Example (bad, doesn't fit on one line):
```zsh
command1 "arg1" "arg2" | command2 "arg1" "arg2" | command3 "arg1" "arg2" | command4 "arg1" "arg2" | command5 "arg1" "arg2" | command6 | command7
```

If the combined command string doesn't fit on one line, then:
- It should be split at one pipe segment per line with the pipe on the newline and
  a 2 space indent for the next section of the pipe.
- This applies to a chain of commands combined using '|' (pipelines) as well as to
  logical compounds using '||' and '&&'.

Example (good, split across multiple lines, pipe on newline, 2 space indent for next section):
```zsh
command1 \
  | command2 "arg1" "arg2" \
  | command3 "arg1" "arg2" "arg3" "arg4" \
  | command4
```

#### Process Substitution

Leverage process substitution `<(command)` and `>(command)` to pass the output of
commands as input streams or arguments to other commands. This is especially useful
for complex command pipelines.

```zsh
diff<(sortfile1)<(sortfile2)
```

#### Command Substitution

Utilize command substitution `$(command)` to capture the output of commands and use
them as arguments or assignments within scripts. Never use backticks for command
substitution.

```zsh
file_size=$(wc-c<"${file}")
```

#### Eval

Eval is evil! Eval munges the input when used for assignment to variables and can
set variables without making it possible to check what those variables were.

Therefore: Avoid `eval` if possible.

### Structure

- **Functions:**
  - Declare functions cleanly using the `function name()` format, never just `name()`.
  - Document functions with a description, arguments, and return value.
  - Naming: Lower-case, with underscores to separate words.
  - Parentheses are required after the function name.
  - The opening brace should appear on the same line as the function name.
  - Private or utility functions should be prefixed with an underscore.

Example (good):
```zsh
function _private_helper_util()  {
  ...
}
```

#### Return Values

After a script or function terminates, a `$?` from the command line gives the exit
status of the script, that is, the exit status of the last command executed in the
script, which is, by convention, 0 on success or an integer in the range 1 - 255 on
error.

- Always check return values and give informative error messages.
- For unpiped commands, use `$?` or check directly via an if statement to keep it simple.
- Use nonzero return values to indicate errors.

Bad Examples:
```zsh

mv "${file_list}" "${dest_dir}/";

my_bad_func() {
  for port in $(seq 32768 61000); do
    for i in $(netstat_used_local_ports); do
      if [[ $used_port -eq $port ]]; then
        continue;
      else
        echo $port;
      fi
    done;
  done;
}
```

Good Examples:
```zsh
function my_good_func() {
  # didn't work with zsh / bash is ok
  #read lowerPort upperPort < /proc/sys/net/ipv4/ip_local_port_range

  for port in $(seq 32768 61000); do
    for i in $(netstat_used_local_ports); do
      if [[ $used_port -eq $port ]]; then
        continue;
      else
        echo $port;
        return 0;
      fi
    done
  done

  return 1;
}

mv "${file_list}" "${dest_dir}/" || exit 1;

if ! mv "${file_list}" "${dest_dir}/"; then
  echo "Unable to move ${file_list} to ${dest_dir}" >&2;
  exit 1;
fi

mv "${file_list}" "${dest_dir}/";
[[ $? -ne 0 ]] && {
  echo "Unable to move ${file_list} to ${dest_dir}" >&2;
  exit 1;
}

```

#### Preferred Script Layout

From top to bottom:

- Setup and initialization
  - Define constants and environment variables
  - Load libraries and function files
- Define global variables
- Function definitions
  - Use a `main()` function to encapsulate the main logic of the script
- Main execution block
  - Parse command-line arguments and;
  - Call the `main()` function at the end of the script


---

### Writing a new script

When writing a new script, start with the following template to ensure consistency and maintainability:

```zsh
#!/usr/bin/env zsh

PREVIOUS_SCRIPT_NAME="${SCRIPT_NAME:-zsh}"; export SCRIPT_NAME="${0:A:t}";
SCRIPT_DIRECTORY="${0:a:h}"; ALT_SCRIPT_DIRECTORY="$(dirname $0:A)";

# Usage: example.sh [--session-preview <session_name>] [--cwd <path>] <file_or_directory>
#######################################
# Libraries
[[ -n "${LFS}" ]] || source "${HOME}/.zshenv";
[[ -n "$functions[load_function_files]" ]] || {
  source "${LFS}" || _log_failed_to_source "${SCRIPT_NAME}" "${LFS}";
}
typeset -A ExampleLoadFiles;
for item in "log" "util" "tmux"; do
  [[ -n "$functions[${Ffn[${item}]}]" ]] || ExampleLoadFiles[${item}]="${item}";
done
[[ ${#ExampleLoadFiles} -gt 0 ]] && {
  load_function_files "ExampleLoadFiles" || _log_zsh_event "fatal" "Failed to load function files for ${SCRIPT_NAME}";
}
```

- The for loop above is used to load function files for the script. It checks if the
  functions are already loaded, and if not, it adds them to the `ExampleLoadFiles` associative
  array.
  - Use this loop pattern to load function files for your script. Replace the items
    in the loop with the prefix of the function files you want to load. Function files
    are located in `functions/shared`.
  - Replace `ExampleLoadFiles` with a descriptive name for your script's function files.
  - After the loop, it checks if there are any files to load and calls `load_function_files`
    to load them. If loading fails, it logs a fatal error.
- Where parts of your script logic are reusable, consider moving them into an appropriate
  function file in `functions/shared`. This promotes code reuse and maintainability.



---


