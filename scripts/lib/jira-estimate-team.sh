#!/usr/bin/env bash
# Team-Specific AI Story Point Estimation Library
# Racing Value Stream (RVS) Team
#
# Team Context:
# - Sprint: 2 weeks (10 working days)
# - Scale: 0.5, 1, 2, 3, 4, 5 (linear, not Fibonacci)
# - 1 Story Point = 7 Focus Hours
# - Philosophy %: Individual capacity per sprint
#
# Estimation Formula: base + complexity + uncertainty + testing
# Where:
#   - base: 0.5 (bug/fix) or 1.0 (story/task)
#   - complexity: 0-2 (low=0, medium=1, high=2)
#   - uncertainty: 0-1 (none=0, medium=0.5, high=1)
#   - testing: 0-1 (none=0, unit=0.5, integration=1)

# Complexity keyword arrays (using simple arrays instead of associative for compatibility)
HIGH_COMPLEXITY_KEYWORDS=(
    "framework upgrade"
    "migration"
    "refactor"
    "architecture"
    "third-party"
    "external api"
    "integration"
    "webhook"
    "security"
    "authentication"
    "authorization"
    "encryption"
    "performance"
    "optimization"
    "caching"
    "async"
    "spring boot"
    "framework"
)

MEDIUM_COMPLEXITY_KEYWORDS=(
    "database"
    "schema"
    "query"
    "endpoint"
    "api"
    "business logic"
    "validation"
    "error handling"
    "multiple"
    "several"
    "various"
    "component"
    "service"
    "connector"
)

LOW_COMPLEXITY_KEYWORDS=(
    "simple"
    "minor"
    "small"
    "quick"
    "easy"
    "config"
    "configuration"
    "setting"
    "flag"
    "typo"
    "label"
    "text"
    "wording"
)

UNCERTAINTY_HIGH_KEYWORDS=(
    "unclear"
    "unknown"
    "investigate"
    "research"
    "might need"
    "possibly"
    "maybe"
    "tbd"
    "to be determined"
    "needs clarification"
    "not sure"
)

UNCERTAINTY_MEDIUM_KEYWORDS=(
    "explore"
    "consider"
    "evaluate"
    "assess"
    "dependent on"
    "depends on"
    "requires"
)

# Keywords that REDUCE uncertainty (reference implementations exist)
UNCERTAINTY_REDUCING_KEYWORDS=(
    "reference"
    "similar"
    "like"
    "same as"
    "follow"
    "based on"
    "example"
    "template"
    "pattern"
    "precedent"
    "already done"
    "previously"
)

BUG_KEYWORDS=(
    "bug"
    "fix"
    "defect"
    "issue"
    "broken"
    "error"
)

CONFIG_KEYWORDS=(
    "config"
    "configuration"
    "setting"
    "environment"
    "env"
)

# Main team estimation function
# Usage: estimate_story_points_team "$ticket_json"
# Returns: JSON with estimated points and reasoning
estimate_story_points_team() {
    local ticket_data="$1"
    
    if [ -z "$ticket_data" ]; then
        echo '{"error": "Ticket data is required"}' >&2
        return 1
    fi
    
    # Extract fields from ticket JSON
    local summary=$(echo "$ticket_data" | jq -r '.fields.summary // ""' | tr '[:upper:]' '[:lower:]')
    local description=$(echo "$ticket_data" | jq -r '.fields.description // ""' | tr '[:upper:]' '[:lower:]')
    local issue_type=$(echo "$ticket_data" | jq -r '.fields.issuetype.name // "Story"')
    
    # Combine summary and description for analysis
    local combined_text="$summary $description"
    
    # Calculate base points
    local base_points=$(calculate_base_points_team "$summary" "$issue_type")
    
    # Calculate complexity factor (0-2)
    local complexity=$(calculate_complexity_factor_team "$combined_text")
    
    # Calculate uncertainty factor (0-1)
    local uncertainty=$(calculate_uncertainty_factor_team "$description")
    
    # Calculate testing factor (0-1)
    local testing=$(calculate_testing_factor_team "$combined_text" "$complexity")
    
    # Calculate total
    local total=$(echo "$base_points + $complexity + $uncertainty + $testing" | bc -l)
    
    # Round to team scale
    local final_points=$(round_to_team_scale "$total")
    
    # Check if should suggest breakdown
    local should_split=$(should_suggest_breakdown "$final_points")
    
    # Determine confidence level
    local confidence=$(calculate_confidence "$complexity" "$uncertainty")
    
    # Format reasoning
    local reasoning=$(format_estimation_reasoning_team "$base_points" "$complexity" "$uncertainty" "$testing" "$final_points")
    
    # Return JSON
    cat << EOF
{
  "estimated_points": $final_points,
  "breakdown": {
    "base": $base_points,
    "complexity": $complexity,
    "uncertainty": $uncertainty,
    "testing": $testing,
    "total_raw": $total
  },
  "reasoning": "$reasoning",
  "should_split": $should_split,
  "confidence": "$confidence"
}
EOF
}

