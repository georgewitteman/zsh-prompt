setopt prompt_subst

PROMPT=''

# SSH
PROMPT+='${${_FP_IS_SSH::="${SSH_TTY}${SSH_CONNECTION}${SSH_CLIENT}"}+}'
PROMPT+='${_FP_IS_SSH:+"%F{15}%K{cyan} SSH %k%f "}'

# Virtual env
VIRTUAL_ENV_DISABLE_PROMPT=1 # Disable default virtualenv prompt
PROMPT+='${VIRTUAL_ENV:+"%F{242}${VIRTUAL_ENV:t}%f "}'

# Exit code or status ($status is a builtin zsh variable)
PROMPT+='${${status:#0}:+"%K{red}%F{15} ${signals[$status-127]:+"${signals[$status-127]}:"}$status %k%f "}'

# Working directory
PROMPT+='%F{cyan}%$(($COLUMNS / 2 - 5))<..<%~%<<%f '

# Background jobs
PROMPT+="%(1j.%F{yellow}%j:bg%f .)"

# Prompt character
PROMPT+="${PROMPT_CHAR:-➜} "
