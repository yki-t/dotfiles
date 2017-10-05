if g:dein#_cache_version != 100 | throw 'Cache loading error' | endif
let [plugins, ftplugin] = dein#load_cache_raw(['/Users/usr/.vimrc', '/Users/usr/.vim/rc/dein.toml', '/Users/usr/.vim/rc/dein_lazy.toml'])
if empty(plugins) | throw 'Cache loading error' | endif
let g:dein#_plugins = plugins
let g:dein#_ftplugin = ftplugin
let g:dein#_base_path = '/Users/usr/.vim/dein'
let g:dein#_runtime_path = '/Users/usr/.vim/dein/.cache/.vimrc/.dein'
let g:dein#_cache_path = '/Users/usr/.vim/dein/.cache/.vimrc'
let &runtimepath = '/Users/usr/.vim/.cache/dein/repos/github.com/Shougo/dein.vim/,/Users/usr/.vim,/Users/usr/.vim/dein/repos/github.com/Shougo/dein.vim,/Users/usr/.vim/dein/.cache/.vimrc/.dein,/usr/local/share/vim/vimfiles,/usr/local/share/vim/vim80,/Users/usr/.vim/dein/.cache/.vimrc/.dein/after,/usr/local/share/vim/vimfiles/after,/Users/usr/.vim/after'
