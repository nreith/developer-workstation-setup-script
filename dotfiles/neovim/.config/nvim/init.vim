"=================="
"    Functions     "
"=================="
function! GitBranch()
  return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
endfunction

function! StatuslineGit()
  let l:branchname = GitBranch()
  return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
endfunction

function GitCommit() abort
  let message = input('Enter commit message: ')
  call system("git commit -m '" . message . "'")
endfunction

"=================="
"  Load plugins    "
"=================="
call plug#begin('~/.config/nvim/plugged')
  " use built-in LSP and treesitter features
  Plug 'nvim-treesitter/nvim-treesitter', { 'branch': '0.5-compat', 'do': ':TSUpdate' }
  Plug 'neovim/nvim-lspconfig'
  " auto completion and LSP codeAction alert
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'kosayoda/nvim-lightbulb'
  " allow non-LSP sources to hook into the LSP client
  Plug 'jose-elias-alvarez/null-ls.nvim'
  Plug 'nvim-lua/plenary.nvim'
  " preview markdown in web browser using pandoc
  Plug 'davidgranstrom/nvim-markdown-preview'
  " fuzzy find
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  " zen mode
  Plug 'folke/zen-mode.nvim'
  " popup with possible key bindings as you type
  Plug 'folke/which-key.nvim'
  " comment stuff out
  Plug 'tpope/vim-commentary'
  " A pretty list for showing diagnostics
  Plug 'folke/trouble.nvim'
call plug#end()

"=================="
"  Load lua setup  "
"=================="
lua require("lsp-setup")
lua require("plugin-setup")

"=================="
" Global Settings  "
"=================="
colorscheme codedark

set inccommand=split        " default in 0.6: shows the effects of a command incrementally as you type
set hidden                  " default in 0.6: keep buffer windows open

set noswapfile
set splitright splitbelow
set nospell spelllang=en_us
set scrolloff=8             " set number of screen lines to keep above/below the cursor
set linebreak               " soft wrap long lines at a character in 'breakat'
set cmdwinheight=14         " increase height of the command-line window
set tabstop=2               " number of spaces that a <Tab> in the file counts for
set expandtab               " use the appropriate number of spaces to insert a <Tab>
set shiftwidth=2            " number of spaces inserted for indentation
set ssop-=options           " do not store global and local values in a session
set termguicolors           " set to true color
set title                   " change terminal title to name of file
set signcolumn=yes          " add gutter space for LSP info on left
set updatetime=100          " increased to LSP code actions appear faster
set completeopt=menu,menuone,noselect " options for insert mode completion
set guicursor+=n-v-c:blinkon1         " set cursor to blink
set clipboard=unnamedplus             " use clipboard register '+' instead of '*'
set grepprg=rg\ --vimgrep\ --smart-case\ --hidden " use rg when using grep command
set grepformat=%f:%l:%c:%m
let g:markdown_folding = 1 " enable markdown folding (doesn't work in after/ftplugin)
let g:fzf_preview_window = ['up:75%', 'ctrl-/']
let g:fzf_layout = { 'window': { 'width': 1, 'height': 1 } }

"=================="
"   Autocommands   "
"=================="
augroup reset_group
  autocmd!
augroup END

" start a terminal, and return to an open terminal in insert mode
autocmd reset_group TermOpen * startinsert
autocmd reset_group BufEnter term://* startinsert
" save active session on exit, to create a session :mks [optional session filename]
autocmd reset_group VimLeave * if !empty(v:this_session) | exe "mksession! ".(v:this_session)
" show highlight on yank
autocmd reset_group TextYankPost * silent! lua require'vim.highlight'.on_yank()

"==========================================="
"         Custom Key Mappings               "
"==========================================="
let mapleader = "\<Space>"

" default in 0.6:turn off search highlighting
nnoremap <silent><c-l> :noh<CR>

" default in 0.6: make Y act like C and D
nnoremap Y y$

"==================
"   trouble.nvim
"==================
nnoremap <leader>xx <cmd>TroubleToggle<cr>
nnoremap <leader>xw <cmd>TroubleToggle lsp_workspace_diagnostics<cr>
nnoremap <leader>xd <cmd>TroubleToggle lsp_document_diagnostics<cr>
nnoremap <leader>xq <cmd>TroubleToggle quickfix<cr>
nnoremap <leader>xl <cmd>TroubleToggle loclist<cr>
nnoremap gR <cmd>TroubleToggle lsp_references<cr>

