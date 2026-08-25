#!/usr/bin/env bash
# List open GitHub pull requests that are waiting for my review.
#
# The queue uses GitHub's search qualifiers rather than the current working
# repository, so it can find review requests across all repositories.

set -euo pipefail

readonly SEARCH_FIELDS='number,title,url,repository,author,createdAt,updatedAt,isDraft,commentsCount'
readonly DEFAULT_LIMIT=100
readonly EXCLUDED_AUTHOR='aws5295'
readonly TYPE_WIDTH=18
readonly PR_WIDTH=30
readonly TITLE_WIDTH=70
readonly AGE_WIDTH=8
readonly IDLE_WIDTH=8
readonly AUTHOR_WIDTH=18
readonly META_WIDTH=24

limit="${GH_REVIEW_QUEUE_LIMIT:-$DEFAULT_LIMIT}"
include_mentions=1
print_only=0
now="${GH_REVIEW_QUEUE_NOW:-$(date +%s)}"

usage() {
  cat <<'USAGE'
Usage: github-reviews.sh [options]

Show open pull requests that request your review, plus pull requests that
mention you. The list is repository-wide and sorted by review urgency.

Options:
  --requested-only  Exclude PRs that only mention you
  --limit N         Fetch at most N results per search (default: 100)
  --print           Print the queue without starting fzf
  -h, --help        Show this help

Interactive controls:
  Enter             Open the selected PR in the browser
  Ctrl-V            View the selected PR in the terminal

Notes:
  "idle" is calculated from GitHub's updatedAt timestamp, which represents
  the last PR activity rather than strictly the last code commit.
  REQUIRED means GitHub reports a pending required review on a PR where you
  are also explicitly requested; GitHub does not expose whether that exact
  individual request is the branch-protection requirement.
  PRs authored by aws5295 are excluded from the queue. Team-only review
  requests are also excluded; direct user requests are verified separately
  because GitHub's review-requested search includes teams you belong to.
USAGE
}

die() {
  printf 'github-reviews: %s\n' "$1" >&2
  exit 1
}

column_header() {
  printf "%-${TYPE_WIDTH}s\t%-${PR_WIDTH}s\t%-${TITLE_WIDTH}s\t%${AGE_WIDTH}s\t%${IDLE_WIDTH}s\t%-${AUTHOR_WIDTH}s\t%-${META_WIDTH}s" \
    'TYPE' 'PR' 'TITLE' 'AGE' 'IDLE' 'AUTHOR' 'META'
}

while (($#)); do
  case "$1" in
    --requested-only)
      include_mentions=0
      ;;
    --limit)
      (($# >= 2)) || die '--limit requires a number'
      limit="$2"
      shift
      ;;
    --print)
      print_only=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown option: $1 (try --help)"
      ;;
  esac
  shift
done

[[ "$limit" =~ ^[1-9][0-9]*$ ]] || die '--limit must be a positive integer'
[[ "$now" =~ ^[0-9]+$ ]] || die 'GH_REVIEW_QUEUE_NOW must be an epoch timestamp'

command -v gh >/dev/null 2>&1 || die "gh is required; install GitHub CLI and run 'gh auth login'"
command -v jq >/dev/null 2>&1 || die 'jq is required'
if ((print_only == 0)); then
  command -v fzf >/dev/null 2>&1 || die 'fzf is required for interactive mode'
fi

search_prs() {
  local qualifier="$1"
  shift
  gh search prs "$qualifier" --state=open --limit "$limit" --json "$SEARCH_FIELDS" "$@"
}

requested_json="$(search_prs --review-requested=@me)"
required_json="$(search_prs --review-requested=@me --review=required)"
mentioned_json='[]'
if ((include_mentions)); then
  mentioned_json="$(search_prs --mentions=@me)"
fi

if ! direct_requested_urls="$({
  gh api graphql -f query="query { search(query: \"is:pr is:open review-requested:@me\", type: ISSUE, first: $limit) { nodes { ... on PullRequest { url reviewRequests(first: 100) { nodes { requestedReviewer { __typename ... on User { login } } } } } } } }" \
    | jq -r --arg login "$EXCLUDED_AUTHOR" '
      .data.search.nodes[]?
      | select([
          .reviewRequests.nodes[]?.requestedReviewer
          | select(.__typename == "User" and .login == $login)
        ] | length > 0)
      | .url
    '
})"; then
  die 'unable to verify direct review requests with GitHub'
fi
direct_requested_urls_json="$(printf '%s\n' "$direct_requested_urls" | jq -R -s 'split("\n") | map(select(length > 0))')"

rows_file="$(mktemp "${TMPDIR:-/tmp}/github-reviews.XXXXXX")"
trap 'rm -f "$rows_file"' EXIT

