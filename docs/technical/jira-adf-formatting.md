# JIRA ADF Formatting Guide

## Overview

The JIRA Copilot Assistant now uses **Atlassian Document Format (ADF)** to create beautifully formatted ticket descriptions with:

- **Proper heading hierarchy** (H2 for main titles, H3 for sections)
- **Visual emojis** for quick scanning
- **No more `\n\n` literals** - proper paragraph and line breaks
- **Consistent font sizes** with visual variety

## What Changed

### Before (Plain Text Issue)
```
🚀 *Platform Modernization*\n\n📋 *Background*\n\nThe service runs on old versions...
```
- `\n\n` showing as literal text in JIRA
- Everything same font size
- Hard to scan
- Looks unprofessional

### After (ADF Format)
```
🚀 Platform Modernization          <- H2 heading (large, bold)

📋 Background                       <- H3 heading (medium, bold)

The service runs on old versions... <- Normal paragraph

• Key point 1                       <- Bullet list
• Key point 2
```
- Proper headings with different sizes
- Clean paragraph breaks
- Professional appearance
- Easy to scan

## How It Works

### 1. Markdown to ADF Conversion

The system converts our enhanced markdown format to JIRA's ADF JSON:

**Input (Enhanced Markdown):**
```
🚀 *Platform Modernization: Service Upgrade*

Brief description here.

---

📋 *Background*

*Current Situation:*

The service currently runs on old versions.

*Why This Matters:*

• Critical for operations
• Vendor support ending

---

🎯 *Scope*

*✅ What's Included:*

• Upgrade framework
• Test integration

*❌ What's NOT Included:*

• New features
```

**Output (JIRA ADF JSON):**
```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "heading",
      "attrs": {"level": 2},
      "content": [
        {"type": "text", "text": "🚀"},
        {"type": "text", "text": " "},
        {"type": "text", "text": "Platform Modernization: Service Upgrade", "marks": [{"type": "strong"}]}
      ]
    },
    {
      "type": "paragraph",
      "content": [
        {"type": "text", "text": "Brief description here."}
      ]
    },
    {
      "type": "rule"
    },
    {
      "type": "heading",
      "attrs": {"level": 3},
      "content": [
        {"type": "text", "text": "📋"},
        {"type": "text", "text": " "},
        {"type": "text", "text": "Background", "marks": [{"type": "strong"}]}
      ]
    },
    ... and so on
  ]
}
```

### 2. Formatting Rules

The converter (`jira-format.sh`) recognizes these patterns:

| Pattern | Converts To | Rendering |
|---------|-------------|-----------|
| `🚀 *Title*` on its own line | H2 heading | Large, bold with emoji |
| `📋 *Section*` on its own line | H3 heading | Medium, bold with emoji |
| `*Sub-header:*` on its own line | Strong paragraph | Bold text |
| `---` on its own line | Horizontal rule | Visual separator |
| `• Item` | Bullet list item | Proper list |
| `⚠️ Item` | Bullet list with emoji | List with visual indicator |
| Regular text | Paragraph | Normal text |
| `*bold text*` inline | Strong text | Bold within paragraph |

### 3. Font Size Hierarchy

JIRA ADF provides proper visual hierarchy:

```
🚀 Heading 2 (Main Title)          ← Largest
   📋 Heading 3 (Section)          ← Medium
      Normal Paragraph             ← Regular
         *Strong Text*             ← Regular (bold)
            • Bullet Item          ← Regular (in list)
```

## Updated Templates

All 5 prompt templates have been updated to generate ADF-compatible format:

### Key Changes

1. **Headers on separate lines**
   ```
   # Before (inline)
   🚀 *Title* - some text here

   # After (separate line for proper heading)
   🚀 *Title*

   Some text here.
   ```

2. **Blank lines for clarity**
   ```
   # Before (condensed)
   📋 *Background*
   *Current Situation:*
   The service...

   # After (properly spaced)
   📋 *Background*

   *Current Situation:*

   The service...
   ```

3. **Consistent bullet formatting**
   ```
   # Use this
   • Item 1
   • Item 2

   # Instead of
   * Item 1
   * Item 2
   ```

## Writing New Descriptions

### Best Practices

1. **Use emoji headers on their own lines:**
   ```
   🚀 *Main Title Here*
   
   Description paragraph.
   
   ---
   
   📋 *Section Name*
   ```

2. **Add blank lines around sections:**
   ```
   *Sub-header:*
   
   Paragraph content here.
   
   Another paragraph.
   ```

3. **Use bullet lists properly:**
   ```
   *List Title:*
   
   • First item
   • Second item with details
   • Third item
   ```

4. **Inline bold for emphasis:**
   ```
   This is a paragraph with *important text* highlighted.
   ```

## Emoji Reference

### Main Titles (H2)
- 🚀 Platform/Service modernization
- ✨ New features
- 🔴 Critical bugs
- 🔍 Research/Spikes
- 🎯 General improvements

### Section Headers (H3)
- 📋 Background/Context
- 🎯 Goals/Scope
- 📦 Deliverables
- 💼 Business Impact
- ⚠️ Risks/Warnings
- 🔗 Dependencies
- ✅ Success Criteria

