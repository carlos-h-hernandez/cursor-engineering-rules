#!/usr/bin/env bash
#
# cursor-maintenance.sh - Clean Cursor cache and temporary files
#
# This script safely removes cache, logs, and temporary files from
# ~/.cursor to reclaim disk space without affecting settings or extensions.
#
# Usage:
#   ./cursor-maintenance.sh [OPTIONS]
#
# Options:
#   -n, --dry-run    Show what would be deleted without actually deleting
#   -v, --verbose    Enable verbose output
#   -a, --aggressive Include additional cleanup (terminal history, backups)
#   -h, --help       Show this help message
#
# Safe to run weekly. Cursor should be closed for best results.
#

set -uo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

readonly CURSOR_DIR="${HOME}/.cursor"
readonly VERSION="1.1.0"
readonly CHAT_RETENTION_DAYS=30

# Declare separately to avoid masking return values (SC2155)
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_NAME

# Colors for output (disabled if not a terminal)
if [[ -t 1 ]]; then
  readonly RED='\033[0;31m'
  readonly GREEN='\033[0;32m'
  readonly YELLOW='\033[0;33m'
  readonly BLUE='\033[0;34m'
  readonly NC='\033[0m' # No Color
else
  readonly RED=''
  readonly GREEN=''
  readonly YELLOW=''
  readonly BLUE=''
  readonly NC=''
fi

# Default options
DRY_RUN=false
VERBOSE=false
AGGRESSIVE=false

# Counters
TOTAL_SIZE=0
ITEMS_CLEANED=0

# -----------------------------------------------------------------------------
# Logging Functions
# -----------------------------------------------------------------------------

