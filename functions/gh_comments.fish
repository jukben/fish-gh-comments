function gh_comments --description "Get PR review comments from GitHub"
    # Fetches code review comments (inline comments on diffs) from a GitHub PR.
    # Auto-detects repo and PR number from current directory/branch if not provided.
    #
    # Usage:
    #   gh_comments [--no-bots] [reviewer] [owner/repo] [pr_number]
    #
    # Arguments:
    #   --no-bots    Optional flag to exclude bot comments (e.g., Copilot)
    #   reviewer     Optional GitHub username to filter comments by
    #   owner/repo   Optional repository in owner/repo format (auto-detected if omitted)
    #   pr_number    Optional PR number (auto-detected from current branch if omitted)
    #
    # Examples:
    #   # Get all comments including bots (default)
    #   gh_comments
    #
    #   # Get only human comments
    #   gh_comments --no-bots
    #
    #   # Get comments from specific reviewer (includes bots)
    #   gh_comments copilot
    #
    #   # Get comments from specific human reviewer
    #   gh_comments --no-bots johndoe
    #
    #   # Full specification
    #   gh_comments --no-bots johndoe facebook/react 12345
    #
    #   # Just Copilot comments with auto-detection
    #   gh_comments copilot

    set -l no_bots false
    set -l reviewer ""
    set -l repo ""
    set -l pr_number ""

    # Parse --no-bots flag
    if test "$argv[1]" = "--no-bots"
        set no_bots true
        set -e argv[1]
    end

    # Assign remaining arguments
    if set -q argv[1]
        set reviewer $argv[1]
    end
    if set -q argv[2]
        set repo $argv[2]
    end
    if set -q argv[3]
        set pr_number $argv[3]
    end

    # Auto-detect repo if not provided
    if test -z "$repo"
        echo "No repo specified, detecting from current directory..."
        set repo (gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
        if test -z "$repo"
            echo "Error: Could not detect repository. Please specify <owner/repo>" >&2
            echo "Usage: gh_comments [--no-bots] [reviewer] [owner/repo] [pr_number]" >&2
            return 1
        end
        echo "Detected repo: $repo"
    end

    # Auto-detect PR number if not provided
    if test -z "$pr_number"
        echo "No PR number specified, detecting from current branch..."
        set pr_number (gh pr view --json number -q .number 2>/dev/null)
        if test -z "$pr_number"
            echo "Error: Could not detect PR number. Please specify PR number or checkout a branch with an associated PR" >&2
            echo "Usage: gh_comments [--no-bots] [reviewer] [owner/repo] [pr_number]" >&2
            return 1
        end
        echo "Detected PR #$pr_number"
    end

    # Output filter status
    if test "$no_bots" = true
        echo "Filtering: humans only (no bots)"
    else
        echo "Filtering: including bots (Copilot, etc.)"
    end

    if test -n "$reviewer"
        echo "Filtering comments by reviewer: $reviewer"
    else
        echo "No reviewer filter specified, showing all comments"
    end

    # Build jq filter based on flags
    set -l jq_filter
    if test "$no_bots" = true
        # Filter for humans only
        if test -n "$reviewer"
            set jq_filter '[ .[] | select(.user.type == "User" and .user.login == $user) | { user: .user.login, diff_hunk, line, start_line, body } ]'
        else
            set jq_filter '[ .[] | select(.user.type == "User") | { user: .user.login, diff_hunk, line, start_line, body } ]'
        end
    else
        # Include bots (default)
        if test -n "$reviewer"
            set jq_filter '[ .[] | select(.user.login == $user) | { user: .user.login, diff_hunk, line, start_line, body } ]'
        else
            set jq_filter '[ .[] | { user: .user.login, diff_hunk, line, start_line, body } ]'
        end
    end

    # Execute API call with appropriate filter
    if test -n "$reviewer"
        gh api "repos/$repo/pulls/$pr_number/comments" | jq --arg user "$reviewer" "$jq_filter"
    else
        gh api "repos/$repo/pulls/$pr_number/comments" | jq "$jq_filter"
    end
end