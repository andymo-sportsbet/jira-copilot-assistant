# JIRA Estimation Guide

## 📊 Understanding Story Point Estimation

### What Are Story Points?

Story points are a relative measure of effort that considers:
- **Effort**: Amount of work required
- **Complexity**: Technical difficulty
- **Uncertainty**: How well we understand the requirements
- **Risk**: Potential blockers or unknowns

**Not Time Estimates**: Story points are NOT hours. They're relative measures compared to other work.

---

## 🎯 Common Estimation Scales

### Fibonacci Sequence (Recommended)
```
1, 2, 3, 5, 8, 13, 21, 34, 55, 89
```

| Points | Effort | Typical Duration | Examples |
|--------|--------|------------------|----------|
| **1** | Trivial | 30 min - 2 hours | Fix typo, update config value, simple doc update |
| **2** | Simple | 2-4 hours | Add logging, simple validation, minor UI tweak |
| **3** | Small | 4-8 hours (~1 day) | Simple feature, bug fix with tests, API endpoint |
| **5** | Medium | 1-2 days | Feature with multiple files, moderate complexity |
| **8** | Large | 2-3 days | Complex feature, multiple integrations, refactoring |
| **13** | Very Large | 3-5 days | Major feature, significant changes, framework upgrade |
| **21** | Huge | 1-2 weeks | Large system change, needs breaking down |
| **34+** | Epic | Too large | **SPLIT THIS** - needs to be broken into smaller tasks |

**Why Fibonacci?** The gaps increase as uncertainty grows - it's harder to distinguish between 13 and 14 than between 1 and 2.

---

## 🤔 How to Estimate

### Step 1: Understand the Work

Ask yourself:
- ✅ What needs to be done?
- ✅ What files/systems are affected?
- ✅ What dependencies exist?
- ✅ What testing is required?
- ✅ What documentation is needed?
- ✅ What unknowns exist?

### Step 2: Compare to Reference Stories

Pick a reference story everyone knows:
```
"Updating a config file is a 1"
"Adding a new API endpoint is a 5"
"Framework upgrade is a 13"
```

Then compare: Is this ticket more or less complex than the reference?

### Step 3: Consider These Factors

#### Complexity Multipliers
- 🔴 **High Complexity**: Multiple systems, new technology, unclear requirements (+complexity)
- 🟡 **Medium Complexity**: Known patterns, some unknowns (baseline)
- 🟢 **Low Complexity**: Straightforward, well-understood (simple)

#### Uncertainty Factors
- ❓ **High Uncertainty**: No one's done this before (+points)
- ⚠️ **Medium Uncertainty**: Similar work exists (baseline)
- ✅ **Low Uncertainty**: Done many times before (-points)

#### Risk Factors
- 🚨 **High Risk**: Critical system, production impact (+points)
- ⚠️ **Medium Risk**: Standard change (baseline)
- ✅ **Low Risk**: Non-critical, easy rollback (simple)

### Step 4: Don't Forget...

Include time for:
- ✅ Unit tests
- ✅ Integration tests
- ✅ Code review
- ✅ Documentation updates
- ✅ Deployment/migration scripts
- ✅ Bug fixes from testing

---

## 🎨 Estimation Examples

### Example 1: Spring Boot Upgrade (RVV-1171)

**Task**: Upgrade Betmaker Feed Ingestor to Spring Boot 3

**Analysis**:
- 📦 **Scope**: Framework upgrade, dependency updates, code changes
- 🔧 **Complexity**: Medium-High (framework changes, breaking changes)
- ❓ **Uncertainty**: Medium (some unknowns in migration)
- 🧪 **Testing**: Extensive (all data flows need validation)
- 📚 **Documentation**: Moderate (operational updates)
- 🔗 **Dependencies**: Racing BOM, shared libraries

**Factors**:
- ✅ Well-documented upgrade path
- ⚠️ Multiple integration points to test
- ⚠️ Critical service (data feeds)
- ✅ Can refer to similar upgrades
- ⚠️ Needs coordination with downstream systems

**Estimate**: **13 points** (3-5 days)
- 1-2 days: Upgrade and code changes
- 1 day: Testing all data flows
- 0.5 day: Documentation and deployment
- 0.5 day: Buffer for issues

### Example 2: Add Logging to Service

**Task**: Add structured logging to AAP Connector

**Analysis**:
- 📦 **Scope**: Add logging statements, configure logger
- 🔧 **Complexity**: Low (well-known pattern)
- ❓ **Uncertainty**: Low (done many times)
- 🧪 **Testing**: Simple (log output verification)
- 📚 **Documentation**: Minimal (comments only)
- 🔗 **Dependencies**: None

**Estimate**: **2 points** (2-4 hours)
- 1 hour: Add logging statements
- 1 hour: Test and verify
- 30 min: Code review adjustments

### Example 3: New Feature with Multiple Integrations

**Task**: Add support for new racing data provider

**Analysis**:
- 📦 **Scope**: New connector, data transformation, integration
- 🔧 **Complexity**: High (new external API, data mapping)
- ❓ **Uncertainty**: High (new provider, unclear API)
- 🧪 **Testing**: Extensive (integration tests, data validation)
- 📚 **Documentation**: Significant (new integration guide)
- 🔗 **Dependencies**: External API, downstream consumers

