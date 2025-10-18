# JIRA Search Library Documentation

## Overview

The `jira-search.sh` library provides reusable functions for searching JIRA tickets using JQL (JIRA Query Language). This library simplifies common search operations and makes it easy to integrate JIRA searches into your scripts.

## Location

- **Library:** `scripts/lib/jira-search.sh`
- **Example Script:** `scripts/find-related-tickets.sh`

## Quick Start

```bash
# In your script
source scripts/lib/jira-search.sh

# Search for tickets
results=$(jira_search "project = RVV AND text ~ \"spring boot\"")

# Extract and display
jira_extract_summaries "$results"
```

## Core Functions

### 1. `jira_search`

General-purpose JQL search function.

**Syntax:**
```bash
jira_search JQL_QUERY [FIELDS] [MAX_RESULTS]
```

**Arguments:**
- `JQL_QUERY` (required): JQL query string
- `FIELDS` (optional): Comma-separated fields to retrieve (default: "summary,issuetype,status,description")
- `MAX_RESULTS` (optional): Maximum number of results (default: 50)

**Returns:** JSON response from JIRA search API

**Examples:**
```bash
# Basic search
results=$(jira_search "project = RVV AND status = Open")

# Custom fields
results=$(jira_search "project = RVV" "summary,assignee,priority")

# Custom max results
results=$(jira_search "project = RVV" "summary" 100)
```

### 2. `jira_search_by_epic`

Search for tickets linked to a specific epic.

**Syntax:**
```bash
jira_search_by_epic EPIC_KEY [ADDITIONAL_FILTERS] [MAX_RESULTS]
```

**Arguments:**
- `EPIC_KEY` (required): Epic key (e.g., "RVV-1178")
- `ADDITIONAL_FILTERS` (optional): Additional JQL filters
- `MAX_RESULTS` (optional): Maximum results (default: 100)

**Examples:**
```bash
# All tickets under epic
results=$(jira_search_by_epic "RVV-1178")

# Filter Spring Boot tickets under epic
results=$(jira_search_by_epic "RVV-1178" 'AND text ~ "spring boot"')

# Exclude .NET tickets
results=$(jira_search_by_epic "RVV-1178" 'AND NOT text ~ ".NET"')
```

### 3. `jira_search_by_text`

Search for tickets containing specific text in a project.

**Syntax:**
```bash
jira_search_by_text PROJECT_KEY SEARCH_TEXT [ADDITIONAL_FILTERS] [MAX_RESULTS]
```

**Arguments:**
- `PROJECT_KEY` (required): Project key (e.g., "RVV")
- `SEARCH_TEXT` (required): Text to search for
- `ADDITIONAL_FILTERS` (optional): Additional JQL filters
- `MAX_RESULTS` (optional): Maximum results (default: 50)

**Examples:**
```bash
# Search for Spring Boot tickets
results=$(jira_search_by_text "RVV" "spring boot upgrade")

# Search with status filter
results=$(jira_search_by_text "RVV" "upgrade" 'AND status = "In Progress"')
```

## Helper Functions

### 4. `jira_extract_keys`

Extract ticket keys from search results.

**Syntax:**
```bash
jira_extract_keys SEARCH_RESULTS
```

**Returns:** List of ticket keys (one per line)

**Example:**
```bash
results=$(jira_search "project = RVV")
keys=$(jira_extract_keys "$results")
echo "$keys"
# Output:
# RVV-1171
# RVV-1174
# RVV-1175
```

### 5. `jira_extract_summaries`

Extract ticket keys and summaries from search results.

**Syntax:**
```bash
jira_extract_summaries SEARCH_RESULTS
```

**Returns:** List of "KEY: Summary" (one per line)

**Example:**
```bash
results=$(jira_search "project = RVV")
jira_extract_summaries "$results"
# Output:
# RVV-1171: [Betmaker Feed Ingestor] Spring boot upgrade
# RVV-1174: [Betmaker Feed Adapter] Spring boot upgrade
```

### 6. `jira_search_count`

Get total count of search results.

