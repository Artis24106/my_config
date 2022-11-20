#!/bin/bash
cd "$(dirname "$0")"

# ANSI Color
RED="\x1b[38;5;1m"
GREEN="\x1b[38;5;2m"
YELLOW="\x1b[38;5;3m"
BLUE="\x1b[38;5;4m"
NC="\x1b[0m"

function msg() {
    echo -e "$BLUE[+] $1$NC"
}

f_cmd() {
    fish -c "$1"
}

export DEBIAN_FRONTEND=noninteractive
export TZ=Asia/Taipei

# use CCNS mirror
#msg "Setting CCNS mirror"
#sed -i 's/archive.ubuntu.com/ubuntu.ccns.ncku.edu.tw/g' /etc/apt/sources.list

# Adding apt repo
msg "Adding apt repo"
sudo add-apt-repository ppa:jonathonf/vim

# install dependency
msg "Installing dependency" 
sudo apt-get update
sudo apt-get install -y build-essential cmake python3-dev python3-pip vim-gtk3 fish tmux git curl wget gdb unzip locales

# chsh fish
msg "Changing default shell to fish ($(which fish))"
chsh -s $(which fish)

# fisher (plugin manager for fish shell)
msg "Installing fisher"
f_cmd "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source"
f_cmd "fisher install jorgebucaran/fisher"
f_cmd "fisher install kenji-miyake/reload.fish"

# fnm (for coc.nvim plugins)
msg "Installing fnm"
SHELL=$(which fish) curl -fsSL https://fnm.vercel.app/install | bash
f_cmd "fnm install 17"

vim -c CocInstall coc-clangd -c q

# vim
msg "Setting vim"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cp -f .vimrc $HOME
vim -E -s -u "$HOME/.vimrc" +PlugInstall +qall
sed -i 's/let terminal = .*/let terminal = "!"/' $HOME/.vim/plugged/LeaderF/plugin/leaderf.vim
vim -E -s -u "$HOME/.vimrc" +LeaderfInstallCExtension +qall
cp molokai.vim $HOME/.vim/plugged/molokai/colors/molokai.vim 
cp coc-settings.json "$HOME/.vim/coc-settings.json"

# tmux (force to use 256 color)
msg "Setting tmux"
cp -f .tmux.conf $HOME
echo 'alias tmux="tmux -2"' >> $HOME/.config/fish/config.fish

# gef
msg "Setting gef"
wget -O $HOME/.gdbinit-gef.py -q http://gef.blah.cat/py
cp -r gdbscripts $HOME/.gdbscripts
cp .gdbinit $HOME

# Done
msg "Done!!"
exec fish
