colorscheme base16

set global grepcmd 'rg --column'

eval %sh{kak-lsp --kakoune -s $kak_session}
lsp-auto-hover-enable

# General hooks
hook global BufCreate .* %{editorconfig-load}

# Rust
hook global BufCreate .*.rs %{ set-option buffer formatcmd 'rustfmt' }
hook global BufWritePre .*.rs %{ format }

# JS
hook global BufCreate .*.(ts|js)x?$ %{ set-option buffer formatcmd 'prettier --stdin --parser=typescript' }
hook global BufWritePre .*.(ts|js)x?$ %{ format }

# TeX
hook global BufCreate .*.tex.tera %{ set-option buffer filetype latex }

# Softwrap
addhl global/ wrap

# inspired by https://github.com/mawww/kakoune/wiki/Fuzzy-finder
def -docstring 'invoke fzf to open a file' \
  fzf-file %{nop %sh{
    if [ -z "$TMUX" ]; then echo echo only works inside tmux
    else
      FILE=$(find * -type f | fzf-tmux -d 15)
      if [ -n "$FILE" ]; then
        printf 'eval -client %%{%s} edit %%{%s}' "$kak_client" "${FILE}" | kak -p "${kak_session}"
      fi
    fi
} }

def -docstring 'invoke fzf to select a buffer' \
  fzf-buffer %{eval %sh{
      BUFFER=$(printf %s\\n ${kak_buflist} | sed "s/'//g" |fzf-tmux -d 15)
      if [ -n "$BUFFER" ]; then
        echo buffer ${BUFFER}
      fi
} }

# Keybindings
map -docstring 'buffers' global user b ':fzf-buffer<ret>'
map -docstring 'copy to clipboard' global user y ':nop %sh( echo "${kak_selection}" | xclip -selection clipboard &> /dev/null )<ret>'
map -docstring 'fuzzy-find file' global user f ':fzf-file<ret>'
map -docstring 'grep' global user g ':grep '
# map -docstring 'open ranger in current directory' global user r ':nop %sh(ranger)<ret>'
map -docstring 'toggle comment' global user c ':comment-line<ret>'
map -docstring 'write' global user w ':write<ret>'
map -docstring 'write-quit' global user q ':write-quit<ret>'

map global insert <c-l> <esc>
map global prompt <c-l> <esc>
