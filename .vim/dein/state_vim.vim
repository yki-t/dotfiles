if g:dein#_cache_version != 100 | throw 'Cache loading error' | endif
let [plugins, ftplugin] = dein#load_cache_raw(['/home/usr/.vimrc', '/home/usr/.vim/rc/dein.toml', '/home/usr/.vim/rc/dein_lazy.toml'])
if empty(plugins) | throw 'Cache loading error' | endif
let g:dein#_plugins = plugins
let g:dein#_ftplugin = ftplugin
let g:dein#_base_path = '/home/usr/.vim/dein'
let g:dein#_runtime_path = '/home/usr/.vim/dein/.cache/.vimrc/.dein'
let g:dein#_cache_path = '/home/usr/.vim/dein/.cache/.vimrc'
let &runtimepath = '/home/usr/.vim/.cache/dein/repos/github.com/Shougo/dein.vim/,/home/usr/.vim,/var/lib/vim/addons,/usr/share/vim/vimfiles,/home/usr/.vim/dein/repos/github.com/Shougo/vimproc.vim,/home/usr/.vim/dein/repos/github.com/Shougo/dein.vim,/home/usr/.vim/dein/.cache/.vimrc/.dein,/usr/share/vim/vim74,/home/usr/.vim/dein/.cache/.vimrc/.dein/after,/usr/share/vim/vimfiles/after,/var/lib/vim/addons/after,/home/usr/.vim/after'
