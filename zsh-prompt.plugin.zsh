setopt prompt_subst

source "${0:a:h}/zsh-prompt-shrink-path.zsh"
source "${0:a:h}/zsh-prompt-tool-versions.zsh"
source "${0:a:h}/zsh-prompt-git-head.zsh"

VIRTUAL_ENV_DISABLE_PROMPT=1
PS_DIR=1
PS_GIT_HEAD=2
PS_NODE_VERSION=3
PS_PYTHON_VERSION=4

chpwd() {
  shrink_path $PS_DIR
}
chpwd # Set up the first short prompt

precmd() {
  prompt_git_head $PS_GIT_HEAD
  get_node_version $PS_NODE_VERSION
  get_python_version $PS_PYTHON_VERSION
}

echo "${fg_bold[blue]}Don't forget to drink water!${reset_color}"

## Left prompt
PS1=""
# SSH
PS1+='${${_FP_IS_SSH::="${SSH_TTY}${SSH_CONNECTION}${SSH_CLIENT}"}+}'
PS1+='${_FP_IS_SSH:+"%F{15}%K{cyan} SSH %k%f "}'

# Virtual env
PS1+='${VIRTUAL_ENV:+"%F{242}${VIRTUAL_ENV:t}%f "}'

# Short path if available
PS1+="%F{cyan}%(${PS_DIR}V.%${PS_DIR}v.%~) %f"

# Git HEAD
PS1+="%(${PS_GIT_HEAD}V.(%F{magenta}%B%${PS_GIT_HEAD}v%f%b) .)"

# Background jobs
PS1+="%(1j.%F{yellow}%j:bg%f .)"

# Subshell warning
PS1+="%(3L.%F{yellow}%L+%f .)"

# Prompt character
PS1+="%(0?..%F{red})%#%f "

## Continuation prompt
PS2='%F{242}%_… %f>%f '

## Right prompt
RPS1=''
# Exit code
RPS1+='%(0?.. %K{red}%F{15} ${signals[$status-127]:-$status} %k%f)'

# Tool versions
RPS1+="%(${PS_NODE_VERSION}V.%F{green} nodejs:%${PS_NODE_VERSION}v.)"
RPS1+="%(${PS_PYTHON_VERSION}V.%F{yellow} python:%${PS_PYTHON_VERSION}v.)"
