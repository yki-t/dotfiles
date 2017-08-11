if g:dein#_cache_version != 100 | throw 'Cache loading error' | endif
let [plugins, ftplugin] = dein#load_cache_raw(['/home/own/.vimrc', '/home/own/.vim/rc/dein.toml', '/home/own/.vim/rc/dein_lazy.toml'])
if empty(plugins) | throw 'Cache loading error' | endif
let g:dein#_plugins = plugins
let g:dein#_ftplugin = ftplugin
let g:dein#_base_path = '/home/own/.vim/dein'
let g:dein#_runtime_path = '/home/own/.vim/dein/.cache/.vimrc/.dein'
let g:dein#_cache_path = '/home/own/.vim/dein/.cache/.vimrc'
let &runtimepath = '/home/own/.vim/dein/repos/github.com/Shougo/dein.vim/,/home/own/.vim,/var/lib/vim/addons,/home/own/.vim/dein/repos/github.com/Shougo/vimproc.vim,/home/own/.vim/dein/repos/github.com/Shougo/dein.vim,/home/own/.vim/dein/.cache/.vimrc/.dein,/usr/share/vim/vimfiles,/usr/share/vim/vim80,/home/own/.vim/dein/.cache/.vimrc/.dein/after,/usr/share/vim/vimfiles/after,/var/lib/vim/addons/after,/home/own/.vim/after'
filetype off