# Calculate base points based on ticket type
# Bug/fix = 0.5, Story/Task = 1.0
calculate_base_points_team() {
    local summary="$1"
    local issue_type="$2"
    
    # Check if it's a bug or fix
    for keyword in "${BUG_KEYWORDS[@]}"; do
        if [[ "$summary" == *"$keyword"* ]]; then
            echo "0.5"
            return 0
        fi
    done
    
    # Check issue type
    if [[ "$issue_type" == "Bug" ]]; then
        echo "0.5"
    else
        echo "1.0"
    fi
}

# Calculate complexity factor (0-2 points)
calculate_complexity_factor_team() {
    local text="$1"
    
    # Check if there's a reference implementation (reduces complexity)
    local has_reference=false
    for keyword in "${UNCERTAINTY_REDUCING_KEYWORDS[@]}"; do
        if [[ "$text" == *"$keyword"* ]]; then
            has_reference=true
            break
        fi
    done
    
    # Check for HIGH complexity keywords
    for keyword in "${HIGH_COMPLEXITY_KEYWORDS[@]}"; do
        if [[ "$text" == *"$keyword"* ]]; then
            # If reference exists, reduce HIGH to MEDIUM
            if [[ "$has_reference" == true ]]; then
                echo "1.0"
            else
                echo "2.0"
            fi
            return 0
        fi
    done
    
    # Check for MEDIUM complexity keywords
    for keyword in "${MEDIUM_COMPLEXITY_KEYWORDS[@]}"; do
        if [[ "$text" == *"$keyword"* ]]; then
            echo "1.0"
            return 0
        fi
    done
    
    # Check for LOW complexity keywords
    for keyword in "${LOW_COMPLEXITY_KEYWORDS[@]}"; do
        if [[ "$text" == *"$keyword"* ]]; then
            echo "0"
            return 0
        fi
    done
    
    # Default to medium-low complexity
    echo "0.5"
}

# Calculate uncertainty factor (0-1 points)
calculate_uncertainty_factor_team() {
    local description="$1"
    
    # First check for REDUCING keywords (reference implementation exists)
    for keyword in "${UNCERTAINTY_REDUCING_KEYWORDS[@]}"; do
        if [[ "$description" == *"$keyword"* ]]; then
            # Reference exists - no uncertainty
            echo "0"
            return 0
        fi
    done
    
    # Check for HIGH uncertainty
    for keyword in "${UNCERTAINTY_HIGH_KEYWORDS[@]}"; do
        if [[ "$description" == *"$keyword"* ]]; then
            echo "1.0"
            return 0
        fi
    done
    
    # Check for MEDIUM uncertainty
    for keyword in "${UNCERTAINTY_MEDIUM_KEYWORDS[@]}"; do
        if [[ "$description" == *"$keyword"* ]]; then
            echo "0.5"
            return 0
        fi
    done
    
    # No uncertainty indicators
    echo "0"
}

# Calculate testing factor (0-1 points)
calculate_testing_factor_team() {
    local text="$1"
    local complexity="$2"
    
    # High complexity tasks need integration/E2E tests
    if (( $(echo "$complexity >= 2.0" | bc -l) )); then
        echo "1.0"
        return 0
    fi
    
    # Check if it's a config/setting change (no tests needed)
    for keyword in "${CONFIG_KEYWORDS[@]}"; do
        if [[ "$text" == *"$keyword"* ]] && [[ "$text" == *"simple"* ]]; then
            echo "0"
            return 0
        fi
    done
    
    # Default to unit tests
    echo "0.5"
}

