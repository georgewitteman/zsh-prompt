zmodload zsh/datetime
setopt prompt_subst

VIRTUAL_ENV_DISABLE_PROMPT=1

ps_yadm_head=1

ps_git_head=2
ps_git_stashes=3
ps_git_stash_word=4

ps_cmd_time=5
ps_cmd_color=6

ps_pwd=7

prompt-shrink-path() {
  psvar[$ps_pwd]=

  local i dir matches
  for i in {${#${PWD//[^\/]/}}..1}; do
    dir="${PWD:F:$((i-1)):h}"
    psvar[$ps_pwd]+='/'

    if [[ "$dir" = "$HOME" ]]; then
      psvar[$ps_pwd]='~'
      continue
    elif [[ "$i" -eq 1 ]]; then
      # Final path part
      psvar[$ps_pwd]+="${PWD:t}"
      break
    elif [[ "${${dir:t}[1]}" = '.' ]]; then
      # Directories that start with "." should have at least 1 letter
      psvar[$ps_pwd]+='.'
    fi

    matches=()
    # Until:
    #  - The path only matches one directory
    #  - There is no more specific path
    until [[ "${#matches}" -eq 1 || "${dir:t}" = "${${psvar[$ps_pwd]}:t}" ]]; do
      psvar[$ps_pwd]+="${${dir:t}[$(( ${#psvar[$ps_pwd]##*/} + 1))]}"
      matches=("${dir:h}/${psvar[$ps_pwd]:t}"*(-/))
    done
  done
}

prompt-git-head() {
  psvar[$ps_git_head]=
  psvar[$ps_git_stashes]=

  # Search up each directory until we get to the root or find one
  # that has a git repository
  local git_root="$PWD"
  until [[ "$git_root" = "/" || -d "${git_root}/.git" ]]; do
    git_root="${git_root:a:h}"
  done

  # Check if we found a git repo
  [[ "$git_root" != "/" && -f "${git_root}/.git/HEAD" ]] || return 1

  # Read contents of HEAD file
  local head=$(<"${git_root}/.git/HEAD")
  if [[ "$head" == 'ref: '* ]]; then
    psvar[$ps_git_head]=${head##ref: refs\/heads\/}
  else
    psvar[$ps_git_head]=${head:0:10}
  fi

  # Set # of stashes
  [[ -f "${git_root}/.git/logs/refs/stash" ]] || return

  local stashes=("${(f)$(<${git_root}/.git/logs/refs/stash)}")
  [[ "${#stashes}" -eq 0 ]] && return
    psvar[$ps_git_stashes]="${#stashes}"
  if [[ "${#stashes}" -eq 1 ]]; then
    psvar[$ps_git_stash_word]="stash"
  else
    psvar[$ps_git_stash_word]="stashes"
  fi
}

prompt-yadm-head() {
  [[ -f "${HOME}/.config/yadm/repo.git/HEAD" ]] || return 1

  local head=$(<"${HOME}/.config/yadm/repo.git/HEAD") &&
  if [[ "$head" == "ref: refs/heads/master" ]]; then
    psvar[$ps_yadm_head]=''
  elif [[ "$head" == 'ref: '* ]]; then
    psvar[$ps_yadm_head]=${head##ref: refs\/heads\/}
  else
    psvar[$ps_yadm_head]=${head:0:10}
  fi
}

prompt-cmd-time() {
  psvar[$ps_cmd_time]=

  [[ -z "$PROMPT_START_TIME" ]] && return

  local elapsed="${${(ps:.:)$(( ($EPOCHREALTIME - $PROMPT_START_TIME) * 1000 ))}[1]}"
  unset PROMPT_START_TIME

  local split=("$elapsed" 0)
  local units="ms"
  psvar[$ps_cmd_color]="green"

  if (( $elapsed >= 1000 * 60 )); then
    # Minutes
    split=("${(ps:.:)$(( elapsed / 1000.0 / 60.0 ))}")
    units="m"
    psvar[$ps_cmd_color]="red"
  elif (( $elapsed >= 1000 )); then
    # Seconds
    split=("${(ps:.:)$(( elapsed / 1000.0 ))}")
    units="s"
    psvar[$ps_cmd_color]="yellow"
  fi
  psvar[$ps_cmd_time]="${split[1]}"
  if (( ${split[2][1]} != 0 )); then
    psvar[$ps_cmd_time]+=".${split[2][1]}"
  fi
  psvar[$ps_cmd_time]+="$units"
}

prompt-precmd() {
  prompt-git-head
  prompt-yadm-head
  prompt-shrink-path
  prompt-cmd-time
}

prompt-preexec() {
  PROMPT_START_TIME="$EPOCHREALTIME"
}

[[ -z "${precmd_functions+1}" ]] && precmd_functions=()
[[ -z "${preexec_functions+1}" ]] && preexec_functions=()

if [[ ${precmd_functions[(ie)prompt-precmd]} -gt ${#precmd_functions} ]]; then
    precmd_functions+=(prompt-precmd)
fi
if [[ ${preexec_functions[(ie)prompt-preexec]} -gt ${#preexec_functions} ]]; then
    preexec_functions+=(prompt-preexec)
fi


## Left prompt
PROMPT=''

# Virtual env
PROMPT+='${VIRTUAL_ENV:+"%F{242}${VIRTUAL_ENV:t}%f "}'

# Short path if available
PROMPT+="%B%F{cyan}%${ps_pwd}v %f%b"

# Background jobs
PROMPT+="%(1j.%F{yellow}%j:bg%f .)"

# Subshell warning
PROMPT+="%(3L.%F{yellow}%L+%f .)"

# Prompt character
PROMPT+="%(0?..%F{red})%#%f "


## Continuation prompt
PROMPT2='%F{242}%_… %f>%f '


## Right prompt
RPROMPT=

# Command time
RPROMPT+="%(${ps_cmd_time}V.%F{%${ps_cmd_color}v}%${ps_cmd_time}v%f.)"

# Exit code
RPROMPT+='%(0?.. %K{red}%F{15} ${signals[$status-127]:-$status} %k%f)'

# YADM HEAD if not master
RPROMPT+="%(${ps_yadm_head}V. yadm:%F{green}%${ps_yadm_head}v%f.)"

# Git HEAD
RPROMPT+="%(${ps_git_head}V. git:%F{magenta}%${ps_git_head}v%f.)"

# Git stashes
RPROMPT+="%(${ps_git_stashes}V. [%F{yellow}%${ps_git_stashes}v%f %${ps_git_stash_word}v].)"

# Time
RPROMPT+=" %D{%L:%M %p}"

# Don't add the random extra space at the end of the right prompt
# https://superuser.com/a/726509
# Turned this off because it messes up the space after the prompt
# character when not in tmux
# ZLE_RPROMPT_INDENT=0
