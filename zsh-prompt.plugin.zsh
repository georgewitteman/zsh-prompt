zmodload zsh/datetime
setopt prompt_subst

SHOW_PROMPT_RENDER_TIME=

VIRTUAL_ENV_DISABLE_PROMPT=1

PS_YADM_HEAD=1

PS_GIT_HEAD=2
PS_GIT_STASHES=3
PS_GIT_STASH_WORD=4

PS_CMD_TIME=5
PS_CMD_COLOR=6

PS_WD=7

prompt_shrink_path() {
  psvar[$PS_WD]=''

  local i
  for i in {${#${PWD//[^\/]/}}..1}; do
    local dir="${PWD:F:$((i-1)):h}"
    # echo
    # echo "dir: $dir"
    # echo "dir:t: ${dir:t}"
    # echo "i: $i"
    # echo "psvar: $psvar[$PS_WD]"
    psvar[$PS_WD]+='/'

    if [[ "$dir" = "$HOME" ]]; then
      # echo 'inside1'
      psvar[$PS_WD]='~'
      continue
    elif [[ "$i" -eq 1 ]]; then
      # echo 'inside2'
      # Final path part
      psvar[$PS_WD]+="${PWD:t}"
      break
    elif [[ "${${dir:t}[1]}" = '.' ]]; then
      # echo 'inside3'
      # Directories that start with "." should have at least 1 letter
      psvar[$PS_WD]+='.'
    fi

    local matches=()
    # Until:
    #  - The path only matches one directory
    #  - There is no more specific path
    # echo "#psvar:t: ${#${psvar[$PS_WD]}:t}"
    # echo "psvar:t: ${${psvar[$PS_WD]}:t}"
    # echo '------'
    until [[ "${#matches}" -eq 1 || "${dir:t}" = "${${psvar[$PS_WD]}:t}" ]]; do
      psvar[$PS_WD]+="${${dir:t}[$(( ${#psvar[$PS_WD]##*/} + 1))]}"
      matches=("${dir:h}/${psvar[$PS_WD]:t}"*(-/))
      # echo "matches: $matches"
      # echo "psvar: ${psvar[$PS_WD]}"
      # echo '------'
    done
  done
}

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
  if [[ "${#stashes}" -eq 1 ]]; then
    psvar[$PS_GIT_STASH_WORD]="stash"
  else
    psvar[$PS_GIT_STASH_WORD]="stashes"
  fi
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
  psvar[$PS_CMD_TIME]=""

  prompt_git_head
  prompt_yadm_head
  prompt_shrink_path

  local stop="$EPOCHREALTIME"
  local start=${_PROMPT_COMMAND_START_TIME}
  unset _PROMPT_COMMAND_START_TIME

  [[ -z "$start" ]] && return
  [[ "$_PROMPT_LAST_COMMAND" =~ "^(vim|fg).*$" ]] && return

  local elapsed=${${(ps:.:)$(( $stop * 1000 - $start * 1000 ))}[1]}

  local split=("${elapsed}" 0)
  local units="ms"
  psvar[$PS_CMD_COLOR]="green"

  if (( $elapsed >= 1000 * 60 )); then
    split=("${(ps:.:)$(( elapsed / 1000.0 / 60.0 ))}")
    units="m"
    psvar[$PS_CMD_COLOR]="red"
  elif (( $elapsed >= 1000 )); then
    # Seconds
    split=("${(ps:.:)$(( elapsed / 1000.0 ))}")
    units="s"
    psvar[$PS_CMD_COLOR]="yellow"
  fi
  psvar[$PS_CMD_TIME]="${split[1]}"
  if (( ${split[2][1]} != 0 )); then
    psvar[$PS_CMD_TIME]+=".${split[2][1]}"
  fi
  psvar[$PS_CMD_TIME]+="${units}"
}

zle-line-init() {
  [[ -z $SHOW_PROMPT_RENDER_TIME ]] && return
  local diff=$((($EPOCHREALTIME * 1000) - ($PROMPT_RENDER_START * 1000)))
  PREDISPLAY="${SHOW_PROMPT_RENDER_TIME:+"(${diff[0,4]}ms) "}"
}
zle -N zle-line-init

preexec() {
  _PROMPT_COMMAND_START_TIME="$EPOCHREALTIME"
  _PROMPT_LAST_COMMAND="$2"
}

## Left prompt
PROMPT=''

# Virtual env
PROMPT+='${VIRTUAL_ENV:+"%F{242}${VIRTUAL_ENV:t}%f "}'

# Short path if available
PROMPT+="%B%F{cyan}%${PS_WD}v %f%b"

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

# Command time
RPROMPT+="%(${PS_CMD_TIME}V.%F{%${PS_CMD_COLOR}v}%${PS_CMD_TIME}v%f.)"

# Exit code
RPROMPT+='%(0?.. %K{red}%F{15} ${signals[$status-127]:-$status} %k%f)'

# YADM HEAD if not master
RPROMPT+="%(${PS_YADM_HEAD}V. yadm:%F{green}%${PS_YADM_HEAD}v%f.)"

# Git HEAD
RPROMPT+="%(${PS_GIT_HEAD}V. git:%F{magenta}%${PS_GIT_HEAD}v%f.)"

# Git stashes
RPROMPT+="%(${PS_GIT_STASHES}V. [%F{yellow}%${PS_GIT_STASHES}v%f %${PS_GIT_STASH_WORD}v].)"

# Time
RPROMPT+=" %D{%L:%M %p}"