**Syntax:**
```bash
jira_search_count SEARCH_RESULTS
```

**Returns:** Total count number

**Example:**
```bash
results=$(jira_search "project = RVV")
count=$(jira_search_count "$results")
echo "Found $count tickets"
```

### 7. `jira_search_filter_by_summary`

Filter search results by summary pattern.

**Syntax:**
```bash
jira_search_filter_by_summary SEARCH_RESULTS GREP_PATTERN
```

**Arguments:**
- `SEARCH_RESULTS`: JSON search results
- `GREP_PATTERN`: Pattern to match (case-insensitive)

**Returns:** Filtered JSON with matching tickets

**Example:**
```bash
results=$(jira_search "project = RVV")
spring_only=$(jira_search_filter_by_summary "$results" "Spring Boot")
jira_extract_summaries "$spring_only"
```

## Using the `find-related-tickets.sh` Script

The example script demonstrates how to use the library with a user-friendly CLI.

### Basic Usage

```bash
# Find all tickets under an epic
./scripts/find-related-tickets.sh -e RVV-1178

# Find Spring Boot tickets
./scripts/find-related-tickets.sh -p RVV -t "spring boot upgrade"

# Find Spring Boot tickets under an epic
./scripts/find-related-tickets.sh -e RVV-1178 -f 'AND text ~ "spring boot"'

# Save results to file
./scripts/find-related-tickets.sh -e RVV-1178 -o .temp/tickets.txt
```

### Command-Line Options

| Option | Description | Example |
|--------|-------------|---------|
| `-e, --epic` | Epic key to search under | `-e RVV-1178` |
| `-t, --text` | Text to search for | `-t "spring boot"` |
| `-p, --project` | Project key (default: RVV) | `-p RVV` |
| `-f, --filter` | Additional JQL filter | `-f 'AND status = Open'` |
| `-o, --output` | Save ticket keys to file | `-o .temp/tickets.txt` |
| `-h, --help` | Show help message | `-h` |

## Common Use Cases

### 1. Find Spring Boot Upgrade Tickets

```bash
# Method 1: Using the script
./scripts/find-related-tickets.sh -e RVV-1178 -f 'AND text ~ "spring boot"' -o .temp/spring-boot-tickets.txt

# Method 2: Using the library directly
source scripts/lib/jira-search.sh
results=$(jira_search_by_epic "RVV-1178" 'AND text ~ "spring boot"')
jira_extract_keys "$results" > .temp/spring-boot-tickets.txt
```

### 2. Batch Groom Tickets

```bash
# Find tickets
./scripts/find-related-tickets.sh -e RVV-1178 -o .temp/tickets.txt

# Groom each ticket
while read -r ticket; do
    echo "Grooming $ticket..."
    ./scripts/jira-groom.sh "$ticket"
done < .temp/tickets.txt
```

### 3. Filter by Multiple Criteria

```bash
source scripts/lib/jira-search.sh

# Find open Spring Boot tickets assigned to specific user
results=$(jira_search 'project = RVV AND text ~ "spring boot" AND status = Open AND assignee = currentUser()')

# Display summary
total=$(jira_search_count "$results")
echo "Found $total tickets:"
jira_extract_summaries "$results"
```

### 4. Generate Report

```bash
source scripts/lib/jira-search.sh

echo "# Spring Boot Upgrade Status Report" > report.md
echo "" >> report.md

results=$(jira_search_by_epic "RVV-1178" 'AND text ~ "spring boot"')
total=$(jira_search_count "$results")

echo "Total tickets: $total" >> report.md
echo "" >> report.md
echo "## Tickets" >> report.md
jira_extract_summaries "$results" | while read -r line; do
    echo "- $line" >> report.md
done

cat report.md
```

## Integration Examples

### Example 1: Custom Search Script

