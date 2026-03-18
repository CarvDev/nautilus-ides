#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

IDE_CONFIG_PATH="config/ides.conf"
TEMPLATE_NAME="nautilus-ide-template.py"
EXTENSIONS_DIR="${HOME}/.local/share/nautilus-python/extensions"
INSTALLED_REGISTRY="${EXTENSIONS_DIR}/.nautilus-ides-installed"

print_info() {
    echo -e "${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}$1${NC}"
}

print_error() {
    echo -e "${RED}$1${NC}" >&2
}

fail() {
    print_error "$1"
    exit 1
}

get_repo_base_dir() {
    local script_source script_dir index

    for ((index=1; index<${#BASH_SOURCE[@]}; index++)); do
        script_source="${BASH_SOURCE[$index]}"
        if [ -n "$script_source" ] && [ -f "$script_source" ]; then
            script_dir="$(cd "$(dirname "$script_source")" && pwd 2>/dev/null)"
            printf '%s\n' "$script_dir"
            return 0
        fi
    done

    return 1
}

get_input_fd() {
    if [ -r /dev/tty ]; then
        printf '%s\n' "/dev/tty"
    else
        printf '%s\n' "/dev/stdin"
    fi
}

read_repo_file() {
    local relative_path=$1
    local repo_dir

    if repo_dir="$(get_repo_base_dir)" && [ -f "${repo_dir}/${relative_path}" ]; then
        cat "${repo_dir}/${relative_path}"
        return 0
    fi

    if command -v curl > /dev/null 2>&1; then
        curl -fsSL "${REPO_RAW_BASE}/${relative_path}"
        return 0
    fi

    if command -v wget > /dev/null 2>&1; then
        wget -qO- "${REPO_RAW_BASE}/${relative_path}"
        return 0
    fi

    fail "Failed to read ${relative_path}. Install curl or wget and try again."
}

parse_ide_stream() {
    awk -F'|' '
        /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
        NF >= 4 { printf "%s|%s|%s|%s\n", $1, $2, $3, $4 }
    '
}

list_available_ide_records() {
    read_repo_file "$IDE_CONFIG_PATH" | parse_ide_stream
}

list_available_ides() {
    list_available_ide_records | awk -F'|' '{ printf "%s|%s\n", $1, $2 }'
}

list_installed_ide_records() {
    if [ ! -f "$INSTALLED_REGISTRY" ]; then
        return 0
    fi

    awk -F'|' '
        /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
        NF >= 4 { printf "%s|%s|%s|%s\n", $1, $2, $3, $4 }
    ' "$INSTALLED_REGISTRY"
}

find_ide_record_by_id() {
    local ide_id=$1
    local record_source=$2

    "$record_source" | awk -F'|' -v ide="$ide_id" '
        $1 == ide {
            printf "%s|%s|%s|%s\n", $1, $2, $3, $4
            found = 1
            exit
        }
        END { exit !found }
    '
}

get_ide_record() {
    local ide_id=$1

    find_ide_record_by_id "$ide_id" list_available_ide_records
}

list_installed_ides() {
    list_installed_ide_records | awk -F'|' '{ printf "%s|%s\n", $1, $2 }'
}

prompt_for_ide_selection() {
    local prompt_msg=$1
    local list_command=$2
    local empty_message=$3
    local choice input_fd index ide_id ide_label
    local entries=()

    while IFS='|' read -r ide_id ide_label; do
        entries+=("${ide_id}|${ide_label}")
    done < <("$list_command")

    if [ "${#entries[@]}" -eq 0 ]; then
        fail "$empty_message"
    fi

    echo -e "${YELLOW}$prompt_msg${NC}"
    for ((index = 0; index < ${#entries[@]}; index++)); do
        IFS='|' read -r ide_id ide_label <<< "${entries[$index]}"
        echo "$((index + 1))) ${ide_label} (${ide_id})"
    done

    input_fd="$(get_input_fd)"
    if ! read -r -p "Enter choice [1-${#entries[@]}]: " choice < "$input_fd"; then
        print_error "Failed to read your choice."
        print_warning "If you are running this script through a pipe, use an interactive terminal."
        exit 1
    fi

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#entries[@]}" ]; then
        fail "Invalid choice."
    fi

    IFS='|' read -r IDE IDE_LABEL <<< "${entries[$((choice - 1))]}"
}

get_available_ide_selection() {
    prompt_for_ide_selection "$1" list_available_ides "No IDEs available in ${IDE_CONFIG_PATH}."
}

get_installed_ide_selection() {
    prompt_for_ide_selection "$1" list_installed_ides "No IDEs installed by this project were found."
}

register_installed_ide() {
    local ide_id=$1
    local ide_label=$2
    local script_name=$3
    local temp_file

    mkdir -p "$EXTENSIONS_DIR"
    temp_file="$(mktemp)"

    if [ -f "$INSTALLED_REGISTRY" ]; then
        awk -F'|' -v ide="$ide_id" '$1 != ide { print }' "$INSTALLED_REGISTRY" > "$temp_file"
    fi

    printf '%s|%s|%s|installed\n' "$ide_id" "$ide_label" "$script_name" >> "$temp_file"
    mv "$temp_file" "$INSTALLED_REGISTRY"
}

unregister_installed_ide() {
    local ide_id=$1
    local temp_file

    if [ ! -f "$INSTALLED_REGISTRY" ]; then
        return 0
    fi

    temp_file="$(mktemp)"
    awk -F'|' -v ide="$ide_id" '$1 != ide { print }' "$INSTALLED_REGISTRY" > "$temp_file"
    mv "$temp_file" "$INSTALLED_REGISTRY"
}

get_installed_script_name() {
    local ide_id=$1

    if [ ! -f "$INSTALLED_REGISTRY" ]; then
        return 0
    fi

    awk -F'|' -v ide="$ide_id" '$1 == ide { print $3; exit }' "$INSTALLED_REGISTRY"
}

build_python_class_name() {
    local ide_id=$1

    printf '%s\n' "$ide_id" | awk -F'[^[:alnum:]]+' '
        {
            output = ""
            for (i = 1; i <= NF; i++) {
                if ($i == "") {
                    continue
                }

                part = tolower($i)
                output = output toupper(substr(part, 1, 1)) substr(part, 2)
            }

            print output "Extension"
        }
    '
}

build_gtype_name() {
    local ide_id=$1

    printf 'Nautilus%sExtension\n' "$(printf '%s\n' "$ide_id" | tr -cd '[:alnum:]')"
}

get_extension_script_name() {
    printf '%s-nautilus.py\n' "$1"
}

render_extension_template() {
    local ide_id=$1
    local ide_label=$2
    local ide_command=$3
    local ide_new_window=$4
    local template_content class_name gtype_name

    template_content="$(read_repo_file "scripts/${TEMPLATE_NAME}")"
    class_name="$(build_python_class_name "$ide_id")"
    gtype_name="$(build_gtype_name "$ide_id")"
    template_content="${template_content//__IDE_ID__/${ide_id}}"
    template_content="${template_content//__IDE_LABEL__/${ide_label}}"
    template_content="${template_content//__IDE_COMMAND__/${ide_command}}"
    template_content="${template_content//__IDE_NEW_WINDOW__/${ide_new_window}}"
    template_content="${template_content//__CLASS_NAME__/${class_name}}"
    template_content="${template_content//__GTYPE_NAME__/${gtype_name}}"
    printf '%s\n' "$template_content"
}

write_extension_file() {
    local script_name=$1
    local content=$2
    local target_path temp_file

    mkdir -p "$EXTENSIONS_DIR"
    target_path="${EXTENSIONS_DIR}/${script_name}"
    temp_file="$(mktemp)"
    printf '%s\n' "$content" > "$temp_file"
    mv "$temp_file" "$target_path"
}

restart_nautilus() {
    print_info "Restarting nautilus..."
    nautilus -q > /dev/null 2>&1 || true
    echo ""
}

install_python_nautilus() {
    local package_name found_package installed

    print_info "Installing python-nautilus..."

    if command -v pacman > /dev/null 2>&1; then
        if pacman -Qi python-nautilus > /dev/null 2>&1; then
            print_success "python-nautilus is already installed"
        else
            sudo pacman -S --noconfirm python-nautilus
        fi
    elif command -v apt-get > /dev/null 2>&1; then
        package_name="python-nautilus"
        found_package="$(apt-cache search --names-only "$package_name")"
        if [ -z "$found_package" ]; then
            package_name="python3-nautilus"
        fi

        installed="$(apt list --installed "$package_name" -qq 2> /dev/null)"
        if [ -z "$installed" ]; then
            sudo apt-get install -y "$package_name"
        else
            print_success "${package_name} is already installed."
        fi
    elif command -v dnf > /dev/null 2>&1; then
        if dnf list --installed nautilus-python > /dev/null 2>&1; then
            print_success "nautilus-python is already installed."
        else
            sudo dnf install -y nautilus-python
        fi
    else
        print_warning "Failed to find python-nautilus, please install it manually."
    fi

    echo ""
}
