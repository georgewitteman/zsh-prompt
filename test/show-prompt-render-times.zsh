# define zle-line-init function
my-zle-line-init () {
 # print time since start was set after prompt
  local now=$(($EPOCHREALTIME*1000000))
  now=$now[0,-5]
  PREDISPLAY="[render: $(( $now - $prompt_start_render ))ms; precmd: $(( $prompt_start_render - $prompt_start_precmd ))ms; total: $(( $now - $prompt_start_precmd ))ms] "
}
# link the zle-line-init widget to the function of the same name
zle -N zle-line-init my-zle-line-init
