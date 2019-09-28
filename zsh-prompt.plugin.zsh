my_prompt_check_git_arrows() {
  local arrows left=${1:-0} right=${2:-0}
  (( right > 0 )) && arrows+=${PURE_GIT_DOWN_ARROW:-↓}
  (( left > 0 )) && arrows+=${PURE_GIT_UP_ARROW:-↑}
  if [ -n "$arrows" ]; then
    echo " $arrows"
  fi
}

my_prompt_async_vcs_info() {
  setopt localoptions noshwordsplit
  # cd $1

  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:git:*' formats "%c%u%b"
  zstyle ':vcs_info:git:*' actionformats "%b%c%u|%a"
  # zstyle ':vcs_info:git:*' stagedstr "+"
  # zstyle ':vcs_info:git:*' unstagedstr "!"

  vcs_info

  RESULT="$vcs_info_msg_0_"
  if [ "$RESULT" != "" ]; then
    git diff --quiet --ignore-submodules HEAD > /dev/null 2>&1
    if [ "$?" != "0" ]; then
      RESULT="%F{red}$RESULT%f%k"
    else
      RESULT="%F{green}$RESULT%f%k"
    fi
    local output
    output=$(command git rev-list --left-right --count HEAD...@{'u'} 2>/dev/null)
    RESULT="$RESULT$(my_prompt_check_git_arrows "${(ps:\t:)output}")%f%k"
    git rev-parse --verify --quiet refs/stash >/dev/null
    if [ "$?" = "0" ]; then
      RESULT="\$$RESULT"
    fi
    RESULT="($RESULT)"
  fi
  echo "$RESULT"
}

my_prompt_precmd() {
  RETVAL="$?"
  VCS_INFO=""
  my_prompt_render
}

my_prompt_render() {
  RESULT="%F{250}$VCS_INFO%f"
  if [ "$RETVAL" != "0" ] && [ -n "$RETVAL" ]; then
    RESULT="$RESULT %K{red}%F{15} $RETVAL %k%f"
  fi
  PROMPT='%F{cyan}%B$(shrink_path --tilde --last)%f%b $(my_prompt_async_vcs_info)$RESULT %% '
}

my_prompt_setup() {
  setopt prompt_subst
  zmodload zsh/zle
  autoload -Uz add-zsh-hook
  autoload -Uz vcs_info
  add-zsh-hook precmd my_prompt_precmd
  my_prompt_render
}

my_prompt_setup
