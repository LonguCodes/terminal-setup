COLOR_GREEN=$(tput setaf 2)
COLOR_RED=$(tput setaf 1)
COLOR_YELLOW=$(tput setaf 3)
COLOR_RESET=$(tput sgr0)

function print {
    type=$1
    shift
    case $type in

        error)
        echo "${COLOR_RED}[ERROR]${COLOR_RESET} $@"
        ;;

        info)
        echo "${COLOR_GREEN}[INFO]${COLOR_RESET} $@"
        ;;

        warn)
        echo "${COLOR_YELLOW}[WARN]${COLOR_RESET} $@"
        ;;
    esac
}
function call {
    local result_action=$1
    shift
    local result=$(call_silent "$@" && echo $? || echo $?)
    case $result_action in

        none)
        ;;

        error)
        if [ $result != 0 ]
        then
            exit -1
        fi
        ;;
            
        rt)
            return $result
        ;;
    esac
   
}

function call_silent {
    return $(command "$@" &> /dev/null && echo $? || echo $?)
}

function get_install_command {
    
    if command -v apt &> /dev/null
    then
        local INSTALL_COMMAND="apt install -y"
    elif command -v zypper &> /dev/null
    then
        local INSTALL_COMMAND="zypper install"
    elif command -v pacman &> /dev/null
    then
        local INSTALL_COMMAND="pacman -S"
    elif command -v xbps-install &> /dev/null
    then
        local INSTALL_COMMAND="xbps-install"
    elif command -v dnf &> /dev/null
    then
        local INSTALL_COMMAND="dnf install -y"
    elif command -v pkg_add &> /dev/null
    then
        local INSTALL_COMMAND="pkg_add"
    elif command -v brew &> /dev/null
    then
        local INSTALL_COMMAND="yum -y install"
    else
        print error "Unsupported OS"
        exit -1
    fi
    return INSTALL_COMMAND

}


function run {

    print info Starting instalation

    sudo -k
    if ! sudo false
    then
        print error "Do not run this script with sudo!"
        exit -1
    fi

    install_command=$(get_install_command)

    print info Detected install command: $(echo ${install_command} | cut -f 1 -d ' ')

    call none 'mkdir -p ~/.config/kitty'
    call none 'mkdir -p ~/.config/sheldon'

    # cp ./kitty.conf ~/.config/kitty/kitty.conf
    call none 'cp ./plugins.toml ~/.config/sheldon/plugins.toml'
    call none 'cp tmux.conf ~/.tmux.conf'


    call none 'sudo ${INSTALL_COMMAND} zsh'
    call none 'sudo ${INSTALL_COMMAND} curl'
    call none 'sudo ${INSTALL_COMMAND} git'
    call none 'RUNZSH=no sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"'
    call none 'curl --proto "=https" -fLsS https://rossmacarthur.github.io/install/crate.sh \
        | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin'

    call none 'echo 'eval "$(sheldon source)"' >> ~/.zshrc'
    call none 'echo -e "export PATH=\$HOME/.local/bin:\$PATH\n$(cat ~/.zshrc)" > ~/.zshrc'
    call none sudo ${INSTALL_COMMAND} tmux
    if ! command -v chsh &> /dev/null
    then
        call rt sudo ${INSTALL_COMMAND} util-linux-user || print warn "You will need to manually change the shell to tmux"
    fi
    if command -v chsh &> /dev/null
    then
        call none sudo chsh -s $(which tmux) $USER
    fi


    call none 'curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin && sudo ln -s $HOME/.local/kitty.app/bin/kitty $HOME/.local/bin/kitty' 
}


