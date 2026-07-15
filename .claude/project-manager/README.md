# Project Manager Agent Workspace

This folder contains working files and logs for the project-manager agent, an intelligent documentation maintenance system for high-intensity development workflows.

## Purpose

The project-manager agent automatically updates planning documentation in response to development events, maintaining perfect project continuity without interrupting the development flow.

## Files

### Core Logs

- **maintenance-log.md**: Timestamped log of all agent actions and updates
- **pending-updates.md**: Items flagged for human review with priority levels
- **patterns.md**: Productivity insights, trend analysis, and lessons learned
- **triggers.md**: Event activation log for system tuning and optimization

## Agent Capabilities

### Primary Triggers (Immediate Response)
1. Task Completion - Feature/bug/refactor/optimization marked complete
2. New Task Creation - New backlog or task list items
3. Task Status Change - Priority changes, status updates
4. Blocker Events - Impediments identified or resolved
5. Architectural Decisions - Technical choices, design patterns
6. New Specifications - Requirements or scope changes
7. Context Switches - Focus area changes
8. Milestone Completion - Significant project phases
9. Knowledge Refinement - Assumptions replaced with verified facts

### Response Actions

On task completion, the agent:
1. Updates SESSION_STATE.md (removes completed task, updates progress)
2. Archives completed work to appropriate completed/ subfolder
3. Updates backlogs and reorders remaining tasks
4. Logs patterns and insights in patterns.md

On architectural decisions, the agent:
1. Documents decision in DECISIONS.md with rationale
2. Updates architecture docs if structural changes
3. Flags potential conflicts with previous decisions

## Silent Operations

The agent works silently without interrupting development:
- Document updates and synchronization
- Task archival and organization
- Time estimate refinements
- Pattern recognition and trend analysis
- Context preservation and session logging
- Dependency mapping and task sequencing

## Human Alert Conditions

The agent flags items for human review when:
- Time estimates consistently wrong (>50% off for similar tasks)
- Recurring blockers (same type >3 times without fix)
- Scope creep significantly expanding timeline
- Technical debt causing >30% productivity slowdown
- Architecture conflicts with established patterns
- Velocity degradation over multiple days

## Integration Points

The agent monitors:
- Task completion events from Claude Code
- New specifications or requirements
- Blocker reports and resolutions
- Architectural choices made during development
- Context switches between work areas
- File change monitoring
- Knowledge refinement (assumptions → verified facts)

## Success Metrics

- Zero "where were we?" questions when resuming work
- Time estimates within 20% accuracy
- All significant decisions documented with context
- Clean, searchable, current documentation
- Seamless context preservation across sessions
- Proactive workflow optimization opportunities

## File Management

### Completed Work Archives
Located in `.claude/docs/completed/` with subfolders:
- `features/`: Complete user-facing functionality
- `bugs/`: Fixed defects with root cause analysis
- `refactors/`: Code improvements and restructuring
- `optimizations/`: Performance and efficiency improvements

Each archive includes:
- Completion date and time taken
- Implementation details and commits
- Related files and impact analysis
- Lessons learned and patterns identified

## Version

**Agent Version**: 1.0
**Deployed**: 2025-11-18
**Status**: Active

## Related Documentation

- Planning System: `.claude/docs/PLANNING-SYSTEM.md`
- Filing System: `.claude/docs/FILING-SYSTEM.md`
- Session State: `.claude/docs/planning/SESSION_STATE.md`
- Decisions Log: `.claude/docs/planning/DECISIONS.md`
