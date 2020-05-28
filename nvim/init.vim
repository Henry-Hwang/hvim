function! DoRemote(arg)
    UpdateRemotePlugins
endfunction
let $HOME="C:\\Users\\hhuang"
let $DIR_PLUGIN='C:\cygwin64\home\hhuang\hvim\nvim\plugged'
let $PYTHON = 'C:\Python27\python' 
let $PYTHON3 = 'C:\Python38\python' 

call plug#begin($DIR_PLUGIN)
" looking
Plug 'mhinz/vim-startify'
Plug 'Yggdroot/indentLine'
Plug 'ryanoasis/vim-devicons'
Plug 'myusuf3/numbers.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ianks/gruvbox'
Plug 'vim-scripts/molokai'
Plug 'airblade/vim-gitgutter'
Plug 'altercation/vim-colors-solarized'
" completion/templating
Plug 'jiangmiao/auto-pairs'
Plug 'ervandew/supertab'
Plug 'tpope/vim-endwise'
"Plug 'scrooloose/nerdcommenter'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
" command extention
Plug 'wellle/targets.vim'
Plug 'tpope/vim-surround'
Plug 'terryma/vim-multiple-cursors'
" utils
Plug 'neomake/neomake'
Plug 'kassio/neoterm'
Plug 'chrisbra/NrrwRgn'
" misc
Plug 'asins/vimcdoc'
Plug 'junegunn/vim-github-dashboard'
" documentation
Plug 'rhysd/nyaovim-markdown-preview'
Plug 'xolox/vim-notes'
Plug 'xolox/vim-misc'
Plug 'itchyny/calendar.vim'
Plug 'junegunn/vim-journal'
Plug 'junegunn/fzf'
" navigation
"Plug 'scrooloose/nerdtree'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'wesleyche/SrcExpl'
Plug 'majutsushi/tagbar'
Plug 'rizzatti/dash.vim'
Plug 'eugen0329/vim-esearch'
" c/c++
" java
Plug 'artur-shaik/vim-javacomplete2'
" python
Plug 'mattn/emmet-vim'
" scala
Plug 'ensime/ensime-vim', { 'do': function('DoRemote') }
Plug 'derekwyatt/vim-scala'
call plug#end()

let g:python_host_prog = 'C:\Python27\python' 
let g:python3_host_prog = 'C:\Python38\python' 
" Fundamental settings
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,gbk,cp936,latin-1
set fileformat=unix
set fileformats=unix,dos,mac
filetype on
filetype plugin on
filetype plugin indent on
syntax on
" Some useful settings
set mat=2            "keep modified buffer
set scrolloff=4
set hidden           "keep modified buffer
set smartindent
set expandtab         "tab to spaces
set tabstop=4         "the width of a tab
set shiftwidth=4      "the width for indent
set foldenable
set foldmethod=indent "folding by indent
set foldlevel=99
set ignorecase        "ignore the case when search texts
set smartcase         "if searching text contains uppercase case will not be ignored
set autochdir
set number           "line number
set cursorline       "hilight the line of the cursor
set nowrap           "no line wrapping
set cst "ctags 多个选择
"colorscheme gruvbox  "use the theme gruvbox
colorscheme molokai  "use the theme gruvbox
set background=dark "use the light version of gruvbox
" change the color of chars over the width of 80 into blue
" (uncomment to enable it)
"au BufWinEnter * let w:m2=matchadd('Underlined', '\%>' . 80 . 'v.\+', -1)
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

