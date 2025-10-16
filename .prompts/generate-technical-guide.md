# AI Prompt: Generate JIRA Technical Guide

Use this prompt with Claude/Copilot to generate a technical implementation guide for JIRA.

## Instructions for AI Agent

Read the specification file and generate a JIRA Atlassian Document Format (ADF) JSON comment with a comprehensive technical implementation guide.

### Requirements:

1. **Analyze the spec file** to extract:
   - Technical stack (languages, frameworks, versions)
   - Key implementation requirements
   - Configuration changes
   - Testing requirements
   - Migration steps (if applicable)

2. **Generate valid JIRA ADF JSON** with this structure:

```json
{
  "body": {
    "type": "doc",
    "version": 1,
    "content": [
      {
        "type": "heading",
        "attrs": { "level": 2 },
        "content": [{ "type": "text", "text": "📋 Technical Implementation Guide" }]
      },
      {
        "type": "paragraph",
        "content": [
          { "type": "text", "text": "Technical reference extracted from: ", "marks": [{ "type": "em" }] },
          { "type": "text", "text": "spec.md", "marks": [{ "type": "code" }] }
        ]
      },
      {
        "type": "rule"
      },
      {
        "type": "heading",
        "attrs": { "level": 3 },
        "content": [{ "type": "text", "text": "Technical Stack" }]
      },
      {
        "type": "bulletList",
        "content": [
          {
            "type": "listItem",
            "content": [
              {
                "type": "paragraph",
                "content": [
                  { "type": "text", "text": "Language: ", "marks": [{ "type": "strong" }] },
                  { "type": "text", "text": "Java 17", "marks": [{ "type": "code" }] }
                ]
              }
            ]
          }
        ]
      },
      {
        "type": "heading",
        "attrs": { "level": 3 },
        "content": [{ "type": "text", "text": "Key Changes" }]
      },
      {
        "type": "bulletList",
        "content": [
          {
            "type": "listItem",
            "content": [
              {
                "type": "paragraph",
                "content": [{ "type": "text", "text": "Describe key changes here" }]
              }
            ]
          }
        ]
      },
      {
        "type": "heading",
        "attrs": { "level": 3 },
        "content": [{ "type": "text", "text": "Configuration Updates" }]
      },
      {
        "type": "bulletList",
        "content": [
          {
            "type": "listItem",
            "content": [
              {
                "type": "paragraph",
                "content": [{ "type": "text", "text": "Configuration items here" }]
              }
            ]
          }
        ]
      },
      {
        "type": "rule"
      },
      {
        "type": "paragraph",
        "content": [
          { "type": "text", "text": "AI-generated from spec using Claude Sonnet", "marks": [{ "type": "em" }] }
        ]
      }
    ]
  }
}
```

### Text Formatting Options:

- **Bold**: `"marks": [{ "type": "strong" }]`
- **Italic**: `"marks": [{ "type": "em" }]`
- **Code**: `"marks": [{ "type": "code" }]`
- **Link**: `"marks": [{ "type": "link", "attrs": { "href": "URL" } }]`

### Example Usage:

**You say to Claude/Copilot:**
> "Read `specs/betmaker-ingestor-springboot3/spec.md` and generate a JIRA technical guide using the template in `.prompts/generate-technical-guide.md`. Save the output to `.temp/technical-guide.json`"

**Claude will:**
1. Read the spec file
2. Extract technical details
3. Generate properly formatted JIRA ADF JSON
4. Save to `.temp/technical-guide.json`

**You then run:**
```bash
./scripts/jira-groom.sh RVV-1177 --ai-guide .temp/technical-guide.json
```

## Key Sections to Include:

1. **📋 Technical Implementation Guide** (H2)
2. **Technical Stack** (H3) - Languages, frameworks, versions
3. **Key Changes** (H3) - Main implementation changes
4. **Configuration Updates** (H3) - Config file changes
5. **Testing Strategy** (H3) - Test requirements
6. **Migration Steps** (H3) - If applicable
7. **Reference Links** (H3) - Confluence, docs, PRs

## Output Format:

- Must be valid JSON (use `jq '.' file.json` to validate)
- Must use JIRA ADF structure exactly
- Save to `.temp/technical-guide.json`
- File will be read by `jira-groom.sh --ai-guide`
