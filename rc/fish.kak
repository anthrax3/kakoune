# http://fishshell.com
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufSetOption mimetype=text/x-fish %{
    set buffer filetype fish
}

hook global BufCreate .*[.](fish) %{
    set buffer filetype fish
}

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

addhl -group / multi_region -default code fish \
    double_string (^|\h)" (?<!\\)(\\\\)*" ''   \
    single_string (^|\h)' (?<!\\)(\\\\)*' ''   \
    comment       (^|\h)# $               ''

addhl -group /fish/double_string fill string
addhl -group /fish/double_string regex (\$\w+)|(\{\$\w+\}) 0:identifier
addhl -group /fish/single_string fill string
addhl -group /fish/comment       fill comment

addhl -group /fish/code regex (\$\w+)|(\{\$\w+\}) 0:identifier

# Command names generated by fish
addhl -group /fish/code regex %sh{ printf '\<(%s)\>' $(printf '\Q%s\\E|' $(fish --command 'builtin --names' --command 'functions --names' | tr --delete ,)) } 0:keyword

# Commands
# ‾‾‾‾‾‾‾‾

def -hidden _fish_filter_around_selections %{
    eval -draft -itersel %{
        exec <a-x>
        # remove trailing white spaces
        try %{ exec -draft s \h+$ <ret> d }
    }
}

def -hidden _fish_indent_on_new_line %{
    eval -draft -itersel %{
        # preserve previous line indent
        try %{ exec -draft <space> K <a-&> }
        # filter previous line
        try %{ exec -draft k : _fish_filter_around_selections <ret> }
        # copy '#' comment prefix and following white spaces
        try %{ exec -draft k x s ^\h*\K#\h* <ret> y j p }
        # indent after (case|else) commands
        try %{ exec -draft <space> k x <a-k> (case|else) <ret> j <a-gt> }
        # indent after (begin|for|function|if|switch|while) commands and add 'end' command
        try %{ exec -draft <space> k x <a-k> (begin|for|function|(?<!(else)\h+)if|switch|while) <ret> x y p j a end <esc> k <a-gt> }
    }
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=fish %{
    addhl ref fish

    hook window InsertEnd  .* -group fish-hooks  _fish_filter_around_selections
    hook window InsertChar \n -group fish-indent _fish_indent_on_new_line
}

hook global WinSetOption filetype=(?!fish).* %{
    rmhl fish
    rmhooks window fish-indent
    rmhooks window fish-hooks
}
