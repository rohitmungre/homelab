sudo apt update
sudo apt upgrade

# Install dependencies 
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# Install pyenv
curl https://pyenv.run | bash

# Add this to ~/.bashrc or ~/.zshrc
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# source the added snippet 
source ~/.zshrc

# Verify version 
pyenv --version

# list all pyenv versions 
pyenv install --list

# Install latest version of python 
pyenv install 3.13.1

# Make it global 
pyenv global 3.13.1

# Use poetry instead 
## Install & source pyenv virtual environment 
# git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
# echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc

##  Create a new virtual environment:
# pyenv virtualenv 3.13.1 venv
# pyenv activate venv
