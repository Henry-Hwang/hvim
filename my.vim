set background=dark
set t_Co=256
"colorscheme molokai
set cursorline
hi CursorLine term=NONE ctermfg=white ctermbg=534 guibg=#293739

"{ [[map keys]]
let mapleader = ","       "Set mapleader
map <leader>t :Tlist<CR>
map <leader>b :ls<CR>:b~
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

" SSH tmux
if exists('$TMUX')
   let &t_SI = "\<Esc>Ptmux;\<Esc>\e[5 q\<Esc>\\"
   let &t_EI = "\<Esc>Ptmux;\<Esc>\e[2 q\<Esc>\\"
else
   let &t_SI = "\e[5 q"
   let &t_EI = "\e[2 q"
endif
