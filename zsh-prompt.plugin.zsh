setopt prompt_subst

source "${0:a:h}/zsh-prompt-shrink-path.zsh"

VIRTUAL_ENV_DISABLE_PROMPT=1
PS_DIR=1

chpwd() {
  shrink_path $PS_DIR
}
chpwd # Set up the first short prompt

echo "${fg_bold[blue]}Don't forget to drink water!${reset_color}"

PS1=""
# SSH
PS1+='${${_FP_IS_SSH::="${SSH_TTY}${SSH_CONNECTION}${SSH_CLIENT}"}+}'
PS1+='${_FP_IS_SSH:+"%F{15}%K{cyan} SSH %k%f "}'

# Exit code
PS1+='${${status:#0}:+"%K{red}%F{15} ${signals[$status-127]:-$status} %k%f "}'

# Virtual env
PS1+='${VIRTUAL_ENV:+"%F{242}${VIRTUAL_ENV:t}%f "}'

# Short path if available
PS1+="%F{cyan}%(${PS_DIR}V.%${PS_DIR}v.%~) %f"

# Background jobs
PS1+="%(1j.%F{yellow}%j:bg%f .)"

# Subshell warning
PS1+="%(3L.%F{yellow}%L+%f .)"

# Prompt character
PS1+="%# "

# Continuation prompt
PS2='%F{242}%_… %f>%f '
