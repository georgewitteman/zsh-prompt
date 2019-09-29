setopt prompt_subst
zmodload zsh/zle
autoload -Uz add-zsh-hook
autoload -Uz vcs_info

add-zsh-hook precmd my_prompt_precmd

ZSH_THEME_GIT_PROMPT_PREFIX="%f%k ("
# ZSH_THEME_GIT_PROMPT_PREFIX="%F{242} ("
ZSH_THEME_GIT_PROMPT_SUFFIX=")"
# ZSH_THEME_GIT_PROMPT_SUFFIX="%F{242})%f%k"
ZSH_THEME_GIT_PROMPT_SEPARATOR="|"
ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_bold[magenta]%}"
# ZSH_THEME_GIT_PROMPT_BRANCH="%F{242}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{↓%G%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{↑%G%}"
# ZSH_THEME_GIT_PROMPT_BEHIND="%F{242}↓"
# ZSH_THEME_GIT_PROMPT_AHEAD="%F{242}↑"
ZSH_THEME_GIT_PROMPT_STASHED="%{$fg[yellow]%}%{*%G%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[green]%}%{✚%G%}"
ZSH_THEME_GIT_PROMPT_CONFLICTS="%{$fg[magenta]%}%{✖%G%}"
ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg[red]%}%{✚%G%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[blue]…%G%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}%{✔%G%}"
# ZSH_THEME_GIT_PROMPT_DIRTY="%F{242}*"

