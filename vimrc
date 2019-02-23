"插件管理

if has('win32') && has ('gui_runing')
	set rtp+=$HOME\.vim\bundle\Vundle.vim
	call vundle#begin()
else
	set rtp+=$HOME/.vim/bundle/Vundle.vim/
	call vundle#begin('$HOME/.vim/bundle/')
endif
Plugin 'VundleVim/Vundle.vim'
Plugin 'kien/ctrlp.vim'
Plugin 'vim-scripts/FuzzyFinder'
Plugin 'eshion/vim-sync'
Plugin 'vim-scripts/molokai.git'
Plugin 'vim-scripts/EasyGrep.git'
Plugin 'vim-scripts/grep.vim'
Plugin 'vim-scripts/taglist.vim'
Plugin 'vim-scripts/a.vim'
Plugin 'vim-scripts/xml.vim'
Plugin 'vim-scripts/python.vim'
Plugin 'vim-scripts/c.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'vim-scripts/ctags.vim'
Plugin 'lifepillar/vim-mucomplete'
Plugin 'xolox/vim-session'
Plugin 'xolox/vim-misc'
Plugin 'will133/vim-dirdiff'
Plugin 'tpope/vim-fugitive'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
"Plugin 'scrooloose/nerdtree'
call vundle#end()

set encoding=utf-8
if has('win32') && has ('gui_running')
	source $VIMRUNTIME/delmenu.vim
	source $VIMRUNTIME/menu.vim
	language messages zh_CN.utf-8

	set guioptions-=T	" 不显示工具栏
	set guioptions-=L	" 不显示左边滚动条
	set guioptions-=r	" 不显示右边滚动条
	set guioptions-=m
endif

set cst "ctags 多个选择
" 设定配色方案
" 自动语法高亮
syntax on
" 检测文件类型
filetype on
" 检测文件类型插件
filetype plugin on
hi Comment ctermfg=cyan
" 不设定在插入状态无法用退格键和 Delete 键删除回车符
set backspace=indent,eol,start
set whichwrap+=<,>,h,l
" 显示行号
set number
" 上下可视行数
set scrolloff=4
set noexpandtab
" 设定 tab 长度为 4
set tabstop=4
" 设置按BackSpace的时候可以一次删除掉4个空格
set softtabstop=4
" 设定 << 和 >> 命令移动时的宽度为 4
set shiftwidth=4
set smarttab
set history=1024
" 覆盖文件时不备份
set nobackup
" 自动切换当前目录为当前文件所在的目录
set autochdir
" 搜索时忽略大小写，但在有一个或以上大写字母时仍大小写敏感
set ignorecase
set smartcase
" 实时搜索
set incsearch
" 搜索时高亮显示被找到的文本
set hlsearch
" 关闭错误声音
set noerrorbells
set novisualbell

" 不自动换行
set nowrap
"How many tenths of a second to blink
set mat=2
" 允许在有未保存的修改时切换缓冲区，此时的修改由 vim 负责保存
set hidden
" 智能自动缩进
set smartindent
" 设定命令行的行数为 1
"set cmdheight=1
" 显示状态栏 (默认值为 1, 无法显示状态栏)
set laststatus=2
"显示括号配对情况
set showmatch
set wrapscan
" 解决自动换行格式下, 如高度在折行之后超过窗口高度结果这一行看不到的问题
set display=lastline
" 设置在状态行显示的信息
set statusline=\ %f%m%r%h%w\ %=%({%{&ff}\|%{(&fenc==\"\"?&enc:&fenc).((exists(\"+bomb\")\ &&\ &bomb)?\",B\":\"\")}%k\|%Y}%)\ %([%l,%L][%p%%]\ %)

" 粘贴保持格式
set paste

" 显示Tab符
set list
set listchars=tab:\|\ ,trail:~,extends:>,precedes:<

"启动时不显示 捐赠提示
set shortmess=atl

"have to put color scheme at last
set background=dark
set t_Co=256
colorscheme molokai
set cursorline
set guifont=Courier_New:h11
if has('win32unix')
	hi CursorLine cterm=NONE ctermfg=white ctermbg=55 guifg=#293739
else
	hi CursorLine term=NONE ctermfg=white ctermbg=534 guibg=#293739
endif
"[[syntax]]
hi Comment term=bold ctermfg=60 guifg=#465457

"command ": h" to show all color
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
"{ [[map keys]]
let mapleader = ","       "Set mapleader
nnoremap <C-s> :CtrlPBuffer<CR>
map <leader>t :Tlist<CR>
map <leader>b :ls<CR>:b<space>
map <leader>3 :b#<CR>
"replace word
map <leader>,r :%s/<C-r><C-w>/<C-r><C-w>/gc
map <leader>br :bufdo %s/<C-r><C-w>/<C-r><C-w>/gc
map <leader>,g :Bgrep <C-r><C-w><CR>
map <leader>,f :Bfind<CR>
map <leader>,m /&clean-search&<CR>
if has('win32unix')
	vnoremap <silent> <leader>y :call Putclip(visualmode(), 1)<CR>
	nnoremap <silent> <leader>y :call Putclip('n', 1)<CR>
	nnoremap <silent> <leader>p :call Getclip()<CR>
else
	map <leader>p "+p
	map <leader>y "+y
endif
"}

"{ [[commands]]
command! Bfind :execute ":cex [] | bufdo vimgrepadd /" . expand('<cword>') . "/g %" | cw
command! Ffind :execute ":cex [] | vimgrepadd /" . expand('<cword>') . "/g %" | cw
"command! Rfind :execute ":%s/" . expand('<cword>') . "/" . expand('<cword>') . "/gc"
command! DiffT windo diffthis
command! DiffO windo diffoff
"}

" SSH tmux
if exists('$TMUX')
	let &t_SI = "\<Esc>Ptmux;\<Esc>\e[5 q\<Esc>\\"
	let &t_EI = "\<Esc>Ptmux;\<Esc>\e[2 q\<Esc>\\"
else
	let &t_SI = "\e[5 q"
	let &t_EI = "\e[2 q"
endif
let Tlist_Ctags_Cmd = '/usr/bin/ctags'
let Tlist_Show_One_File = 1
let Tlist_Exit_OnlyWindow = 1
let Tlist_Auto_Open=0               "打开文件时候不自动打开Taglist窗口
let Tlist_Use_Right_Window = 0      "在右侧窗口中显示taglist窗口

"[[Session management]]
if &diff
    map ] ]c
    map [ [c
    hi DiffAdd    ctermfg=233 ctermbg=LightGreen guifg=#003300 guibg=#DDFFDD gui=none cterm=none
    hi DiffChange ctermbg=white  guibg=#ececec gui=none   cterm=none
	hi DiffText   ctermfg=233  ctermbg=yellow  guifg=#000033 guibg=#DDDDFF gui=none cterm=none
else
	let g:session_autosave = 'yes'
	let g:session_default_to_last = 1
	let g:session_autoload = 'yes'
	let g:session_directory = '~/vim-sessions'
endif
set undodir=~/.vim/tmp/undo//     " undo files
set backupdir=~/.vim/tmp/backup// " backups
set directory=~/.vim/tmp/swap//   " swap files
" Make those folders automatically if they don't already exist.
if !isdirectory(expand(&undodir))
    call mkdir(expand(&undodir), "p")
endif
if !isdirectory(expand(&backupdir))
    call mkdir(expand(&backupdir), "p")
endif
if !isdirectory(expand(&directory))
    call mkdir(expand(&directory), "p")
endif
