# -*- mode: sh; eval: (sh-set-shell "zsh") -*-

############################################################################
# Public Functions
############################################################################

# Return the default cache location for the given package name.
function xdg_cache_for {
    local package="${1}"
    printf '%s' "${XDG_CACHE_HOME}/${package}"
}

# Return `0` if the default cache location for the given package 
# name exists, else `1`.
function xdg_cache_exists_for {
    [[ -d $(xdg_cache_for "${1}") ]]
}

# Return the default configuration location for the given package name.
function xdg_config_for {
    local package="${1}"
    printf '%s' "${XDG_CONFIG_HOME}/${package}"
}

# Return `0` if the default configuration location for the given package 
# name exists, else `1`.
function xdg_config_exists_for {
    [[ -d $(xdg_config_for "${1}") ]]
}

function xdg_find_config_for {
    local package="${1}"
    local config_dirs
    IFS=':' read -r -A config_dirs <<< "${XDG_CONFIG_DIRS}"

    local config_dir
    for config_dir in ${config_dirs[@]}; do
        if [[ -d "${config_dir}/${package}" ]]; then
            printf '%s' "${config_dir}/${package}"
            return 0
        fi
    done
    printf ''
    return 1
}

# Return the default data location for the given package name.
function xdg_data_for {
    local package="${1}"
    printf '%s' "${XDG_DATA_HOME}/${package}"
}

# Return `0` if the default data location for the given package 
# name exists, else `1`.
function xdg_data_exists_for {
    [[ -d $(xdg_data_for "${1}") ]]
}

function xdg_find_data_for {
    local package="${1}"
    local data_dirs
    IFS=':' read -r -A data_dirs <<< "${XDG_DATA_DIRS}"

    local data_dir
    for data_dir in ${data_dirs[@]}; do
        if [[ -d "${data_dir}/${package}" ]]; then
            printf '%s' "${data_dir}/${package}"
            return 0
        fi
    done
    printf ''
    return 1
}

# Return the default state location for the given package name.
function xdg_state_for {
    local package="${1}"
    printf '%s' "${XDG_STATE_HOME}/${package}"
}

# Return `0` if the default state location for the given package 
# name exists, else `1`.
function xdg_state_exists_for {
    [[ -d $(xdg_state_for "${1}") ]]
}

# Return the runtime configuration location for the given package name.
function xdg_runtime_for {
    local package="${1}"
    printf '%s' "${XDG_RUNTIME_HOME}/${package}"
}

# Return `0` if the default runtime location for the given package 
# name exists, else `1`.
function xdg_runtime_exists_for {
    [[ -d $(xdg_runtime_for "${1}") ]]
}

_xdg_remember_fn _xdg_example
