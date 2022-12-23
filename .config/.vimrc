call plug#begin()
  Plug 'preservim/nerdtree'
  Plug 'vim-airline/vim-airline'
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
call plug#end()

set number