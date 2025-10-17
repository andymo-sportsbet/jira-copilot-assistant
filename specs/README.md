# Spec 008: Copilot-Powered JIRA Workflow Assistant

**Version**: 5.0.0  
**Last Updated**: 2025-10-15  
**Status**: Epic 1-4 Complete ✅ | Epic 5 In Progress 🚧  
**Story Points**: 28.5 SP (22 complete + 6.5 in progress)

---

## 📚 Documentation Index

### Core Documentation

| File | Description | Status |
|------|-------------|--------|
| **spec.md** | Complete project specification with all 5 epics | ✅ Updated |
| **tasks.md** | Detailed task breakdown for all 16 tasks across 5 epics | ✅ Updated |
| **plan.md** | Implementation plan with timeline and milestones | ✅ Updated |
| **implementation.md** | Technical implementation guide and code examples | ✅ Updated |
| **automation.md** | Spec for automated Confluence → spec sync and maintenance | ⏳ New |

### Reference Documentation

| File | Description |
|------|-------------|
| **TRANSFORMATION.md** | History of project approach transformation |

---

## 🎯 Project Overview

Build a Copilot-powered JIRA workflow assistant using **Custom Instructions + Shell Scripts** instead of a traditional VS Code extension.

### Key Features

✅ **Completed (Epic 1-4)**:
- Create JIRA tickets from spec files
- AI-generated acceptance criteria and summaries
- GitHub-JIRA sync
- Copilot natural language commands
- Confluence integration (create tickets from pages, save pages as specs)

🚧 **In Progress (Epic 5)**:
- AI story point estimation
- Team-specific estimation (linear scale 0.5-5, 7 focus hours per point)
- Interactive estimation workflow

---

## 📊 Epic Status

| Epic | Name | Tasks | SP | Status |
|------|------|-------|----|----|
| 1 | Core Shell Scripts | 4 | 8 | ✅ Complete |
| 2 | Copilot Integration | 2 | 4 | ✅ Complete |
| 3 | Documentation | 2 | 3 | ✅ Complete |
| 4 | Confluence Integration | 4 | 7 | ✅ Complete |
| 5 | AI Story Point Estimation | 4 | 6.5 | 🚧 In Progress |
| **Total** | | **16** | **28.5** | **77% Complete** |

---

## 🚀 Quick Start

### 1. Read the Specification
Start with **spec.md** for the complete project overview and architecture.

### 2. Review Tasks
Check **tasks.md** for detailed task breakdown and acceptance criteria.

### 3. Follow Implementation Guide
Use **implementation.md** for step-by-step technical implementation.

### 4. Track Progress
See **plan.md** for timeline, milestones, and risk management.

---

## 📋 Current Sprint (Epic 5)

**Objective**: Implement AI story point estimation

**Tasks**:
1. **CJA-013**: Estimation Library (3 SP) - Create `scripts/lib/jira-estimate.sh`
2. **CJA-014**: Enhance jira-groom.sh (2 SP) - Add `--estimate` flag
3. **CJA-015**: Environment Config (0.5 SP) - Add JIRA_STORY_POINTS_FIELD
4. **CJA-016**: Copilot Instructions (1 SP) - Update with estimation patterns

**References**:
- Team estimation spec: `../001-user-authentication-system/team-story-points-estimation-spec.md`
- Confluence: [Story points based estimation](https://sportsbet.atlassian.net/wiki/spaces/RVS/pages/13287785039)

---

## 🎯 Next Steps

1. **Week 4**: Implement Epic 5 tasks (6.5 SP)
2. **Week 5**: Testing and full team rollout

---

## 📦 Repository Structure

```
jira-copilot-assistant/
├── .github/
│   └── copilot-instructions.md       # Copilot custom instructions
├── scripts/
│   ├── jira-create.sh                # Create JIRA tickets
│   ├── jira-groom.sh                 # Groom tickets with AI
│   ├── jira-close.sh                 # Close tickets with summary
│   ├── jira-sync.sh                  # Sync GitHub-JIRA
│   ├── confluence-to-jira.sh         # Convert Confluence → JIRA
│   ├── confluence-to-spec.sh         # Convert Confluence → spec
│   └── lib/
│       ├── jira-api.sh               # JIRA REST API wrapper
│       ├── jira-search.sh            # JIRA search utilities
│       ├── jira-format.sh            # ADF formatting
│       ├── confluence-api.sh         # Confluence REST API wrapper
│       └── jira-estimate.sh          # AI estimation (Epic 5)
├── specs/
│   └── 008-copilot-jira-agent/       # This directory
└── .env                              # Environment configuration
```

---

## 🔗 Related Specs

- **Spec 001**: User Authentication System (has team estimation spec)

---

**Maintained By**: Engineering Team  
**Contact**: GitHub Copilot Chat
