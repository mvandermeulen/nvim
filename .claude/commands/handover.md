---
name: handover
description: Prepare a clean cross-session handover so the next agent (or you tomorrow) can pick up exactly where you left off. Writes a focused `continue.md` and `handover-YYYY-MM-DD-HH-MM-SS.md`
---

<objective>
Leave the project in a state where a fresh agent with no memory of this session can read two or three files and be productive within one minute. The deliverables are `continue-YYYY-MM-DD-HH-MM-SS.md` and `handover-YYYY-MM-DD-HH-MM-SS.md` in the session/handover/ directory plus up-to-date summary artifacts — not a chat recap.
</objective>

<core_principle>
**WRITE FOR A STRANGER.** The next reader is not you. They do not have this conversation. They have `handover-YYYY-MM-DD-HH-MM-SS.md`, `continue-YYYY-MM-DD-HH-MM-SS.md` and the code. That has to be enough.

**CURRENT STATE ONLY.** `continue-YYYY-MM-DD-HH-MM-SS.md` is ephemeral — it says "pick up HERE." It is not a log of what you did; that goes in summaries. It is not a plan for future work; that lives in the plan files.

**NO SECRETS, NO STALE PATHS.** Do not inline env values, tokens, or paths that only exist in your working directory. Cite artifacts by relative path from the project root.
</core_principle>


# Handover Command

Use this command to generate a session handover document when transferring work to another team member or continuing work in a new session.

## Usage

```
/handover [optional-notes]
```

## Description

This command generates a comprehensive handover document that includes:

- Current session health status
- Task progress and todos
- Technical context and working files
- Instructions for resuming work
- Any blockers or important notes

## Example

```
/handover Working on authentication refactor, need to complete OAuth integration
```

## Output Location

The handover document MUST be saved to:
- **Primary Location**: `{{HOME_TOOL_DIR}}/session/handover/handover-{{TIMESTAMP}}.md`

The path to the handover file MUST also be saved to:
- **File Pointer Location**: `{{HOME_TOOL_DIR}}/session/last-handover.md`

## File Naming Convention

Use this format: `handover-YYYY-MM-DD-HH-MM-SS.md` `continue-YYYY-MM-DD-HH-MM-SS.md`

Example: `handover-2024-01-15-14-30-45.md`
Example: `continue-2024-01-15-14-30-45.md`

## Implementation

1. Generate handover using `{{HOME_TOOL_DIR}}/templates/handover-template.md`
2. Replace all `{{VARIABLE}}` placeholders with actual values
3. Save to the specified location
4. Display the full file path to the user for reference

The handover document will be saved as a markdown file and can be used to seamlessly continue work in a new session.

Create `{{HOME_TOOL_DIR}}/session/handover/continue-{{TIMESTAMP}}.md` with the following shape. Keep it tight — one screenful max.

```markdown
# Continue — S02 / T03

## Last action

<one sentence — what you just did, with evidence>
Example: "Ran `npm test` after editing `src/auth/session.ts`; 2 failures in `session.test.ts` — both complain about a missing `expiresAt` field in the mock fixture."

## Next action

<one concrete action the next agent should take>
Example: "Update `fixtures/sessions.ts` to include `expiresAt: Date.now() + 3600_000` on every fixture, then re-run `npm test`."

## Why

<one or two sentences — why this next step, not something else>
Example: "The session refactor moved `expiresAt` from optional to required in `Session`; fixtures were never updated."

## Open threads

<list of things you noticed but deliberately didn't act on>
- Validator in `src/auth/validator.ts` still accepts unbounded session lengths — file as a separate issue after T03 lands.

## Do not

<traps and false paths the next agent might stumble into>
- Do NOT revert the `Session` interface change — it's required for T04.
- Do NOT run `npm run db:reset` in this branch; dev data is still needed for manual UAT.
```

### Sanity check

Read `handover-YYYY-MM-DD-HH-MM-SS.md` + `continue-YYYY-MM-DD-HH-MM-SS.md`. Ask:
1. Do I know what to do next?
2. Do I know why?
3. Do I know what not to do?

If any answer is no, the handoff is incomplete. Fix it before stopping.


<anti_patterns>

- **Chat-log handoffs.** "First I did X, then Y, then Z…" The next agent doesn't need the journey.
- **`continue-YYYY-MM-DD-HH-MM-SS.md` that summarizes all changes.** 
- **No "Next action".** A handoff without a concrete next action is a journal entry.
- **Implicit assumptions.** "Obviously the next thing is…" — write it down.
- **Leaving background processes running.** They'll be orphaned when the session ends.
- **Handoff without updating summaries.** `continue-YYYY-MM-DD-HH-MM-SS.md` should be thin because the summaries carry the weight.

</anti_patterns>

<success_criteria>

- [ ] `handover-YYYY-MM-DD-HH-MM-SS.md` exists in the handover directory.
- [ ] `continue-YYYY-MM-DD-HH-MM-SS.md` exists in the handover directory.
- [ ] The "Next action" is concrete and executable without this session's context.
- [ ] Background processes are not orphaned.
- [ ] A cold-read of `handover-YYYY-MM-DD-HH-MM-SS.md` + `continue-YYYY-MM-DD-HH-MM-SS.md` would produce the right next action.

</success_criteria>

