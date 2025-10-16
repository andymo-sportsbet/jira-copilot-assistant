#!/usr/bin/env bash

# JIRA Formatting Library
# Converts markdown-style text to JIRA Atlassian Document Format (ADF)

# Convert enhanced markdown description to JIRA ADF JSON
# This handles:
# - Emoji headers (🚀 *Title*) -> heading level 2 with emoji
# - Section headers (📋 *Section*) -> heading level 3 with emoji  
# - Sub-headers (*Sub:*) -> strong text
# - Horizontal rules (---) -> rule element
# - Bullet points (•) -> bullet list
# - Multiple paragraphs
#
# Usage: markdown_to_jira_adf <markdown_text>
markdown_to_jira_adf() {
    local markdown_text="$1"
    
    # Start building ADF content array
    local content_json='[]'
    local in_list=false
    local list_items='[]'
    
    # Process line by line
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines (they'll be handled as paragraph breaks)
        if [[ -z "$line" ]]; then
            # If we were building a list, close it
            if [[ "$in_list" == "true" ]]; then
                content_json=$(echo "$content_json" | jq --argjson items "$list_items" '. += [{
                    "type": "bulletList",
                    "content": $items
                }]')
                in_list=false
                list_items='[]'
            fi
            continue
        fi
        
        # Check for horizontal rule
        if [[ "$line" =~ ^---+$ ]]; then
            if [[ "$in_list" == "true" ]]; then
                content_json=$(echo "$content_json" | jq --argjson items "$list_items" '. += [{
                    "type": "bulletList",
                    "content": $items
                }]')
                in_list=false
                list_items='[]'
            fi
            content_json=$(echo "$content_json" | jq '. += [{"type": "rule"}]')
            continue
        fi
        
        # Check for main title (🚀 *Title* or ✨ *Title* etc.)
        if [[ "$line" =~ ^([🚀✨🔴🔍🎯])[[:space:]]*\*([^*]+)\*[[:space:]]*$ ]]; then
            if [[ "$in_list" == "true" ]]; then
                content_json=$(echo "$content_json" | jq --argjson items "$list_items" '. += [{
                    "type": "bulletList",
                    "content": $items
                }]')
                in_list=false
                list_items='[]'
            fi
            local emoji="${BASH_REMATCH[1]}"
            local title="${BASH_REMATCH[2]}"
            content_json=$(echo "$content_json" | jq --arg emoji "$emoji" --arg title "$title" '. += [{
                "type": "heading",
                "attrs": {"level": 2},
                "content": [
                    {"type": "text", "text": $emoji},
                    {"type": "text", "text": " "},
                    {"type": "text", "text": $title, "marks": [{"type": "strong"}]}
                ]
            }]')
            continue
        fi
        
        # Check for section header (📋 *Section*)
        if [[ "$line" =~ ^([📋🎯📦💼⚠️🔗✅])[[:space:]]*\*([^*]+)\*[[:space:]]*$ ]]; then
            if [[ "$in_list" == "true" ]]; then
                content_json=$(echo "$content_json" | jq --argjson items "$list_items" '. += [{
                    "type": "bulletList",
                    "content": $items
                }]')
                in_list=false
                list_items='[]'
            fi
            local emoji="${BASH_REMATCH[1]}"
            local section="${BASH_REMATCH[2]}"
            content_json=$(echo "$content_json" | jq --arg emoji "$emoji" --arg section "$section" '. += [{
                "type": "heading",
                "attrs": {"level": 3},
                "content": [
                    {"type": "text", "text": $emoji},
                    {"type": "text", "text": " "},
                    {"type": "text", "text": $section, "marks": [{"type": "strong"}]}
                ]
            }]')
            continue
        fi
        
        # Check for sub-header (*Sub:*)
        if [[ "$line" =~ ^\*([^*]+):\*[[:space:]]*$ ]]; then
            if [[ "$in_list" == "true" ]]; then
                content_json=$(echo "$content_json" | jq --argjson items "$list_items" '. += [{
                    "type": "bulletList",
                    "content": $items
                }]')
                in_list=false
                list_items='[]'
            fi
            local subheader="${BASH_REMATCH[1]}"
            content_json=$(echo "$content_json" | jq --arg text "$subheader" '. += [{
                "type": "paragraph",
                "content": [
                    {"type": "text", "text": $text, "marks": [{"type": "strong"}]},
                    {"type": "text", "text": ":"}
                ]
            }]')
            continue
        fi
        
        # Check for bullet point (• item or ✅/❌/⚠️/🔴/🟡/🟢 item)
        if [[ "$line" =~ ^[[:space:]]*[•✅❌⚠️🔴🟡🟢][[:space:]](.+)$ ]]; then
            local item_text="${BASH_REMATCH[1]}"
            
            # Check if item has bold parts (text: detail)
            if [[ "$item_text" =~ ^([^:]+):[[:space:]](.+)$ ]]; then
                local bold_part="${BASH_REMATCH[1]}"
                local regular_part="${BASH_REMATCH[2]}"
                list_items=$(echo "$list_items" | jq --arg bold "$bold_part" --arg regular "$regular_part" '. += [{
                    "type": "listItem",
                    "content": [{
                        "type": "paragraph",
                        "content": [
                            {"type": "text", "text": $bold, "marks": [{"type": "strong"}]},
                            {"type": "text", "text": ": "},
                            {"type": "text", "text": $regular}
                        ]
                    }]
                }]')
            else
                list_items=$(echo "$list_items" | jq --arg text "$item_text" '. += [{
                    "type": "listItem",
                    "content": [{
                        "type": "paragraph",
                        "content": [{"type": "text", "text": $text}]
                    }]
                }]')
            fi
            in_list=true
            continue
        fi
        
        # Regular paragraph - check for inline formatting
        if [[ "$in_list" == "true" ]]; then
            content_json=$(echo "$content_json" | jq --argjson items "$list_items" '. += [{
                "type": "bulletList",
                "content": $items
            }]')
            in_list=false
            list_items='[]'
        fi
        
        # Handle inline bold (*text*)
        if [[ "$line" =~ \*([^*]+)\* ]]; then
            # Complex inline formatting - need to split and build content array
            local para_content='[]'
            local remaining="$line"
            
            while [[ "$remaining" =~ ^([^*]*)\*([^*]+)\*(.*)$ ]]; do
                local before="${BASH_REMATCH[1]}"
                local bold="${BASH_REMATCH[2]}"
                remaining="${BASH_REMATCH[3]}"
                
                if [[ -n "$before" ]]; then
                    para_content=$(echo "$para_content" | jq --arg text "$before" '. += [{"type": "text", "text": $text}]')
                fi
                para_content=$(echo "$para_content" | jq --arg text "$bold" '. += [{"type": "text", "text": $text, "marks": [{"type": "strong"}]}]')
            done
            
            if [[ -n "$remaining" ]]; then
                para_content=$(echo "$para_content" | jq --arg text "$remaining" '. += [{"type": "text", "text": $text}]')
            fi
            
            content_json=$(echo "$content_json" | jq --argjson content "$para_content" '. += [{
                "type": "paragraph",
                "content": $content
            }]')
        else
            # Simple paragraph
            content_json=$(echo "$content_json" | jq --arg text "$line" '. += [{
                "type": "paragraph",
                "content": [{"type": "text", "text": $text}]
            }]')
        fi
        
    done <<< "$markdown_text"
    
    # Close any open list
    if [[ "$in_list" == "true" ]]; then
        content_json=$(echo "$content_json" | jq --argjson items "$list_items" '. += [{
            "type": "bulletList",
            "content": $items
        }]')
    fi
    
    # Build final ADF structure
    local adf_json=$(jq -n --argjson content "$content_json" '{
        type: "doc",
        version: 1,
        content: $content
    }')
    
    echo "$adf_json"
}

# Simple text to JIRA ADF paragraph (fallback for non-formatted text)
text_to_jira_adf() {
    local text="$1"
    
    jq -n --arg text "$text" '{
        type: "doc",
        version: 1,
        content: [{
            type: "paragraph",
            content: [{
                type: "text",
                text: $text
            }]
        }]
    }'
}
