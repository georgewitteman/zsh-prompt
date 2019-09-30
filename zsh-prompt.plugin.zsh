setopt prompt_subst
autoload -Uz add-zsh-hook

add-zsh-hook precmd my_prompt_precmd

gitstatus_stop 'MY' && gitstatus_start -s -1 -u -1 -c -1 -d -1 'MY'

function gitstatus_prompt_update() {
  emulate -L zsh
  typeset -g  GITSTATUS_PROMPT=''
  typeset -gi GITSTATUS_PROMPT_LEN=0

  # Call gitstatus_query synchronously. Note that gitstatus_query can also be called
  # asynchronously; see documentation in gitstatus.plugin.zsh.
  gitstatus_query 'MY'                  || return 1  # error
  [[ $VCS_STATUS_RESULT == 'ok-sync' ]] || return 0  # not a git repo

  local clean='%F{magenta}'   # green foreground
  local modified='%F{yellow}'  # yellow foreground
  local untracked='%F{blue}'   # blue foreground
  local conflicted='%F{red}'  # red foreground

  local before
  local after

  local where  # branch name, tag or commit
  if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
    where=$VCS_STATUS_LOCAL_BRANCH
  elif [[ -n $VCS_STATUS_TAG ]]; then
    before+='%f#'
    where=$VCS_STATUS_TAG
  else
    before+='%f@'
    where=${VCS_STATUS_COMMIT[1,8]}
  fi

  (( $#where > 32 )) && where[13,-13]="…"  # truncate long branch names and tags
  before+="${clean}${where//\%/%%}"             # escape %

  # ⇣42 if behind the remote.
  (( VCS_STATUS_COMMITS_BEHIND )) && before+="%f↓${VCS_STATUS_COMMITS_BEHIND}"
  # ⇡42 if ahead of the remote; no leading space if also behind the remote: ⇣42⇡42.
  (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && before+=""
  (( VCS_STATUS_COMMITS_AHEAD  )) && before+="%f↑${VCS_STATUS_COMMITS_AHEAD}"

  # 'merge' if the repo is in an unusual state.
  [[ -n $VCS_STATUS_ACTION     ]] && after+="${conflicted}${VCS_STATUS_ACTION}"
  # ~42 if have merge conflicts.
  (( VCS_STATUS_NUM_CONFLICTED )) && after+="%F{magenta}✖${VCS_STATUS_NUM_CONFLICTED}"
  # +42 if have staged changes.
  (( VCS_STATUS_NUM_STAGED     )) && after+="%F{green}✚${VCS_STATUS_NUM_STAGED}"
  # !42 if have unstaged changes.
  (( VCS_STATUS_NUM_UNSTAGED   )) && after+="%F{red}✚${VCS_STATUS_NUM_UNSTAGED}"
  # ?42 if have untracked files. It's really a question mark, your font isn't broken.
  (( VCS_STATUS_NUM_UNTRACKED  )) && after+="%F{blue}…${VCS_STATUS_NUM_UNTRACKED}"
  # *42 if have stashes.
  (( VCS_STATUS_STASHES        )) && after+="%F{yellow}*${VCS_STATUS_STASHES}"

  local sep
  [ "$after" != "" ] && sep='%f|'
  GITSTATUS_PROMPT=" (${before}${sep}${after}%f)"

  # The length of GITSTATUS_PROMPT after removing %f and %F.
  GITSTATUS_PROMPT_LEN="${(m)#${${GITSTATUS_PROMPT//\%\%/x}//\%(f|<->F)}}"
}

jobscount() {
  JOBSCOUNT="%(1j. %F{15}%K{yellow} %j %f%k.)"
}

my_prompt_precmd() {
  RETVAL="$?"
  VCS_INFO=""
  gitstatus_prompt_update
  jobscount
  my_prompt_render
}

my_prompt_render() {
  PVENV=
  result=
  if [ "$RETVAL" != "0" ] && [ -n "$RETVAL" ]; then
    result=" %K{red}%F{15} $RETVAL %k%f"
  fi
  if [ "$VIRTUAL_ENV" != "" ]; then
    PVENV="$(basename "$VIRTUAL_ENV") "
  fi
  PROMPT='%F{244}${PVENV}%f%F{cyan}%B%~%f%b$GITSTATUS_PROMPT %% '
  RPROMPT='$JOBSCOUNT$result'
}

my_prompt_render
