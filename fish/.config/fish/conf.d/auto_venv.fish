function __auto_activate_venv --on-variable PWD
    # Only deactivate if we're leaving the venv's project directory
    if set -q VIRTUAL_ENV
        set venv_dir (dirname (dirname $VIRTUAL_ENV))
        if not string match -q "$venv_dir*" $PWD
            deactivate
        end
    end

    # Only look for new venv if none active
    if not set -q VIRTUAL_ENV
        set dir $PWD
        while test "$dir" != "" -a "$dir" != "/"
            if test -d "$dir/.venv/bin"
                source "$dir/.venv/bin/activate.fish"
                break
            end
            set dir (dirname "$dir")
        end
    end
end
