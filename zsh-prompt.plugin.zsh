## Left prompt
PS1=

# Short path if available
PS1+="%F{cyan}%~ %f%b"

# Background jobs
PS1+="%(1j.%F{yellow}%j:bg%f .)"

# Subshell warning
PS1+="%("
if [[ -n "$TMUX" ]]; then
  # If we're in tmux then we're already in a subshell but it's ok
  PS1+="3"
else
  PS1+="2"
fi
PS1+="L.%F{yellow}%L+%f .)"

# Prompt character
PS1+="%(0?..%F{red})%#%f "


## Continuation prompt
PS2='%F{242}%_… %f>%f '


# Execution trace prompt (set -x)
PS4="%B%D{%H:%M:%S.%9.} +%N:%i>%b "


## Right prompt
RPS1=

# Exit code
RPS1+='%(0?.. %K{red}%F{15} %? %k%f)'

# Time
RPS1+=" %D{%L:%M %p}"

# Don't add the random extra space at the end of the right prompt
# https://superuser.com/a/726509
# Turned this off because it messes up the space after the prompt
# character when not in tmux.
# Turned this back on because it doesn't seem to be an issue now.
ZLE_RPROMPT_INDENT=0
