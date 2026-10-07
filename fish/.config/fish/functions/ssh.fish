# background tint for an ssh target, derived from its host key in known_hosts

function _ssh_tint
    set -l cfg (command ssh -G $argv 2>/dev/null)
    set -l host ''
    set -l port ''
    set -l files

    for line in $cfg
        if set -l m (string match -r '^hostname (.+)$' -- $line)
            set host $m[2]
        else if set -l m (string match -r '^port (.+)$' -- $line)
            set port $m[2]
        else if set -l m (string match -r '^userknownhostsfile (.+)$' -- $line)
            set -a files (string split ' ' -- $m[2])
        else if set -l m (string match -r '^globalknownhostsfile (.+)$' -- $line)
            set -a files (string split ' ' -- $m[2])
        end
    end

    test -n "$host"; or return 1
    if test "$port" != 22
        set host "[$host]:$port"
    end

    set -l lines
    for f in $files
        if test -r "$f"
            set -a lines (command ssh-keygen -F $host -f $f 2>/dev/null)
        end
    end

    # prefer ed25519 (what ssh records by default), then any key
    set -l key ''
    for l in $lines
        if string match -q -- '*ssh-ed25519*' -- $l
            set key $l
            break
        end
    end
    if test -z "$key"
        for l in $lines
            if not string match -q -- '#*' -- $l
                set key $l
                break
            end
        end
    end

    if test -n "$key"
        set key (string split ' ' -- $key)[3]
    end

    # unknown host: plain red tint
    if test -z "$key"
        printf '#2a1a1a'
        return
    end

    set -l sum (printf '%s' $key | cksum | string split ' ')[1]

    # 16 evenly spaced hues x 2 brightness levels, dark and muted like the terminal background
    set -l n (math "$sum % 32")
    set -l hp (math "$n % 16 * 6 / 16.0")
    set -l s 0.35
    set -l l 0.12
    if test $n -ge 16
        set l 0.19
    end
    set -l c (math "(1 - abs(2 * $l - 1)) * $s")
    set -l x (math "$c * (1 - abs($hp % 2 - 1))")
    set -l m (math "$l - $c / 2")
    set -l hi (math "floor($hp)")

    set -l r 0
    set -l g 0
    set -l b 0
    switch $hi
        case 0
            set r $c
            set g $x
            set b 0
        case 1
            set r $x
            set g $c
            set b 0
        case 2
            set r 0
            set g $c
            set b $x
        case 3
            set r 0
            set g $x
            set b $c
        case 4
            set r $x
            set g 0
            set b $c
        case '*'
            set r $c
            set g 0
            set b $x
    end

    printf '#%02x%02x%02x' (math "round(($r + $m) * 255)") (math "round(($g + $m) * 255)") (math "round(($b + $m) * 255)")
end

function ssh
    set -l tint (_ssh_tint $argv)
    if test -n "$tint"
        printf '\e]11;%s\a' $tint
    end
    command ssh $argv
    set -l rc $status
    printf '\e]111\a'
    return $rc
end
