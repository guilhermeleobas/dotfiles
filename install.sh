# install softwares

# brew cask
brew tap caskroom/cask

# dev tools
brew install git
brew install neovim/neovim/neovim

# terminal
brew install zsh
# brew install antigen
git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"
# set zsh the default shell
chsh -s /bin/zsh

# languages
brew install node
brew install python3
brew install sqlite
brew install ghci

# pip
pip3 install jupyter
pip3 install beautifulsoup4
pip3 install aiohttp
pip3 install numpy
pip3 install pandas
pip3 install neovim
pip3 install matplotlib
pip3 install numpy

# cli tools
brew install ack
brew install ag
brew install wget

# brew cask
brew cask install firefox
brew cask install spectacle
brew cask install sublime-text
brew cask install franz
brew cask install iterm2
brew cask install google-chrome
brew cask install google-drive
brew cask install spotify
brew cask install skype
brew cask install lastpass
brew cask install the-unarchiver
brew cask install sublime
brew cask install vlc
brew cask install shady
brew cask install dropbox
brew cask install transmission
brew cask install flux
brew cask install opera

# create symbolic links
ln -s ~/Dropbox/dotfiles/nvim ~/.config/nvim/init.vim
ln -s ~/Dropbox/dotfiles/ycm_extra_conf.py ~/.config/nvim/ycm_extra_conf.py
ln -s ~/Dropbox/dotfiles/zshrc ~/.zshrc
ln -s ~/Dropbox/dotfiles/tmux.conf ~/.tmux.conf
ln -s ~/Dropbox/code ~/code
ln -s ~/Dropbox/code/maratona ~/code/maratona

# install vim plugins
curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
