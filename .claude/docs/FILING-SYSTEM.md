# FILING SYSTEM - Mark's Project Documentation Standards

**Date Created**: 2025-10-12
**Last Updated**: 2025-10-12
**Status**: ✅ ACTIVE STANDARD

---

## Purpose

This document defines the universal filing system for all project documentation across Mark's workspace. This system ensures consistency, easy navigation, and clear organization across all projects and AI development sessions.

---

## Core Principles

1. **Numbered Sequential Ordering**: All documents and folders use sequential numbers (00, 01, 02, etc.) for natural sorting
2. **Feature-Based Grouping**: Related documents (PRDs, tasks, ADRs) grouped together in feature folders
3. **Chronological Tracking**: Docs numbered chronologically (0001, 0002, etc.) with dates
4. **Never Reset Numbering**: Numbers always increment, never restart
5. **Clear Descriptive Names**: Folder and file names clearly describe content

---

## Directory Structure Standards

### Project Root Structure

```
project-name/
├── .claude/docs/plans/                     # Chronological reports
│   ├── 0001-PHASE-MMDDYY-DESCRIPTION.md
│   ├── 0002-PHASE-MMDDYY-DESCRIPTION.md
│   ├── ...
│   ├── 00-feature-name/                    # Feature-specific docs grouped
│   ├── 01-feature-name/
│   └── 02-feature-name/
├── docs/                                   # General documentation
└── .archive/                                # Old/deprecated files
```

---

## Docs Numbering System

### Format: `####-PHASE-MMDDYY-DESCRIPTION.md`

**Components**:
- **####**: 4-digit sequential number (0001-9999)
- **PHASE**: Work phase identifier
- **MMDDYY**: Date work performed (092724, 092825, etc.)
- **DESCRIPTION**: Clear description in CAPS-WITH-DASHES

**Phase Identifiers**:
- **DEBUG**: Initial problem diagnosis and fixes
- **CLEAN**: Infrastructure cleanup and optimization
- **ENT**: Enterprise finalization and production deployment
- **FIX**: Specific bug fixes and patches
- **TEST**: Testing documentation and results
- **FEAT**: New feature development
- **SEC**: Security implementations and audits
- **DEV**: Development planning and PRDs

**Examples**:
```
0001-DEBUG-092424-CLEANUP_PLAN.md
0027-ENT-092525-FRONTEND_FIX_PROOF.md
0076-FIX-092725-SIGNED-URL-DELIVERY.md
0079-ENT-092727-AI-PROMPTS-AND-TEMPLATES.md
```

**Rules**:
1. Always use next sequential number (check highest existing first)
2. Phase must match work type being performed
3. Date must be actual work date in MMDDYY format
4. Description must be specific and clear
5. NEVER skip numbers or reuse numbers

---

## Feature-Based Document Organization

### Feature Folder Structure

```
plans/
├── 00-feature-name/
│   ├── 00-prd-featureName.md           # Product Requirements Doc
│   ├── 00-tasks-featureName.md         # Task breakdown
│   └── 00-adr-featureName.md           # Architecture Decision Record
├── 01-next-feature/
│   ├── 01-prd-nextFeature.md
│   ├── 01-tasks-nextFeature.md
│   └── 01-adr-nextFeature.md
```

**Naming Convention**:
- **Folder**: `##-feature-name/` (lowercase with dashes)
- **PRD**: `##-prd-featureName.md` (camelCase feature name)
- **Tasks**: `##-tasks-featureName.md` (camelCase, no "prd" in filename)
- **ADR**: `##-adr-featureName.md` (lowercase "adr", camelCase feature name)

**Benefits**:
- All related docs in one folder
- No flipping between PRD/tasks/ADR directories
- Natural alphabetical sorting by number
- Easy to find all docs for a feature

---

## Document Type Definitions

### PRD (Product Requirements Document)
**Purpose**: Define what needs to be built and why
**Naming**: `##-prd-featureName.md` (camelCase)
**Contains**:
- Business objectives
- User stories
- Technical requirements
- Success criteria
- Dependencies

### Tasks (Task Breakdown)
**Purpose**: Step-by-step implementation plan
**Naming**: `##-tasks-featureName.md` (camelCase, no "prd")
**Contains**:
- Numbered task list
- Time estimates
- Dependencies between tasks
- Acceptance criteria
- Testing requirements

