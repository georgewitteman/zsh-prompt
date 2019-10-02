MY_PROMPT_DIR="${0:a:h}"

source "$MY_PROMPT_DIR/zsh-prompt-nice-exit-code.zsh"
source "$MY_PROMPT_DIR/zsh-prompt-tool-versions.zsh"
source "$MY_PROMPT_DIR/zsh-prompt-shrink-path.zsh"

gitstatus_stop 'MY' && gitstatus_start -s -1 -u -1 -c -1 -d -1 'MY'

type should_drink >/dev/null 2>&1 && HYDRATE_INSTALLED=1

PS_NICE_EXIT_CODE=1
PS_VIRTUAL_ENV=2
PS_PYTHON_VERSION=3
PS_NODE_VERSION=4
PS_HYDRATE=5
PS_DIR=6

# Git stuff
PS_GIT_LOADED=8
PS_GIT_REPO=9
PS_LOCAL_BRANCH=10
PS_TAG=11
PS_COMMIT=12
PS_COMMITS_BEHIND=13
PS_COMMITS_AHEAD=14
PS_STATUS_ACTION=15
PS_NUM_CONFLICTED=16
PS_NUM_STAGED=17
PS_NUM_UNSTAGED=18
PS_NUM_UNTRACKED=19
PS_STASHES=20

gitstatus_callback() {
  if [[ "$VCS_STATUS_RESULT" != 'ok-async' ]]; then
    psvar[9]=""
    unset VCS_STATUS_RESULT
    zle && zle reset-prompt
    return 0
  fi

  set_conditional_ps() {
    (( $2 )) && psvar[$1]="$2" || psvar[$1]=""
  }

  psvar[$PS_GIT_LOADED]="1"
  psvar[$PS_GIT_REPO]="1"
  psvar[$PS_LOCAL_BRANCH]="${VCS_STATUS_LOCAL_BRANCH}"
  psvar[$PS_TAG]="${VCS_STATUS_TAG}"
  psvar[$PS_COMMIT]="${VCS_STATUS_COMMIT[1,8]}"
  psvar[$PS_STATUS_ACTION]="${VCS_STATUS_ACTION}"
  set_conditional_ps $PS_COMMITS_BEHIND $VCS_STATUS_COMMITS_BEHIND
  set_conditional_ps $PS_COMMITS_AHEAD $VCS_STATUS_COMMITS_AHEAD
  set_conditional_ps $PS_NUM_CONFLICTED $VCS_STATUS_NUM_CONFLICTED
  set_conditional_ps $PS_NUM_STAGED $VCS_STATUS_NUM_STAGED
  set_conditional_ps $PS_NUM_UNSTAGED $VCS_STATUS_NUM_UNSTAGED
  set_conditional_ps $PS_NUM_UNTRACKED $VCS_STATUS_NUM_UNTRACKED
  set_conditional_ps $PS_STASHES $VCS_STATUS_STASHES

  unset VCS_STATUS_RESULT
  zle && zle reset-prompt
}

precmd() {
  # echo start precmd $EPOCHREALTIME
  # return_code=$(print -P "%?")
  return_code=$?
  shrink_path
  # shrink_path --last --tilde
  # shrink_path --last
  psvar[$PS_DIR]="$RETVAL"
  # echo after return code before exit code $EPOCHREALTIME
  # psvar=()
  nice_exit_code $return_code
  psvar[$PS_NICE_EXIT_CODE]="$RETVAL"
  # echo after exit code before virtual env $EPOCHREALTIME
  if [ "$VIRTUAL_ENV" != "" ]; then
    psvar[$PS_VIRTUAL_ENV]="$(basename "$VIRTUAL_ENV") "
  else
    psvar[$PS_VIRTUAL_ENV]=""
  fi
  # echo after virtual env $EPOCHREALTIME

  get_python_version
  psvar[$PS_PYTHON_VERSION]=$retval
  get_node_version
  psvar[$PS_NODE_VERSION]=$retval
  # psvar[$PS_PYTHON_VERSION]=$(get_python_version)
  # psvar[$PS_NODE_VERSION]=$(get_node_version)

  # echo before hydrate $EPOCHREALTIME
  if [ "$HYDRATE_INSTALLED" != "0" ]; then
    should_drink
    if [ "$SHOULD_DRINK" != "0" ]; then
      psvar[$PS_HYDRATE]="Time to drink!"
    else
      psvar[$PS_HYDRATE]=""
    fi
  fi
  # echo after hydratei $EPOCHREALTIME

  # echo before gitstatus_query $EPOCHREALTIME
  psvar[$PS_GIT_LOADED]=""
  [ -z "$VCS_STATUS_RESULT" ] && gitstatus_query -d $PWD -c gitstatus_callback -t 0 'MY'
  # echo after gitstatus_query $EPOCHREALTIME
}

