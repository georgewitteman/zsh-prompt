zmodload zsh/datetime
setopt prompt_subst

SHOW_PROMPT_RENDER_TIME=

VIRTUAL_ENV_DISABLE_PROMPT=1
PS_GIT_HEAD=1
PS_YADM_HEAD=2
PS_GIT_STASHES=3

prompt_git_head() {
  psvar[$PS_GIT_HEAD]=''
  psvar[$PS_GIT_STASHES]=''

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

  # Set # of stashes
  [[ -f "$git_root/.git/logs/refs/stash" ]] || return
  local stashes=("${(f)$(<$git_root/.git/logs/refs/stash)}")
  [[ "${#stashes}" -eq 0 ]] && return
  psvar[$PS_GIT_STASHES]="${#stashes}"
}

prompt_yadm_head() {
  [[ -f "$HOME/.config/yadm/repo.git/HEAD" ]] || return 1

  local head=$(<"$HOME/.config/yadm/repo.git/HEAD") &&
  if [[ "$head" == "ref: refs/heads/master" ]]; then
    psvar[$PS_YADM_HEAD]=''
  elif [[ "$head" == 'ref: '* ]]; then
    psvar[$PS_YADM_HEAD]=${head##ref: refs\/heads\/}
  else
    psvar[$PS_YADM_HEAD]=${head:0:10}
  fi
}

precmd() {
  PROMPT_RENDER_START="$EPOCHREALTIME"
  prompt_git_head
  prompt_yadm_head
}

zle-line-init() {
  [[ -z $SHOW_PROMPT_RENDER_TIME ]] && return
  local diff=$((($EPOCHREALTIME * 1000) - ($PROMPT_RENDER_START * 1000)))
  PREDISPLAY="${SHOW_PROMPT_RENDER_TIME:+"(${diff[0,4]}ms) "}"
}
zle -N zle-line-init

## Left prompt
PROMPT=''

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

# Git stashes
RPROMPT+="%(${PS_GIT_STASHES}V. [%F{yellow}%${PS_GIT_STASHES}v%f stashes].)"

# ZLE keymap
RPROMPT+=' ${PROMPT_KEYMAP}'
