function! DoRemote(arg)
    UpdateRemotePlugins
endfunction
if has('win32')
    let $PYTHON = 'C:\Python27\python' 
    let $PYTHON3 = 'C:\Python38\python' 
    let $DIR_TEMP = $XDG_CONFIG_HOME
    let $HOME="C:\\Users\\hhuang"
    let $MYVIMRC = '$XDG_CONFIG_HOME\nvim\init.vim'
    let $DIR_PLUGIN='C:\cygwin64\home\hhuang\hvim\nvim\plugged'
else
    let $DIR_PLUGIN='~/.config/nvim/plugged'
    let $PYTHON = '/usr/bin/python' 
    let $PYTHON3 = '/usr/bin/python3' 
    let $DIR_TEMP = '~/.config/nvim'
endif

call plug#begin($DIR_PLUGIN)
Plug 'mhinz/vim-startify'
Plug 'myusuf3/numbers.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'vim-scripts/molokai'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'wellle/targets.vim'
Plug 'tpope/vim-surround'
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
Plug 'ensime/ensime-vim', { 'do': function('DoRemote') }
Plug 'universal-ctags/ctags'
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
set softtabstop=4
set smarttab
set history=1024
set nobackup
set incsearch
set hlsearch
set noerrorbells
set novisualbell
set laststatus=2
set showmatch
set wrapscan
colorscheme molokai  "use the theme gruvbox
set background=dark "use the light version of gruvbox
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

let mapleader = ","       "Set mapleader
"command ": hi" to show all color
imap <leader><leader> <esc>:
"nnoremap <leader><leader>t :vs|:te<CR>
nnoremap <C-e> :Ex<CR>
nnoremap <C-f><C-f> :FZF %:p:h
nnoremap <leader>bw :bw!<CR>
if has('win32unix')
	vnoremap <silent> <leader>y :call Putclip(visualmode(), 1)<CR>
	nnoremap <silent> <leader>y :call Putclip('n', 1)<CR>
	nnoremap <silent> <leader>p :call Getclip()<CR>
else
	map <leader>p "+p
	map <leader>y "+yy
endif
nnoremap <leader>r :%s/<C-r><C-w>/<C-r><C-w>/gc
nnoremap <C-s> :g/<C-r><C-w>/<CR>
nnoremap <C-s><C-s> :g/,C-r><C-w>/yank A<CR>:vnew<CR>p
nnoremap <C-f> /<C-r><C-w><CR>
nnoremap <C-g> :Rg <C-r><C-w> %:p:h
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
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline_powerline_fonts = 1
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
            \ { 'c': 'C:\cygwin64\home\hhuang\hvim\vimrc' },
            \ { 'y': 'C:\cygwin64\home\hhuang\hvim\nvim\init.vim' },
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

if has('win32')
	let g:ctrlp_user_command = 'dir %s /-n /b /s /a-d'  " Windows
else
	let g:ctrlp_user_command = 'find %s -type f'        " MacOSX/Linux
endif

let g:ctrlp_funky_syntax_highlight = 1
let g:ctrlp_extensions = ['funky']

if has('win32unix')
	function! Putclip(type, ...) range
		let sel_save = &selection
		let &selection = "inclusive"
		let reg_save = @@
		if a:type == 'n'
			silent exe a:firstline . "," . a:lastline . "y"
		elseif a:type == 'c'
			silent exe a:1 . "," . a:2 . "y"
		else
			silent exe "normal! `<" . a:type . "`>y"
		endif
	
		"call system('putclip', @@)  " if you're using an old Cygwin
		"call system('clip.exe', @@) " if you're using Bash on Windows
	
		"As of Cygwin 1.7.13, the /dev/clipboard device was added to provide
		"access to the native Windows clipboard. It provides the added benefit
		"of supporting utf-8 characters which putclip currently does not. Based
		"on a tip from John Beckett, use the following:
		call writefile(split(@@,"\n"), '/dev/clipboard')
	
		let &selection = sel_save
		let @@ = reg_save
	endfunction
	function! Getclip()
		let reg_save = @@
		"let @@ = system('getclip')
		"Much like Putclip(), using the /dev/clipboard device to access to the
		"native Windows clipboard for Cygwin 1.7.13 and above. It provides the
		"added benefit of supporting utf-8 characters which getclip currently does
		"not. Based again on a tip from John Beckett, use the following:
		let @@ = join(readfile('/dev/clipboard'), "\n")
		setlocal paste
		exe 'normal p'
		setlocal nopaste
		let @@ = reg_save
	endfunction
endif

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


"if has('win32')
"let g:UltiSnipsSnippetDirectories=[$HOME.'\.vim\mysnippets']
"else
"let g:UltiSnipsSnippetDirectories=[$HOME.'/.vim/mysnippets']
"endif
"[[Session management]]
if &diff
    nnoremap ] ]c
    nnoremap [ [c
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
