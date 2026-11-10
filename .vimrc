" Keep Vim's stock defaults (syntax highlighting, filetype detection, etc.),
" which are otherwise skipped once a ~/.vimrc exists.
unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

" Indent with spaces, 2 per level by default.
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2

" C, C++ and C#: 4 spaces per level.
augroup indentation
  autocmd!
  autocmd FileType c,cpp,cs setlocal tabstop=4 softtabstop=4 shiftwidth=4
augroup END

" NetRW config
" Hide the obnoxious banner at the top
let g:netrw_banner = 0

" Set tree view style (collapsible folders)
let g:netrw_liststyle = 3

" Set the sidebar width to 25% of the screen
let g:netrw_winsize = 25

" Shortcut to toggle the sidebar using Ctrl+B (like VS Code)
nnoremap <C-b> :Lexplore<CR>
