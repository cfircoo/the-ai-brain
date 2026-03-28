#!/bin/bash
set -e

# ============================================================================
# The AI Brain - Universal Installer
# Installs a persistent AI memory system into any directory/vault
# Supports: Claude Code, Cursor, Gemini CLI, OpenAI Codex
# ============================================================================

BRAIN_VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ── Helpers ──────────────────────────────────────────────────────────────────

print_banner() {
    echo -e "${BLUE}"
    echo '  ╔══════════════════════════════════════════╗'
    echo '  ║         🧠 The AI Brain v'"$BRAIN_VERSION"'           ║'
    echo '  ║   Persistent Memory for AI Agents        ║'
    echo '  ╚══════════════════════════════════════════╝'
    echo -e "${NC}"
}

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

ask() {
    local prompt="$1" default="$2" var="$3"
    if [ -n "$default" ]; then
        read -rp "$(echo -e "${BOLD}$prompt${NC} [$default]: ")" input
        eval "$var=\"${input:-$default}\""
    else
        read -rp "$(echo -e "${BOLD}$prompt${NC}: ")" input
        eval "$var=\"$input\""
    fi
}

ask_yn() {
    local prompt="$1" default="$2"
    read -rp "$(echo -e "${BOLD}$prompt${NC} [${default}]: ")" input
    input="${input:-$default}"
    [[ "$input" =~ ^[Yy] ]]
}

ask_multi() {
    local prompt="$1"
    shift
    local options=("$@")
    echo -e "${BOLD}$prompt${NC}"
    for i in "${!options[@]}"; do
        echo "  $((i+1)). ${options[$i]}"
    done
}

# ── Dependency Check ────────────────────────────────────────────────────────

