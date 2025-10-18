# Auto-Generate Descriptions - Complete Guide

## Problem

Currently, `jira-groom.sh` requires `--ai-description` flag to add enhanced descriptions. 
Without it, only acceptance criteria are generated.

## Solutions

### Option 1: Make AI Description Generation Automatic (Recommended)

Update `jira-groom.sh` to auto-generate descriptions using AI when no `--ai-description` is provided.

**Pros:**
- Fully automatic - no manual steps
- Consistent descriptions across all tickets
- One command to groom everything

**Cons:**
- Requires AI API integration in the script
- May need API keys configuration

### Option 2: Semi-Automatic Workflow (Current Best Practice)

Keep the current two-step process:

**Step 1: Generate Description with VS Code Copilot**
```
In VS Code Chat:
"@workspace Read JIRA ticket RVV-1174 from JIRA API and generate 
an enhanced description using the template at 
.prompts/generate-description-tech-debt.md

The ticket is about Spring Boot upgrade for [Service Name].
Save the output to .temp/rvv-1174-description.txt"
```

**Step 2: Apply to JIRA**
```bash
./scripts/jira-groom.sh RVV-1174 --ai-description .temp/rvv-1174-description.txt
```

### Option 3: Batch Script with AI Generation

Create a helper script that:
1. Fetches ticket details from JIRA
2. Calls AI to generate description
3. Automatically grooms with the generated description

## Immediate Solution: Re-Groom All Tickets

### For RVV-1171 (We have saved description)

```bash
cd /Users/andym/projects/my-project/jira-copilot-assistant
./scripts/jira-groom.sh RVV-1171 --ai-description .temp/rvv-1171-enhanced-format.txt
```

### For RVV-1174, 1175, 1176, 1177 (Need to generate)

**Using VS Code Copilot:**

1. **RVV-1174: [Betmaker Feed Adapter] Spring boot upgrade**
   ```
   Prompt: "Read JIRA ticket RVV-1174 and generate an enhanced description
   for a Spring Boot upgrade ticket for the Betmaker Feed Adapter service.
   Use the template .prompts/generate-description-tech-debt.md
   
   Context: This is a Spring Boot framework upgrade ticket similar to RVV-1171.
   The Betmaker Feed Adapter processes racing data feeds."
   
   Save to: .temp/rvv-1174-description.txt
   
   Then run:
   ./scripts/jira-groom.sh RVV-1174 --ai-description .temp/rvv-1174-description.txt
   ```

2. **RVV-1175: [AAP Connector] Spring boot upgrade**
   ```
   Prompt: "Read JIRA ticket RVV-1175 and generate an enhanced description
   for a Spring Boot upgrade ticket for the AAP Connector service.
   Use the template .prompts/generate-description-tech-debt.md
   
   Context: This is a Spring Boot framework upgrade ticket.
   The AAP Connector integrates with AAP racing data provider."
   
   Save to: .temp/rvv-1175-description.txt
   
   Then run:
   ./scripts/jira-groom.sh RVV-1175 --ai-description .temp/rvv-1175-description.txt
   ```

3. **RVV-1176: [R&S Connector] Spring boot upgrade**
   ```
   Prompt: "Read JIRA ticket RVV-1176 and generate an enhanced description
   for a Spring Boot upgrade ticket for the R&S Connector service.
   Use the template .prompts/generate-description-tech-debt.md
   
   Context: This is a Spring Boot framework upgrade ticket.
   The R&S Connector integrates with R&S racing data provider."
   
   Save to: .temp/rvv-1176-description.txt
   
   Then run:
   ./scripts/jira-groom.sh RVV-1176 --ai-description .temp/rvv-1176-description.txt
   ```

4. **RVV-1177: [RAMP2] Spring boot upgrade**
   ```
   Prompt: "Read JIRA ticket RVV-1177 and generate an enhanced description
   for a Spring Boot upgrade ticket for the RAMP2 service.
   Use the template .prompts/generate-description-tech-debt.md
   
   Context: This is a Spring Boot framework upgrade ticket.
   RAMP2 is a racing data processing platform."
   
   Save to: .temp/rvv-1177-description.txt
   
   Then run:
   ./scripts/jira-groom.sh RVV-1177 --ai-description .temp/rvv-1177-description.txt
   ```

## Future Enhancement: Modify jira-groom.sh

To make `--ai-description` automatic, we could:

1. **Add AI API integration** to jira-groom.sh
2. **Auto-detect ticket type** using existing `get-description-template.sh`
3. **Generate description** using GitHub Copilot API or Claude API
4. **Apply automatically** without requiring a file

This would enable:
```bash
./scripts/jira-groom.sh RVV-1174  # Automatically generates description!
```

Would you like me to implement this enhancement?

## Summary

**Current State:**
- ✅ RVV-1171: Can be restored with saved file
- ❌ RVV-1174-1177: Need AI-generated descriptions

**Recommended Workflow:**
1. Use VS Code Copilot to generate each description (5 min per ticket)
2. Run groom command with --ai-description flag
3. Verify in JIRA

**Future State (If We Enhance):**
1. Run single command: `./scripts/jira-groom.sh TICKET-123`
2. Script auto-generates description using AI
3. Fully automatic - no manual steps!

Let me know which approach you'd like to take! 🚀
