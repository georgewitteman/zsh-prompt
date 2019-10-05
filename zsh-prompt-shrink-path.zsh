shrink_path () {
  setopt localoptions
  setopt rc_quotes null_glob

  typeset -a tree expn
  typeset result part dir=${PWD/#$HOME/\~}
  typeset -i i

  tree=(${(s:/:)dir})
  if [[ $tree[1] == \~* ]] {
    result=$tree[1]
    full_dir=$HOME
    shift tree
  } else {
    full_dir=/
  }
  for dir in $tree; {
    if (( $#tree == 1 )) {
      result+="/$tree"
      break
    }
    expn=(a b)
    part=""
    i=0
    until [[ (( ${#expn} == 1 )) || $dir = $expn || $i -gt 99 ]] do
      (( i++ ))
      part+=$dir[$i]
      expn=(${full_dir}/${part}*(-/))
    done
    result+="/$part"
    full_dir+="/$dir"
    shift tree
  }
  psvar[$1]=${result:-/}
}
