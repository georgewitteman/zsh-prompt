parse_tool_versions() {
  name=$1
  file_name=$2
  if [ -f "$file_name" ]; then
    cat "$file_name" | grep "$name" | cut -d' ' -f2
  fi
}

recursively_find_file() {
  file_name=$1
  found_dir=$PWD
  while [ ! -e "$found_dir/$file_name" ] && [ "$found_dir" != '/' ]; do
    found_dir $(dirname "$found_dir")
  done
  echo "$found_dir/$file_name"
}

get_tool_version() {
  name=$1
  file_name=$2
  echo $(parse_tool_versions $name $(recursively_find_file $file_name))
}

get_tool_version_if_not_default() {
  name=$1
  file_name=$2
  versions_file=$(recursively_find_file $file_name)
  [ "$versions_file" != "$HOME/$file_name" ] && parse_tool_versions $name $file_name
}

get_node_version() {
  current_version=$(get_tool_version_if_not_default nodejs .tool-versions)
  [ "$current_version" != "" ] && echo "$current_version"
}

get_python_version() {
  if [ "$VIRTUAL_ENV" != "" ]; then
    python --version 2>&1 | cut -d' ' -f2
  else
    current_version=$(get_tool_version_if_not_default python .tool-versions)
    [ "$current_version" != "" ] && echo "$current_version"
  fi
}
