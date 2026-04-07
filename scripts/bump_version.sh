#!/usr/bin/env bash
# Bumps the semantic version in pubspec.yaml based on conventional commits.
#
# Usage:
#   bash scripts/bump_version.sh [major|minor|patch|auto]
#
# "auto" (default) analyzes commits since the last version tag and determines
# the bump type from conventional commit prefixes:
#   - BREAKING CHANGE / feat!: → major
#   - feat:                    → minor
#   - fix:                     → patch
#
# The build number (+N) is always set to the git commit count.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PUBSPEC="$ROOT_DIR/pubspec.yaml"

# ── Read current version ────────────────────────────────────────────────────
CURRENT=$(grep '^version:' "$PUBSPEC" | sed 's/version: //' | tr -d '[:space:]')
SEMVER=$(echo "$CURRENT" | sed 's/+.*//')
MAJOR=$(echo "$SEMVER" | cut -d. -f1)
MINOR=$(echo "$SEMVER" | cut -d. -f2)
PATCH=$(echo "$SEMVER" | cut -d. -f3)

echo "Current version: $SEMVER (major=$MAJOR minor=$MINOR patch=$PATCH)"

# ── Determine bump type ────────────────────────────────────────────────────
BUMP_TYPE="${1:-auto}"

if [ "$BUMP_TYPE" = "auto" ]; then
  # Find the latest version tag (v1.0.0 format)
  LAST_TAG=$(git -C "$ROOT_DIR" tag --list 'v[0-9]*' --sort=-v:refname | head -1 || true)

  if [ -z "$LAST_TAG" ]; then
    echo "No version tag found. Analyzing all commits."
    COMMITS=$(git -C "$ROOT_DIR" log --oneline --format="%s" 2>/dev/null || true)
  else
    echo "Last version tag: $LAST_TAG"
    COMMITS=$(git -C "$ROOT_DIR" log "$LAST_TAG"..HEAD --oneline --format="%s" 2>/dev/null || true)
  fi

  if [ -z "$COMMITS" ]; then
    echo "No new commits since last tag. Nothing to bump."
    exit 0
  fi

  echo ""
  echo "Commits since last tag:"
  echo "$COMMITS" | head -20
  echo ""

  # Determine bump type from commit messages
  BUMP_TYPE="patch"  # default

  if echo "$COMMITS" | grep -qiE '(BREAKING CHANGE|^[a-z]+(\(.+\))?!:)'; then
    BUMP_TYPE="major"
  elif echo "$COMMITS" | grep -qE '^feat(\(.+\))?:'; then
    BUMP_TYPE="minor"
  fi

  echo "Auto-detected bump type: $BUMP_TYPE"
fi

# ── Calculate new version ───────────────────────────────────────────────────
case "$BUMP_TYPE" in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
  *)
    echo "Error: Unknown bump type '$BUMP_TYPE'. Use major, minor, patch, or auto."
    exit 1
    ;;
esac

BUILD_NUMBER=$(git -C "$ROOT_DIR" rev-list --count HEAD 2>/dev/null || echo "1")
NEW_VERSION="$MAJOR.$MINOR.$PATCH+$BUILD_NUMBER"

echo ""
echo "New version: $NEW_VERSION"

# ── Update pubspec.yaml ─────────────────────────────────────────────────────
sed -i "s/^version: .*/version: $NEW_VERSION/" "$PUBSPEC"
echo "Updated $PUBSPEC"

# ── Output for CI ────────────────────────────────────────────────────────────
# If GITHUB_OUTPUT is set, export variables for subsequent workflow steps
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  {
    echo "new_version=$MAJOR.$MINOR.$PATCH"
    echo "new_version_full=$NEW_VERSION"
    echo "bump_type=$BUMP_TYPE"
    echo "build_number=$BUILD_NUMBER"
  } >> "$GITHUB_OUTPUT"
fi

echo ""
echo "Done. Version bumped: $SEMVER → $MAJOR.$MINOR.$PATCH (build $BUILD_NUMBER)"
