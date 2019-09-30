human_time() {
  local human total_seconds=$1 var=$2
  local days=$(( total_seconds / 60 / 60 / 24 ))
  local hours=$(( total_seconds / 60 / 60 % 24 ))
  local minutes=$(( total_seconds / 60 % 60 ))
  local seconds=$(( total_seconds % 60 ))
  (( days > 0 )) && human+="${days}d "
  (( hours > 0 )) && human+="${hours}h "
  (( minutes > 0 )) && human+="${minutes}m "
  human+="${seconds}s"

  echo $human
}

# Ignore commands if they start with the follow
zlong_ignore_cmds=(tmux vim ssh)

# Define what a long duration is
zlong_duration=10

# Need to set an initial timestamps otherwise, we'll be comparing an empty
# string with an integer.
zlong_timestamp=$EPOCHSECONDS

zlong_alert_pre() {
  zlong_timestamp=$EPOCHSECONDS
  zlong_last_cmd=$1
}

zlong_alert_post() {
  if [ -z "$zlong_timestamp" ]; then
    return
  fi
  LONG_COMMAND=
  local duration=$(($EPOCHSECONDS - $zlong_timestamp))
  local lasted_long=$(($duration - $zlong_duration))
  local cmd_head=$(echo $zlong_last_cmd | cut -d ' ' -f 1)
  if [ $lasted_long -gt 0 ] && [ ! -z $zlong_last_cmd ] && [ ! ${zlong_ignore_cmds[(ie)$cmd_head]} -le ${#zlong_ignore_cmds} ]; then
    LONG_COMMAND="$(human_time $duration)"
  fi
  unset zlong_timestamp
  unset zlong_last_cmd
}

add-zsh-hook preexec zlong_alert_pre
