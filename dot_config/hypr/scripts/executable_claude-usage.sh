#!/bin/bash
# Claude Code Usage for DMS statusbar

CREDS_FILE="$HOME/.claude/.credentials.json"

if [[ ! -f "$CREDS_FILE" ]]; then
    echo "N/A"
    exit 0
fi

TOKEN=$(jq -r '.claudeAiOauth.accessToken' "$CREDS_FILE" 2>/dev/null)

if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
    echo "N/A"
    exit 0
fi

RESPONSE=$(curl -s --max-time 10 "https://api.anthropic.com/api/oauth/usage" \
    -H "Authorization: Bearer $TOKEN" \
    -H "anthropic-beta: oauth-2025-04-20" 2>/dev/null)

if [[ -z "$RESPONSE" || "$RESPONSE" == *"error"* ]]; then
    echo "..."
    exit 0
fi

# Parse values
FIVE_HOUR=$(echo "$RESPONSE" | jq -r '.five_hour.utilization // empty' 2>/dev/null)
FIVE_RESET=$(echo "$RESPONSE" | jq -r '.five_hour.resets_at // empty' 2>/dev/null)
SEVEN_DAY=$(echo "$RESPONSE" | jq -r '.seven_day.utilization // empty' 2>/dev/null)
SEVEN_RESET=$(echo "$RESPONSE" | jq -r '.seven_day.resets_at // empty' 2>/dev/null)

# Calculate time until reset
format_time_diff() {
    local reset_time="$1"
    if [[ -z "$reset_time" || "$reset_time" == "null" ]]; then
        echo "?"
        return
    fi

    local reset_epoch=$(date -d "$reset_time" +%s 2>/dev/null)
    local now_epoch=$(date +%s)
    local diff=$((reset_epoch - now_epoch))

    if [[ $diff -lt 0 ]]; then
        echo "0m"
        return
    fi

    local days=$((diff / 86400))
    local hours=$(((diff % 86400) / 3600))
    local mins=$(((diff % 3600) / 60))

    if [[ $days -gt 0 ]]; then
        echo "${days}d${hours}h"
    elif [[ $hours -gt 0 ]]; then
        echo "${hours}h${mins}m"
    else
        echo "${mins}m"
    fi
}

FIVE_TIME=$(format_time_diff "$FIVE_RESET")
SEVEN_TIME=$(format_time_diff "$SEVEN_RESET")

if [[ -n "$FIVE_HOUR" ]]; then
    printf "● %.0f%% ↻%s │ ○ %.0f%% ↻%s" "$FIVE_HOUR" "$FIVE_TIME" "$SEVEN_DAY" "$SEVEN_TIME"
else
    echo "N/A"
fi