build_git_prompt() {
  C_LOADING="241"
  C_DEFAULT="%F{%(${PS_GIT_LOADED}V.default.$C_LOADING)}"
  C_MAGENTA="%F{%(${PS_GIT_LOADED}V.magenta.$C_LOADING)}"
  C_RED="%F{%(${PS_GIT_LOADED}V.red.$C_LOADING)}"
  C_GREEN="%F{%(${PS_GIT_LOADED}V.green.$C_LOADING)}"
  C_BLUE="%F{%(${PS_GIT_LOADED}V.blue.$C_LOADING)}"
  C_YELLOW="%F{%(${PS_GIT_LOADED}V.yellow.$C_LOADING)}"

  O_PAREN="${C_DEFAULT}(%f"
  C_PAREN="${C_DEFAULT})%f"
  SEP="${C_DEFAULT}|%f"
  BRANCH_NAME="${C_MAGENTA}%B%${PS_LOCAL_BRANCH}v%b%f"
  TAG="${C_DEFAULT}#%f${C_MAGENTA}%${PS_TAG}v%f"
  COMMIT_HASH="${C_DEFAULT}@%f${C_MAGENTA}%${PS_COMMIT}v%f"

  RETVAL=''
  RETVAL+="%(${PS_GIT_REPO}V." # if we have a git prompt
  RETVAL+=" $O_PAREN" # prefix
  RETVAL+="%(${PS_LOCAL_BRANCH}V.$BRANCH_NAME.%(${PS_TAG}V.$TAG.$COMMIT_HASH))"
  RETVAL+="%(${PS_COMMITS_BEHIND}V.${C_DEFAULT}↓%f.)"
  RETVAL+="%(${PS_COMMITS_AHEAD}V.${C_DEFAULT}↑%f.)"

  # Separator
  RETVAL+="%(${PS_STATUS_ACTION}V.$SEP."
  RETVAL+="%(${PS_NUM_CONFLICTED}V.$SEP."
  RETVAL+="%(${PS_NUM_STAGED}V.$SEP."
  RETVAL+="%(${PS_NUM_UNSTAGED}V.$SEP."
  RETVAL+="%(${PS_NUM_UNTRACKED}V.$SEP."
  RETVAL+="%(${PS_STASHES}V.$SEP."
  RETVAL+="))))))"

  RETVAL+="%(${PS_STATUS_ACTION}V.${C_RED}%${PS_STATUS_ACTION}v%f.)"
  RETVAL+="%(${PS_NUM_CONFLICTED}V.${C_MAGENTA}✖%${PS_NUM_CONFLICTED}v%f.)"
  RETVAL+="%(${PS_NUM_STAGED}V.${C_GREEN}✚%${PS_NUM_STAGED}v%f.)"
  RETVAL+="%(${PS_NUM_UNSTAGED}V.${C_RED}✚%${PS_NUM_UNSTAGED}v%f.)"
  RETVAL+="%(${PS_NUM_UNTRACKED}V.${C_BLUE}…%${PS_NUM_UNTRACKED}v%f.)"
  RETVAL+="%(${PS_STASHES}V.${C_YELLOW}!%${PS_STASHES}v%f.)"
  RETVAL+="$C_PAREN" # suffix
  RETVAL+=".)" # if no git prompt don't display anything
}

VIRTUAL_ENV_DISABLE_PROMPT=1

PROMPT=""
PROMPT+="%(${PS_VIRTUAL_ENV}V.%F{247}%${PS_VIRTUAL_ENV}v %f.)"
PROMPT+="%B%F{cyan}%${PS_DIR}v%b%f" # Path
build_git_prompt
PROMPT+="$RETVAL "
PROMPT+="%(1j.%F{yellow}%j:bg%f .)" # Jobs
PROMPT+="%(${PS_HYDRATE}V.%F{blue}%${PS_HYDRATE}v%f .)"
PROMPT+="%(0?..%F{red})%#%f " # Prompt char (red if last non-zero exit status)

# Right prompt
RPROMPT=""
RPROMPT+="%(0?..%F{red}%(1V.%1v:%?.%?)%f)" # Show nice exit code or just #
RPROMPT+="%(${PS_NODE_VERSION}V. %F{green}node:%${PS_NODE_VERSION}v%f.)"
RPROMPT+="%(${PS_PYTHON_VERSION}V. %F{yellow}python:%${PS_PYTHON_VERSION}v%f.)"


