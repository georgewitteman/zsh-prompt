# TODO: Fix this because right now it only looks for the first
# .tool-versions file but the first file might not be the one
# that has the version for what we're looking for
parse_tool_versions() {
  unset retval
  local name=$1
  local file_name=$2
  if [ -f "$file_name" ]; then
    for line in "${(@f)"$(<"$file_name")"}"; do
      line_contents=(${(ps: :)line})
      if [ "${line_contents[1]}" = "$name" ] && [ "${line_contents[2]}" != "" ]; then
        retval="${line_contents[2]}"
        return 0
      fi
    done
  fi
  return 1
}

recursively_find_file() {
  unset retval
  local file_name=$1
  local name=$2
  local found_dir=$PWD
  while ! parse_tool_versions "$name" "$found_dir/$file_name" && \
    [ "${PWD##/${HOME[2,-1]}/}" != "${PWD}" ]; do
    found_dir=${found_dir:a:h}
  done
  retval="$found_dir/$file_name"
}

get_tool_version_if_not_default() {
  unset retval
  local name=$1
  local file_name=$2
  recursively_find_file "$file_name" $name
  # echo a
  local versions_file=$retval
  unset retval
  # versions_file=$(recursively_find_file $file_name)
  # echo end of get version $name $versions_file
  [ "$versions_file" != "$HOME/$file_name" ] && parse_tool_versions $name $versions_file
  # echo b
}

get_node_version() {
  unset retval
  get_tool_version_if_not_default nodejs .tool-versions
  psvar[$1]=$retval
  # current_version=$retval
  # current_version=$(get_tool_version_if_not_default nodejs .tool-versions)
  # [ "$current_version" != "" ] && echo "$current_version"
}

get_python_version() {
  unset retval
  if [ "$VIRTUAL_ENV" != "" ]; then
    psvar[$1]=${${(ps: :)$(python --version 2>&1)}[2]}
  else
    get_tool_version_if_not_default python .tool-versions
    psvar[$1]=$retval
    # current_version=$retval
    # current_version=$(get_tool_version_if_not_default python .tool-versions)
    # [ "$current_version" != "" ] && retval="$current_version"
  fi
}
