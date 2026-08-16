#!/usr/bin/env fish

# Star every resolved repository in an input file and add it to a GitHub star
# list. Existing list memberships are preserved. Finally, report remote list
# entries absent from the local input.
#
# Usage: ./star-develpkgs.fish <resolved-file> <list URL|OWNER/SLUG|SLUG>
# Example: ./star-develpkgs.fish develpkgs.github awesome-dev-tools

if test (count $argv) -ne 2
    echo "usage: "(status filename)" <resolved-file> <list URL|OWNER/SLUG|SLUG>" >&2
    exit 2
end

set -l input_file $argv[1]
set -l list_reference $argv[2]

if not test -r $input_file
    echo (status filename)": cannot read $input_file" >&2
    exit 2
end

if not command -q gh
    echo (status filename)": required command not found: gh" >&2
    exit 2
end

set -l authenticated_user (gh api user --jq .login)
if test $status -ne 0
    echo (status filename)": could not determine the authenticated GitHub user" >&2
    exit 1
end

set -l target_list_owner $authenticated_user
set -l target_list_slug
set -l list_parts (string match --regex --groups-only --ignore-case \
    '^https://github\.com/stars/([^/]+)/lists/([^/?#]+)/?(?:[?#].*)?$' -- $list_reference)
if test (count $list_parts) -eq 2
    set target_list_owner $list_parts[1]
    set target_list_slug $list_parts[2]
else
    set list_parts (string match --regex --groups-only '^([^/]+)/([^/]+)$' -- $list_reference)
    if test (count $list_parts) -eq 2
        set target_list_owner $list_parts[1]
        set target_list_slug $list_parts[2]
    else if string match --quiet --regex '^[^/]+$' -- $list_reference
        set target_list_slug $list_reference
    else
        echo (status filename)": invalid GitHub list: $list_reference" >&2
        exit 2
    end
end

if test (string lower -- $authenticated_user) != (string lower -- $target_list_owner)
    echo (status filename)": list owner is $target_list_owner, but gh is authenticated as $authenticated_user" >&2
    echo "GitHub only permits modifying the authenticated user's lists." >&2
    exit 1
end

# Updating GitHub star lists requires the classic OAuth `user` scope. Check it
# before starring anything so an insufficient token cannot cause a partial run.
set -l authenticated_scopes (gh auth status --active --hostname github.com \
    --json hosts --jq '.hosts["github.com"][] | select(.active).scopes')
set -l scope_list (string split , -- $authenticated_scopes | string trim)
if not contains -- user $scope_list
    echo (status filename)": the active gh token needs the 'user' scope" >&2
    echo "Grant it, then rerun this script:" >&2
    echo "  gh auth refresh --hostname github.com --scopes user" >&2
    exit 1
end

set -l input_repositories
set -l input_repositories_lower
while read --line line
    set -l fields (string split --max 1 \t -- $line)
    test (count $fields) -ge 2; or continue

    set -l url (string trim -- $fields[2])
    set -l repository (string match --regex --groups-only --ignore-case \
        '^https://github\.com/([^/]+/[^/]+?)(?:\.git)?/?$' -- $url)
    test (count $repository) -eq 1; or continue

    set -l repository_lower (string lower -- $repository)
    if not contains -- $repository_lower $input_repositories_lower
        set --append input_repositories $repository
        set --append input_repositories_lower $repository_lower
    end
end <$input_file

if test (count $input_repositories) -eq 0
    echo (status filename)": no GitHub repositories found in $input_file" >&2
    exit 1
end

# Get every user list. Pagination keeps this correct for accounts with more
# than 100 lists.
set -l lists_query '
query($endCursor: String) {
  viewer {
    lists(first: 100, after: $endCursor) {
      nodes { id slug }
      pageInfo { hasNextPage endCursor }
    }
  }
}'
set -l list_rows (gh api graphql --paginate -f query="$lists_query" \
    --jq '.data.viewer.lists.nodes[] | [.id, .slug] | @tsv')
if test $status -ne 0
    echo (status filename)": could not retrieve GitHub star lists" >&2
    exit 1
end