log_info() {
  printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

log_success() {
  printf "${GREEN}[OK]${NC} %s\n" "$1"
}

log_warn() {
  printf "${YELLOW}[WARN]${NC} %s\n" "$1"
}

log_error() {
  printf "${RED}[ERROR]${NC} %s\n" "$1" >&2
}

log_verbose() {
  if [[ "${VERBOSE}" == true ]]; then
    printf "  ${BLUE}→${NC} %s\n" "$1"
  fi
}

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

usage() {
  cat << EOF
${SCRIPT_NAME} v${VERSION} - Cursor IDE Maintenance Script

Cleans cache, logs, and temporary files from ~/.cursor to reclaim disk space.

USAGE:
    ${SCRIPT_NAME} [OPTIONS]

OPTIONS:
    -n, --dry-run      Show what would be deleted without actually deleting
    -v, --verbose      Enable verbose output
    -a, --aggressive   Include additional cleanup (old chats, terminal history, backups)
    -h, --help         Show this help message

EXAMPLES:
    ${SCRIPT_NAME}                # Standard cleanup
    ${SCRIPT_NAME} -n             # Dry run - preview what would be deleted
    ${SCRIPT_NAME} -v             # Verbose output
    ${SCRIPT_NAME} -a             # Aggressive cleanup including backups
    ${SCRIPT_NAME} -n -a -v       # Dry run with aggressive + verbose

CLEANED DIRECTORIES:
    Standard:
      - cache/              General cache files
      - CachedData/         Cached extension data
      - CachedExtensionVSIXs/  Downloaded extension packages
      - Code Cache/         V8 JavaScript engine cache
      - GPUCache/           GPU shader cache
      - logs/               Application logs

    Aggressive (-a):
      - chats/ (30+ days)   Chat sessions not modified in last 30 days
      - Backups/            Old file backups
      - projects/*/terminals/  Terminal session history

NOTES:
    - Close Cursor before running for best results
    - User settings, extensions, and keybindings are NOT affected
    - Safe to run weekly

EOF
}

get_dir_size() {
  local dir="$1"
  if [[ -d "${dir}" ]]; then
    du -sh "${dir}" 2> /dev/null | cut -f1
  else
    echo "0B"
  fi
}

get_dir_size_bytes() {
  local dir="$1"
  if [[ -d "${dir}" ]]; then
    du -s "${dir}" 2> /dev/null | cut -f1
  else
    echo "0"
  fi
}

format_bytes() {
  local bytes=$1
  if [[ "${bytes}" -ge 1073741824 ]]; then
    printf "%.2f GB" "$(echo "scale=2; ${bytes} / 1073741824" | bc)"
  elif [[ "${bytes}" -ge 1048576 ]]; then
    printf "%.2f MB" "$(echo "scale=2; ${bytes} / 1048576" | bc)"
  elif [[ "${bytes}" -ge 1024 ]]; then
    printf "%.2f KB" "$(echo "scale=2; ${bytes} / 1024" | bc)"
  else
    printf "%d B" "${bytes}"
  fi
}

check_cursor_running() {
  if pgrep -x "Cursor" > /dev/null 2>&1; then
    log_warn "Cursor appears to be running"
    log_warn "For best results, close Cursor before running cleanup"
    echo ""
    read -r -p "Continue anyway? [y/N] " response
    case "${response}" in
      [yY][eE][sS] | [yY])
        return 0
        ;;
      *)
        log_info "Aborted by user"
        exit 0
        ;;
    esac
  fi
}

clean_directory() {
  local dir="$1"
  local description="$2"

  if [[ ! -d "${dir}" ]]; then
    log_verbose "Skipping ${description} (not found)"
    return 0
  fi

  local size
  local size_bytes
  size=$(get_dir_size "${dir}")
  size_bytes=$(get_dir_size_bytes "${dir}")

  if [[ "${size_bytes}" -eq 0 ]]; then
    log_verbose "Skipping ${description} (empty)"
    return 0
  fi

  if [[ "${DRY_RUN}" == true ]]; then
    log_info "[DRY RUN] Would clean ${description}: ${size}"
  else
    log_info "Cleaning ${description}: ${size}"
    if rm -rf "${dir:?}"/* 2> /dev/null; then
      log_success "Cleaned ${description}"
      ((ITEMS_CLEANED++)) || true
    else
      log_warn "Partial cleanup of ${description} (some files may be in use)"
    fi
  fi

  # Track total size in KB (du -s returns KB on macOS)
  TOTAL_SIZE=$((TOTAL_SIZE + size_bytes))
}

clean_terminal_directories() {
  local projects_dir="${CURSOR_DIR}/projects"

  if [[ ! -d "${projects_dir}" ]]; then
    log_verbose "Skipping terminal history (no projects directory)"
    return 0
  fi

  local terminal_dirs
  terminal_dirs=$(find "${projects_dir}" -type d -name "terminals" 2> /dev/null || true)

  if [[ -z "${terminal_dirs}" ]]; then
    log_verbose "Skipping terminal history (none found)"
    return 0
  fi

  local total_terminal_size=0

  while IFS= read -r terminal_dir; do
    if [[ -d "${terminal_dir}" ]]; then
      local size_bytes
      size_bytes=$(get_dir_size_bytes "${terminal_dir}")
      total_terminal_size=$((total_terminal_size + size_bytes))
    fi
  done <<< "${terminal_dirs}"

  if [[ "${total_terminal_size}" -eq 0 ]]; then
    log_verbose "Skipping terminal history (empty)"
    return 0
  fi

  local size
  size=$(format_bytes $((total_terminal_size * 1024)))

  if [[ "${DRY_RUN}" == true ]]; then
    log_info "[DRY RUN] Would clean terminal history: ${size}"
  else
    log_info "Cleaning terminal history: ${size}"
    while IFS= read -r terminal_dir; do
      if [[ -d "${terminal_dir}" ]]; then
        rm -rf "${terminal_dir:?}"/* 2> /dev/null || true
      fi
    done <<< "${terminal_dirs}"
    log_success "Cleaned terminal history"
    ((ITEMS_CLEANED++)) || true
  fi

  TOTAL_SIZE=$((TOTAL_SIZE + total_terminal_size))
}

clean_old_chats() {
  local chats_dir="${CURSOR_DIR}/chats"

  if [[ ! -d "${chats_dir}" ]]; then
    log_verbose "Skipping old chats (no chats directory)"
    return 0
  fi

  # Find chat directories older than retention period
  local old_chats
  old_chats=$(find "${chats_dir}" -type d -mindepth 1 -maxdepth 1 -mtime +${CHAT_RETENTION_DAYS} 2> /dev/null || true)

  if [[ -z "${old_chats}" ]]; then
    log_verbose "Skipping old chats (none found older than ${CHAT_RETENTION_DAYS} days)"
    return 0
  fi

  local total_chat_size=0
  local chat_count=0

  # Calculate total size of old chats
  while IFS= read -r chat_dir; do
    if [[ -d "${chat_dir}" ]]; then
      local size_bytes
      size_bytes=$(get_dir_size_bytes "${chat_dir}")
      total_chat_size=$((total_chat_size + size_bytes))
      ((chat_count++)) || true
    fi
  done <<< "${old_chats}"

  if [[ "${total_chat_size}" -eq 0 ]]; then
    log_verbose "Skipping old chats (empty directories)"
    return 0
  fi

  local size
  size=$(format_bytes $((total_chat_size * 1024)))

  if [[ "${DRY_RUN}" == true ]]; then
    log_info "[DRY RUN] Would clean ${chat_count} old chat(s) (${CHAT_RETENTION_DAYS}+ days): ${size}"
    if [[ "${VERBOSE}" == true ]]; then
      while IFS= read -r chat_dir; do
        if [[ -d "${chat_dir}" ]]; then
          local chat_size
          chat_size=$(get_dir_size "${chat_dir}")
          log_verbose "  Would remove: $(basename "${chat_dir}") (${chat_size})"
        fi
      done <<< "${old_chats}"
    fi
  else
    log_info "Cleaning ${chat_count} old chat(s) (${CHAT_RETENTION_DAYS}+ days): ${size}"
    while IFS= read -r chat_dir; do
      if [[ -d "${chat_dir}" ]]; then
        if rm -rf "${chat_dir:?}" 2> /dev/null; then
          log_verbose "Removed: $(basename "${chat_dir}")"
        else
          log_warn "Failed to remove: $(basename "${chat_dir}")"
        fi
      fi
    done <<< "${old_chats}"
    log_success "Cleaned ${chat_count} old chat(s)"
    ((ITEMS_CLEANED++)) || true
  fi

  TOTAL_SIZE=$((TOTAL_SIZE + total_chat_size))
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      -n | --dry-run)
        DRY_RUN=true
        shift
        ;;
      -v | --verbose)
        VERBOSE=true
        shift
        ;;
      -a | --aggressive)
        AGGRESSIVE=true
        shift
        ;;
      -h | --help)
        usage
        exit 0
        ;;
      *)
        log_error "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
  done

  # Header
  echo ""
  log_info "Cursor Maintenance Script v${VERSION}"
  echo ""

  # Check if Cursor directory exists
  if [[ ! -d "${CURSOR_DIR}" ]]; then
    log_error "Cursor directory not found: ${CURSOR_DIR}"
    exit 1
  fi

  # Show current disk usage
  local current_size
  current_size=$(get_dir_size "${CURSOR_DIR}")
  log_info "Current ~/.cursor size: ${current_size}"
  echo ""

  # Check if Cursor is running
  check_cursor_running

  # Dry run notice
  if [[ "${DRY_RUN}" == true ]]; then
    log_warn "DRY RUN MODE - No files will be deleted"
    echo ""
  fi

  # Standard cleanup directories
  log_info "Standard cleanup:"
  clean_directory "${CURSOR_DIR}/cache" "cache"
  clean_directory "${CURSOR_DIR}/CachedData" "CachedData"
  clean_directory "${CURSOR_DIR}/CachedExtensionVSIXs" "CachedExtensionVSIXs"
  clean_directory "${CURSOR_DIR}/Code Cache" "Code Cache"
  clean_directory "${CURSOR_DIR}/GPUCache" "GPUCache"
  clean_directory "${CURSOR_DIR}/logs" "logs"
  echo ""

  # Aggressive cleanup
  if [[ "${AGGRESSIVE}" == true ]]; then
    log_info "Aggressive cleanup:"
    clean_old_chats
    clean_directory "${CURSOR_DIR}/Backups" "Backups"
    clean_terminal_directories
    echo ""
  fi

  # Summary
  local freed_size
  freed_size=$(format_bytes $((TOTAL_SIZE * 1024)))

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  if [[ "${DRY_RUN}" == true ]]; then
    log_info "Summary (Dry Run):"
    log_info "  Would free: ${freed_size}"
  else
    log_success "Cleanup complete!"
    log_info "  Items cleaned: ${ITEMS_CLEANED}"
    log_info "  Space freed: ${freed_size}"

    # Show new size
    local new_size
    new_size=$(get_dir_size "${CURSOR_DIR}")
    log_info "  New ~/.cursor size: ${new_size}"
  fi
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
}

main "$@"
