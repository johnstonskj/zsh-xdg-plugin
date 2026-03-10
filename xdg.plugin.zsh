# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name: xdg
# @brief: Bootstrap/setup the XDG Base Directory environment variables.
# @repository: https://github.com/johnstonskj/zsh-xdg-plugin
# @version: 0.1.1
# @license: MIT AND Apache-2.0
#
# ### Public Variables
#
# * `XDG_USE_MACOS_LIBRARY`; if set, use the Apple _File System Programming
#   Guide_ for directories rather than the POSIX versions.
#

############################################################################
# @section Lifecycle
# @description Plugin lifecycle functions.
#

xdg_plugin_init() {
    emulate -L zsh

    load_and_export() {
        local file_name="${1}"
        while IFS= read -r line; do
            if [[ ${line} =~ ^XDG_[A-Z_]+= ]]; then
                eval "export ${line}"
            fi
        done < "${file_name}"
    }

    # This is for bootstrap purposes only
    @zplugins_envvar_save xdg XDG_CONFIG_HOME
    if [[ "${OSTYPE}" == darwin* && -n "${XDG_USE_MACOS_LIBRARY}" ]]; then
        export XDG_CONFIG_HOME="${HOME}/Library/Application\ Support/.config"
    else
        export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
    fi

    if [[ -s ${XDG_CONFIG_HOME}/base-dirs.dirs ]]; then
        load_and_export ${XDG_CONFIG_HOME}/base-dirs.dirs
    else
        @zplugins_envvar_save xdg XDG_CACHE_HOME
        if [[ -d "${HOME}/.cache" ]]; then
            export XDG_CACHE_HOME="${HOME}/.cache"
        elif [[ "${OSTYPE}" == darwin* && -n "${XDG_USE_MACOS_LIBRARY}" ]]; then
            export XDG_CACHE_HOME=$"${HOME}/Library/Application\ Support/Caches/.cache"
        else
            export XDG_CACHE_HOME="$(dirname "${TMPDIR}")/C/.cache"
        fi
        
        @zplugins_envvar_save xdg XDG_CONFIG_DIRS
        if [[ "${OSTYPE}" == darwin* && -n "${XDG_USE_MACOS_LIBRARY}" ]]; then
            export XDG_CONFIG_DIRS="${XDG_CONFIG_HOME}"
        else
            export XDG_CONFIG_DIRS=":"
        fi
        
        @zplugins_envvar_save xdg XDG_DATA_HOME
        if [[ "${OSTYPE}" == darwin* && -n "${XDG_USE_MACOS_LIBRARY}" ]]; then
            export XDG_DATA_HOME="${HOME}/Library/Application\ Support/.local/share"
        else
            export XDG_DATA_HOME="${HOME}/.local/share"
        fi
        
        @zplugins_envvar_save xdg XDG_DATA_DIRS
        if [[ "${OSTYPE}" == darwin* && -n "${XDG_USE_MACOS_LIBRARY}" ]]; then
            export XDG_DATA_DIRS="${HOME}/.local/share:/usr/local/share:/usr/share"
        else
            export XDG_DATA_DIRS="/usr/local/share:/usr/share"
        fi

        @zplugins_envvar_save xdg XDG_STATE_HOME
        if [[ "${OSTYPE}" == darwin* && -n "${XDG_USE_MACOS_LIBRARY}" ]]; then
            export XDG_STATE_HOME="${HOME}/Library/Application\ Support/.local/state"
        else
            export XDG_STATE_HOME="${HOME}/.local/state"
        fi
        
        @zplugins_envvar_save xdg XDG_RUNTIME_HOME
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
        @zplugins_envvar_save xdg XDG_DESKTOP_DIR
        export XDG_DESKTOP_DIR="${HOME}/Desktop"
        @zplugins_envvar_save xdg XDG_DOWNLOAD_DIR
        export XDG_DOWNLOAD_DIR="${HOME}/Downloads"
        @zplugins_envvar_save xdg XDG_TEMPLATES_DIR
        export XDG_TEMPLATES_DIR="${HOME}/Templates"
        @zplugins_envvar_save xdg XDG_PUBLICSHARE_DIR
        export XDG_PUBLICSHARE_DIR="${HOME}/Public"
        @zplugins_envvar_save xdg XDG_DOCUMENTS_DIR
        export XDG_DOCUMENTS_DIR="${HOME}/Documents"
        @zplugins_envvar_save xdg XDG_MUSIC_DIR
        export XDG_MUSIC_DIR="${HOME}/Music"
        @zplugins_envvar_save xdg XDG_PICTURES_DIR
        export XDG_PICTURES_DIR="${HOME}/Pictures"
        @zplugins_envvar_save xdg XDG_VIDEOS_DIR
        export XDG_VIDEOS_DIR="${HOME}/Movies"
    fi
}

xdg_plugin_unload() {
    emulate -L zsh

    @zplugins_envvar_restore xdg XDG_CONFIG_HOME
    @zplugins_envvar_restore xdg XDG_CACHE_HOME
    @zplugins_envvar_restore xdg XDG_CONFIG_DIRS
    @zplugins_envvar_restore xdg XDG_DATA_HOME
    @zplugins_envvar_restore xdg XDG_DATA_DIRS
    @zplugins_envvar_restore xdg XDG_STATE_HOME        
    @zplugins_envvar_restore xdg XDG_RUNTIME_HOME
    @zplugins_envvar_restore xdg XDG_DESKTOP_DIR
    @zplugins_envvar_restore xdg XDG_DOWNLOAD_DIR
    @zplugins_envvar_restore xdg XDG_TEMPLATES_DIR
    @zplugins_envvar_restore xdg XDG_PUBLICSHARE_DIR
    @zplugins_envvar_restore xdg XDG_DOCUMENTS_DIR
    @zplugins_envvar_restore xdg XDG_MUSIC_DIR
    @zplugins_envvar_restore xdg XDG_PICTURES_DIR
    @zplugins_envvar_restore xdg XDG_VIDEOS_DIR
}
