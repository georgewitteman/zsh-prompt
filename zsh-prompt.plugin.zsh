MY_PROMPT_DIR="${0:a:h}"

source "$MY_PROMPT_DIR/zsh-prompt-tool-versions.zsh"
source "$MY_PROMPT_DIR/zsh-prompt-shrink-path.zsh"

type should_drink >/dev/null 2>&1 && HYDRATE_INSTALLED=1

PS_NICE_EXIT_CODE=1
PS_PYTHON_VERSION=3
PS_NODE_VERSION=4
PS_HYDRATE=5
PS_DIR=6

chpwd() {
  shrink_path $PS_DIR
}

precmd() {
  prompt_start_precmd="$EPOCHREALTIME"

  get_python_version $PS_PYTHON_VERSION
  get_node_version $PS_NODE_VERSION

  if [ "$HYDRATE_INSTALLED" != "0" ]; then
    should_drink
    if [ "$SHOULD_DRINK" != "0" ]; then
      psvar[$PS_HYDRATE]="Time to drink!"
    else
      psvar[$PS_HYDRATE]=""
    fi
  fi

  prompt_start_render="$EPOCHREALTIME"
}

# Set up the first short prompt
chpwd

setopt prompt_subst

PROMPT=""
# SSH
PROMPT+='${${_FP_IS_SSH::="${SSH_TTY}${SSH_CONNECTION}${SSH_CLIENT}"}+}'
PROMPT+='${_FP_IS_SSH:+"%F{15}%K{cyan} SSH %k%f "}'

# Exit code
PROMPT+='${${status:#0}:+"%K{red}%F{15} ${signals[$status-127]:-$status} %k%f "}'
# PROMPT+='${${status:#0}:+"%K{red}%F{15} ${signals[$status-127]:+"${signals[$status-127]}:"}$status %k%f "}'

# Virtual env
VIRTUAL_ENV_DISABLE_PROMPT=1
PROMPT+='${VIRTUAL_ENV:+"%F{242}${VIRTUAL_ENV:t}%f "}'

# Short path if available
PROMPT+="%F{cyan}%(${PS_DIR}V.%${PS_DIR}v.%~) %f"

# Background jobs
PROMPT+="%(1j.%F{yellow}%j:bg%f .)" # Jobs

# Hydrate
PROMPT+="%(${PS_HYDRATE}V.%F{blue}%${PS_HYDRATE}v%f .)"

# Subshell warning
PROMPT+="%(3L.%F{yellow}%L+%f .)" # Show a + if I'm in a subshell (set to 3 bc tmux)

# Prompt character
PROMPT+="%# "
# PROMPT+="%F{magenta}%#%f "
# PROMPT+="%F{magenta}❯%f "
# PROMPT+="%F{magenta}➜%f "

# Continuation prompt
PROMPT2='%F{242}%_… %f>%f '

# Right prompt
RPROMPT=""
RPROMPT+="%(${PS_NODE_VERSION}V. %F{green}node:%${PS_NODE_VERSION}v%f.)"
RPROMPT+="%(${PS_PYTHON_VERSION}V. %F{yellow}python:%${PS_PYTHON_VERSION}v%f.)"
