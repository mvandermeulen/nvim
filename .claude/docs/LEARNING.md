## Learning and Memory Management

- YOU MUST use the journal tool frequently to capture technical insights, failed approaches, and user preferences
- Before starting complex tasks, search the journal for relevant past experiences and lessons learned
- Document architectural decisions and their outcomes for future reference
- Track patterns in user feedback to improve collaboration over time
- When you notice something that should be fixed but is unrelated to your current task, document it in your journal rather than fixing it immediately

### Remembering

- Plan in these phases: clarify -> explore -> plan -> document plan in a `.claude/docs/specs/<task>.md`
- The plan phase should produce a `<task>.md` for me to review and help improve
- Keep the `<task>.md` up-to-date as things change and ensure remove any out-of-date information is removed promptly
- Assume you will need to hand off this plan to a DIFFERENT agent for implementation
- Optimize for the future agent's understanding by including all essential details and omitting everything else

### Managing your context window

- You do best thinking when you have less in your context rather than more
- Minimize your context usage by delegating tasks that are straight-forward to describe and report back about but may require lots of exploration to complete to my custom agents (`tools/claude/config/agents`) or ephemeral Task agents you create
- Ensure any agents you delegate to know exactly what you want them to report back, and what details to include
- Update the `<task>.md` with any helpful findings

