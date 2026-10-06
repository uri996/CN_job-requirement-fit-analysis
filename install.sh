#!/usr/bin/env bash
set -euo pipefail

source_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target_dir="${HOME}/.codex/skills/CN_job-requirement-fit-analysis"
force=0

required_files=(
  ".gitignore"
  "AGENTS.md"
  "LICENSE"
  "README.md"
  "SKILL.md"
  "references/CAMPUS-HIRING.md"
  "references/EXPERIENCED-HIRING.md"
  "references/INTERNSHIP-HIRING.md"
  "references/ISOLATED-EVALUATOR-PROTOCOL.md"
  "docs/DEVELOPMENT.md"
  "docs/RECRUITMENT-MODE-RULES.md"
  "docs/SPECIFICATION.md"
)

usage() {
  cat <<'EOF'
Usage: bash install.sh [--target DIRECTORY] [--force]

Installs CN_job-requirement-fit-analysis into the Codex Skill runtime.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      [[ $# -ge 2 ]] || { echo "INSTALL_FAILED: --target requires a directory" >&2; exit 2; }
      target_dir="$2"
      shift 2
      ;;
    --target=*)
      target_dir="${1#*=}"
      shift
      ;;
    --force)
      force=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "INSTALL_FAILED: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

hash_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    echo "INSTALL_FAILED: sha256sum or shasum -a 256 is required for verification" >&2
    return 1
  fi
}

assert_required_files() {
  local root="$1"
  local file
  for file in "${required_files[@]}"; do
    [[ -f "$root/$file" ]] || { echo "INSTALL_FAILED: required payload file is missing: $file" >&2; return 1; }
  done
}

assert_payload() {
  local root="$1" forbidden
  assert_required_files "$root"
  for forbidden in .git .github runs cases evaluation; do
    [[ ! -e "$root/$forbidden" ]] || { echo "INSTALL_FAILED: forbidden development artifact found in payload: $forbidden" >&2; return 1; }
  done
}

assert_hash_parity() {
  local left="$1" right="$2" file
  for file in "${required_files[@]}"; do
    [[ "$(hash_file "$left/$file")" == "$(hash_file "$right/$file")" ]] || {
      echo "INSTALL_FAILED: SHA-256 verification failed: $file" >&2
      return 1
    }
  done
}

normalize_target() {
  local supplied="$1" parent leaf
  [[ -n "$supplied" ]] || { echo "INSTALL_FAILED: target directory must not be empty" >&2; return 1; }
  if [[ -e "$supplied" ]]; then
    [[ -d "$supplied" ]] || { echo "INSTALL_FAILED: target exists but is not a directory: $supplied" >&2; return 1; }
    cd -P "$supplied" && pwd
    return
  fi
  parent="$(dirname "$supplied")"
  leaf="$(basename "$supplied")"
  [[ "$leaf" != "." && "$leaf" != ".." ]] || { echo "INSTALL_FAILED: target directory must not end in . or .." >&2; return 1; }
  mkdir -p "$parent"
  printf '%s/%s\n' "$(cd -P "$parent" && pwd)" "$leaf"
}

assert_safe_target() {
  local candidate="$1" home_path source_parent root
  candidate="$(normalize_target "$candidate")"
  home_path="${HOME%/}"
  source_parent="$(dirname "$source_dir")"
  root="$(cd -P / && pwd)"
  if [[ "$candidate" == "$root" || "$candidate" == "$home_path" || "$candidate" == "$source_dir" || "$candidate" == "$source_parent" || "$candidate" =~ ^[A-Za-z]:/?$ ]]; then
    echo "INSTALL_FAILED: refusing unsafe target directory: $candidate" >&2
    return 1
  fi
  printf '%s\n' "$candidate"
}

assert_required_files "$source_dir"
source_version="$(sed -n 's/.*<!-- skill-version: \([^ ]*\) -->.*/\1/p' "$source_dir/SKILL.md" | head -n 1)"
[[ -n "$source_version" ]] || { echo "INSTALL_FAILED: skill version marker is missing from source payload" >&2; exit 1; }
target_dir="$(assert_safe_target "$target_dir")"
target_parent="$(dirname "$target_dir")"
target_leaf="$(basename "$target_dir")"

if [[ -e "$target_dir" && "$force" -ne 1 ]]; then
  read -r -p "existing installation found at $target_dir. Overwrite? [y/N] " answer
  if [[ ! "$answer" =~ ^([Yy]|[Yy][Ee][Ss])$ ]]; then
    echo "Installation cancelled."
    exit 0
  fi
fi

staging_dir="$(mktemp -d "${target_parent}/.${target_leaf}.staging.XXXXXX")"
backup_dir="${target_parent}/.${target_leaf}.backup.$$"
cleanup_staging() {
  if [[ -n "$staging_dir" && -d "$staging_dir" ]]; then
    rm -rf -- "$staging_dir"
  fi
}
trap cleanup_staging EXIT

for file in "${required_files[@]}"; do
  mkdir -p "$staging_dir/$(dirname "$file")"
  cp "$source_dir/$file" "$staging_dir/$file"
done

assert_payload "$staging_dir"
assert_hash_parity "$source_dir" "$staging_dir"

had_existing_target=0
if [[ -e "$target_dir" ]]; then
  had_existing_target=1
  mv "$target_dir" "$backup_dir"
fi

if ! mv "$staging_dir" "$target_dir"; then
  if [[ "$had_existing_target" -eq 1 && ! -e "$target_dir" && -e "$backup_dir" ]]; then
    mv "$backup_dir" "$target_dir"
  fi
  echo "INSTALL_FAILED: could not activate staged installation" >&2
  exit 1
fi
staging_dir=""

if ! assert_payload "$target_dir" || ! assert_hash_parity "$source_dir" "$target_dir"; then
  rm -rf -- "$target_dir"
  if [[ "$had_existing_target" -eq 1 && -e "$backup_dir" ]]; then
    mv "$backup_dir" "$target_dir"
  fi
  echo "INSTALL_FAILED: post-install verification failed" >&2
  exit 1
fi

version="$(sed -n 's/.*<!-- skill-version: \([^ ]*\) -->.*/\1/p' "$target_dir/SKILL.md" | head -n 1)"
if [[ -z "$version" || "$version" != "$source_version" ]]; then
  rm -rf -- "$target_dir"
  if [[ "$had_existing_target" -eq 1 && -e "$backup_dir" ]]; then
    mv "$backup_dir" "$target_dir"
  fi
  echo "INSTALL_FAILED: skill version marker is missing" >&2
  exit 1
fi

if [[ -e "$backup_dir" ]]; then
  rm -rf -- "$backup_dir"
fi

echo "CN_job-requirement-fit-analysis $version installed successfully"
echo "Source: $source_dir"
echo "Target: $target_dir"
echo "Files installed: ${#required_files[@]}"
echo "Integrity: PASS"
echo "INSTALL_SUCCESS"
