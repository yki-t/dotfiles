
if [ -d /usr/vim ];then
    rm -rf /usr/vim || exit
fi
sudo apt install libncurses5-dev libgtk2.0-dev libatk1.0-dev libcairo2-dev libx11-dev python-dev python3-dev git checkinstall \
&& sudo apt remove vim vim-runtime gvim \
&& cd /usr && sudo git clone https://github.com/vim/vim.git && cd vim \
&& sudo ./configure \
--with-features=huge \
--enable-multibyte \
--enable-gpm \
--enable-cscope \
--enable-pythoninterp=dynamic \
--enable-python3interp=dynamic \
--enable-rubyinterp=dynamic \
--enable-luainterp=dynamic \
--with-python-config-dir=/usr/lib/python2.7/config-x86_64-linux-gnu/ \
--with-python3-config-dir=/usr/lib/python3.5/config-3.5m-x86_64-linux-gnu/ \
--enable-gui=auto \
--prefix=/usr/local/ \
&& sudo make -j$(nproc) VIMRUNTIMEDIR=/usr/local/share/vim/vim81 \
&& sudo make install \
&& sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1 \
&& sudo update-alternatives --set editor /usr/local/bin/vim \
&& sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1 \
&& sudo update-alternatives --set vi /usr/local/bin/vim \
&& echo '[ALL DONE]'