check_deps() {
    info "Checking dependencies..."

    local missing=()
    command -v git  >/dev/null 2>&1 || missing+=("git")
    command -v jq   >/dev/null 2>&1 || missing+=("jq")

    if [ ${#missing[@]} -gt 0 ]; then
        warn "Missing dependencies: ${missing[*]}"
        echo ""
        if command -v apt-get >/dev/null 2>&1; then
            echo "  Install with: sudo apt-get install ${missing[*]}"
        elif command -v brew >/dev/null 2>&1; then
            echo "  Install with: brew install ${missing[*]}"
        elif command -v pacman >/dev/null 2>&1; then
            echo "  Install with: sudo pacman -S ${missing[*]}"
        fi
        echo ""
        if ask_yn "Try to install automatically?" "y"; then
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get install -y "${missing[@]}"
            elif command -v brew >/dev/null 2>&1; then
                brew install "${missing[@]}"
            else
                error "Cannot auto-install. Please install manually: ${missing[*]}"
            fi
        else
            error "Required dependencies missing: ${missing[*]}"
        fi
    fi

    # Optional: yq for better YAML parsing
    if command -v yq >/dev/null 2>&1; then
        success "yq found (enhanced YAML support)"
        HAS_YQ=true
    else
        info "yq not found (will use fallback YAML parsing)"
        HAS_YQ=false
    fi

    # Optional: Obsidian CLI (1.12+)
    if command -v obsidian >/dev/null 2>&1 && obsidian version &>/dev/null 2>&1; then
        success "Obsidian CLI found (enhanced vault integration)"
        HAS_OBSIDIAN_CLI=true
    else
        info "Obsidian CLI not found (install Obsidian 1.12+ and enable CLI in Settings → General)"
        HAS_OBSIDIAN_CLI=false
    fi

    success "All required dependencies satisfied"
}

# ── YAML Parser (fallback when yq not available) ───────────────────────────

yaml_get() {
    local file="$1" key="$2"
    if $HAS_YQ; then
        yq -r ".$key // \"\"" "$file" 2>/dev/null
    else
        # Simple key: value parser for flat YAML
        grep -E "^\s*${key##*.}:" "$file" 2>/dev/null | head -1 | sed 's/^[^:]*:\s*//' | sed 's/^"//' | sed 's/"$//' | sed "s/^'//" | sed "s/'$//"
    fi
}

yaml_set() {
    local file="$1" key="$2" value="$3"
    if $HAS_YQ; then
        yq -i ".$key = \"$value\"" "$file" 2>/dev/null
    else
        # Simple sed replacement for flat YAML
        local leaf="${key##*.}"
        sed -i "s|^\(\s*${leaf}:\s*\).*|\1\"${value}\"|" "$file" 2>/dev/null
    fi
}

# ── Interactive Configuration ───────────────────────────────────────────────

configure_brain() {
    local vault_path="$1"
    local config_file="$vault_path/.brain/brain.yaml"

    echo ""
    echo -e "${BOLD}━━━ Brain Configuration ━━━${NC}"
    echo ""

    # Owner info
    ask "Your name" "$(whoami)" OWNER_NAME
    ask "Your role (e.g., developer, PM, researcher)" "" OWNER_ROLE

    # Brain name
    local default_name="$(basename "$vault_path") Brain"
    ask "Name this brain" "$default_name" BRAIN_NAME

    # Agent selection
    echo ""
    echo -e "${BOLD}Which AI agents do you use?${NC} (enter numbers, comma-separated)"
    echo "  1. Claude Code"
    echo "  2. Cursor"
    echo "  3. Gemini CLI"
    echo "  4. OpenAI Codex"
    read -rp "$(echo -e "${BOLD}Agents${NC} [1]: ")" AGENT_SELECTION
    AGENT_SELECTION="${AGENT_SELECTION:-1}"

    ENABLE_CLAUDE=false
    ENABLE_CURSOR=false
    ENABLE_GEMINI=false
    ENABLE_CODEX=false

    IFS=',' read -ra AGENTS <<< "$AGENT_SELECTION"
    for agent in "${AGENTS[@]}"; do
        agent="$(echo "$agent" | tr -d ' ')"
        case "$agent" in
            1) ENABLE_CLAUDE=true ;;
            2) ENABLE_CURSOR=true ;;
            3) ENABLE_GEMINI=true ;;
            4) ENABLE_CODEX=true ;;
        esac
    done

    # Format preference
    if ask_yn "Use Obsidian format (wikilinks, frontmatter)?" "y"; then
        FORMAT="obsidian"
    else
        FORMAT="plain"
    fi

    # Self-improvement
    SELF_IMPROVE=true
    if ! ask_yn "Enable self-improving rules?" "y"; then
        SELF_IMPROVE=false
    fi

    # Write config
    cp "$SCRIPT_DIR/brain.yaml" "$config_file"

    yaml_set "$config_file" "brain.name" "$BRAIN_NAME"
    yaml_set "$config_file" "owner.name" "$OWNER_NAME"
    yaml_set "$config_file" "owner.role" "$OWNER_ROLE"
    yaml_set "$config_file" "vault.path" "$vault_path"
    yaml_set "$config_file" "agents.claude_code.enabled" "$ENABLE_CLAUDE"
    yaml_set "$config_file" "agents.cursor.enabled" "$ENABLE_CURSOR"
    yaml_set "$config_file" "agents.gemini_cli.enabled" "$ENABLE_GEMINI"
    yaml_set "$config_file" "agents.codex.enabled" "$ENABLE_CODEX"
    yaml_set "$config_file" "preferences.format" "$FORMAT"
    yaml_set "$config_file" "memory.self_improve" "$SELF_IMPROVE"

    # Obsidian CLI
    if $HAS_OBSIDIAN_CLI; then
        yaml_set "$config_file" "integrations.obsidian_cli.enabled" "true"
        ask "Obsidian vault name (leave blank if single vault)" "" OBSIDIAN_VAULT_NAME
        if [ -n "$OBSIDIAN_VAULT_NAME" ]; then
            yaml_set "$config_file" "integrations.obsidian_cli.vault_name" "$OBSIDIAN_VAULT_NAME"
        fi
        success "Obsidian CLI integration enabled"
    fi

    success "Brain configured: $config_file"
}

# ── Vault Scaffolding ───────────────────────────────────────────────────────

