setopt prompt_subst
autoload -Uz add-zsh-hook
add-zsh-hook precmd my_prompt_precmd

MY_PROMPT_DIR="${0:a:h}"

source "$MY_PROMPT_DIR/zsh-prompt-nice-exit-code.zsh"
source "$MY_PROMPT_DIR/zsh-prompt-gitstatus.zsh"
source "$MY_PROMPT_DIR/zsh-prompt-tool-versions.zsh"

gitstatus_stop 'MY' && gitstatus_start -s -1 -u -1 -c -1 -d -1 'MY'

type should_drink >/dev/null 2>&1 && HYDRATE_INSTALLED=1

jobscount() {
  JOBSCOUNT="%(1j. %F{15}%K{yellow} %j %f%k.)"
}

my_prompt_precmd() {
  RETVAL="$?"
  typeset -g PROMPT_DRINK=''
  VCS_INFO=""
  [ "$HYDRATE_INSTALLED" != "0" ] && PROMPT_DRINK="$(drink_water)"
  gitstatus_prompt_update
  jobscount
  my_prompt_render
}

my_prompt_render() {
  PVENV=
  exit_code=
  if [ "$RETVAL" != "0" ] && [ -n "$RETVAL" ]; then
    nice_code=$(nice_exit_code "$RETVAL")
    if [ "$nice_code" != "" ]; then
      exit_code=" %K{red}%F{15} $nice_code ($RETVAL) %k%f"
    else
      exit_code=" %K{red}%F{15} $RETVAL %k%f"
    fi
  fi
  if [ "$VIRTUAL_ENV" != "" ]; then
    PVENV="$(basename "$VIRTUAL_ENV") "
  fi
  PYTHON_VERSION=$(get_python_version)
  # echo $PYTHON_VERSION
  if [ "$PYTHON_VERSION" != "" ]; then
    PYTHON_PROMPT=" %F{yellow}py $PYTHON_VERSION%f"
  fi
  NODEJS_VERSION=$(get_node_version)
  if [ "$NODEJS_VERSION" != "" ]; then
    NODEJS_PROMPT=" %F{green}⬢ $NODEJS_VERSION%f"
  fi
  PROMPT='%F{244}${PVENV}%f%F{cyan}%B%~%f%b$GITSTATUS_PROMPT $PROMPT_DRINK%% '
  RPROMPT='$PYTHON_PROMPT$NODEJS_PROMPT$JOBSCOUNT$exit_code'
}

my_prompt_render
