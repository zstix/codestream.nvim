" Title:        CodeStream.vim
" Description:  POC plugin that brings the power of CodeStream to neovim
" Maintainer:   Zack Stickles <https://git.sr.ht/~zstix>

" Prevent the plugin from being loaded multiple times
if exists("g:loaded_codestreamvim")
  finish
endif
let g:loaded_codestreamvim = 1

" Defines the package path for Lua
let s:lua_deps_loc = expand("<sfile>:h:r") . "../lua/codestream.vim/deps"
exe "lua package.path = package.path ..';" . s:lua_deps_loc . "/lua-?/init.lua'"

" TODO: expose plugins functions here
