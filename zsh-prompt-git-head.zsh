prompt_git_head() {
  psvar[$1]=''
  local head
  local git_root=$PWD
  until [ -d "${git_root}/.git" ] || [ "$git_root" = "/" ]; do
    git_root=${git_root:a:h}
  done
  git_root="${git_root}/.git"
  [ -f "${git_root}/HEAD" ] || return 1
  head=$(<"${git_root}/HEAD")
  if [[ $head == 'ref: '* ]]; then
    psvar[$1]=${head##ref: refs\/heads\/}
  else
    psvar[$1]=${head:0:10}
  fi
}
