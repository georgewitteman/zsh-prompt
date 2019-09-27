my_prompt_async_callback() {
  VCS_INFO="$3"
  # echo call from callback
  my_prompt_render_right
  my_prompt_reset_prompt
}

my_prompt_async_vcs_info() {
  cd $1
  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:*' use-simple false
  zstyle ':vcs_info:*' check-for-changes false
  zstyle ':vcs_info:git:*' formats "%b"
  zstyle ':vcs_info:git:*' actionformats "%b|%a"

  vcs_info

  RESULT="$vcs_info_msg_0_"
  if [ "$vcs_info_msg_0_" != "" ]; then
    command git diff --no-ext-diff --quiet --exit-code
    GIT_DIRTY="$?"
    if [ "$GIT_DIRTY" != "0" ]; then
      RESULT="$RESULT*"
    fi
  fi
  echo "$RESULT"
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
  my_prompt_precmd_async
}

my_prompt_render_right() {
  RESULT="%F{250}$VCS_INFO%f"
  if [ "$RETVAL" != "0" ] && [ -n "$RETVAL" ]; then
    RESULT="$RESULT %K{red}%F{15} $RETVAL %k%f"
  fi
  RPROMPT="$RESULT"
}

my_prompt_render_left() {
  PROMPT='%F{110}%~%f %# '
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
