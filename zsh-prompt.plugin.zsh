setopt prompt_subst

prompt-precmd() {
  GIT_PROMPT=

  # Search up each directory until we get to the root or find one
  # that has a git repository
  local git_root="$PWD"
  until [[ "$git_root" = "/" || -d "${git_root}/.git" ]]; do
    git_root="${git_root:a:h}"
  done

  # Check if we found a git repo
  [[ "$git_root" != "/" && -f "${git_root}/.git/HEAD" ]] || return

  # Read contents of HEAD file
  local head=$(<"${git_root}/.git/HEAD")
  if [[ "$head" == 'ref: '* ]]; then
    head=${head##ref: refs\/heads\/}
  else
    head=${head:0:10}
  fi

  GIT_PROMPT="%F{magenta}${head}%f"

  # Set # of stashes
  [[ -f "${git_root}/.git/logs/refs/stash" ]] || return

  local stashes=("${(f)$(<${git_root}/.git/logs/refs/stash)}")
  [[ "${#stashes}" -eq 0 ]] && return
  GIT_PROMPT+=" [%F{yellow}${#stashes}%f "
  if [[ "${#stashes}" -eq 1 ]]; then
    GIT_PROMPT+="stash]"
  else
    GIT_PROMPT+="stashes]"
  fi
}

[[ -z "${precmd_functions+1}" ]] && precmd_functions=()
if [[ ${precmd_functions[(ie)prompt-precmd]} -gt ${#precmd_functions} ]]; then
  precmd_functions+=(prompt-precmd)
fi

## Left prompt
PS1=

VIRTUAL_ENV_DISABLE_PROMPT=1
PS1+='${VIRTUAL_ENV:+%F{242\}${VIRTUAL_ENV:t}%f }'

# Short path if available
PS1+="%F{cyan}%~ %f%b"

# Background jobs
PS1+="%(1j.%F{yellow}%j:bg%f .)"

# Subshell warning
PS1+="%("
if [[ -n "$TMUX" ]]; then
  # If we're in tmux then we're already in a subshell but it's ok
  PS1+="3"
else
  PS1+="2"
fi
PS1+="L.%F{yellow}%L+%f .)"

# Prompt character
PS1+="%(0?..%F{red})%#%f "


## Continuation prompt
PS2='%F{242}%_… %f>%f '


# Execution trace prompt (set -x)
PS4="%B%D{%H:%M:%S.%9.} +%N:%i>%b "


## Right prompt
RPS1=

# Exit code
RPS1+='%(0?.. %K{red}%F{15} %? %k%f)'

# Git info
RPS1+='${GIT_PROMPT:+ }${GIT_PROMPT}'

# Time
RPS1+=" %D{%L:%M %p}"

# Don't add the random extra space at the end of the right prompt
# https://superuser.com/a/726509
# Turned this off because it messes up the space after the prompt
# character when not in tmux.
# Turned this back on because it doesn't seem to be an issue now.
ZLE_RPROMPT_INDENT=0