# gitstatus_stop 'MY' && gitstatus_start -s -1 -u -1 -c -1 -d -1 'MY'
gitstatus_stop 'MY' && gitstatus_start -s -1 -u -1 -c -1 -d -1 'MY'
# gitstatus_stop 'MY' && gitstatus_start ' MY'
# autoload -Uz add-zsh-hook
# add-zsh-hook precmd git-prompt
function gitstatus_prompt_update() {
  emulate -L zsh
  typeset -g  GITSTATUS_PROMPT=''
  typeset -gi GITSTATUS_PROMPT_LEN=0

  # Call gitstatus_query synchronously. Note that gitstatus_query can also be called
  # asynchronously; see documentation in gitstatus.plugin.zsh.
  gitstatus_query 'MY'                  || return 1  # error
  [[ $VCS_STATUS_RESULT == 'ok-sync' ]] || return 0  # not a git repo

  local      clean='%F{magenta}'   # green foreground
  local   modified='%F{yellow}'  # yellow foreground
  local  untracked='%F{blue}'   # blue foreground
  local conflicted='%F{red}'  # red foreground

  local p

  local where  # branch name, tag or commit
  if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
    where=$VCS_STATUS_LOCAL_BRANCH
  elif [[ -n $VCS_STATUS_TAG ]]; then
    p+='%f#'
    where=$VCS_STATUS_TAG
  else
    p+='%f@'
    where=${VCS_STATUS_COMMIT[1,8]}
  fi

  (( $#where > 32 )) && where[13,-13]="…"  # truncate long branch names and tags
  p+="${clean}${where//\%/%%}"             # escape %

  # ⇣42 if behind the remote.
  (( VCS_STATUS_COMMITS_BEHIND )) && p+="%f↓${VCS_STATUS_COMMITS_BEHIND}"
  # ⇡42 if ahead of the remote; no leading space if also behind the remote: ⇣42⇡42.
  (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && p+=""
  (( VCS_STATUS_COMMITS_AHEAD  )) && p+="↑${VCS_STATUS_COMMITS_AHEAD}"
  p+="%f|"
  # 'merge' if the repo is in an unusual state.
  [[ -n $VCS_STATUS_ACTION     ]] && p+="${conflicted}${VCS_STATUS_ACTION}"
  # ~42 if have merge conflicts.
  (( VCS_STATUS_NUM_CONFLICTED )) && p+="%F{magenta}✖${VCS_STATUS_NUM_CONFLICTED}"
  # +42 if have staged changes.
  (( VCS_STATUS_NUM_STAGED     )) && p+="%F{green}✚${VCS_STATUS_NUM_STAGED}"
  # !42 if have unstaged changes.
  (( VCS_STATUS_NUM_UNSTAGED   )) && p+="%F{red}✚${VCS_STATUS_NUM_UNSTAGED}"
  # ?42 if have untracked files. It's really a question mark, your font isn't broken.
  (( VCS_STATUS_NUM_UNTRACKED  )) && p+="%F{blue}…${VCS_STATUS_NUM_UNTRACKED}"
  # *42 if have stashes.
  (( VCS_STATUS_STASHES        )) && p+="%F{yellow}*${VCS_STATUS_STASHES}"

  GITSTATUS_PROMPT=" (${p}%f)"

  # The length of GITSTATUS_PROMPT after removing %f and %F.
  GITSTATUS_PROMPT_LEN="${(m)#${${GITSTATUS_PROMPT//\%\%/x}//\%(f|<->F)}}"
}
git_prompt() {
  # echo $(pwd)
  local STATUS
  STATUS=
  # gitstatus_query MY
  # echo result $VCS_STATUS_RESULT
  if gitstatus_query MY && [[ $VCS_STATUS_RESULT == ok-sync ]]; then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_PREFIX$ZSH_THEME_GIT_PROMPT_BRANCH$VCS_STATUS_LOCAL_BRANCH%{${reset_color}%}"
    if [ "$VCS_STATUS_COMMITS_BEHIND" -ne "0" ]; then
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_BEHIND$VCS_STATUS_COMMITS_BEHIND%{${reset_color}%}"
      # STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_BEHIND%{${reset_color}%}"
    fi
    if [ "$VCS_STATUS_COMMITS_AHEAD" -ne "0" ]; then
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_AHEAD$VCS_STATUS_COMMITS_AHEAD%{${reset_color}%}"
      # STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_AHEAD%{${reset_color}%}"
    fi
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_SEPARATOR"
    if [ "$VCS_STATUS_HAS_STAGED" -ne "0" ]; then
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_STAGED$VCS_STATUS_NUM_STAGED%{${reset_color}%}"
      # STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_STAGED%{${reset_color}%}"
    fi
    if [ "$VCS_STATUS_STASHES" != "0" ]; then
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_STASHED$VCS_STATUS_STASHES%{${reset_color}%}"
    fi
    if [ "$VCS_STATUS_HAS_CONFLICTED" -ne "0" ]; then
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CONFLICTS$VCS_STATUS_NUM_CONFLICTED%{${reset_color}%}"
      # STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CONFLICTS%{${reset_color}%}"
    fi
    if [ "$VCS_STATUS_HAS_UNSTAGED" -ne "0" ]; then
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CHANGED$VCS_STATUS_NUM_UNSTAGED%{${reset_color}%}"
      # STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CHANGED%{${reset_color}%}"
    fi
    if [ "$VCS_STATUS_HAS_UNTRACKED" -ne "0" ]; then
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED$VCS_STATUS_NUM_UNTRACKED%{${reset_color}%}"
      # STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED%{${reset_color}%}"
    fi
    if [ "$VCS_STATUS_HAS_UNSTAGED" -eq "0" ] && [ "$VCS_STATUS_HAS_CONFLICTED" -eq "0" ] && [ "$VCS_STATUS_HAS_STAGED" -eq "0" ] && [ "$VCS_STATUS_HAS_UNTRACKED" -eq "0" ] && [ "$VCS_STATUS_STASHES" -eq "0" ]; then
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CLEAN"
    else
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_DIRTY"
    fi
    STATUS="$STATUS%{${reset_color}%}$ZSH_THEME_GIT_PROMPT_SUFFIX"
    echo "$STATUS"
    # GIT_PROMPT=$STATUS
  fi
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

  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:git:*' formats "%c%u%b"
  zstyle ':vcs_info:git:*' actionformats "%b%c%u|%a"

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
  echo " $RESULT"
}

my_prompt_precmd() {
  RETVAL="$?"
  VCS_INFO=""
  gitstatus_prompt_update
  my_prompt_render
}

my_prompt_render() {
  result=
  if [ "$RETVAL" != "0" ] && [ -n "$RETVAL" ]; then
    result="%K{red}%F{15} $RETVAL %k%f"
  fi
  PROMPT='%F{cyan}%B%~%f%b$GITSTATUS_PROMPT %% '
  RPROMPT='$result'
}

my_prompt_render