**Factors**:
- ⚠️ New external API (needs exploration)
- ⚠️ Data format unknown
- ⚠️ Multiple downstream systems affected
- ⚠️ Requires API credentials and testing environment
- ✅ Can follow existing connector patterns

**Estimate**: **21 points** (1-2 weeks) - **SHOULD BE SPLIT**
- Better: Split into:
  - **8 points**: Basic connector implementation
  - **5 points**: Data transformation and validation
  - **8 points**: Integration with downstream systems

---

## 🧮 AI-Assisted Estimation

AI can help by analyzing:
- **Ticket description** - Scope and requirements
- **Technical details** - Complexity indicators
- **Dependencies** - Integration points
- **Similar tickets** - Historical data
- **Risk factors** - Uncertainty markers

### AI Estimation Factors

AI considers:
1. **Keywords**: "upgrade", "new", "refactor", "critical", "migration"
2. **Scope**: Number of systems/services mentioned
3. **Dependencies**: External systems, APIs, libraries
4. **Testing needs**: Integration, performance, migration
5. **Risk indicators**: "production", "critical", "unknown", "new technology"
6. **Historical patterns**: Similar tickets and their estimates

### Example AI Analysis

```
Ticket: Spring Boot 3 Upgrade - Betmaker Feed Ingestor

AI Analysis:
- Keyword: "upgrade" → +complexity
- Scope: "framework", "dependencies" → medium-large
- Dependencies: "shared libraries", "racing BOM" → +points
- Testing: "validate data flows", "downstream systems" → +testing effort
- Risk: "critical service", "data feeds" → +risk
- Similar: Found 3 similar upgrades (8-13 points)

AI Recommendation: 13 points (3-5 days)
Confidence: High (based on similar tickets)

Breakdown:
- Upgrade work: 8 points
- Testing/validation: +3 points
- Documentation: +2 points
```

---

## ✅ Best Practices

### Do's ✅
- **Estimate as a team** - Multiple perspectives improve accuracy
- **Use reference stories** - "This is like ticket X, which was Y points"
- **Include everything** - Testing, docs, review, deployment
- **Be honest about unknowns** - More uncertainty = more points
- **Split large tickets** - Anything > 13 points should be broken down
- **Review after completion** - Learn from actual effort

### Don'ts ❌
- **Don't equate points to hours** - They're relative, not absolute
- **Don't pressure for low estimates** - Underestimating helps no one
- **Don't estimate alone** - Team input is valuable
- **Don't forget non-coding work** - Testing, docs, meetings count
- **Don't be too precise** - 13 vs 14 doesn't matter, use Fibonacci gaps

---

## 🎯 Quick Estimation Guide

### Quick Reference

```
1 point  = Config change, doc update, typo fix
2 points = Simple change with tests
3 points = Feature in 1-2 files, straightforward
5 points = Feature across multiple files, moderate complexity
8 points = Complex feature, refactoring, multiple integrations
13 points = Major change, framework upgrade, significant effort
21+ points = TOO BIG - SPLIT IT
```

### Red Flags 🚩

If you see these, add points:
- ⚠️ "We've never done this before"
- ⚠️ "Need to research how to..."
- ⚠️ "Multiple systems affected"
- ⚠️ "Critical production service"
- ⚠️ "Unclear requirements"
- ⚠️ "External dependencies"
- ⚠️ "New technology/framework"

### Green Flags 🟢

If you see these, might be simpler:
- ✅ "We've done this many times"
- ✅ "Well-documented approach"
- ✅ "Single file change"
- ✅ "Non-critical service"
- ✅ "Clear requirements"
- ✅ "No external dependencies"
- ✅ "Familiar technology"

---

## 📈 Estimation in JIRA

### How to Set Story Points

1. **Manual Entry**: Edit ticket → "Story Points" field
2. **Via API**: Update `customfield_10016` (or your field ID)
3. **During Grooming**: Team discussion → consensus

### JIRA Field Names

Common field names/IDs:
- `Story Points` - Usually `customfield_10016` or `customfield_10002`
- `Original Estimate` - Time-based (hours)
- `Time Tracking` - Actual hours logged

**Find your field ID:**
```bash
# Get ticket and look for story point field
curl -u email:token https://company.atlassian.net/rest/api/3/issue/PROJ-123 | jq '.fields'
```

---

## 🔧 Planning Poker

**Team estimation technique:**

1. Everyone picks a card (1, 2, 3, 5, 8, 13...)
2. Reveal simultaneously
3. Discuss differences
4. Re-estimate until consensus

**Why it works:**
- Prevents anchoring bias
- Gets multiple perspectives
- Identifies knowledge gaps
- Builds shared understanding

---

## 📚 Further Reading

- [Agile Estimation Guide](https://www.atlassian.com/agile/project-management/estimation)
- [Story Points Explained](https://www.mountaingoatsoftware.com/blog/what-are-story-points)
- [Planning Poker](https://www.planningpoker.com/)
- [Estimation Best Practices](https://www.scrum.org/resources/blog/10-tips-better-sprint-planning)
