# Session Start Checklist

**Purpose**: Ensure all required processes are followed from the beginning of each session.

---

## ✅ Every Session Start (Before Any Work)

### 1. Health Check
- [ ] Run `<Health-Check>` to verify session state
- [ ] Note message count and health status
- [ ] Plan handover points if health is 🟡 or 🔴

### 2. Load Session Context
- [ ] Read `.claude/session/current-session.yaml`
- [ ] Understand current task, phase, and progress
- [ ] Review pending todos

### 3. Review Planning System
- [ ] Check `.claude/docs/planning/README.md` (if exists)
- [ ] Review SESSION_STATE.md for current work
- [ ] Understand active backlogs

### 4. Check Documentation Requirements
- [ ] Review FILING-SYSTEM.md for current project
- [ ] Identify if planning docs needed
- [ ] Check for existing doc numbering sequence

---

## ✅ When Starting New Feature/Task

### 1. Create Planning Documentation First
- [ ] Determine next sequence number (ls plans/ | sort | tail -1)
- [ ] Identify phase: DEBUG, CLEAN, ENT, FIX, TEST, FEAT, SEC, DEV
- [ ] Create `####-PHASE-MMDDYY-DESCRIPTION.md`
- [ ] Document objectives, scope, and planned phases
- [ ] Update as work progresses, not after completion

### 2. Update Session State
- [ ] Set task title and scope (MICRO/SMALL/MEDIUM/LARGE/EPIC)
- [ ] Link to planning doc
- [ ] Initialize todos with planned phases

### 3. Plan with Handover in Mind
- [ ] Break EPIC tasks into session-sized chunks
- [ ] Identify natural breakpoints for handover
- [ ] Plan for phases that can be independently committed

---

## ✅ During Work (Every Major Milestone)

### 1. Update Session State
- [ ] Move completed todos to completed list
- [ ] Update progress percentage
- [ ] Note architectural decisions with rationale
- [ ] Update message count estimate

### 2. Commit Early and Often
- [ ] Commit after each logical phase completion
- [ ] Use conventional commit format
- [ ] Reference planning doc in commits if applicable

### 3. Trigger Project-Manager
- [ ] After completing tasks (update SESSION_STATE, archive)
- [ ] When making architectural decisions (update DECISIONS.md)
- [ ] When reaching milestones (archive phase, update overview)

---

## ✅ Before Completing Session

### 1. Finalize Documentation
- [ ] Update planning doc with completion status
- [ ] Mark completed phases with ✅
- [ ] Document any known issues or blockers
- [ ] Note next steps clearly

### 2. Update Session State
- [ ] Ensure all completed todos marked
- [ ] Update progress percentage
- [ ] Add notes about what was learned
- [ ] Update health status

### 3. Prepare for Handover (if needed)
- [ ] Complete logical unit of work
- [ ] Ensure all commits pushed
- [ ] Update todos with clear next steps
- [ ] Run `<Handover01>` if health is 🟡 or 🔴

---

## ✅ Preventive Measures for Process Adherence

### Self-Check Questions
Before marking any phase "complete":
1. Have I updated session state?
2. Have I updated planning doc?
3. Have I committed this phase?
4. Have I triggered project-manager?
5. Are todos accurately reflecting current state?

### Red Flags to Watch For
- ⚠️ Committing without updating documentation
- ⚠️ Completing multiple phases before updating session state
- ⚠️ Planning without creating planning doc first
- ⚠️ Ignoring pending todos in plan
- ⚠️ Not breaking EPIC tasks into manageable chunks

### Automation Opportunities
- Consider pre-commit hook to verify session state updated
- Consider reminder at message count milestones (30, 45, 60)
- Consider template for planning docs to speed creation

---

## Quick Reference: Key Files


| File | Purpose | Update When |
|------|---------|-------------|
| `.claude/session/current-session.yaml` | Session tracking | Start, every milestone, end |
| `.claude/docs/plans/####-*.md` | Feature documentation | Create at start, update throughout |
| `.claude/docs/planning/SESSION_STATE.md` | Planning system state | Via project-manager agent |
| TodoWrite tool | In-conversation tracking | Real-time as you work |

---

**Principle**: Documentation and process adherence should happen **throughout** the work, not as an afterthought.

**Last Updated**: 2025-10-13
**Status**: ✅ ACTIVE