scaffold_vault() {
    local vault_path="$1"

    info "Scaffolding vault structure..."

    # Create directories (non-destructive)
    local dirs=(
        "Human/Daily"
        "Human/Projects"
        "Human/Archive"
        "Machine/Session-Logs"
        "Machine/Memory"
        "Machine/Rules"
        "Machine/Templates"
        ".brain/agent-configs"
        ".brain/hooks"
    )

    for dir in "${dirs[@]}"; do
        mkdir -p "$vault_path/$dir"
    done

    # Copy vault templates (only if files don't exist)
    local template_dir="$SCRIPT_DIR/vault-template"
    if [ -d "$template_dir" ]; then
        find "$template_dir" -type f -not -name ".gitkeep" | while read -r src; do
            local rel="${src#$template_dir/}"
            local dest="$vault_path/$rel"
            if [ ! -f "$dest" ]; then
                mkdir -p "$(dirname "$dest")"
                cp "$src" "$dest"
                info "  Created: $rel"
            else
                info "  Exists (skipped): $rel"
            fi
        done
    fi

    # Create .gitkeep files for empty dirs
    for dir in "${dirs[@]}"; do
        if [ -z "$(ls -A "$vault_path/$dir" 2>/dev/null)" ]; then
            touch "$vault_path/$dir/.gitkeep"
        fi
    done

    success "Vault structure ready"
}

# ── Install Hooks (Claude Code) ────────────────────────────────────────────

install_hooks() {
    local vault_path="$1"

    info "Installing Claude Code hooks..."

    # Copy hook scripts to .brain/hooks/
    local hook_dir="$vault_path/.brain/hooks"
    mkdir -p "$hook_dir"

    for hook_file in "$SCRIPT_DIR/hooks/"*.sh; do
        if [ -f "$hook_file" ]; then
            cp "$hook_file" "$hook_dir/"
            chmod +x "$hook_dir/$(basename "$hook_file")"
        fi
    done

    # Initialize state
    if [ -f "$hook_dir/init-state.sh" ]; then
        bash "$hook_dir/init-state.sh" "$vault_path"
    fi

    # Merge hooks into .claude/settings.json
    local claude_dir="$vault_path/.claude"
    local settings_file="$claude_dir/settings.json"
    local hooks_template="$SCRIPT_DIR/hooks/settings-template.json"

    mkdir -p "$claude_dir"

    if [ ! -f "$hooks_template" ]; then
        warn "hooks/settings-template.json not found, skipping hook config"
        return
    fi

    if [ -f "$settings_file" ]; then
        # Backup existing settings
        cp "$settings_file" "$settings_file.backup.$(date +%s)"
        info "  Backed up existing settings.json"

        # Merge hooks into existing settings
        if command -v jq >/dev/null 2>&1; then
            local merged
            merged=$(jq -s '.[0] * .[1]' "$settings_file" "$hooks_template")
            echo "$merged" > "$settings_file"
        else
            warn "jq not available, copying hooks template as settings.json"
            cp "$hooks_template" "$settings_file"
        fi
    else
        cp "$hooks_template" "$settings_file"
    fi

    success "Claude Code hooks installed"
}

# ── Install Skills (Claude Code) ───────────────────────────────────────────

