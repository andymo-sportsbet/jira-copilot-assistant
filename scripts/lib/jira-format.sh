#!/usr/bin/env bash

# Minimal markdown -> ADF converter
# Conservative support: ATX headings, fenced code blocks, bullet lists, paragraphs, inline code, bold

# Helper: process inline formatting (bold, inline code)
process_inline_formatting() {
    local text="$1"
    local result='[]'
    
    # Simple state machine to parse inline formatting
    # For now, use a Python one-liner for robust parsing
    python3 -c "
import json
import re

text = '''$text'''
result = []
pos = 0

# Pattern: match **bold**, \`code\`, or plain text
pattern = r'(\*\*([^*]+)\*\*)|(\`([^\`]+)\`)|([^*\`]+)'

for match in re.finditer(pattern, text):
    if match.group(2):  # Bold
        result.append({
            'type': 'text',
            'text': match.group(2),
            'marks': [{'type': 'strong'}]
        })
    elif match.group(4):  # Inline code
        result.append({
            'type': 'text',
            'text': match.group(4),
            'marks': [{'type': 'code'}]
        })
    elif match.group(5):  # Plain text
        result.append({
            'type': 'text',
            'text': match.group(5)
        })

print(json.dumps(result))
" 2>/dev/null || echo "[{\"type\":\"text\",\"text\":\"$text\"}]"
}

markdown_to_jira_adf() {
    local markdown_text="$1"
    echo "[DEBUG] markdown_to_jira_adf input markdown:" >&2
    echo "$markdown_text" >&2
    local content='[]'
    local in_list=false
    local list_items='[]'

    # Read input line-by-line
    while IFS= read -r line || [[ -n "$line" ]]; do
        # trim leading/trailing whitespace
        line="$(echo "$line" | sed -E 's/^[ \t]+|[ \t]+$//g')"
        if [[ -z "$line" ]]; then
            # If we were in a list, close it
            if [[ "$in_list" == true ]]; then
                content=$(echo "$content" | jq --argjson items "$list_items" '. += [{"type":"bulletList","content":$items}]')
                list_items='[]'
                in_list=false
            fi
            continue
        fi

        # fenced code block start
        if [[ "${line:0:3}" == '```' ]]; then
            # Close any open list first
            if [[ "$in_list" == true ]]; then
                content=$(echo "$content" | jq --argjson items "$list_items" '. += [{"type":"bulletList","content":$items}]')
                list_items='[]'
                in_list=false
            fi
            
            local lang="${line:3}"
            local code=""
            while IFS= read -r cline; do
                if [[ "${cline:0:3}" == '```' ]]; then
                    break
                fi
                code+="$cline\n"
            done
            content=$(echo "$content" | jq --arg code "$code" --arg lang "$lang" '. += [{"type":"codeBlock","attrs":{"language":($lang//null)},"content":[{"type":"text","text":$code}]}]')
            continue
        fi

        # ATX heading
        if [[ "$line" =~ ^(#{1,6})[[:space:]]+(.+)$ ]]; then
            # Close any open list first
            if [[ "$in_list" == true ]]; then
                content=$(echo "$content" | jq --argjson items "$list_items" '. += [{"type":"bulletList","content":$items}]')
                list_items='[]'
                in_list=false
            fi
            
            local level=${#BASH_REMATCH[1]}
            local text=${BASH_REMATCH[2]}
            local inline_content=$(process_inline_formatting "$text")
            content=$(echo "$content" | jq --argjson lvl "$level" --argjson inline "$inline_content" '. += [{"type":"heading","attrs":{"level":($lvl|tonumber)},"content":$inline}]')
            continue
        fi

        # bullet list item
        if [[ "$line" =~ ^[-\*][[:space:]]+(.+)$ ]]; then
            local item_text="${BASH_REMATCH[1]}"
            local inline_content=$(process_inline_formatting "$item_text")
            in_list=true
            list_items=$(echo "$list_items" | jq --argjson inline "$inline_content" '. += [{"type":"listItem","content":[{"type":"paragraph","content":$inline}]}]')
            continue
        fi

        # Non-list line: close list if open
        if [[ "$in_list" == true ]]; then
            content=$(echo "$content" | jq --argjson items "$list_items" '. += [{"type":"bulletList","content":$items}]')
            list_items='[]'
            in_list=false
        fi

        # paragraph with inline formatting
        local inline_content=$(process_inline_formatting "$line")
        content=$(echo "$content" | jq --argjson inline "$inline_content" '. += [{"type":"paragraph","content":$inline}]')
    done <<< "$markdown_text"

    # Close list if still open at end
    if [[ "$in_list" == true ]]; then
        content=$(echo "$content" | jq --argjson items "$list_items" '. += [{"type":"bulletList","content":$items}]')
    fi

    local adf_output
    adf_output=$(jq -n --argjson content "$content" '{type:"doc",version:1,content:$content}')
    echo "[DEBUG] markdown_to_jira_adf output ADF:" >&2
    echo "$adf_output" >&2
    echo "$adf_output"
}