### ADR (Architecture Decision Record)
**Purpose**: Document architectural decisions and rationale
**Naming**: `##-adr-featureName.md` (lowercase "adr", camelCase feature)
**Contains**:
- Decision context
- Options considered
- Decision made
- Rationale
- Consequences

---

## Real-World Examples

### DiagnosticPro Platform Structure

```
DiagnosticPro/
├── .claude/docs/plans/
│   ├── 0001-DEBUG-092424-CLEANUP_PLAN.md
│   ├── 0076-FIX-092725-SIGNED-URL-DELIVERY.md
│   ├── 0078-ENT-092727-BUY-BUTTON-INTEGRATION.md
│   ├── 0079-ENT-092727-AI-PROMPTS-AND-TEMPLATES.md
│   ├── 0080-DEV-092727-ONGOING-IMPROVEMENTS.md
│   ├── 00-platform-migration/
│   │   ├── 00-prd-platformMigration.md
│   │   ├── 00-tasks-platformMigration.md
│   │   └── 00-adr-platformMigration.md
│   ├── 01-storage-infrastructure/
│   │   ├── 01-prd-storageInfrastructure.md
│   │   ├── 01-tasks-storageInfrastructure.md
│   │   └── 01-adr-storageInfrastructure.md
│   ├── 02-ai-api-integration/
│   │   ├── 02-prd-aiApiIntegration.md
│   │   ├── 02-tasks-aiApiIntegration.md
│   │   └── 02-adr-aiApiIntegration.md
│   ├── 03-file-upload/
│   │   ├── 03-prd-fileUpload.md
│   │   └── 03-tasks-fileUpload.md
│   └── ... (04-08 continue)
```

---

## Workflow: Creating New Documents

### For Reports
1. Check highest number: `ls ./claude/docs/plans/ | sort | tail -1`
2. Increment by 1: If last is 0079, next is 0080
3. Identify phase: DEBUG, CLEAN, ENT, FIX, TEST, FEAT, SEC, DEV
4. Use current date: MMDDYY format
5. Create descriptive name: CAPS-WITH-DASHES
6. Format: `0080-PHASE-MMDDYY-DESCRIPTION.md`

### For Feature Development
1. Determine next feature number: Check existing folders
2. Create folder: `mkdir ##-feature-name/` (dashes in folder name)
3. Create PRD: `##-prd-featureName.md` (camelCase in filename)
4. Create tasks: `##-tasks-featureName.md` (camelCase, no "prd")
5. Create ADR (if needed): `##-adr-featureName.md` (lowercase "adr", camelCase)

---

## File Naming Conventions

### General Rules
- **Folders**: Use lowercase with dashes: `feature-name/`
- **Files**: Use camelCase for feature names: `prd-featureName.md`
- **Document types**: All lowercase: `prd`, `tasks`, `adr` (not ADR)
- **Numbers always first**: `03-file-upload/` not `file-upload-03/`
- **Be specific**: `AI-PROMPTS-AND-TEMPLATES` not `AI-STUFF`
- **Tasks**: No "prd" in filename: `tasks-featureName.md` not `tasks-prd-featureName.md`

### Date Formats
- **File names**: MMDDYY (092727, 092825)
- **Inside documents**: YYYY-MM-DD (2025-09-27)
- **Timestamps**: ISO 8601 (2025-09-27T21:45:00Z)

### Capitalization
- **Docs**: CAPS-WITH-DASHES
- **Feature folders**: lowercase-with-dashes
- **Feature files**: camelCase for feature names (`prd-featureName.md`)
- **Document types**: lowercase (`prd`, `tasks`, `adr`)
- **Phase identifiers**: CAPS (DEBUG, ENT, FIX)

---

## Archive Strategy

### When to Archive
- Project completed or deprecated
- Major version transition
- Documentation superseded by new approach
- Cleanup of outdated files

### Archive Structure
```
.archive/
├── cleanup-YYYY-MM-DD-description/
│   └── [archived files]
├── backups-YYYY-MM/
│   └── [backup files]
└── deprecated-feature-name/
    └── [old feature docs]
```

### Archive Naming
- Include date: `cleanup-2025-09-24-mess/`
- Include description: `backups-2025-09/`
- Never delete: Move to archive instead

---

## Migration from Old System

