
# GitHub Issue Management

<github_issue_best_practices>
CRITICAL: All GitHub issues must follow best practices and proper hierarchy. Use GraphQL API for sub-issue creation.

**Required Issue Structure:**
Every issue MUST contain:
1. **User Story** - "As a [user type], I want [functionality] so that [benefit]"
2. **Technical Requirements** - Specific technical details and constraints
3. **Acceptance Criteria** - Clear, testable conditions for completion
4. **Success Metrics** - How success will be measured
5. **Definition of Done** - Checklist of completion requirements

**Additional for Epics:**
- **User Experience** - UX considerations and user journey details

**Issue Hierarchy:**
```
Epic (Large feature/initiative)
├── Feature (Sub-issue of Epic)
│   ├── Task (Sub-issue of Feature, if Feature is complex)
│   └── Task (Sub-issue of Feature, if Feature is complex)
└── Feature (Sub-issue of Epic)
    └── Task (Sub-issue of Feature, if Feature is complex)
```

**Sub-Issue Creation:**
- NEVER use `gh cli` for sub-issues (not yet supported)
- ALWAYS use GraphQL API `addSubIssue` mutation
- Alternative: Create issues with proper labels, then use GraphQL to link as sub-issues

**GraphQL Sub-Issue Example:**
```graphql
mutation AddSubIssue {
  addSubIssue(input: {
    parentIssueId: "parent_issue_node_id"
    subIssueId: "child_issue_node_id"
  }) {
    subIssue {
      id
      title
    }
  }
}
```

**Implementation Workflow:**
1. Create Epic issue with full structure including User Experience section
2. Create Feature issues as sub-issues of Epic using GraphQL
3. If Feature is complex, create Task issues as sub-issues of Feature
4. Link all issues using GraphQL API, not gh cli
5. Ensure all issues follow the required structure template

**Labels for Hierarchy:**
- `epic` - For Epic-level issues
- `feature` - For Feature-level issues  
- `task` - For Task-level issues

RATIONALE: Proper issue structure ensures clear requirements, measurable success criteria, and maintainable project organization. GraphQL API usage ensures correct sub-issue relationships that gh cli cannot yet provide.
</github_issue_best_practices>




