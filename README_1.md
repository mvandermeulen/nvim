# Copy To

All files in this directory are copied to the root of the project when the template is used.

NOTE: I have trimmed the CLAUDE.md and moved content out into other files to make it simpler/lighter.

The following files exist in the `.claude/docs/templates/` directory:
- `global-coding-standards.md` (new file with content moved from CLAUDE.md)
- `project-overview.md` (updated file with Project Structure line updated)

## Using this template

- Copy files from this directory(the `copy/` directory) to the root of your project.
- CLAUDE.md is configured to load these files:
    - `.claude/docs/project-overview.md`
    - `.claude/docs/global-coding-standards.md`

Either remove the lines in CLAUDE.md that reference these files if you do not want to use them, or ensure you copy these files to your project.

- Copy `project-overview.md` from `.claude/docs/templates/` to `.claude/docs/` in your project, replacing the existing file.
    - Update Project Structure Line 43 in project-overview.md
- Copy `global-coding-standards.md` from `.claude/docs/templates/` to `.claude/docs/` in your project, replacing the existing file.


