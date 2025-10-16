#!/usr/bin/env bash

# Utility functions for JIRA scripts

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Print colored messages
success() {
    echo -e "${GREEN}✅ $*${NC}"
}

error() {
    echo -e "${RED}❌ $*${NC}" >&2
}

warning() {
    echo -e "${YELLOW}⚠️  $*${NC}" >&2
}

info() {
    echo -e "${BLUE}ℹ️  $*${NC}"
}

debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${CYAN}🔍 $*${NC}" >&2
    fi
}

# Load environment from .env file
load_env() {
    local env_file="${1:-.env}"
    
    if [[ -f "$env_file" ]]; then
        debug "Loading environment from $env_file"
        set -a
        # shellcheck disable=SC1090
        source "$env_file"
        set +a
    else
        debug "No $env_file file found"
    fi
}

# Validate JIRA ticket key format
validate_ticket_key() {
    local key="$1"
    
    if [[ ! "$key" =~ ^[A-Z]+-[0-9]+$ ]]; then
        error "Invalid ticket key format: $key"
        info "Expected format: PROJECT-123 (e.g., PROJ-456)"
        return 1
    fi
    
    return 0
}

# Truncate text to max length
truncate_text() {
    local text="$1"
    local max_length="${2:-500}"
    
    if [[ ${#text} -gt $max_length ]]; then
        echo "${text:0:$max_length}..."
    else
        echo "$text"
    fi
}

# Convert comma-separated features to bullet points
features_to_bullets() {
    local features="$1"
    
    if [[ -z "$features" ]]; then
        echo ""
        return
    fi
    
    echo "$features" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed 's/^/* /'
}

# Extract priority from text based on keywords
detect_priority() {
    local text="$1"
    local text_lower=$(echo "$text" | tr '[:upper:]' '[:lower:]')
    
    if echo "$text_lower" | grep -qE "(critical|blocker|urgent|asap|emergency|highest)"; then
        echo "High"
    elif echo "$text_lower" | grep -qE "(nice to have|future|optional|low priority|lowest)"; then
        echo "Low"
    else
        echo "Medium"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check required dependencies
check_dependencies() {
    local missing=()
    
    command_exists jq || missing+=("jq")
    command_exists curl || missing+=("curl")
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Missing required dependencies:"
        printf '%s\n' "${missing[@]}" | sed 's/^/  - /'
        echo ""
        info "Install with: brew install ${missing[*]}"
        return 1
    fi
    
    return 0
}

# Parse command line arguments
# Usage: parse_args "$@"
# Sets global variables based on --arg-name value pairs
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                return 2  # Special code for help
                ;;
            --*)
                local key="${1#--}"
                local value="${2:-}"
                
                if [[ -z "$value" ]] || [[ "$value" =~ ^-- ]]; then
                    error "Option $1 requires a value"
                    return 1
                fi
                
                # Convert kebab-case to UPPER_SNAKE_CASE
                key=$(echo "$key" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
                eval "ARG_${key}=\"${value}\""
                shift 2
                ;;
            *)
                error "Unknown argument: $1"
                return 1
                ;;
        esac
    done
    
    return 0
}