```bash
#!/usr/bin/env bash
set -euo pipefail

source scripts/lib/jira-search.sh
source scripts/lib/utils.sh

# Find all upgrade tickets
info "Searching for upgrade tickets..."
results=$(jira_search_by_text "RVV" "upgrade")

# Filter Spring Boot only
spring_results=$(jira_search_filter_by_summary "$results" "Spring Boot")

# Display results
total=$(jira_search_count "$spring_results")
success "Found $total Spring Boot upgrade tickets:"
jira_extract_summaries "$spring_results"
```

### Example 2: Automated Grooming Pipeline

```bash
#!/usr/bin/env bash
set -euo pipefail

source scripts/lib/jira-search.sh

# Find all ungroomed tickets
results=$(jira_search 'project = RVV AND description !~ "COPILOT_GENERATED"')

# Process each ticket
jira_extract_keys "$results" | while read -r ticket; do
    echo "Processing $ticket..."
    ./scripts/jira-groom.sh "$ticket" --ai-description
done
```

## JQL Query Examples

Here are some useful JQL queries you can use with `jira_search`:

```bash
# All open tickets in project
jira_search "project = RVV AND status = Open"

# Tickets assigned to me
jira_search "assignee = currentUser() AND status != Done"

# Tickets created this week
jira_search "project = RVV AND created >= -1w"

# High priority bugs
jira_search "project = RVV AND issuetype = Bug AND priority = High"

# Tickets without description
jira_search "project = RVV AND description is EMPTY"

# Tickets with Copilot-generated content
jira_search 'project = RVV AND description ~ "COPILOT_GENERATED"'

# Spring Boot tickets excluding .NET
jira_search 'project = RVV AND text ~ "spring boot" AND NOT text ~ ".NET"'
```

## Error Handling

The library includes built-in error handling:

```bash
# Example error handling
if results=$(jira_search "invalid jql"); then
    jira_extract_summaries "$results"
else
    echo "Search failed"
    exit 1
fi
```

## Best Practices

1. **Always source required libraries:**
   ```bash
   source scripts/lib/utils.sh
   source scripts/lib/jira-api.sh
   source scripts/lib/jira-search.sh
   ```

2. **Load environment variables:**
   ```bash
   load_env .env
   ```

3. **Quote your variables:**
   ```bash
   results=$(jira_search "$jql_query")
   ```

4. **Check result count before processing:**
   ```bash
   count=$(jira_search_count "$results")
   if [[ $count -eq 0 ]]; then
       echo "No tickets found"
       exit 0
   fi
   ```

5. **Save intermediate results:**
   ```bash
   results=$(jira_search "project = RVV")
   echo "$results" > .temp/search-results.json
   ```

## Performance Tips

1. **Limit fields to reduce payload:**
   ```bash
   # Only get what you need
   results=$(jira_search "project = RVV" "summary,key")
   ```

2. **Use appropriate max results:**
   ```bash
   # Don't fetch more than needed
   results=$(jira_search "project = RVV" "summary" 10)
   ```

3. **Cache results when possible:**
   ```bash
   CACHE_FILE=".temp/search-cache.json"
   if [[ -f "$CACHE_FILE" ]]; then
       results=$(cat "$CACHE_FILE")
   else
       results=$(jira_search "project = RVV")
       echo "$results" > "$CACHE_FILE"
   fi
   ```

## Troubleshooting

### Common Issues

1. **Authentication errors:**
   - Ensure `JIRA_EMAIL` and `JIRA_TOKEN` are set in `.env`
   - Check token has not expired

2. **Invalid JQL:**
   - Test your JQL in JIRA web interface first
   - Use proper quoting for text searches

3. **No results:**
   - Check if tickets exist with the criteria
   - Verify project key is correct
   - Check permissions

4. **API errors:**
   - Library uses JIRA API v3 (not v2)
   - Check `JIRA_BASE_URL` is correct
   - Verify network connectivity

## See Also

- [JIRA REST API Documentation](https://developer.atlassian.com/cloud/jira/platform/rest/v3/)
- [JQL Reference](https://support.atlassian.com/jira-software-cloud/docs/use-advanced-search-with-jira-query-language-jql/)
- `jira-api.sh` - Core JIRA API functions
- `jira-groom.sh` - Ticket grooming script
