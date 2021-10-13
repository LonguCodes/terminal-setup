sudo -k
if ! sudo true
then
    echo "This script needs to be run as administrator"
    exit -1
fi

if command -v apt &> /dev/null
then
    INSTALL_COMMAND="apt install -y"
elif command -v zypper &> /dev/null
then
    INSTALL_COMMAND="zypper install"
elif command -v pacman &> /dev/null
then
    INSTALL_COMMAND="pacman -S"
elif command -v xbps-install &> /dev/null
then
    INSTALL_COMMAND="xbps-install"
elif command -v dnf &> /dev/null
then
    INSTALL_COMMAND="dnf install -y"
elif command -v pkg_add &> /dev/null
then
    INSTALL_COMMAND="pkg_add"
elif command -v brew &> /dev/null
then
    INSTALL_COMMAND="yum -y install"
else
    echo "Unsupported OS"
    exit -1
fi

mkdir -p ~/.config/kitty
mkdir -p ~/.config/sheldon

# cp ./kitty.conf ~/.config/kitty/kitty.conf
cp ./plugins.toml ~/.config/sheldon/plugins.toml

cp tmux.conf ~/.tmux.conf


command sudo ${INSTALL_COMMAND} zsh 
command sudo ${INSTALL_COMMAND} curl 
command sudo ${INSTALL_COMMAND} git 
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
    | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin

echo 'eval "$(sheldon source)"' >> ~/.zshrc
echo -e "export PATH=\$HOME/.local/bin:\$PATH\n$(cat ~/.zshrc)" > ~/.zshrc
command sudo ${INSTALL_COMMAND} tmux
if ! command -v chsh &> /dev/null
then
	command sudo ${INSTALL_COMMAND} util-linux-user || echo "You will need to manually change the shell to tmux"
fi
if command -v chsh &> /dev/null
then
	command chsh -s $(which tmux)
fi


curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin && sudo ln -s $HOME/.local/kitty.app/bin/kitty $HOME/.local/bin/kitty 