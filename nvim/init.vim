function! DoRemote(arg)
    UpdateRemotePlugins
endfunction
if has('win32')
    let $PYTHON = 'C:\Python27\python'
    let $PYTHON3 = 'C:\Python38\python'
    let $DIR_PLUGIN='C:\cygwin64\home\hhuang\hvim\nvim\plugged'
    let $HOME="C:\\Users\\hhuang"
    let $DIR_TEMP = $XDG_CONFIG_HOME
    let $MYVIMRC = '$XDG_CONFIG_HOME\nvim\init.vim'
else
    let $DIR_PLUGIN='~/.config/nvim/plugged'
    let $PYTHON = '/usr/bin/python'
    let $PYTHON3 = '/usr/bin/python3'
    let $DIR_TEMP = '~/.config/nvim'
endif

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
Plug 'jremmen/vim-ripgrep'
" navigation
"Plug 'scrooloose/nerdtree'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'wesleyche/SrcExpl'
Plug 'majutsushi/tagbar'
Plug 'rizzatti/dash.vim'
Plug 'eugen0329/vim-esearch'
Plug 'ludovicchabant/vim-gutentags'
" c/c++
" java
Plug 'artur-shaik/vim-javacomplete2'
" python
Plug 'mattn/emmet-vim'
" scala
Plug 'ensime/ensime-vim', { 'do': function('DoRemote') }
Plug 'derekwyatt/vim-scala'
Plug 'universal-ctags/ctags'
call plug#end()

let g:python_host_prog = $PYTHON
let g:python3_host_prog = $PYTHON3
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
set nowrap           "no line wrapping
set cst "ctags 多个选择
"colorscheme gruvbox  "use the theme gruvbox
colorscheme molokai  "use the theme gruvbox
set background=dark "use the light version of gruvbox
hi CursorLine cterm=bold,reverse ctermfg=238 ctermbg=253 gui=bold,reverse guifg=#455354 guibg=fg
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
nmap <leader>t :vs\|Topen<CR>
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
            \ { 'c': '$MYVIMRC' },
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

" gutentags搜索工程目录的标志，碰到这些文件/目录名就停止向上一级目录递归 "
let g:gutentags_project_root = ['.root', '.svn', '.git', '.project']

" 所生成的数据文件的名称 "
let g:gutentags_ctags_tagfile = '.tags'

" 将自动生成的 tags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录 "
let s:vim_tags = expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags
" 检测 ~/.cache/tags 不存在就新建 "
if !isdirectory(s:vim_tags)
   silent! call mkdir(s:vim_tags, 'p')
endif

" 配置 ctags 的参数 "
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+pxI']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']


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
