get_tool_version_if_not_default() {
  local name=$1
  local file_name=$2
  local found_dir=$PWD
  while [ "${found_dir##/${HOME[2,-1]}/}" != "${found_dir}" ]; do
    [ -f "${found_dir}/${file_name}" ] || continue
    while IFS=' ' read -r tool version extra_versions; do
      # Skip over lines containing comments.
      # (Lines starting with '#').
      [ "${tool##\#*}" ] || continue
      if [ "$tool" = "$name" ] && [ "$version" != "" ]; then
        REPLY="$version"
        return
      fi
    done < "${found_dir}/${file_name}"
    found_dir=${found_dir:a:h}
  done
  unset REPLY
}

get_node_version() {
  get_tool_version_if_not_default nodejs .tool-versions
  psvar[$1]=$REPLY
}

get_python_version() {
  if [ -n "$VIRTUAL_ENV" ]; then
    psvar[$1]=${${(ps: :)$(python --version 2>&1)}[2]}
  else
    get_tool_version_if_not_default python .tool-versions
    psvar[$1]=$REPLY
  fi
}
