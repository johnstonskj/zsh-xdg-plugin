# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# Plugin Name: xdg
# Description: Zsh plugin to bootstrap/setup XDG Base Directory environment variables.
# Repository: https://github.com/johnstonskj/zsh-xdg-plugin
#
# Public variables:
#
# * `XDG`; plugin-defined global associative array with the following keys:
#   * `_PLUGIN_DIR`; the directory the plugin is sourced from.
#   * `_PLUGIN_FNS_DIR`; the directory of plugin functions.
#   * `_FUNCTIONS`; a list of all functions defined by the plugin.
# * `XDG_USE_MACOS_LIBRARY`; if set, use the Apple _File System Programming
#   Guide_ for directories rather than the POSIX versions.
#

############################################################################
# Standard Setup Behavior
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# See https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
declare -gA XDG
XDG[_PLUGIN_DIR]="${0:h}"
XDG[_PLUGIN_FNS_DIR]="${XDG[_PLUGIN_DIR]}/functions"
XDG[_FUNCTIONS]=""

############################################################################
# Internal Support Functions
############################################################################

_xdg_remember_fn() {
    local fn_name="${1}"
    if [[ -z "${XDG[_FUNCTIONS]}" ]]; then
        XDG[_FUNCTIONS]="${fn_name}"
    elif [[ ",${XDG[_FUNCTIONS]}," != *",${fn_name},"* ]]; then
        XDG[_FUNCTIONS]="${XDG[_FUNCTIONS]},${fn_name}"
    fi
}
_xdg_remember_fn _xdg_remember_fn

_xdg_environment_init() {
    load_and_export() {
        local file_name="${1}"
        while IFS= read -r line; do
            if [[ ${line} =~ ^XDG_[A-Z_]+= ]]; then
                eval "export ${line}"
            fi
        done < "${file_name}"
    }

    # This is for bootstrap purposes only
    if [[ "${OSTYPE}" == darwin* && -n "${XDG_USE_MACOS_LIBRARY}" ]]; then
        export XDG_CONFIG_HOME="${HOME}/Library/Application\ Support/.config"
    else
        export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
    fi

    if [[ -s ${XDG_CONFIG_HOME}/base-dirs.dirs ]]; then
        load_and_export ${XDG_CONFIG_HOME}/base-dirs.dirs
    else
        if [[ -d "${HOME}/.cache" ]]; then
            export XDG_CACHE_HOME="${HOME}/.cache"
        elif [[ "${OSTYPE}" == darwin* && -n "${XDG_USE_MACOS_LIBRARY}" ]]; then
            export XDG_CACHE_HOME=$"${HOME}/Library/Application\ Support/Caches/.cache"
        else
            export XDG_CACHE_HOME="$(dirname "${TMPDIR}")/C/.cache"
        fi
        
        if [[ "${OSTYPE}" == darwin* && -n "${XDG_USE_MACOS_LIBRARY}" ]]; then
            export XDG_CONFIG_DIRS="${HOME}/.config"
        else
            export XDG_CONFIG_DIRS=":"
        fi
        
        if [[ -d "${HOME}/.local/share" ]]; then
            export XDG_DATA_HOME="${HOME}/.local/share"
        else
            export XDG_DATA_HOME="${HOME}/Library/Application\ Support/.local/share"
        fi
        
        if [[ "${OSTYPE}" == darwin* && -n "${XDG_USE_MACOS_LIBRARY}" ]]; then
            export XDG_DATA_DIRS="${HOME}/.local/share:/usr/local/share:/usr/share"
        else
            export XDG_DATA_DIRS="/usr/local/share:/usr/share"
        fi

        if [[ "${OSTYPE}" == darwin* && -n "${XDG_USE_MACOS_LIBRARY}" ]]; then
            export XDG_STATE_HOME="${HOME}/Library/Application\ Support/.local/state"
        else
            export XDG_STATE_HOME="${HOME}/.local/state"
        fi
        
        if [[ -d "${HOME}/.local/runtime" ]]; then
            export XDG_RUNTIME_HOME="${HOME}/.local/runtime"
        elif [[ "${OSTYPE}" == Linux* ]]; then
            export XDG_RUNTIME_DIR="/run/user/$(id -u)"
        else
            export XDG_RUNTIME_HOME="$(dirname "$TMPDIR")/T/.local/runtime"
        fi
    fi

    if [[ -s ${XDG_CONFIG_HOME}/user-dirs.dirs ]]; then
        load_and_export ${XDG_CONFIG_HOME}/user-dirs.dirs
    else
        export XDG_DESKTOP_DIR="${HOME}/Desktop"
        export XDG_DOWNLOAD_DIR="${HOME}/Downloads"
        export XDG_TEMPLATES_DIR="${HOME}/Templates"
        export XDG_PUBLICSHARE_DIR="${HOME}/Public"
        export XDG_DOCUMENTS_DIR="${HOME}/Documents"
        export XDG_MUSIC_DIR="${HOME}/Music"
        export XDG_PICTURES_DIR="${HOME}/Pictures"
        export XDG_VIDEOS_DIR="${HOME}/Movies"
    fi
}
_xdg_remember_fn _xdg_environment_init

_xdg_plugin_init() {
    emulate -L zsh

    _xdg_environment_init

    if [[ -d "${XDG[_PLUGIN_DIR]}/functions" ]]; then
        XDG[_PLUGIN_FNS_DIR]="${XDG[_PLUGIN_DIR]}/functions"
        # See https://wiki.zshell.dev/community/zsh_plugin_standard#functions-directory
        if [[ $PMSPEC != *f* ]]; then
            fpath+=( "${XDG[_PLUGIN_FNS_DIR]}" )
        elif [[ ${zsh_loaded_plugins[-1]} != */xdg && -z ${fpath[(r)${XDG[_PLUGIN_FNS_DIR]}]} ]]; then
            fpath+=( "${XDG[_PLUGIN_FNS_DIR]}" )
        fi

        local fn
        for fn in ${XDG[_PLUGIN_FNS_DIR]}/*(.:t); do
            autoload -Uz ${fn}
            _xdg_remember_fn ${fn}
        done
    fi
}
_xdg_remember_fn _xdg_plugin_init

xdg_plugin_unload() {
    emulate -L zsh

    local plugin_fns
    IFS=',' read -r -A plugin_fns <<< "${XDG[_FUNCTIONS]}"

    local fn
    for fn in ${plugin_fns[@]}; do
        whence -w "${fn}" &> /dev/null && unfunction "${fn}"
    done

    # Removing path/fpath entries.
    fpath=( "${(@)fpath:#${XDG[_PLUGIN_FNS_DIR]}}" )

    # Remove the global data variable (after above!).
    unset XDG

    unfunction xdg_plugin_unload
}

############################################################################
# Initialize Plugin
############################################################################

_xdg_plugin_init
true
