function __auto_activate_venv --on-variable PWD
    # deactivate any active venv when moving out
    if set -q VIRTUAL_ENV
        deactivate
    end

    # walk up directories to find a .venv folder
    set dir $PWD
    while test "$dir" != ""
        if test -d "$dir/.venv/bin"
            source "$dir/.venv/bin/activate.fish"
            break
        end
        set dir (dirname "$dir")
        if test "$dir" = /
            break
        end
    end
end