jq -nr \
  --argjson requested "$requested_json" \
  --argjson required "$required_json" \
  --argjson mentioned "$mentioned_json" \
  --argjson direct_requested_urls "$direct_requested_urls_json" \
  --arg excluded_author "$EXCLUDED_AUTHOR" \
  --argjson now "$now" '
  def with_source($items; $source):
    $items | map(. + {_source: $source});
  def days_since($timestamp):
    ([0, (($now - ($timestamp | fromdateiso8601)) / 86400 | floor)] | max);
  def kind:
    if ._source == "requested" and ._required then "REQUIRED REQUESTED"
    elif ._source == "requested" then "REQUESTED"
    else "MENTIONED"
    end;
  def metadata:
    ([
      (if .isDraft then "DRAFT" else empty end),
      ("comments:" + ((.commentsCount // 0) | tostring))
    ] | join(" "));

  ($required | map(.url)) as $required_urls
  | (with_source($requested; "requested") + with_source($mentioned; "mentioned"))
  | map(select((.author.login // "") != $excluded_author))
  | map(select(
      ._source != "requested"
      or (.url as $url | ($direct_requested_urls | index($url) != null))
    ))
  | group_by(.url)
  | map(
      .[0] as $pr
      | {
          url: $pr.url,
          number: $pr.number,
          title: $pr.title,
          repo: ($pr.repository.nameWithOwner // $pr.repository.name // "unknown/repository"),
          author: ($pr.author.login // "unknown"),
          isDraft: ($pr.isDraft // false),
          commentsCount: ($pr.commentsCount // 0),
          age_days: days_since($pr.createdAt),
          idle_days: days_since($pr.updatedAt),
          _source: (if any(.[]; ._source == "requested") then "requested" else "mentioned" end),
          _required: ($pr.url as $url | any($required_urls[]; . == $url))
        }
      )
  | map(. + {
      score: (if ._source == "requested" then 1000 else 0 end)
        + (if ._required then 500 else 0 end)
        + (.idle_days * 3)
        + (.age_days * 2)
        + (if .isDraft then -100 else 0 end)
    })
  | sort_by([-.score, -.idle_days, -.age_days, .repo, .number])
  | .[]
  | [
      (.score | tostring),
      kind,
      (.repo + "#" + (.number | tostring)),
      ((.age_days | tostring) + "d old"),
      (("idle " + (.idle_days | tostring) + "d")),
      ("@" + .author),
      metadata,
      .title,
      .url
    ]
  | @tsv
' | awk -F '\t' -v OFS='\t' \
  -v type_width="$TYPE_WIDTH" -v pr_width="$PR_WIDTH" \
  -v title_width="$TITLE_WIDTH" -v age_width="$AGE_WIDTH" \
  -v idle_width="$IDLE_WIDTH" -v author_width="$AUTHOR_WIDTH" \
  -v meta_width="$META_WIDTH" '
  function fit(value, width) {
    gsub(/[[:space:]]+/, " ", value)
    if (length(value) > width) {
      return substr(value, 1, width - 1) "…"
    }
    return value
  }
  {
    printf "%s\t%-*s\t%-*s\t%-*s\t%*s\t%*s\t%-*s\t%-*s\t%s\n", \
      $1, type_width, fit($2, type_width), pr_width, fit($3, pr_width), \
      title_width, fit($8, title_width), age_width, fit($4, age_width), \
      idle_width, fit($5, idle_width), author_width, fit($6, author_width), \
      meta_width, fit($7, meta_width), $9
  }
' >"$rows_file"

if [[ ! -s "$rows_file" ]]; then
  printf 'No open pull requests are currently waiting for your review.\n'
  exit 0
fi

if ((print_only)); then
  column_header
  printf '\n'
  awk -F '\t' -v OFS='\t' '{ print $2, $3, $4, $5, $6, $7, $8 }' "$rows_file"
  exit 0
fi

header='Enter: open in browser | Ctrl-V: view in terminal'$'\n'"$(column_header)"

set +e
selection="$(fzf \
  --delimiter=$'\t' \
  --with-nth=2..8 \
  --layout=reverse \
  --border \
  --header="$header" \
  --expect=enter,ctrl-v \
  <"$rows_file")"
fzf_status=$?
set -e

((fzf_status == 0)) || exit 0

key="$(printf '%s\n' "$selection" | sed -n '1p')"
selected_row="$(printf '%s\n' "$selection" | sed -n '2p')"
selected_url="$(printf '%s\n' "$selected_row" | cut -f9)"
[[ -n "$selected_url" ]] || exit 0

if [[ "$key" == 'ctrl-v' ]]; then
  gh pr view "$selected_url"
else
  gh pr view "$selected_url" --web
fi
