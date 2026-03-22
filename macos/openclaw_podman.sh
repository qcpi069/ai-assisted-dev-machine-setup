#!/bin/zsh
# openclaw_podman.sh - macOS helper script to build and run OpenClaw with Podman
# and print a starting-point config for LM Studio's OpenAI-compatible API.

set -euo pipefail

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

log_info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }
log_success() { echo -e "\033[0;32m[SUCCESS]\033[0m $1"; }
log_warning() { echo -e "\033[1;33m[WARNING]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; }

print_header() {
    echo ""
    echo -e "\033[0;36m╔════════════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[0;36m║$(printf '%*s' $((58 - ${#1})) | tr ' ' '=')\033[0m"
    echo -e "\033[0;36m║  $1\033[0m"
    echo -e "\033[0;36m╚════════════════════════════════════════════════════════════╝\033[0m"
    echo ""
}

print_section() {
    local section_name="$1"
    echo ""
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\033[0;34m➡  $section_name\033[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
}

command_exists() { command -v "$1" &>/dev/null; }

# ============================================================================
# CONFIGURATION
# ============================================================================

DRY_RUN=false
OPENCLAW_DIR="$HOME/openclaw"
OPENCLAW_STATE_DIR="$HOME/.openclaw"
LM_STUDIO_HOST="host.docker.internal"
LM_STUDIO_PORT="1234"
CONTAINER_NAME="openclaw-lm"
IMAGE_NAME="openclaw:latest"
GATEWAY_PORT="18789"
MODEL_NAME=""

# ============================================================================
# MAIN FUNCTIONS
# ============================================================================

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
}

check_prerequisites() {
    print_section "Checking Prerequisites"

    local missing=()

    if ! command_exists podman; then
        missing+=("podman")
    fi

    if ! command_exists git; then
        missing+=("git")
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Missing required tools: ${missing[*]}"
        log_info "Install them with the repo's macOS flow or run: brew install podman git"
        log_info "If you prefer the GUI, install Podman Desktop too: brew install --cask podman-desktop"
        exit 1
    fi

    log_success "✓ All prerequisites are installed"
}

ensure_podman_machine() {
    print_section "Preparing Podman"

    if podman info >/dev/null 2>&1; then
        log_success "✓ Podman is ready"
        return 0
    fi

    if ! podman machine inspect >/dev/null 2>&1; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would initialize the default Podman machine: podman machine init"
        else
            log_info "Initializing the default Podman machine..."
            podman machine init
        fi
    fi

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would start the default Podman machine: podman machine start"
        return 0
    fi

    log_info "Starting the default Podman machine..."
    podman machine start

    if podman info >/dev/null 2>&1; then
        log_success "✓ Podman machine is running"
    else
        log_error "✗ Podman is installed but not responding"
        exit 1
    fi
}

validate_openclaw_checkout() {
    if [ ! -d "$OPENCLAW_DIR" ]; then
        log_error "✗ Expected OpenClaw directory at $OPENCLAW_DIR"
        exit 1
    fi

    if [ ! -d "$OPENCLAW_DIR/.git" ]; then
        log_error "✗ $OPENCLAW_DIR exists but is not a git checkout"
        log_info "Move it aside or remove it, then rerun this script."
        exit 1
    fi

    if [ ! -f "$OPENCLAW_DIR/package.json" ]; then
        log_error "✗ $OPENCLAW_DIR does not look like an OpenClaw checkout (missing package.json)"
        exit 1
    fi

    if ! grep -Eq '"name"[[:space:]]*:[[:space:]]*"openclaw"' "$OPENCLAW_DIR/package.json"; then
        log_error "✗ $OPENCLAW_DIR/package.json does not appear to be the OpenClaw project"
        exit 1
    fi

    if [ ! -f "$OPENCLAW_DIR/Dockerfile" ]; then
        log_error "✗ OpenClaw checkout is missing its Dockerfile"
        log_info "Update the checkout and rerun this script."
        exit 1
    fi
}

clone_openclaw() {
    print_section "Setting up OpenClaw"

    if [ -d "$OPENCLAW_DIR" ]; then
        log_success "✓ OpenClaw directory already exists at $OPENCLAW_DIR"
        validate_openclaw_checkout

        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would update OpenClaw: cd $OPENCLAW_DIR && git pull --ff-only"
        else
            log_info "Updating OpenClaw..."
            if (cd "$OPENCLAW_DIR" && git pull --ff-only); then
                log_success "✓ OpenClaw updated successfully"
            else
                log_warning "⚠ Could not fast-forward OpenClaw; continuing with the existing checkout"
            fi
        fi
        return 0
    fi

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would clone OpenClaw: git clone https://github.com/OpenClaw/OpenClaw.git $OPENCLAW_DIR"
        return 0
    fi

    log_info "Cloning OpenClaw to $OPENCLAW_DIR..."

    if git clone https://github.com/OpenClaw/OpenClaw.git "$OPENCLAW_DIR"; then
        log_success "✓ OpenClaw cloned successfully"
        validate_openclaw_checkout
    else
        log_error "✗ Failed to clone OpenClaw"
        exit 1
    fi
}

get_model_name() {
    print_section "LM Studio Model"

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Skipping interactive model name prompt."
        return 0
    fi

    echo ""
    log_info "LM Studio is expected at: $LM_STUDIO_HOST:$LM_STUDIO_PORT"
    log_info "The model name is optional and is only used in the example config shown at the end."
    echo ""

    read "MODEL_NAME?Preferred LM Studio model (optional): "

    if [ -n "$MODEL_NAME" ]; then
        log_success "✓ Model noted: $MODEL_NAME"
    else
        log_info "No model name provided; a placeholder will be shown in the example config."
    fi
}

build_container() {
    print_section "Building OpenClaw Container"

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would build container: cd $OPENCLAW_DIR && podman build -t $IMAGE_NAME -f Dockerfile ."
        return 0
    fi

    validate_openclaw_checkout
    
    log_info "Building the upstream OpenClaw image..."

    if (cd "$OPENCLAW_DIR" && podman build -t "$IMAGE_NAME" -f Dockerfile .); then
        log_success "✓ Container image built successfully"
    else
        log_error "✗ Failed to build container image"
        exit 1
    fi
}

run_container() {
    print_section "Starting OpenClaw Container"

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would create state directory: mkdir -p $OPENCLAW_STATE_DIR"
        log_info "[DRY-RUN] Would stop/remove existing container: $CONTAINER_NAME"
        log_info "[DRY-RUN] Would start container: podman run -d --name $CONTAINER_NAME ..."
        return 0
    fi

    mkdir -p "$OPENCLAW_STATE_DIR" "$OPENCLAW_STATE_DIR/workspace"

    if podman ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        log_info "Stopping existing container..."
        podman stop "$CONTAINER_NAME" 2>/dev/null || true
        podman rm "$CONTAINER_NAME" 2>/dev/null || true
    fi

    log_info "Starting OpenClaw gateway container..."

    podman run -d \
        --name "$CONTAINER_NAME" \
        --add-host=host.docker.internal:host-gateway \
        -p "$GATEWAY_PORT:18789" \
        -v "$OPENCLAW_STATE_DIR:/home/node/.openclaw" \
        "$IMAGE_NAME" \
        node openclaw.mjs gateway --allow-unconfigured --bind lan

    log_success "✓ Container started successfully"
    echo ""
    print_section "Container Status"
    podman ps --filter "name=$CONTAINER_NAME"
    echo ""
    log_info "To view logs: podman logs -f $CONTAINER_NAME"
    log_info "To stop container: podman stop $CONTAINER_NAME"
    log_info "To access shell: podman exec -it $CONTAINER_NAME /bin/sh"
    echo ""
}

show_instructions() {
    local selected_model="${MODEL_NAME:-<your-lm-studio-model>}"

    print_header "OpenClaw Container Ready"

    echo ""
    echo -e "\033[1mContainer Details:\033[0m"
    echo "  Name: $CONTAINER_NAME"
    echo "  Gateway URL: http://127.0.0.1:$GATEWAY_PORT"
    echo "  OpenClaw state: $OPENCLAW_STATE_DIR"
    echo "  LM Studio URL: http://$LM_STUDIO_HOST:$LM_STUDIO_PORT/v1"
    echo ""
    echo -e "\033[1mRecommended Next Steps:\033[0m"
    echo "  1. Run onboarding inside the container:"
    echo "     podman exec -it $CONTAINER_NAME node openclaw.mjs onboard"
    echo ""
    echo "  2. If you want to use LM Studio's OpenAI-compatible API, start from a config like:"
    echo ""
    cat <<EOF
{
  env: {
    OPENAI_API_KEY: "lm-studio",
  },
  models: {
    providers: {
      openai: {
        baseUrl: "http://$LM_STUDIO_HOST:$LM_STUDIO_PORT/v1",
        apiKey: "\${OPENAI_API_KEY}",
      },
    },
  },
  agents: {
    defaults: {
      model: { primary: "openai/$selected_model" },
    },
  },
}
EOF
    echo ""
    echo "  Save that to $OPENCLAW_STATE_DIR/openclaw.json if it matches your setup, then restart the container."
    echo ""
    echo -e "\033[1mUseful Commands:\033[0m"
    echo "  View logs:       podman logs -f $CONTAINER_NAME"
    echo "  Stop container:  podman stop $CONTAINER_NAME"
    echo "  Remove container: podman rm $CONTAINER_NAME"
    echo "  Access shell:    podman exec -it $CONTAINER_NAME /bin/sh"
    echo ""
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    parse_args "$@"

    if [ "$DRY_RUN" = true ]; then
        print_header "OpenClaw Podman Setup (DRY-RUN)"
        log_info "Running in dry-run mode. No changes will be made."
    else
        print_header "OpenClaw Podman Setup"

        echo ""
        echo -e "\033[0;36mThis script will:\033[0m"
        echo -e "  • \033[0;32mClone or update OpenClaw\033[0m at $OPENCLAW_DIR"
        echo -e "  • \033[0;32mBuild the upstream OpenClaw image\033[0m with Podman"
        echo -e "  • \033[0;32mStart the OpenClaw gateway container\033[0m"
        echo -e "  • \033[0;32mPrint an LM Studio config example\033[0m for manual setup"
        echo ""

        read "REPLY?Continue? (y/N) "
        echo

        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Setup cancelled by user"
            exit 0
        fi
    fi

    echo ""

    check_prerequisites
    ensure_podman_machine
    clone_openclaw
    get_model_name
    build_container
    run_container
    show_instructions

    if [ "$DRY_RUN" = true ]; then
        log_success "✅ Dry-run complete! No changes were made."
    else
        log_success "✅ OpenClaw container setup complete!"
    fi
}

main "$@"
