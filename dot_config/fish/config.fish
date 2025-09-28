if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Disable greetings messege
set -g fish_greeting

fish_default_key_bindings

# Starship 
function starship_transient_prompt_func
    starship module character
end

function starship_transient_rprompt_func
    starship module time
end

starship init fish | source
enable_transience

set -Ux fifc_editor helix

# Yazi wrapper
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

zoxide init --cmd cd fish | source
