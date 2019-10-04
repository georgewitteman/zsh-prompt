get_tool_version_if_not_default() {
  local name=$1
  local file_name=$2
  local found_dir=$PWD
  while [ "${found_dir##/${HOME[2,-1]}/}" != "${found_dir}" ]; do
    if [ -f "${found_dir}/${file_name}" ]; then
      for line in "${(@f)"$(<"${found_dir}/${file_name}")"}"; do
        line_contents=(${(ps: :)line})
        if [ "${line_contents[1]}" = "$name" ] && [ "${line_contents[2]}" != "" ]; then
          REPLY="${line_contents[2]}"
          return
        fi
      done
    fi
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