" Shortcuts
" \\ => go to command mode
let mapleader = ","       "Set mapleader
imap <leader><leader> <esc>:
"nnoremap <leader><leader>t :vs|:te<CR>
nnoremap <C-e> :Ex<CR>
nnoremap <C-f> :FZF %:p:h
nmap <leader>p "*p
nmap <leader>p "*y
nnoremap <leader><leader>r :%s/<C-r><C-w>/<C-r><C-w>/gc
" <space> => fold/unfold current code
" tips: zR => unfold all; zM => fold all
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>
tnoremap <Esc> <C-\><C-n> 
nnoremap <leader>. :e $XDG_CONFIG_HOME\nvim\init.vim<CR>
nnoremap <leader>.. :source $XDG_CONFIG_HOME\nvim\init.vim<CR>
nmap tt :vs\|Topen<CR>
nmap tn :Tnext<CR>
nmap tq :TcloseaAll!<CR>
" te => send current line/selected lines to the terminal
nnoremap <silent> te :TREPLSend<CR>
" tE => send the thole current file to the terminal
nnoremap <silent> tE :TREPLSendFile<CR>
" tm => toggle the markdown preview
let g:markdown_preview_on = 0
au! BufWinEnter *.md,*.markdown,*.mdown let g:markdown_preview_on = g:markdown_preview_auto || g:markdown_preview_on  
au! BufWinLeave *.md,*.markdown,*.mdown let g:markdown_preview_on = !g:markdown_preview_auto && g:markdown_preview_on  
nmap tm @=(g:markdown_preview_on ? ':Stop' : ':Start')<CR>MarkdownPreview<CR>:let g:markdown_preview_on = 1 - g:markdown_preview_on<CR>
" Airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:indentLine_color_gui = "#504945"
" Markdown_preview (a plugin in nyaovim)
let g:markdown_preview_eager = 1
let g:markdown_preview_auto = 1
" Multi_cursor
let g:multi_cursor_use_default_mapping=0
let g:multi_cursor_start_key='<c-n>'
let g:multi_cursor_next_key='<tab>'
let g:multi_cursor_prev_key='b'
let g:multi_cursor_skip_key='x'
let g:multi_cursor_quit_key='q'
" Neomake
let g:neomake_cpp_enabled_makers = ['clang']
let g:neomake_cpp_clang_args = ['-Wall', '-Wextra', '-std=c++11', '-o', '%:p:r']
let g:neomake_cpp_gcc_args = ['-Wall', '-Wextra', '-std=c++11', '-o', '%:p:r']
let g:neomake_scala_enabled_markers = ['fsc', 'scalastyle']
let g:neomake_scala_scalac_args = ['-Ystop-after:parser', '-Xexperimental']
" Neoterm
let g:neoterm_size=20
" toogle the terminal
" kills the current job (send a <c-c>)
nnoremap <silent> tc :call neoterm#kill()<cr>
" Notes
let g:notes_directories = ['~/.config/nvim/note/notes-in-vim']
" Startify
command! -nargs=1 CD cd <args> | Startify
autocmd User Startified setlocal cursorline
let g:startify_enable_special         = 0
let g:startify_files_number           = 8
let g:startify_relative_path          = 1
let g:startify_change_to_dir          = 1
let g:startify_update_oldfiles        = 1
let g:startify_session_autoload       = 1
let g:startify_session_persistence    = 1
let g:startify_session_delete_buffers = 1
let g:startify_list_order = [
            \ ['   LRU within this dir:'],
            \ 'dir',
            \ ['   LRU:'],
            \ 'files',
            \ ['   Sessions:'],
            \ 'sessions',
            \ ['   Bookmarks:'],
            \ 'bookmarks',
            \ ]
let g:startify_skiplist = [
            \ 'COMMIT_EDITMSG',
            \ 'plugged/.*/doc',
            \ '/data/repo/neovim/runtime/doc',
            \ '.vimrc',
            \ 'nyaovimrc.html',
            \ ]
let g:startify_bookmarks = [
            \ { 'c': 'C:\cygwin64\home\hhuang\hvim\vimrc' },
            \ { 'y': 'C:\cygwin64\home\hhuang\hvim\nvim\init.vim' },
            \ ]
let g:startify_custom_footer =
            \ ['', "Henry Huang", '']
highlight StartifyFooter  ctermfg=240
" UltiSnip
" <tab> => expand the snippets
let g:UltiSnipsExpandTrigger = '<tab>'
" <ctrl-d> => list available snippets start with the chars before the cursor
let g:UltiSnipsListSnippets = '<c-d>'
" <enter> => go to the next placeholder
let g:UltiSnipsJumpForwardTrigger = '<enter>'
" <shift-enter> => go to the previous placeholder
let g:UltiSnipsJumpBackwardTrigger = '<c-k>'

"[[Ctrlp]]
let g:ctrlp_cmd = 'CtrlP'
nnoremap <C-a> :CtrlPBuffer<CR>
let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v[\/]\.(git|hg|svn|rvm)$',
    \ 'file': '\v\.(exe|so|bin|dll|zip|tar|tar.gz|pyc)$',
    \ }
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_match_window_bottom=1
let g:ctrlp_max_height=15
let g:ctrlp_match_window_reversed=0
let g:ctrlp_mruf_max=500
let g:ctrlp_follow_symlinks=1

if has('win32')
	let g:ctrlp_user_command = 'dir %s /-n /b /s /a-d'  " Windows
else
	let g:ctrlp_user_command = 'find %s -type f'        " MacOSX/Linux
endif

let g:ctrlp_funky_syntax_highlight = 1
let g:ctrlp_extensions = ['funky']

" Automatics
function! ToStartify()
    if winnr("$") == 1 && buffer_name(winbufnr(winnr())) != ""
        vs
        Startify
        exec "normal \<c-w>w"
    endif
endfunction
au! QuitPre * call ToStartify()
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
autocmd BufWritePost *.scala :EnTypeCheck
cd $XDG_CONFIG_HOME
au BufRead,BufNewFile,BufEnter \@!(term://)* cd %:p:h
autocmd FileType json set nocursorcolumn
