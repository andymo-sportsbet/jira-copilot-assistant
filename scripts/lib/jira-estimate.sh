#!/usr/bin/env bash
#
# AI-Powered Story Point Estimation
# Analyzes ticket content and suggests story point estimates
#

# Estimate story points based on ticket content
estimate_story_points() {
    local description="$1"
    local summary="$2"
    
    local points=0
    local factors=()
    
    # Analyze keywords for complexity
    if echo "$description $summary" | grep -qiE "upgrade|migration|framework|refactor|redesign|rewrite"; then
        points=$((points + 8))
        factors+=("Framework/major change: +8")
    fi
    
    if echo "$description $summary" | grep -qiE "new feature|implement|add support for"; then
        points=$((points + 5))
        factors+=("New feature: +5")
    fi
    
    if echo "$description $summary" | grep -qiE "bug fix|fix|resolve|patch"; then
        points=$((points + 2))
        factors+=("Bug fix: +2")
    fi
    
    if echo "$description $summary" | grep -qiE "config|configuration|settings|environment"; then
        points=$((points + 1))
        factors+=("Configuration change: +1")
    fi
    
    # Analyze scope
    if echo "$description $summary" | grep -qiE "multiple|several|various|all|across"; then
        points=$((points + 3))
        factors+=("Multiple systems/components: +3")
    fi
    
    # Analyze dependencies
    if echo "$description $summary" | grep -qiE "integration|external|api|third.?party|provider"; then
        points=$((points + 3))
        factors+=("External dependencies: +3")
    fi
    
    if echo "$description $summary" | grep -qiE "downstream|upstream|dependent|dependency"; then
        points=$((points + 2))
        factors+=("Internal dependencies: +2")
    fi
    
    # Analyze testing needs
    if echo "$description $summary" | grep -qiE "test|testing|validation|verify|validate"; then
        points=$((points + 2))
        factors+=("Testing requirements: +2")
    fi
    
    # Analyze risk/uncertainty
    if echo "$description $summary" | grep -qiE "critical|production|live|customer.?facing"; then
        points=$((points + 2))
        factors+=("Critical/production system: +2")
    fi
    
    if echo "$description $summary" | grep -qiE "unknown|unclear|investigate|research|explore"; then
        points=$((points + 3))
        factors+=("High uncertainty: +3")
    fi
    
    if echo "$description $summary" | grep -qiE "new technology|never done|unfamiliar"; then
        points=$((points + 5))
        factors+=("New technology: +5")
    fi
    
    # Analyze documentation needs
    if echo "$description $summary" | grep -qiE "document|documentation|guide|readme|wiki"; then
        points=$((points + 1))
        factors+=("Documentation: +1")
    fi
    
    # Negative factors (reduce complexity)
    if echo "$description $summary" | grep -qiE "simple|straightforward|trivial|minor|small"; then
        points=$((points - 2))
        factors+=("Marked as simple: -2")
    fi
    
    if echo "$description $summary" | grep -qiE "well.?known|familiar|standard|common pattern"; then
        points=$((points - 1))
        factors+=("Well-known pattern: -1")
    fi
    
    # Minimum 1 point
    if [[ $points -lt 1 ]]; then
        points=1
    fi
    
    # Map to Fibonacci sequence
    local fibonacci=(1 2 3 5 8 13 21 34 55)
    local estimate=1
    local min_diff=1000
    
    for fib in "${fibonacci[@]}"; do
        local diff=$((fib - points))
        if [[ $diff -lt 0 ]]; then
            diff=$((diff * -1))
        fi
        
        if [[ $diff -lt $min_diff ]]; then
            min_diff=$diff
            estimate=$fib
        fi
    done
    
    # Return estimate and factors
    echo "$estimate"
    
    # Print analysis to stderr so it doesn't interfere with the number return
    if [[ ${#factors[@]} -gt 0 ]]; then
        echo "AI Estimation Analysis:" >&2
        for factor in "${factors[@]}"; do
            echo "  • $factor" >&2
        done
        echo "  Raw score: $points → Fibonacci: $estimate" >&2
    fi
}

# Generate estimation explanation
generate_estimation_explanation() {
    local estimate="$1"
    local summary="${2:-}"
    
    case $estimate in
        1)
            echo "**Estimated Effort: 1 Story Point** (Trivial - 30min to 2 hours)"
            echo ""
            echo "This appears to be a simple change with minimal complexity. Typically includes:"
            echo "• Config changes"
            echo "• Documentation updates"
            echo "• Minor fixes"
            ;;
        2)
            echo "**Estimated Effort: 2 Story Points** (Simple - 2-4 hours)"
            echo ""
            echo "This appears to be a straightforward task. Typically includes:"
            echo "• Simple code changes"
            echo "• Bug fixes with tests"
            echo "• Minor enhancements"
            ;;
        3)
            echo "**Estimated Effort: 3 Story Points** (Small - 4-8 hours / ~1 day)"
            echo ""
            echo "This is a small feature or fix. Typically includes:"
            echo "• Feature in 1-2 files"
            echo "• Standard bug fix"
            echo "• API endpoint addition"
            ;;
        5)
            echo "**Estimated Effort: 5 Story Points** (Medium - 1-2 days)"
            echo ""
            echo "This is a medium-sized feature with moderate complexity. Typically includes:"
            echo "• Feature across multiple files"
            echo "• Some integration work"
            echo "• Moderate testing needs"
            ;;
        8)
            echo "**Estimated Effort: 8 Story Points** (Large - 2-3 days)"
            echo ""
            echo "This is a complex feature or significant change. Typically includes:"
            echo "• Multiple integrations"
            echo "• Refactoring work"
            echo "• Extensive testing"
            ;;
        13)
            echo "**Estimated Effort: 13 Story Points** (Very Large - 3-5 days)"
            echo ""
            echo "This is a major change or framework upgrade. Typically includes:"
            echo "• Framework/platform upgrades"
            echo "• Significant system changes"
            echo "• Multiple dependencies"
            echo "• Extensive validation"
            ;;
        21|34|55)
            echo "**Estimated Effort: $estimate Story Points** (Epic-sized - 1-2+ weeks)"
            echo ""
            echo "⚠️ **This ticket is very large and should be split into smaller tasks.**"
            echo ""
            echo "Consider breaking it down into:"
            echo "• Separate implementation phases"
            echo "• Individual components"
            echo "• Incremental deliverables"
            ;;
    esac
    
    echo ""
    echo "*Note: This is an AI-generated estimate based on ticket content. Team review recommended.*"
}

# Export functions
export -f estimate_story_points
export -f generate_estimation_explanation
