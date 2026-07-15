# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**ALWAYS START BY READING**: 
- `.claude/docs/SESSION_START_CHECKLIST.md`
- `.claude/docs/PLANNING-SYSTEM.md`
- `.claude/docs/FILING-SYSTEM.md`
- `.claude/docs/SESSION_MANAGEMENT.md`
- `.claude/docs/TASK_MANAGEMENT.md`
- `.claude/docs/LEARNING.md`

## Task Planning
All task plans must follow the standard structure defined in the Task Plan Guide:

- **Core Principles**: 
  - Detailed task descriptions for consistent understanding
  - Verification-first development approach
  - Version control discipline with frequent commits
  - Human-friendly documentation with usage examples
- **Structure Elements**:
  - Clear objectives and requirements
  - Step-by-step implementation tasks
  - Verification methods for each function
  - Usage tables with examples
  - Version control plan
  - Progress tracking

Refer to the full [Task Plan Guide](.claude/docs/guides/TASK_PLAN_GUIDE.md) for comprehensive details.

## Memory and Planning

- Plan in these phases: clarify -> explore -> plan -> document plan in a `.claude/docs/specs/<task>.md`
- The plan phase should produce a `<task>.md` for me to review and help improve
- Keep the `<task>.md` up-to-date as things change and ensure remove any out-of-date information is removed promptly
- Assume you will need to hand off this plan to a DIFFERENT agent for implementation
- Optimize for the future agent's understanding by including all essential details and omitting everything else
- You have issues with memory formation both during and between conversations. Use your journal to record important facts and insights, as well as things you
  want to remember _before_ you forget them.
- You search your journal when you trying to remember or figure stuff out.
- NEVER pad out your responses with commentary on the quality of the user's questions or ideas. For example, NEVER say "That's an excellent question".
- NEVER praise questions or ideas. For example, NEVER say "You're absolutely right".
- NEVER use exclamation points.
- YOU MUST use the journal tool frequently to capture technical insights, failed approaches, and user preferences
- Before starting complex tasks, search the journal for relevant past experiences and lessons learned
- Document architectural decisions and their outcomes for future reference
- Track patterns in user feedback to improve collaboration over time
- When you notice something that should be fixed but is unrelated to your current task, document it in your journal rather than fixing it immediately
- Review: `.claude/docs/FILING-SYSTEM.md`
- Review: `.claude/docs/TASK_MANAGEMENT.md`
- Review: `.claude/docs/SESSION_MANAGEMENT.md`
- Review: `.claude/docs/guides/session-management.md`


## First-Time Setup

On first use in any repository, run:

```bash
zsh .claude/hooks/setup.sh
```

This script:
- Verifies Redis is running
- Applies all pending database migrations to `.rhino/share/hooks.db`

## Managing your context window

- You do best thinking when you have less in your context rather than more
- Minimize your context usage by delegating tasks that are straight-forward to describe and report back about but may require lots of exploration to complete to ephemeral Task agents you create
- Ensure any agents you delegate to know exactly what you want them to report back, and what details to include
- Update the `<task>.md` with any helpful findings

