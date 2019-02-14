set rtp+=$HOME/.vim/bundle/Vundle.vim/
call vundle#begin('$HOME/.vim/bundle/')
Plugin 'VundleVim/Vundle.vim'
Plugin 'eshion/vim-sync'
Plugin 'junegunn/vim-easy-align'
Plugin 'vim-scripts/molokai'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'vim-scripts/EasyGrep.git'
Plugin 'vim-scripts/grep.vim'
Plugin 'vim-scripts/taglist.vim'
Plugin 'vim-scripts/a.vim'
Plugin 'vim-scripts/xml.vim'
Plugin 'vim-scripts/python.vim'
Plugin 'vim-scripts/c.vim'
Plugin 'vim-scripts/OmniCppComplete'
Plugin 'vim-scripts/ctags.vim'
Plugin 'lifepillar/vim-mucomplete'
Plugin 'vim-scripts/VIM-Color-Picker'
"Plugin 'vim-scripts/minibufexplorerpp'
"Plugin 'scrooloose/nerdtree'
"Plugin 'altercation/vim-colors-solarized'
"Plugin 'jistr/vim-nerdtree-tabs'
"Plugin  'Xuyuanp/nerdtree-git-plugin'
"Plugin 'Valloric/YouCompleteMe'
"Plugin 'vim-scripts/winmanager'
call vundle#end()

set helplang=cn
set encoding=utf-8
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
set scrolloff=6
set noexpandtab
" 设定 tab 长度为 4
set tabstop=4
" 设置按BackSpace的时候可以一次删除掉4个空格
set softtabstop=4
" 设定 << 和 >> 命令移动时的宽度为 4
set shiftwidth=4
set smarttab
set history=1024
" 不突出显示当前行
set nocursorline
" 覆盖文件时不备份
set nobackup
" 自动切换当前目录为当前文件所在的目录
set autochdir
" 搜索时忽略大小写，但在有一个或以上大写字母时仍大小写敏感
set ignorecase
set smartcase
" 搜索到文件两端时不重新搜索
set nowrapscan
" 实时搜索
set incsearch
" 搜索时高亮显示被找到的文本
set hlsearch
" 关闭错误声音
set noerrorbells
set novisualbell
"set t_vb=

" 不自动换行
"set nowrap
"How many tenths of a second to blink
set mat=2
" 允许在有未保存的修改时切换缓冲区，此时的修改由 vim 负责保存
set hidden
" 智能自动缩进
set smartindent
" 设定命令行的行数为 1
set cmdheight=1
" 显示状态栏 (默认值为 1, 无法显示状态栏)
set laststatus=2
"显示括号配对情况
set showmatch
set wrapscan
" 解决自动换行格式下, 如高度在折行之后超过窗口高度结果这一行看不到的问题
set display=lastline
" 设置在状态行显示的信息
set statusline=\ %<%F[%1*%M%*%n%R%H]%=\ %y\ %0(%{&fileformat}\ [%{(&fenc==\"\"?&enc:&fenc).(&bomb?\",BOM\":\"\")}]\ %c:%l/%L%)

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
hi CursorLine term=NONE ctermfg=white ctermbg=534 guibg=#293739
"command ": h" to show all color

"{ [[map keys]]
let mapleader = ","       "Set mapleader
map <leader>t :Tlist<CR>
map <leader>b :ls<CR>:b 
map <leader>3 :b#<CR>
map <leader>n :bn<CR>
map <leader>p :bp<CR>
"replace word
map <leader>,r :%s/<C-r><C-w>/<C-r><C-w>/gc
map <leader>br :bufdo %s/<C-r><C-w>/<C-r><C-w>/gc
map <leader>,g :Bgrep <C-r><C-w><CR>
map <leader>,m /&clean-search&<CR>
"}

"{ [[commands]]
command! Bfind :execute ":cex [] | bufdo vimgrepadd /" . expand('<cword>') . "/g %" | cw
command! Ffind :execute ":cex [] | vimgrepadd /" . expand('<cword>') . "/g %" | cw
"command! Rfind :execute ":%s/" . expand('<cword>') . "/" . expand('<cword>') . "/gc"
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
"Ctags可执行文件的路径，千万要写对了，否则显示no such file
let Tlist_Show_One_File = 1
"不同时显示多个文件的tag，只显示当前文件的
let Tlist_Exit_OnlyWindow = 1
"如果taglist窗口是最后一个窗口，则退出vim
let Tlist_Auto_Open=0               "打开文件时候不自动打开Taglist窗口
let Tlist_Use_Right_Window = 0      "在右侧窗口中显示taglist窗口

""""""""""""""""""""""""""""""
" lookupfile setting
"""""""""""""""""""""""""""""""
let g:LookupFile_MinPatLength = 2               "最少输入2个字符才开始查找
let g:LookupFile_PreserveLastPattern = 0        "不保存上次查找的字符串
let g:LookupFile_PreservePatternHistory = 1     "保存查找历史
let g:LookupFile_AlwaysAcceptFirst = 1          "回车打开第一个匹配项目
let g:LookupFile_AllowNewFiles = 0              "不允许创建不存在的文件
if filereadable("./filenametags")                "设置tag文件的名字
let g:LookupFile_TagExpr = '"./filenametags"'
endif
" "映射LookupFile为,lk
nmap <silent> <leader>lk :LUTags<cr>
"映射LUBufs为,ll
nmap <silent> <leader>ll :LUBufs<cr>
"映射LUWalk为,lw
nmap <silent> <leader>lw :LUWalk<cr>
let g:session_autoload = 'no'
"set sessionoptions-=curdir
"set sessionoptions+=sesdir

