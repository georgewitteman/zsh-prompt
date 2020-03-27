setopt prompt_subst

VIRTUAL_ENV_DISABLE_PROMPT=1
PS_GIT_HEAD=1
PS_YADM_HEAD=2
# Shell always initializes with keymap main
PROMPT_KEYMAP="[MAIN]"

prompt_git_head() {
  psvar[$PS_GIT_HEAD]=''

  local git_root=$PWD
  # Search up each directory until we get to the root or find one
  # that has a git repository
  until [[ -d "${git_root}/.git" ]] || [[ "$git_root" = "/" ]]; do
    git_root=${git_root:a:h}
  done

  # Check if we found a git repo
  [[ -f "${git_root}/.git/HEAD" ]] || return 1

  # Read contents of HEAD file
  local head=$(<"${git_root}/.git/HEAD")
  if [[ $head == 'ref: '* ]]; then
    psvar[$PS_GIT_HEAD]=${head##ref: refs\/heads\/}
  else
    psvar[$PS_GIT_HEAD]=${head:0:10}
  fi
}

prompt_yadm_head() {
  [[ -f "$HOME/.config/yadm/repo.git/HEAD" ]] || return 1

  local head=$(<"$HOME/.config/yadm/repo.git/HEAD")
  if [[ "$head" == "ref: refs/heads/master" ]]; then
    psvar[$PS_YADM_HEAD]=''
  elif [[ "$head" == 'ref: '* ]]; then
    psvar[$PS_YADM_HEAD]=${head##ref: refs\/heads\/}
  else
    psvar[$PS_YADM_HEAD]=${head:0:10}
  fi
}

precmd() {
  prompt_git_head
  prompt_yadm_head
}

set_prompt_keymap() {
  case $KEYMAP in
    main) PROMPT_KEYMAP="[MAIN]" ;;
    emacs) PROMPT_KEYMAP="[EMACS]" ;;
    viins) PROMPT_KEYMAP="[VIINS]" ;;
    vicmd) PROMPT_KEYMAP="[VICMD]" ;;
    viopp) PROMPT_KEYMAP="[VIOPP]" ;;
    visual) PROMPT_KEYMAP="[VISUAL]" ;;
    isearch) PROMPT_KEYMAP="[ISEARCH]" ;;
    command) PROMPT_KEYMAP="[COMMAND]" ;;
    *safe) PROMPT_KEYMAP="[.SAFE]" ;;
  esac
  zle reset-prompt
}
# Executed every time the keymap change
zle -N zle-keymap-select set_prompt_keymap
# Executed every time the line editor is started to read a new line of input
zle -N zle-line-init set_prompt_keymap

## Left prompt
PROMPT=''
# SSH
PROMPT+='${${_FP_IS_SSH::="${SSH_TTY}${SSH_CONNECTION}${SSH_CLIENT}"}+}'
PROMPT+='${_FP_IS_SSH:+"%F{15}%K{cyan} SSH %k%f "}'

# Virtual env
PROMPT+='${VIRTUAL_ENV:+"%F{242}${VIRTUAL_ENV:t}%f "}'

# Short path if available
PROMPT+="%B%F{cyan}%1~ %f%b"

# Background jobs
PROMPT+="%(1j.%F{yellow}%j:bg%f .)"

# Subshell warning
PROMPT+="%(3L.%F{yellow}%L+%f .)"

# Prompt character
PROMPT+="%(0?..%F{red})%#%f "

## Continuation prompt
PROMPT2='%F{242}%_… %f>%f '

## Right prompt
# Don't add the random extra space at the end of the right prompt
# https://superuser.com/a/726509
# Turned this off because it messes up the space after the prompt
# character when not in tmux
# ZLE_RPROMPT_INDENT=0

RPROMPT=

# Exit code
RPROMPT+='%(0?.. %K{red}%F{15} ${signals[$status-127]:-$status} %k%f)'

# YADM HEAD if not master
RPROMPT+="%(${PS_YADM_HEAD}V. yadm:%F{green}%${PS_YADM_HEAD}v%f.)"

# Git HEAD
RPROMPT+="%(${PS_GIT_HEAD}V. git:%F{magenta}%${PS_GIT_HEAD}v%f.)"

# ZLE keymap
RPROMPT+=' ${PROMPT_KEYMAP}'