### Steps to Reorganize Existing Project
1. Create feature folders: `00-feature/`, `01-feature/`, etc.
2. Copy PRDs to feature folders
3. Copy tasks to same feature folders
4. Copy ADRs to same feature folders
5. Rename ADRs: Add number prefix (`00-ADR-name.md`)
6. Verify all docs present
7. Delete old scattered directories

### Script Template
```bash
# Create feature folders
mkdir -p 00-platform-migration 01-storage 02-ai-integration

# Copy and organize docs (with camelCase naming)
cp /source/00-prd-platform-migration.md 00-platform-migration/00-prd-platformMigration.md
cp /source/00-tasks-prd-platform-migration.md 00-platform-migration/00-tasks-platformMigration.md
cp /source/ADR-000-platform-migration.md 00-platform-migration/00-adr-platformMigration.md

# Verify
ls -la 00-platform-migration/
```

---

## Cross-Project Consistency

### Standard Locations
- **PRDs/Tasks/ADRs**: `.claude/docs/plans/##-feature-name/`
- **Reports**: `.claude/docs/plans/####-PHASE-MMDDYY-DESC.md`
- **AI prompts**: `.claude/docs/plans/####-ENT-MMDDYY-AI-PROMPTS-AND-TEMPLATES.md`
- **Templates**: `.claude/templates/` `.claude/docs/templates/`
- **Archive**: `.archive/cleanup-YYYY-MM-DD-desc/`

### Documentation Headers
Every document should include:
```markdown
# ####-PHASE-MMDDYY-DESCRIPTION.md

**Date**: 2025-09-27
**Phase**: PHASE_NAME
**Status**: ✅ COMPLETE / 🔄 ONGOING / 📋 PLANNED

## Description
[What this document covers]

---

[Content]

---

**Last Updated**: 2025-09-27 HH:MM UTC
**Maintained By**: Mark / Team Name
```

---

## AI Assistant Guidelines

### When Creating New Documents
1. Check existing numbering first
2. Follow naming conventions exactly
3. Use appropriate phase identifier
4. Include complete header with date and status
5. Update index/roadmap documents

### When Organizing Existing Docs
1. Preserve original content
2. Update file names to match standards
3. Create feature folders as needed
4. Maintain chronological order
5. Document what was moved where

### File Creation Discipline
- **ALWAYS** ask before creating files
- **NEVER** create without approval
- **ALWAYS** use proper naming conventions
- **NEVER** reset numbering sequences
- **ALWAYS** document in changelog

---

## Maintenance and Updates

### Regular Reviews
- **Weekly**: Check for misfiled documents
- **Monthly**: Verify numbering sequence integrity
- **Quarterly**: Archive completed features
- **Annually**: Purge truly obsolete archives

### Version Control
- All documents tracked in git
- Commit messages reference document numbers
- Tag major milestones: `v1.0-deployment-0079`
- Branch naming: `feature/03-file-upload`

---

## Quick Reference Card

### Doc Format
```
####-PHASE-MMDDYY-DESCRIPTION.md
0080-DEV-092727-ONGOING-IMPROVEMENTS.md
```

### Feature Folder Format
```
##-feature-name/
  ├── ##-prd-featureName.md
  ├── ##-tasks-featureName.md
  └── ##-adr-featureName.md
```

### Phase Identifiers
- DEBUG, CLEAN, ENT, FIX, TEST, FEAT, SEC, DEV

### Date Formats
- File names: MMDDYY (092727)
- Documents: YYYY-MM-DD (2025-09-27)

---

## Benefits of This System

1. **Easy Navigation**: Numbers ensure natural sort order
2. **Feature Cohesion**: All related docs in one folder
3. **Historical Tracking**: Chronological reports
4. **No Confusion**: Clear naming conventions
5. **AI-Friendly**: Structured format for AI assistants
6. **Scalable**: Works for 10 docs or 10,000 docs
7. **Professional**: Consistent across all projects

---

## Enforcement

### Pre-Commit Checks
- File naming conventions verified
- Numbering sequence validated
- Required headers present
- No duplicate numbers

### Code Review
- New documents follow standards
- Archive strategy followed
- Documentation complete
- Index files updated

---

**This filing system is a living document. Update it as patterns evolve, but maintain backward compatibility.**

**Last Updated**: 2025-09-27 22:00 UTC
**Version**: 1.0
**Maintained By**: Mark
**Status**: ✅ ACTIVE STANDARD
