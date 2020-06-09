let $DIR_PLUGIN='~/.config/nvim/plugged'
let $PYTHON = '/usr/bin/python' 
let $PYTHON3 = '/usr/bin/python3' 
let $DIR_TEMP = '~/.vim/tmp'
call plug#begin($DIR_PLUGIN)
Plug 'mhinz/vim-startify'
Plug 'myusuf3/numbers.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'vim-scripts/molokai'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'wellle/targets.vim'
Plug 'will133/vim-dirdiff'
Plug 'asins/vimcdoc'
Plug 'xolox/vim-notes'
Plug 'xolox/vim-misc'
Plug 'itchyny/calendar.vim'
Plug 'junegunn/vim-journal'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'jremmen/vim-ripgrep'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'ludovicchabant/vim-gutentags'
Plug 'universal-ctags/ctags'
Plug 'majutsushi/tagbar'
Plug 'tacahiroy/ctrlp-funky'
Plug 'eshion/vim-sync'
Plug 'vim-scripts/a.vim'
Plug 'vim-scripts/xml.vim'
Plug 'vim-scripts/python.vim'
Plug 'vim-scripts/c.vim'
Plug 'scrooloose/nerdcommenter'
call plug#end()

let g:python_host_prog = $PYTHON
let g:python3_host_prog = $PYTHON3
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,gbk,cp936,latin-1
set fileformat=unix
set fileformats=unix,dos,mac
filetype on
filetype plugin on
filetype plugin indent on
syntax on
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim
set guioptions-=T	" 不显示工具栏
set guioptions-=L	" 不显示左边滚动条
set guioptions-=r	" 不显示右边滚动条
set guioptions-=m

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
set nowrap           "no line wrapping
set cst "ctags 多个选择

hi Comment ctermfg=cyan
set backspace=indent,eol,start
set whichwrap+=<,>,h,l
set softtabstop=4
set smarttab
set history=1024
set nobackup
set noswapfile
set incsearch
set hlsearch
set noerrorbells
set novisualbell
set laststatus=2
set showmatch
set wrapscan
set display=lastline
set paste
set list
set listchars=tab:\|\ ,trail:~,extends:>,precedes:<

set shortmess=atl

colorscheme molokai  "use the theme gruvbox
set background=dark "use the light version of gruvbox
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set t_Co=256
set guifont=Courier_New:h11
hi CursorLine term=underline ctermbg=236 guibg=#293739
"[[syntax]]
hi Comment term=bold ctermfg=60 guifg=#465457
let mapleader = ","       "Set mapleader
"command ": hi" to show all color
imap <leader><leader> <esc>:
"nnoremap <leader><leader>t :vs|:te<CR>
nnoremap <C-e> :Ex<CR>
nnoremap <C-f><C-f> :FZF %:p:h
nnoremap <leader>bw :bw!<CR>
map <leader>p "+p
map <leader>y "+yy
nnoremap <leader>r :%s/<C-r><C-w>/<C-r><C-w>/gc
nnoremap <C-s> :g/<C-r><C-w>/<CR>
nnoremap <C-s><C-s> :g/<C-r><C-w>/yank A<CR>:vnew<CR>p
nnoremap <C-f> /<C-r><C-w><CR>
nnoremap <C-g> :Rg <C-r><C-w> %:p:h
"select a function
nnoremap <leader>f [[%v%h0
"<CR>:vnew

" <space> => fold/unfold current code
" tips: zR => unfold all; zM => fold all
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>
tnoremap <Esc> <C-\><C-n> 
nnoremap <leader>. :e $MYVIMRC<CR>
nnoremap <leader>.. :source $MYVIMRC<CR>

nnoremap <leader>t :vertical terminal<CR>
nnoremap <leader>,m /&clean-search&<CR>
let g:markdown_preview_on = 0
au! BufWinEnter *.md,*.markdown,*.mdown let g:markdown_preview_on = g:markdown_preview_auto || g:markdown_preview_on  
au! BufWinLeave *.md,*.markdown,*.mdown let g:markdown_preview_on = !g:markdown_preview_auto && g:markdown_preview_on  
nmap tm @=(g:markdown_preview_on ? ':Stop' : ':Start')<CR>MarkdownPreview<CR>:let g:markdown_preview_on = 1 - g:markdown_preview_on<CR>
" Airline
let g:airline#extensions#tagbar#flags = 'f' " show full tag hierarchy
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
            \ { 'c': '$MYVIMRC' },
            \ { 'p': 'C:\Users\hhuang\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1' },
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

let g:ctrlp_user_command = 'find %s -type f'        " MacOSX/Linux

let g:ctrlp_funky_syntax_highlight = 1
let g:ctrlp_extensions = ['funky']

command! Difft windo diffthis
command! Diffo windo diffoff
" gutentags stop at the point list bellow"
let g:gutentags_project_root = ['.root', '.svn', '.git', '.project']

" ctag name"
let g:gutentags_ctags_tagfile = '.tags'

" Put all tags in ~/.cache/tags"
let s:vim_tags = expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags
if !isdirectory(s:vim_tags)
   silent! call mkdir(s:vim_tags, 'p')
endif

" ctags settings "
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+pxI']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
" calculator
command! -nargs=+ Calc :py print <args>
py from math import *
"}

" SSH tmux
if exists('$TMUX')
	let &t_SI = "\<Esc>Ptmux;\<Esc>\e[5 q\<Esc>\\"
	let &t_EI = "\<Esc>Ptmux;\<Esc>\e[2 q\<Esc>\\"
else
	let &t_SI = "\e[5 q"
	let &t_EI = "\e[2 q"
endif

"[[Session management]]
if &diff
    hi DiffAdd    ctermfg=233 ctermbg=LightGreen guifg=#003300 guibg=#DDFFDD gui=none cterm=none
    hi DiffChange ctermbg=white  guibg=#ececec gui=none   cterm=none
	hi DiffText   ctermfg=233  ctermbg=yellow  guifg=#000033 guibg=#DDDDFF gui=none cterm=none
endif
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
cd $DIR_TEMP
au BufRead,BufNewFile,BufEnter \@!(term://)* cd %:p:h
autocmd FileType json set nocursorcolumn
