# define zle-line-init function
my-zle-line-init () {
 # print time since start was set after prompt
  local now=$(($EPOCHREALTIME*1000000))
  now=$now[0,-2]
  PREDISPLAY="[render: $(( $now - $prompt_start_render ))ns; precmd: $(( $prompt_start_render - $prompt_start_precmd ))ns; total: $(( $now - $prompt_start_precmd ))ns] "
}
# link the zle-line-init widget to the function of the same name
zle -N zle-line-init my-zle-line-init
