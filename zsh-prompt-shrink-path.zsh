# Shrink directory paths, e.g. /home/me/foo/bar/quux -> ~/f/b/quux.
#
# For a fish-style working directory in your command prompt, add the following
# to your theme or zshrc:
#
# setopt prompt_subst
# PS1='%n@%m $(shrink_path -f)>'
#
# The following options are available:
#
# -f, --fish  fish simulation, equivalent to -l -s -t.
# -l, --last  Print the last directory's full name.
# -s, --short  Truncate directory names to the first character. Without
#     -s, names are truncated without making them ambiguous.
# -t, --tilde  Substitute ~ for the home directory.
# -T, --nameddirs Substitute named directories as well.
#
# The long options can also be set via zstyle, like
# zstyle :prompt:shrink_path fish yes
#
# Note: Directory names containing two or more consecutive spaces are not yet
# supported.
#
# Keywords: prompt directory truncate shrink collapse fish
#
# Copyright (C) 2008 by Daniel Friesel <derf@xxxxxxxxxxxxxxxxxx>
# License: WTFPL <http://www.wtfpl.net>
#
# Ref: https://www.zsh.org/mla/workers/2009/msg00415.html
#  https://www.zsh.org/mla/workers/2009/msg00419.html

shrink_path () {
  setopt localoptions
  setopt rc_quotes null_glob

  typeset -i lastfull=1
  typeset -i short=0
  typeset -i tilde=1
  typeset -i named=0

  typeset -a tree expn
  typeset result part dir=$PWD
  typeset -i i

  [[ -d $dir ]] || return 0

  (( tilde )) && dir=${dir/#$HOME/\~}
  tree=(${(s:/:)dir})
  if [[ $tree[1] == \~* ]] {
    result=$tree[1]
    full_dir=$HOME
    shift tree
  } else {
    full_dir=/
  }
  for dir in $tree; {
    if (( lastfull && $#tree == 1 )) {
      result+="/$tree"
      break
    }
    expn=(a b)
    part="${dir[1]}"
    i=1
    until [[ (( ${#expn} == 1 )) || $dir = $expn || $i -gt 99 ]] do
      (( i++ ))
      part+=$dir[$i]
      expn=(${full_dir}/${part}*(-/))
      # (( short )) && break
    done
    result+="/$part"
    full_dir+="/$dir"
    shift tree
  }
  psvar[$1]=${result:-/}
}

## vim:ft=zsh
