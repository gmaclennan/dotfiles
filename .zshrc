#!/bin/zsh
[ -f /Users/gregor/.travis/travis.sh ] && source /Users/gregor/.travis/travis.sh

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Path to your dotfiles.
export DOTFILES=$HOME/.dotfiles

# Load the shell dotfiles, and then some:
for file in "${DOTFILES}"/{path,aliases,functions}.zsh; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# export ZSH_DISABLE_COMPFIX=true
# export ZSH=${HOME}/.zgen/robbyrussell/oh-my-zsh-master
# export NVM_AUTO_USE=true

# Load compinit
autoload -Uz compinit && compinit -C

# Uncomment following line if you want red dots to be displayed while waiting for completion
export COMPLETION_WAITING_DOTS="true"

# Correct spelling for commands
setopt correct

# Don't throw an error for wildcards like ^ in a command
# Stops errors from `npm install my-module@^1` etc.
setopt +o nomatch

# turn off the infernal correctall for filenames
unsetopt correctall

# Yes, these are a pain to customize. Fortunately, Geoff Greer made an online
# tool that makes it easy to customize your color scheme and keep them in sync
# across Linux and OS X/*BSD at http://geoff.greer.fm/lscolors/

export CLICOLOR=1
export LSCOLORS='Exfxcxdxbxegedabagacad'
export LS_COLORS='di=1;34;40:ln=35;40:so=32;40:pi=33;40:ex=31;40:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:'

load-our-ssh-keys() {
  # Fun with SSH
  if [ $(ssh-add -l | grep -c "The agent has no identities." ) -eq 1 ]; then
    if [[ "$(uname -s)" == "Darwin" ]]; then
      # macOS allows us to store ssh key pass phrases in the keychain, so try
      # to load ssh keys using pass phrases stored in the macOS keychain.
      #
      # You can use ssh-add -K /path/to/key to store pass phrases into
      # the macOS keychain
      ssh-add -k
    fi

    for key in $(find ~/.ssh -type f -a \( -name '*id_rsa' -o -name '*id_dsa' -name '*id_ecdsa' \))
    do
      if [ -f ${key} -a $(ssh-add -l | grep -c "${key//$HOME\//}" ) -eq 0 ]; then
        # ssh-add ${key}
      fi
    done
  fi
}

load-our-ssh-keys

# setup zgen
export ZGEN_DIR="${HOME}"/.zgen
[[ -d "$ZGEN_DIR" ]] || git clone https://github.com/tarjoilija/zgen.git --depth=1 "$ZGEN_DIR"
ZGEN_RESET_ON_CHANGE=(
  ${DOTFILES}/.zshrc
)

# load zgen
source "${ZGEN_DIR}/zgen.zsh"

# if the init script doesn't exist
if ! zgen saved; then
  echo "Creating a zgen save"
  # zgen oh-my-zsh

  # prezto and modules
  zgen prezto

  # A Zsh plugin to help remembering those shell aliases and Git aliases you
  # once defined. https://github.com/djui/alias-tips
  zgen load djui/alias-tips
  # Update nvm with `nvm upgrade`. Auto-switched Node if .nvmrc is defined.
  # zgen load lukechilds/zsh-nvm
  # Shows detailed information on script contents for npm run
  zgen load lukechilds/zsh-better-npm-completion
  # Fish shell-like syntax highlighting for Zsh.
  zgen load zsh-users/zsh-syntax-highlighting

  # Sets directory options and defines directory aliases.
  zgen prezto directory
  # Enhances git by providing aliases and functions
  zgen prezto git
  # Sets history options and defines history aliases.
  zgen prezto history

  if [ $(uname -a | grep -ci Darwin) = 1 ]; then
    # Load macOS-specific plugins
    # Defines macOS aliases and functions.
    zgen prezto osx
  fi

  # Loads and configures tab completion and provides additional completions from
  # the zsh-completions project. **Must be after utility module**
  zgen prezto completion
  # Type in any part of a previously entered command and press up and down to
  # cycle through matching commands. **Must be after syntax-highlighting
  zgen prezto history-substring-search
  # Type in any part of a previously entered command and Zsh suggests commands
  # as you type based on history and completions. **Must be last**
  zgen prezto autosuggestions

  zgen prezto 'autosuggestions' color 'yes'
  zgen prezto 'autosuggestions:color' found 'fg=8'

  # generate the init script from plugins above
  zgen save
fi

# You may need to manually set your language environment
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Make it easy to append your own customizations that override the above by
# loading all files from the ~/.zshrc.d directory
mkdir -p ~/.zshrc.d
if [ -n "$(/bin/ls ~/.zshrc.d)" ]; then
  for dotfile in ~/.zshrc.d/*
  do
    if [ -r "${dotfile}" ]; then
      source "${dotfile}"
    fi
  done
fi

# Load iTerm shell integrations if found.
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Cross-shell prompt https://starship.rs
eval "$(starship init zsh)"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
# fnm
eval "$(fnm env --multi)"

find-up() {
  path=$(pwd)
  while [[ "$path" != "" && ! -e "$path/$1" ]]; do
    path=${path%/*}
  done
  echo "$path"
}

autoload -U add-zsh-hook
_fnm_autoload_hook () {
	nvmrc_path=$(find-up .nvmrc | tr -d '[:space:]')

  if [ -n "$nvmrc_path" ]; then
    nvm_version=`cat $nvmrc_path/.nvmrc`
    fnm use $nvm_version --quiet
  else
    fnm use default --quiet
  fi
}
add-zsh-hook chpwd _fnm_autoload_hook && _fnm_autoload_hook
