FROM node:9.0.0
MAINTAINER Yanhao Yang <yanhao.yang@gmail.com>

# Development tools
RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
  # for build vim
  libncurses5-dev libncursesw5-dev \
  ruby-dev lua5.1 liblua5.1-dev python-dev \
  zsh silversearcher-ag curl nginx locales sudo \
	cmake \
  && \
  apt-get autoremove -y && \
  apt-get autoclean && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY files/nginx.conf /etc/nginx/nginx.conf
COPY files/dumb-init_1.2.0_amd64 /usr/local/bin/dumb-init

RUN \
  chsh --shell /bin/zsh && \
  echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
  locale-gen && \
  echo "node ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/user && \
  chmod 0440 /etc/sudoers.d/user && \
  chown -R node:node /var/lib/nginx && \
  chown -R node:node /var/log/nginx && \
  chmod +x /usr/local/bin/dumb-init && \
  # build vim
  cd /tmp && \
  git clone https://github.com/vim/vim.git && \
  cd /tmp/vim && \
  ./configure \
    --with-features=huge \
    --enable-multibyte \
    --enable-rubyinterp=yes \
    --enable-pythoninterp=yes \
		--with-python-config-dir=/usr/lib/python2.7/config-x86_64-linux-gnu \
    --enable-luainterp=yes \
    --enable-cscope \
  && \
  make && \
  make install && \
  cd ~ && \
  rm -rf /tmp/*

ENV TERM=xterm-256color

# To make oh-my-zsh installer happy
ENV SHELL=/usr/bin/zsh

USER node

RUN \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" && \
   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
   git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
  git clone https://github.com/YanhaoYang/vim-for-node.git ~/.vim && \
  cd ~ && ln -s .vim/vimrc .vimrc && vim +BundleInstall +qa && \
	cd ~/.vim/bundle/YouCompleteMe && ./install.py && \
  cd ~ && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
  ~/.fzf/install --all

COPY files/.zshrc /home/node/.zshrc

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["nginx", "-g", "daemon off;", "-c", "/etc/nginx/nginx.conf"]