# Round raw points to team scale (0.5, 1, 2, 3, 4, 5)
round_to_team_scale() {
    local raw_points="$1"
    
    if (( $(echo "$raw_points <= 0.75" | bc -l) )); then
        echo "0.5"
    elif (( $(echo "$raw_points <= 1.5" | bc -l) )); then
        echo "1"
    elif (( $(echo "$raw_points <= 2.5" | bc -l) )); then
        echo "2"
    elif (( $(echo "$raw_points <= 3.5" | bc -l) )); then
        echo "3"
    elif (( $(echo "$raw_points <= 4.5" | bc -l) )); then
        echo "4"
    else
        echo "5"
    fi
}

# Check if task should be broken down (4-5 points)
should_suggest_breakdown() {
    local points="$1"
    
    if (( $(echo "$points >= 4" | bc -l) )); then
        echo "true"
    else
        echo "false"
    fi
}

# Calculate confidence level based on complexity and uncertainty
calculate_confidence() {
    local complexity="$1"
    local uncertainty="$2"
    
    local total=$(echo "$complexity + $uncertainty" | bc -l)
    
    if (( $(echo "$total <= 1.0" | bc -l) )); then
        echo "high"
    elif (( $(echo "$total <= 2.0" | bc -l) )); then
        echo "medium"
    else
        echo "low"
    fi
}

# Format estimation reasoning as human-readable text
format_estimation_reasoning_team() {
    local base="$1"
    local complexity="$2"
    local uncertainty="$3"
    local testing="$4"
    local final="$5"
    
    local focus_hours=$(echo "$final * 7" | bc -l)
    focus_hours=$(printf "%.0f" "$focus_hours")
    
    local reasoning=""
    
    # Base points explanation
    if (( $(echo "$base == 0.5" | bc -l) )); then
        reasoning+="Base: 0.5 point (bug fix/small change)\\n"
    else
        reasoning+="Base: 1 point (new feature/story)\\n"
    fi
    
    # Complexity explanation
    if (( $(echo "$complexity == 0" | bc -l) )); then
        reasoning+="Complexity: +0 (simple task)\\n"
    elif (( $(echo "$complexity == 0.5" | bc -l) )); then
        reasoning+="Complexity: +0.5 (standard implementation)\\n"
    elif (( $(echo "$complexity == 1.0" | bc -l) )); then
        reasoning+="Complexity: +1 (moderate - database/API)\\n"
    elif (( $(echo "$complexity == 2.0" | bc -l) )); then
        reasoning+="Complexity: +2 (high - framework/integration)\\n"
    fi
    
    # Uncertainty explanation
    if (( $(echo "$uncertainty > 0" | bc -l) )); then
        if (( $(echo "$uncertainty == 0.5" | bc -l) )); then
            reasoning+="Uncertainty: +0.5 (some unknowns)\\n"
        else
            reasoning+="Uncertainty: +1 (significant unknowns)\\n"
        fi
    fi
    
    # Testing explanation
    if (( $(echo "$testing == 0" | bc -l) )); then
        reasoning+="Testing: +0 (no test changes)\\n"
    elif (( $(echo "$testing == 0.5" | bc -l) )); then
        reasoning+="Testing: +0.5 (unit tests)\\n"
    else
        reasoning+="Testing: +1 (integration + E2E)\\n"
    fi
    
    # Total with philosophy context
    local focus_days=$(echo "scale=1; $final / 1" | bc -l)
    local working_days=$(echo "scale=0; $focus_days * 2" | bc -l)  # Assuming 50% philosophy
    
    reasoning+="Total: $final points (~$focus_hours focus hours / $focus_days focus days)\\n"
    reasoning+="With 50% philosophy: ~$working_days working days"
    
    echo "$reasoning"
}