set -l list_ids
set -l target_list_id
for row in $list_rows
    set -l fields (string split \t -- $row)
    test (count $fields) -eq 2; or continue
    set --append list_ids $fields[1]
    if test $fields[2] = $target_list_slug
        set target_list_id $fields[1]
    end
end

if test -z "$target_list_id"
    echo (status filename)": GitHub star list '$target_list_slug' was not found" >&2
    exit 1
end

# Record every existing list membership so the update mutation cannot remove a
# repository from another list. Also collect the target list for the report.
set -l items_query '
query($listId: ID!, $endCursor: String) {
  node(id: $listId) {
    ... on UserList {
      items(first: 100, after: $endCursor) {
        nodes { ... on Repository { id nameWithOwner } }
        pageInfo { hasNextPage endCursor }
      }
    }
  }
}'
set -l membership_repository_ids
set -l membership_list_ids
set -l target_repositories

for list_id in $list_ids
    set -l item_rows (gh api graphql --paginate -f query="$items_query" \
        -F listId="$list_id" \
        --jq '.data.node.items.nodes[] | select(.id != null) | [.id, .nameWithOwner] | @tsv')
    if test $status -ne 0
        echo (status filename)": could not retrieve all existing list memberships; refusing an unsafe update" >&2
        exit 1
    end

    for row in $item_rows
        set -l fields (string split \t -- $row)
        test (count $fields) -eq 2; or continue
        set --append membership_repository_ids $fields[1]
        set --append membership_list_ids $list_id
        if test $list_id = $target_list_id
            set --append target_repositories $fields[2]
        end
    end
end

set -l repository_query '
query($owner: String!, $name: String!) {
  repository(owner: $owner, name: $name) { id nameWithOwner }
}'
set -l update_query '
mutation($itemId: ID!, $listIds: [ID!]!) {
  updateUserListsForItem(input: { itemId: $itemId, listIds: $listIds }) {
    clientMutationId
  }
}'
set -l failed_repositories

for repository in $input_repositories
    set -l name_parts (string split --max 1 / -- $repository)
    set -l repository_row (gh api graphql -f query="$repository_query" \
        -F owner="$name_parts[1]" -F name="$name_parts[2]" \
        --jq '.data.repository | select(.id != null) | [.id, .nameWithOwner] | @tsv')
    if test $status -ne 0 -o -z "$repository_row"
        echo "$repository: could not resolve repository" >&2
        set --append failed_repositories $repository
        continue
    end

    set -l repository_fields (string split \t -- $repository_row)
    set -l repository_id $repository_fields[1]
    set -l canonical_name $repository_fields[2]

    printf 'Starring and adding %s to %s ... ' $canonical_name $target_list_slug
    if not gh api --method PUT --silent "/user/starred/$canonical_name"
        echo failed
        set --append failed_repositories $canonical_name
        continue
    end

    set -l current_list_ids
    for index in (seq (count $membership_repository_ids))
        if test $membership_repository_ids[$index] = $repository_id
            set --append current_list_ids $membership_list_ids[$index]
        end
    end

    if contains -- $target_list_id $current_list_ids
        echo already-present
        continue
    end

    set --append current_list_ids $target_list_id
    set -l list_arguments
    for list_id in $current_list_ids
        set --append list_arguments -F "listIds[]=$list_id"
    end

    if gh api graphql -f query="$update_query" -F itemId="$repository_id" \
            $list_arguments --silent
        echo done
        set --append target_repositories $canonical_name
    else
        echo failed
        set --append failed_repositories $canonical_name
    end
end

set target_repositories (string join \n -- $target_repositories | sort --ignore-case --unique)
set -l repositories_not_in_input
for repository in $target_repositories
    if not contains -- (string lower -- $repository) $input_repositories_lower
        set --append repositories_not_in_input $repository
    end
end

if test (count $repositories_not_in_input) -eq 0
    echo "All repositories in $target_list_slug are present in $input_file."
else
    echo
    echo "Repositories in $target_list_slug that are not present in $input_file:"
    printf '%s\n' $repositories_not_in_input
end

if test (count $failed_repositories) -gt 0
    echo >&2
    echo "Failed to process: "(string join ', ' $failed_repositories) >&2
    exit 1
end
