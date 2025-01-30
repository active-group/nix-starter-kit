enable_nix() {
    if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
        . ~/.nix-profile/etc/profile.d/nix.sh
    fi
}

load_home_manager_session_variables() {
    if [ -e ~/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then
        . ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    fi
}

start_fish_if_interactive() {
    # When used interactively, change to a 'fish' shell; make sure we don't do
    # this when zsh is called from -i -c, like from Emacs's
    # `exec-path-from-shell`.
    if [[ -o interactive ]] && [[ -z "$ZSH_EXECUTION_STRING" ]] && [[ -e ~/.nix-profile/bin/fish ]]; then
        exec ~/.nix-profile/bin/fish
    fi
}
