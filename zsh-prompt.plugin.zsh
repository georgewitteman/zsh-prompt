setopt prompt_subst

VIRTUAL_ENV_DISABLE_PROMPT=1
PS_GIT_HEAD=1

prompt_git_head() {
  psvar[$PS_GIT_HEAD]=''

  local git_root=$PWD
  # Search up each directory until we get to the root or find one
  # that has a git repository
  until [ -d "${git_root}/.git" ] || [ "$git_root" = "/" ]; do
    git_root=${git_root:a:h}
  done

  # Check if we found a git repo
  [ -f "${git_root}/.git/HEAD" ] || return 1

  # Read contents of HEAD file
  local head=$(<"${git_root}/.git/HEAD")
  if [[ $head == 'ref: '* ]]; then
    psvar[$PS_GIT_HEAD]=${head##ref: refs\/heads\/}
  else
    psvar[$PS_GIT_HEAD]=${head:0:10}
  fi
}

precmd() {
  prompt_git_head
}

echo "${fg_bold[blue]}Don't forget to drink water!${reset_color}"

## Left prompt
PS1=''
# SSH
PS1+='${${_FP_IS_SSH::="${SSH_TTY}${SSH_CONNECTION}${SSH_CLIENT}"}+}'
PS1+='${_FP_IS_SSH:+"%F{15}%K{cyan} SSH %k%f "}'

# Virtual env
PS1+='${VIRTUAL_ENV:+"%F{242}${VIRTUAL_ENV:t}%f "}'

# Short path if available
PS1+="%B%F{cyan}%1~ %f%b"

# Git HEAD
PS1+="%(${PS_GIT_HEAD}V.(%F{magenta}%${PS_GIT_HEAD}v%f) .)"

# Background jobs
PS1+="%(1j.%F{yellow}%j:bg%f .)"

# Subshell warning
PS1+="%(3L.%F{yellow}%L+%f .)"

# Prompt character
PS1+="%(0?..%F{red})%#%f "

## Continuation prompt
PS2='%F{242}%_… %f>%f '

## Right prompt
# Exit code
RPS1='%(0?.. %K{red}%F{15} ${signals[$status-127]:-$status} %k%f)'
