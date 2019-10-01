parse_tool_versions() {
  name=$1
  file_name=$2
  if [ -f "$file_name" ]; then
    retval=${${(ps: :)$(fgrep "$name" "$file_name")}[2]}
  fi
}

recursively_find_file() {
  file_name=$1
  found_dir=$PWD
  while [ ! -e "$found_dir/$file_name" ] && [ "$found_dir" != '/' ]; do
    found_dir=${found_dir:a:h}
  done
  retval="$found_dir/$file_name"
}

get_tool_version() {
  name=$1
  file_name=$2
  recursively_find_file "$file_name"
  versions_file=$retval
  parse_tool_versions "$name" "$versions_file"
  # echo $(parse_tool_versions $name $(recursively_find_file $file_name))
}

get_tool_version_if_not_default() {
  return
  unset retval
  name=$1
  file_name=$2
  recursively_find_file "$file_name"
  versions_file=$retval
  # versions_file=$(recursively_find_file $file_name)
  [ "$versions_file" != "$HOME/$file_name" ] && parse_tool_versions $name $versions_file
}

get_node_version() {
  unset retval
  get_tool_version_if_not_default nodejs .tool-versions
  # current_version=$retval
  # current_version=$(get_tool_version_if_not_default nodejs .tool-versions)
  # [ "$current_version" != "" ] && echo "$current_version"
}

get_python_version() {
  unset retval
  if [ "$VIRTUAL_ENV" != "" ]; then
    retval=${${(ps: :)$(python --version 2>&1)}[2]}
  else
    get_tool_version_if_not_default python .tool-versions
    # current_version=$retval
    # current_version=$(get_tool_version_if_not_default python .tool-versions)
    # [ "$current_version" != "" ] && retval="$current_version"
  fi
}