install_skills() {
    local vault_path="$1"

    info "Installing Claude Code skills..."

    local claude_dir="$vault_path/.claude"
    mkdir -p "$claude_dir/skills" "$claude_dir/commands"

    # Copy skills
    if [ -d "$SCRIPT_DIR/skills" ]; then
        for skill_dir in "$SCRIPT_DIR/skills"/*/; do
            local skill_name="$(basename "$skill_dir")"
            local dest="$claude_dir/skills/$skill_name"
            mkdir -p "$dest"
            cp "$skill_dir"* "$dest/" 2>/dev/null || true
            info "  Skill: /$skill_name"
        done
    fi

    # Copy commands
    if [ -d "$SCRIPT_DIR/commands" ]; then
        for cmd_file in "$SCRIPT_DIR/commands/"*.md; do
            if [ -f "$cmd_file" ]; then
                cp "$cmd_file" "$claude_dir/commands/"
                info "  Command: /$(basename "$cmd_file" .md)"
            fi
        done
    fi

    success "Skills and commands installed"
}

# ── Generate Agent Configs ──────────────────────────────────────────────────

generate_configs() {
    local vault_path="$1"

    info "Generating agent configuration files..."

    if [ -x "$SCRIPT_DIR/generators/generate-all.sh" ]; then
        bash "$SCRIPT_DIR/generators/generate-all.sh" "$vault_path" "$SCRIPT_DIR"
    else
        warn "Generators not found, skipping config generation"

        # Fallback: copy brain-rules.md as CLAUDE.md if no generator
        if [ -f "$SCRIPT_DIR/core/brain-rules.md" ]; then
            cp "$SCRIPT_DIR/core/brain-rules.md" "$vault_path/CLAUDE.md"
            info "  Copied brain-rules.md as CLAUDE.md (fallback)"
        fi
    fi

    success "Agent configs generated"
}

# ── Git Init ────────────────────────────────────────────────────────────────

init_git() {
    local vault_path="$1"

    if [ -d "$vault_path/.git" ]; then
        info "Git repo already exists"
        return
    fi

    if ask_yn "Initialize git repo for version control?" "y"; then
        cd "$vault_path"
        git init

        # Create .gitignore
        cat > "$vault_path/.gitignore" << 'GITIGNORE'
# OS
.DS_Store
Thumbs.db

# Obsidian
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/cache

# Brain internals (keep state.json tracked)
.brain/agent-configs/

# Sensitive
*.env
credentials*
GITIGNORE

        git add -A
        git commit -m "Initial brain setup via the-ai-brain v$BRAIN_VERSION"
        success "Git repo initialized with initial commit"
    fi
}

# ── Summary ─────────────────────────────────────────────────────────────────

print_summary() {
    local vault_path="$1"

    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  🧠 The AI Brain installed successfully!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${BOLD}Vault:${NC}  $vault_path"
    echo ""
    echo -e "  ${BOLD}Structure:${NC}"
    echo "    Human/Daily/      ← Your daily notes"
    echo "    Human/Projects/   ← Your project files"
    echo "    Machine/Memory/   ← AI's persistent memory"
    echo "    Machine/Rules/    ← Self-updating behavioral rules"
    echo "    Machine/Session-Logs/ ← Session continuity"
    echo ""
    echo -e "  ${BOLD}Agents configured:${NC}"
    $ENABLE_CLAUDE && echo "    ✓ Claude Code (hooks + skills + CLAUDE.md)"
    $ENABLE_CURSOR && echo "    ✓ Cursor (.cursorrules)"
    $ENABLE_GEMINI && echo "    ✓ Gemini CLI (GEMINI.md)"
    $ENABLE_CODEX  && echo "    ✓ OpenAI Codex (AGENTS.md)"
    echo ""
    echo -e "  ${BOLD}Quick start:${NC}"
    echo "    cd $vault_path"
    $ENABLE_CLAUDE && echo "    claude                          # Start Claude Code"
    $ENABLE_CLAUDE && echo "    /brain-today                    # Morning startup"
    $ENABLE_CLAUDE && echo "    /brain-new <brain dump>          # Triage input"
    $ENABLE_CLAUDE && echo "    /brain-debrief                  # End-of-session log"
    echo ""
    echo -e "  ${BOLD}Available commands:${NC}"
    echo "    /brain-today        Morning startup planner"
    echo "    /brain-new          Universal brain-dump triage"
    echo "    /brain-tldr         Summarize session or file"
    echo "    /brain-debrief      End-of-session ritual"
    echo "    /brain-vault-audit  Vault health check"
    echo "    /brain-vault-align  Re-sync agent configs"
    echo "    /brain-reflect      AI self-review"
    echo "    /brain-ingest       Import external content"
    echo "    /brain-canvas       Create Obsidian canvas visualizations"
    echo ""
}

# ── Main ────────────────────────────────────────────────────────────────────

main() {
    print_banner

    # Get target vault path
    local vault_path="${1:-}"

    if [ -z "$vault_path" ]; then
        ask "Target vault/directory path" "$(pwd)" vault_path
    fi

    # Resolve to absolute path
    vault_path="$(cd "$vault_path" 2>/dev/null && pwd || echo "$vault_path")"

    # Create if doesn't exist
    if [ ! -d "$vault_path" ]; then
        if ask_yn "Directory '$vault_path' doesn't exist. Create it?" "y"; then
            mkdir -p "$vault_path"
        else
            error "Target directory does not exist"
        fi
    fi

    # Check for existing brain
    if [ -d "$vault_path/.brain" ]; then
        warn "Brain already installed at this location"
        if ask_yn "Update/re-sync existing brain?" "y"; then
            info "Updating existing brain..."
        else
            echo "Aborted."
            exit 0
        fi
    fi

    # Run installation steps
    check_deps

    echo ""
    mkdir -p "$vault_path/.brain"

    configure_brain "$vault_path"
    scaffold_vault "$vault_path"
    generate_configs "$vault_path"

    # Agent-specific installations
    if $ENABLE_CLAUDE; then
        install_hooks "$vault_path"
        install_skills "$vault_path"
    fi

    init_git "$vault_path"
    print_summary "$vault_path"
}

main "$@"
