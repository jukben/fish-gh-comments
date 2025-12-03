# fish-get-comments

Get GitHub PR review comments from the command line. Fish-compatible [rewrite](https://github.com/cli/cli/issues/5788#issuecomment-3491834672) (AI) from @amingilani.

## Installation

Install with [Fisher](https://github.com/jorgebucaran/fisher):

```fish
fisher install jukben/fish-gh-comments
```

## Requirements

- [GitHub CLI](https://cli.github.com/) (`gh`)
- [jq](https://stedolan.github.io/jq/)

## Usage

```fish
gh_comments [--no-bots] [reviewer] [owner/repo] [pr_number]
```

### Arguments

- `--no-bots` - Optional flag to exclude bot comments (e.g., Copilot)
- `reviewer` - Optional GitHub username to filter comments by
- `owner/repo` - Optional repository in owner/repo format (auto-detected if omitted)
- `pr_number` - Optional PR number (auto-detected from current branch if omitted)

### Examples

```fish
# Get all comments including bots (default)
gh_comments

# Get only human comments
gh_comments --no-bots

# Get comments from specific reviewer (includes bots)
gh_comments copilot

# Get comments from specific human reviewer
gh_comments --no-bots johndoe

# Full specification
gh_comments --no-bots johndoe facebook/react 12345

# Just Copilot comments with auto-detection
gh_comments copilot
```

## License

MIT
