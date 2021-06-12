if !has('nvim-0.5') || exists('g:loaded_window_jumping') | finish | endif

" set up hightlight colors
hi def WindowJumping gui=bold guifg=#ededed guibg=#4493c8

command! WindowJumping lua require('window-jumping').window_jumping()

let g:loaded_window_jumping = 1