# Generate team estimation explanation with philosophy context
generate_team_estimation_explanation() {
    local estimate="$1"
    local summary="$2"
    
    local focus_hours=$(echo "$estimate * 7" | bc -l)
    focus_hours=$(printf "%.0f" "$focus_hours")
    
    case $estimate in
        0.5)
            echo "**Team Estimate: 0.5 Story Point** (~4 focus hours / 0.5 focus days / 1 working day)"
            echo ""
            echo "This is a minimal change. Typically includes:"
            echo "• Bug fixes"
            echo "• Config/setting changes"
            echo "• Minor text/label updates"
            echo ""
            echo "**Sprint Context:** 8% of 2-week sprint capacity (with 50% philosophy)"
            ;;
        1)
            echo "**Team Estimate: 1 Story Point** (~7 focus hours / 1 focus day / 2 working days)"
            echo ""
            echo "This is a small task. Typically includes:"
            echo "• Simple feature implementation"
            echo "• Standard bug fix with tests"
            echo "• Minor enhancements"
            echo ""
            echo "**Sprint Context:** 17% of 2-week sprint capacity (with 50% philosophy)"
            ;;
        2)
            echo "**Team Estimate: 2 Story Points** (~14 focus hours / 2 focus days / 4 working days)"
            echo ""
            echo "This is a standard story. Typically includes:"
            echo "• Feature across 2-3 files"
            echo "• Database changes with tests"
            echo "• API endpoint with validation"
            echo ""
            echo "**Sprint Context:** 33% of 2-week sprint capacity (with 50% philosophy)"
            ;;
        3)
            echo "**Team Estimate: 3 Story Points** (~21 focus hours / 3 focus days / 6 working days)"
            echo ""
            echo "This is a moderate feature. Typically includes:"
            echo "• Multiple component changes"
            echo "• Integration work"
            echo "• Moderate testing needs"
            echo ""
            echo "**Sprint Context:** 50% of 2-week sprint capacity (with 50% philosophy)"
            ;;
        4)
            echo "**Team Estimate: 4 Story Points** (~28 focus hours / 4 focus days / 8 working days)"
            echo ""
            echo "⚠️ This is a complex feature. Consider breaking down."
            echo ""
            echo "Typically includes:"
            echo "• Framework changes"
            echo "• Multiple integrations"
            echo "• Extensive testing"
            echo ""
            echo "**Sprint Context:** 67% of 2-week sprint capacity (with 50% philosophy)"
            echo ""
            echo "**Suggestion:** Break into 2 stories (2 points each)"
            ;;
        5)
            echo "**Team Estimate: 5 Story Points** (~35 focus hours / 5 focus days / 10 working days)"
            echo ""
            echo "⚠️ **This is very large. Should be split into smaller tasks.**"
            echo ""
            echo "Typically includes:"
            echo "• Major architecture changes"
            echo "• Framework upgrades"
            echo "• Multiple dependencies"
            echo ""
            echo "**Sprint Context:** 83% of 2-week sprint capacity (with 50% philosophy)"
            echo ""
            echo "**Suggestion:** Break into 2-3 smaller stories (1-2 points each)"
            ;;
    esac
    
    echo ""
    echo "---"
    echo "**Team Scale:** 0.5, 1, 2, 3, 4, 5 (linear)"
    echo "**Formula:** 1 Story Point = 7 Focus Hours = 1 Focus Day"
    echo "**Philosophy:** 50% = 1 Focus Day requires 2 Working Days"
    echo "**Sprint:** 2 weeks (10 working days, 80 hours total)"
    echo ""
    echo "*Note: Actual capacity varies by Philosophy % (e.g., 50% = 6 points/sprint)*"
}

# Helper function to analyze complexity keywords in text
analyze_complexity_team() {
    local summary="$1"
    local description="$2"
    
    local combined="$summary $description"
    combined=$(echo "$combined" | tr '[:upper:]' '[:lower:]')
    
    local high_count=0
    local medium_count=0
    local low_count=0
    
    for keyword in "${HIGH_COMPLEXITY_KEYWORDS[@]}"; do
        if [[ "$combined" == *"$keyword"* ]]; then
            ((high_count++))
        fi
    done
    
    for keyword in "${MEDIUM_COMPLEXITY_KEYWORDS[@]}"; do
        if [[ "$combined" == *"$keyword"* ]]; then
            ((medium_count++))
        fi
    done
    
    for keyword in "${LOW_COMPLEXITY_KEYWORDS[@]}"; do
        if [[ "$combined" == *"$keyword"* ]]; then
            ((low_count++))
        fi
    done
    
    cat << EOF
{
  "high_complexity_matches": $high_count,
  "medium_complexity_matches": $medium_count,
  "low_complexity_matches": $low_count
}
EOF
}

# Export team functions
export -f estimate_story_points_team
export -f calculate_base_points_team
export -f calculate_complexity_factor_team
export -f calculate_uncertainty_factor_team
export -f calculate_testing_factor_team
export -f round_to_team_scale
export -f should_suggest_breakdown
export -f calculate_confidence
export -f format_estimation_reasoning_team
export -f generate_team_estimation_explanation
export -f analyze_complexity_team