"==================
"  zen-mode.nvim
"==================
nnoremap <silent><leader>z :ZenMode<CR>

"==================
"     fzf.vim
"==================
nnoremap <silent><c-p> :Files!<CR>
nnoremap <silent><leader>b :Buffers!<CR>
nnoremap <silent><leader>h :History!<CR>
nnoremap <silent><leader>gs :GFiles?<CR>
nnoremap <silent><leader>gh :BCommits!<CR>
nnoremap <silent><leader>rg :Rg!<CR>

" escape key
inoremap jk <Esc>
tnoremap jk <C-\><C-n>

" set ctrl-backspace to delete previous word
inoremap <C-H> <C-W>

" change operations are sent to the black hole register, not unnamed
nnoremap c "_c
nnoremap C "_C

" keep cursor position when joining lines
nnoremap J mxJ'x

" set undo break points
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap ! !<c-g>u
inoremap ? ?<c-g>u

" go to next spelling error and prompt for correction
nmap <silent><leader>sn ]sz=

" quit all but confirm if buffer unsaved 
nnoremap <silent><leader>qa :confirm qall<CR>

" open new terminal to the right
nnoremap <silent><leader>t :vsplit<bar>term<CR>

" disable netrw loading and replace broken link opening https://github.com/vim/vim/issues/4738
let g:loaded_netrw       = 1
let g:loaded_netrwPlugin = 1
nnoremap <silent> gx :execute 'silent! !xdg-open ' . shellescape(expand('<cWORD>'), 1)<CR>

" run make on current buffer
nnoremap <leader>m :make %<CR>

" change working directory to the location of the current file
nnoremap <leader>cd :cd %:p:h<CR>:pwd<CR>

" open init.vim file
nnoremap <silent><leader>c :e $MYVIMRC<CR>

" toggle colorcolumn
nnoremap <silent><leader>cc :execute "set colorcolumn=" . (&colorcolumn == "" ? "80" : "")<CR>

" toggle line numbers
nnoremap <silent><leader>n :set invnumber<CR>

" toggle spell checking
nnoremap <silent><leader>s :set invspell<CR>

" toggle showing white spaces
set lcs+=space:.
nnoremap <silent><leader>w :set list!<CR>

" ctrl-s to save (add stty -ixon to ~/.bashrc required)
nnoremap <silent><c-s> :<c-u>update<CR>
inoremap <silent><c-s> <c-o>:update<CR>
vnoremap <silent><c-s> <c-c>:update<CR>gv

" use `ALT+{h,j,k,l}` to navigate windows from any mode
tnoremap <A-h> <C-\><C-N><C-w>h
tnoremap <A-j> <C-\><C-N><C-w>j
tnoremap <A-k> <C-\><C-N><C-w>k
tnoremap <A-l> <C-\><C-N><C-w>l
inoremap <A-h> <C-\><C-N><C-w>h
inoremap <A-j> <C-\><C-N><C-w>j
inoremap <A-k> <C-\><C-N><C-w>k
inoremap <A-l> <C-\><C-N><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

" git add buffer / add to staging area
nnoremap <leader>ga :!git add %<CR>
" git reset buffer / lossless unstage
nnoremap <leader>gr :!git reset %<CR>
" git commit
nnoremap <leader>gc :call GitCommit()<CR>
" git push
nnoremap <leader>gp :!git push<CR>

" disable accidentally pressing ctrl-z and suspending
nnoremap <c-z> <Nop>

" disable recording
nnoremap q <Nop>

" disable arrow keys
noremap  <Up>    <Nop>
noremap  <Down>  <Nop>
noremap  <Left>  <Nop>
noremap  <Right> <Nop>
inoremap <Up>    <Nop>
inoremap <Down>  <Nop>
inoremap <Left>  <Nop>
inoremap <Right> <Nop>

"======================================="
"        Movement Mappings              "
"======================================="
" line without new line character
onoremap l :silent normal 0vg_<CR>

"======================================="
"            Status Line                "
"======================================="
set statusline=
set statusline+=%#PmenuSel#
set statusline+=%{StatuslineGit()}
set statusline+=%#LineNr#
set statusline+=\ %f
set statusline+=%m\
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\[%{&fileformat}\]
set statusline+=\ %p%%
set statusline+=\ %l:%c
set statusline+=\ 