### Visual Indicators
- ✅ Included/Completed/Success
- ❌ Excluded/Not in scope
- 🔴 Critical/Urgent
- 🟡 High priority
- 🟢 Low priority
- ⚠️ Warning/Risk

## Technical Details

### Files Modified

1. **`scripts/lib/jira-format.sh`** (NEW)
   - `markdown_to_jira_adf()` - Main conversion function
   - Handles all markdown patterns → ADF JSON

2. **`scripts/jira-groom.sh`**
   - Sources `jira-format.sh` library
   - Calls `markdown_to_jira_adf()` before sending to JIRA
   - Uses `$'\n\n'` instead of `"\n\n"` for proper newlines

3. **All 5 prompt templates**
   - Updated examples to show proper spacing
   - Clear guidelines for ADF-compatible formatting

### Newline Fix

**Before (broken):**
```bash
enhanced_description+="\n\n"  # Literal \n\n string
```

**After (fixed):**
```bash
enhanced_description+=$'\n\n'  # Actual newline characters
```

The `$'...'` syntax in bash interprets escape sequences properly.

## Testing

### Verify ADF Format

1. **Generate description:**
   ```bash
   # In VS Code with spec file
   "Read spec.md and generate description using .prompts/generate-description-tech-debt.md"
   ```

2. **Check format before applying:**
   ```bash
   cat .temp/description.txt
   # Should see emoji headers on separate lines
   # Should see blank lines between sections
   ```

3. **Apply to JIRA:**
   ```bash
   ./scripts/jira-groom.sh RVV-1234 --ai-description .temp/description.txt
   ```

4. **Verify in JIRA:**
   - Main title should be **large H2 heading** with emoji
   - Section headers should be **medium H3 headings** with emojis
   - Regular text should be normal paragraphs
   - Bullet lists should render properly
   - No `\n\n` literals visible

### Example Output in JIRA

**What you should see:**

# 🚀 **Platform Modernization: Service Upgrade** ← (Large H2)

Brief description paragraph in normal text.

---

### 📋 **Background** ← (Medium H3)

**Current Situation:**

The service runs on old versions...

**Why This Matters:**

• Critical for operations  
• Vendor support ending

---

### 🎯 **Scope** ← (Medium H3)

**✅ What's Included:**

• Upgrade framework  
• Test integration

**❌ What's NOT Included:**

• New features

---

## Troubleshooting

### Issue: Still seeing `\n\n` in JIRA

**Cause:** Old descriptions not converted to ADF  
**Fix:** Re-groom the ticket with updated script

### Issue: Headers not rendering as headings

**Cause:** Headers not on their own line  
**Fix:** Update template to put emoji headers on separate lines:
```
# Wrong
📋 *Background* - text here

# Right
📋 *Background*

Text here.
```

### Issue: Bullet lists not formatting

**Cause:** Missing `•` character or wrong list marker  
**Fix:** Use `•` (bullet point U+2022):
```
# Wrong
* Item 1
- Item 2

# Right
• Item 1
• Item 2
```

### Issue: No font size variation

**Cause:** Not using heading patterns  
**Fix:** Ensure emoji + `*text*` pattern:
```
🚀 *This becomes H2*
📋 *This becomes H3*
```

## Migration Guide

### For Existing Descriptions

Re-groom tickets to apply ADF formatting:

```bash
# 1. Generate new description with updated templates
# (in VS Code)

# 2. Apply with re-grooming
./scripts/jira-groom.sh TICKET-123 --ai-description .temp/description.txt

# The script will:
# - Preserve any manual edits (before markers)
# - Convert new description to ADF
# - Apply proper headings and formatting
```

### For New Descriptions

Just use the updated templates - everything works automatically!

```bash
# 1. Auto-select template
./scripts/get-description-template.sh TICKET-123

# 2. Generate with AI (returns .temp/description.txt)
# In VS Code: "Read spec.md and generate description using [template]"

# 3. Apply (automatic ADF conversion)
./scripts/jira-groom.sh TICKET-123 --ai-description .temp/description.txt
```

## Benefits

✅ **Professional appearance** - Proper headings and hierarchy  
✅ **Better scannability** - Visual variety with H2/H3 headings  
✅ **No more `\n\n`** - Clean paragraph breaks  
✅ **Emoji support** - Visual indicators work correctly  
✅ **Accessible** - Screen readers recognize proper heading structure  
✅ **Consistent** - All tickets follow same visual pattern  
✅ **Automatic** - No manual formatting needed  

## Summary

The JIRA Copilot Assistant now creates **professional, properly formatted** ticket descriptions using JIRA's native ADF format. The system automatically converts our enhanced markdown to ADF JSON, providing:

- **Visual hierarchy** with H2/H3 headings
- **Proper formatting** without `\n\n` literals
- **Font size variation** for better scannability
- **Clean, professional appearance** in JIRA

All existing templates have been updated and the conversion happens automatically when applying descriptions to JIRA.
