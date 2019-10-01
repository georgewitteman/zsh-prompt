MY_PROMPT_DIR="${0:a:h}"

# autoload -Uz zle
# autoload -U colors && colors

source "$MY_PROMPT_DIR/zsh-prompt-nice-exit-code.zsh"
source "$MY_PROMPT_DIR/zsh-prompt-gitstatus.zsh"
source "$MY_PROMPT_DIR/zsh-prompt-tool-versions.zsh"

gitstatus_stop 'MY' && gitstatus_start -s -1 -u -1 -c -1 -d -1 'MY'

PS_NICE_EXIT_CODE=1
PS_VIRTUAL_ENV=2
PS_PYTHON_VERSION=3
PS_NODE_VERSION=4

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
  set_conditional_ps $PS_COMMITS_BEHIND $VCS_STATUS_COMMITS_BEHIND
  set_conditional_ps $PS_COMMITS_AHEAD $VCS_STATUS_COMMITS_AHEAD
  set_conditional_ps $PS_STATUS_ACTION $VCS_STATUS_ACTION
  set_conditional_ps $PS_NUM_CONFLICTED $VCS_STATUS_NUM_CONFLICTED
  set_conditional_ps $PS_NUM_STAGED $VCS_STATUS_NUM_STAGED
  set_conditional_ps $PS_NUM_UNSTAGED $VCS_STATUS_NUM_UNSTAGED
  set_conditional_ps $PS_NUM_UNTRACKED $VCS_STATUS_NUM_UNTRACKED
  set_conditional_ps $PS_STASHES $VCS_STATUS_STASHES

  unset VCS_STATUS_RESULT
  zle && zle reset-prompt
}

precmd() {
  return_code=$(print -P "%?")
  # psvar=()
  psvar[$PS_NICE_EXIT_CODE]=$(nice_exit_code $return_code)
  if [ "$VIRTUAL_ENV" != "" ]; then
    psvar[$PS_VIRTUAL_ENV]="$(basename "$VIRTUAL_ENV") "
  else
    psvar[$PS_VIRTUAL_ENV]=""
  fi

  psvar[$PS_PYTHON_VERSION]=$(get_python_version)
  psvar[$PS_NODE_VERSION]=$(get_node_version)

  psvar[$PS_GIT_LOADED]=""
  [ -z "$VCS_STATUS_RESULT" ] && gitstatus_query -d $PWD -c gitstatus_callback -t 0 'MY'
}

build_git_prompt() {
  ccolor() {
    echo -n "%F{%(${PS_GIT_LOADED}V.$1.241)}$2%f"
  }

  pif() {
    condition=$1
    iftrue=$2
    iffalse=$3

    echo -n "%($condition.$iftrue.$iffalse)"
  }

  O_PAREN="$(ccolor default "(")"
  C_PAREN="$(ccolor default ")")"
  SEP="$(ccolor default "|")"
  BRANCH_NAME="$(ccolor magenta "%B%${PS_LOCAL_BRANCH}v%b")"
  TAG="$(ccolor default "#")$(ccolor magenta "%${PS_TAG}v")"
  COMMIT_HASH="$(ccolor default "@")$(ccolor magenta "%${PS_COMMIT}v")"

  echo -n "%(${PS_GIT_REPO}V." # if we have a git prompt
  echo -n " $O_PAREN" # prefix
  echo -n "%(${PS_LOCAL_BRANCH}V.$BRANCH_NAME.%(${PS_TAG}V.$TAG.$COMMIT_HASH))"
  echo -n "%(${PS_COMMITS_BEHIND}V.$(ccolor default "↓").)"
  echo -n "%(${PS_COMMITS_AHEAD}V.$(ccolor default "↑").)"

  # Separator
  # echo -n "%(${PS_STATUS_ACTION}V.)"
  pif "${PS_STATUS_ACTION}V" "$SEP" $( \
    pif "${PS_NUM_CONFLICTED}V" "$SEP" $( \
    pif "${PS_NUM_STAGED}V" "$SEP" $( \
    pif "${PS_NUM_UNSTAGED}V" "$SEP" $( \
    pif "${PS_NUM_UNTRACKED}V" "$SEP" $( \
    pif "${PS_STASHES}V" "$SEP" ""\
    )))))

  echo -n "%(${PS_STATUS_ACTION}V.$(ccolor red "%${PS_STATUS_ACTION}v").)"
  echo -n "%(${PS_NUM_CONFLICTED}V.$(ccolor magenta "✖%${PS_NUM_CONFLICTED}v").)"
  echo -n "%(${PS_NUM_STAGED}V.$(ccolor green "✚%${PS_NUM_STAGED}v").)"
  echo -n "%(${PS_NUM_UNSTAGED}V.$(ccolor red "✚%${PS_NUM_UNSTAGED}v").)"
  echo -n "%(${PS_NUM_UNTRACKED}V.$(ccolor blue "…%${PS_NUM_UNTRACKED}v").)"
  echo -n "%(${PS_STASHES}V.$(ccolor yellow "!%${PS_STASHES}v").)"
  echo -n "$C_PAREN" # suffix
  echo -n ".)" # if no git prompt don't display anything
}

VIRTUAL_ENV_DISABLE_PROMPT=1

# Left prompt
PROMPT=""
PROMPT+="%(${PS_VIRTUAL_ENV}V.%F{247}%${PS_VIRTUAL_ENV}v %f.)"
PROMPT+="%B%F{cyan}%~%b%f" # Path
PROMPT+="$(build_git_prompt)"
PROMPT+="%(1j. %F{yellow}%j:bg%f.)" # Jobs
PROMPT+="%(0?..%F{red}) %#%f " # Prompt char (red if last non-zero exit status)

# Right prompt
RPROMPT=""
RPROMPT+="%(0?..%F{red}%(1V.%1v:%?.%?)%f)" # Show nice exit code or just #
RPROMPT+="%(${PS_NODE_VERSION}V. %F{green}node:%${PS_NODE_VERSION}v%f.)"
RPROMPT+="%(${PS_PYTHON_VERSION}V. %F{yellow}python:%${PS_PYTHON_VERSION}v%f.)"


