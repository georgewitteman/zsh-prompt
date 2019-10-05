MY_PROMPT_DIR="${0:a:h}"

source "$MY_PROMPT_DIR/zsh-prompt-nice-exit-code.zsh"
source "$MY_PROMPT_DIR/zsh-prompt-tool-versions.zsh"
source "$MY_PROMPT_DIR/zsh-prompt-shrink-path.zsh"

gitstatus_stop 'MY' && gitstatus_start -s -1 -u -1 -c -1 -d -1 'MY'

type should_drink >/dev/null 2>&1 && HYDRATE_INSTALLED=1

# psvar indexes
PS_NICE_EXIT_CODE=1
# PS_VIRTUAL_ENV=2
PS_PYTHON_VERSION=3
PS_NODE_VERSION=4
PS_HYDRATE=5
PS_DIR=6

# Git stuff
PS_LOADING_NEW_DIR=7
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

# When initially loading prompt start out by loading dir
psvar[$PS_LOADING_NEW_DIR]=1

gitstatus_callback() {
  psvar[$PS_LOADING_NEW_DIR]=""
  if [[ "$VCS_STATUS_RESULT" != ok-* ]]; then
    psvar[$PS_LOADING_NEW_DIR]=""
    psvar[$PS_GIT_REPO]=""
    unset VCS_STATUS_RESULT
    zle && zle reset-prompt
    return 0
  fi

  set_conditional_ps() {
    (( $2 )) && psvar[$1]="$2" || psvar[$1]=""
  }

  psvar[$PS_LOADING_NEW_DIR]=""
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

chpwd() {
  psvar[$PS_LOADING_NEW_DIR]="1"
  psvar[$PS_GIT_REPO]=""
  shrink_path $PS_DIR
}

precmd() {
  return_code=$?
  prompt_start_precmd="$EPOCHREALTIME"

  nice_exit_code $return_code $PS_NICE_EXIT_CODE

  # psvar[$PS_VIRTUAL_ENV]="${VIRTUAL_ENV:t}"

  get_python_version $PS_PYTHON_VERSION
  get_node_version $PS_NODE_VERSION

  if [ "$HYDRATE_INSTALLED" != "0" ]; then
    should_drink
    if [ "$SHOULD_DRINK" != "0" ]; then
      psvar[$PS_HYDRATE]="Time to drink!"
    else
      psvar[$PS_HYDRATE]=""
    fi
  fi

  psvar[$PS_GIT_LOADED]=""
  [ -z "$VCS_STATUS_RESULT" ] && gitstatus_query -d $PWD -c gitstatus_callback -t 0 'MY'
  case $VCS_STATUS_RESULT in
    # tout) ;;
    norepo-sync|ok-sync) gitstatus_callback ;;
  esac

  prompt_start_render="$EPOCHREALTIME"
}

build_git_prompt() {
  C_LOADING="241"
  C_DEFAULT="%F{%(${PS_GIT_LOADED}V.7.$C_LOADING)}"
  C_MAGENTA="%F{%(${PS_GIT_LOADED}V.13.$C_LOADING)}"
  C_RED="%F{%(${PS_GIT_LOADED}V.9.$C_LOADING)}"
  C_GREEN="%F{%(${PS_GIT_LOADED}V.10.$C_LOADING)}"
  C_BLUE="%F{%(${PS_GIT_LOADED}V.12.$C_LOADING)}"
  C_YELLOW="%F{%(${PS_GIT_LOADED}V.11.$C_LOADING)}"

  O_PAREN="${C_DEFAULT}(%f"
  C_PAREN="${C_DEFAULT})%f"
  SEP="${C_DEFAULT}|%f"
  BRANCH_NAME="${C_MAGENTA}%B%${PS_LOCAL_BRANCH}v%b%f"
  TAG="${C_DEFAULT}#%f${C_MAGENTA}%${PS_TAG}v%f"
  COMMIT_HASH="${C_DEFAULT}@%f${C_MAGENTA}%${PS_COMMIT}v%f"

  REPLY=''
  REPLY+="%(${PS_GIT_REPO}V." # if we have a git prompt
  REPLY+=" $O_PAREN" # prefix
  REPLY+="%(${PS_LOCAL_BRANCH}V.$BRANCH_NAME.%(${PS_TAG}V.$TAG.$COMMIT_HASH))"
  REPLY+="%(${PS_COMMITS_BEHIND}V.${C_DEFAULT}↓%f.)"
  REPLY+="%(${PS_COMMITS_AHEAD}V.${C_DEFAULT}↑%f.)"

  # Show the separator if there's anything on the left side
  REPLY+="%(${PS_STATUS_ACTION}V.$SEP."
  REPLY+="%(${PS_NUM_CONFLICTED}V.$SEP."
  REPLY+="%(${PS_NUM_STAGED}V.$SEP."
  REPLY+="%(${PS_NUM_UNSTAGED}V.$SEP."
  REPLY+="%(${PS_NUM_UNTRACKED}V.$SEP."
  REPLY+="%(${PS_STASHES}V.$SEP."
  REPLY+="))))))"

  REPLY+="%(${PS_STATUS_ACTION}V.${C_RED}%${PS_STATUS_ACTION}v%f.)"
  REPLY+="%(${PS_NUM_CONFLICTED}V.${C_MAGENTA}✖%${PS_NUM_CONFLICTED}v%f.)"
  REPLY+="%(${PS_NUM_STAGED}V.${C_GREEN}✚%${PS_NUM_STAGED}v%f.)"
  REPLY+="%(${PS_NUM_UNSTAGED}V.${C_RED}✚%${PS_NUM_UNSTAGED}v%f.)"
  REPLY+="%(${PS_NUM_UNTRACKED}V.${C_BLUE}…%${PS_NUM_UNTRACKED}v%f.)"
  REPLY+="%(${PS_STASHES}V.${C_YELLOW}!%${PS_STASHES}v%f.)"
  REPLY+="$C_PAREN" # suffix
  REPLY+=".%(${PS_LOADING_NEW_DIR}V. %F{$C_LOADING}(loading)%f.)"
  REPLY+=")"
}

VIRTUAL_ENV_DISABLE_PROMPT=1
chpwd

setopt PROMPT_SUBST

PROMPT=""

# SSH
PROMPT+='${${_FP_IS_SSH::="${SSH_TTY}${SSH_CONNECTION}${SSH_CLIENT}"}+}'
PROMPT+='${_FP_IS_SSH:+"%F{15}%K{cyan} SSH %k%f "}'

PROMPT+="%(0?..%K{red}%F{15} %(1V.%1v:%?.%?) %f%k )" # Show nice exit code or just #
PROMPT+='${VIRTUAL_ENV:+"%F{242}${VIRTUAL_ENV:t}%f "}' # Virtual env
PROMPT+="%B%F{cyan}%(${PS_DIR}V.%${PS_DIR}v.%~)%b%f" # Short path if available, else %~

build_git_prompt
PROMPT+="$REPLY " # Git prompt

PROMPT+="%(1j.%F{yellow}%j:bg%f .)" # Jobs
PROMPT+="%(${PS_HYDRATE}V.%F{blue}%${PS_HYDRATE}v%f .)" # Hydrate
PROMPT+="%(3L.%F{yellow}%L+%f .)" # Show a + if I'm in a subshell (set to 3 bc tmux)
PROMPT+="%# " # Prompt char
# PROMPT+="➜ " # Prompt char

# Continuation prompt
PROMPT2='%F{242}%_… %f>%f '

# Right prompt
RPROMPT=""
RPROMPT+="%(${PS_NODE_VERSION}V. %F{green}node:%${PS_NODE_VERSION}v%f.)"
RPROMPT+="%(${PS_PYTHON_VERSION}V. %F{yellow}python:%${PS_PYTHON_VERSION}v%f.)"
