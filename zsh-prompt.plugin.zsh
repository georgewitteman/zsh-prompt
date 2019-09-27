my_prompt_async_callback() {
  VCS_INFO="$3"
  my_prompt_render_right
  my_prompt_reset_prompt
}

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
  fi
  echo "($RESULT)"
}

my_prompt_precmd_async() {
  if [ !${my_prompt_async_init:-0} ]; then
    async_start_worker "my_prompt" -u -n
    async_register_callback "my_prompt" my_prompt_async_callback
    typeset -g my_prompt_async_init=1
  fi

  async_job "my_prompt" my_prompt_async_vcs_info $PWD
}

my_prompt_precmd() {
  RETVAL="$?"
  VCS_INFO=""
  my_prompt_render_right
  # my_prompt_precmd_async
}

my_prompt_render_right() {
  RESULT="%F{250}$VCS_INFO%f"
  if [ "$RETVAL" != "0" ] && [ -n "$RETVAL" ]; then
    RESULT="$RESULT %K{red}%F{15} $RETVAL %k%f"
  fi
  # RPROMPT="$RESULT"
  PROMPT='%F{cyan}%B$(shrink_path --tilde --last)%f%b $(my_prompt_async_vcs_info)$RESULT $ '
}

my_prompt_render_left() {
  # PROMPT='%F{cyan}$(shrink_path --fish)%f $ '
  # PROMPT='%F{cyan}%B$(shrink_path --tilde --last)%f%b $ '
}

my_prompt_reset_prompt() {
  if [[ $CONTEXT == cont ]]; then
    # When the context is "cont", PS2 is active and calling
    # reset-prompt will have no effect on PS1, but it will
    # reset the execution context (%_) of PS2 which we don't
    # want. Unfortunately, we can't save the output of "%_"
    # either because it is only ever rendered as part of the
    # prompt, expanding in-place won't work.
    return
  fi

  zle && zle .reset-prompt
}

my_prompt_setup() {
  setopt prompt_subst
  zmodload zsh/zle
  autoload -Uz add-zsh-hook
  autoload -Uz vcs_info
  add-zsh-hook precmd my_prompt_precmd
  my_prompt_render_left
  my_prompt_render_right
}

my_prompt_setup
