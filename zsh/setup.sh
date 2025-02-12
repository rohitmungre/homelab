# Install using package manager 
sudo apt install zsh

# Verify installation 
zsh --version

# Make it your default shell
chsh -s $(which zsh)

# Install ohmyzsh using curl 
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)

# autosuggesions plugin
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions

# zsh-syntax-highlighting plugin
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

# zsh-fast-syntax-highlighting plugin
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting

# zsh-autocomplete plugin
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete

# Add plugins to .zshrc
vi .zshrc
plugins=(
git
zsh-autosuggestions
zsh-syntax-highlighting
fast-syntax-highlighting
zsh-autocomplete
)

# Reload your environment to make changes work!
source ~/.zshrc

# Enable cutom theme
# nano ~/.zshrc
# Find the ZSH_THEME="robbyrussell"
# Replace with ZSH_THEME="alanpeabody"

# add in .zshrc file plugins the following 
terraform 
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/terraform

docker 
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker
