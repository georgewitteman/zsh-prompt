# define zle-line-init function
my-zle-line-init () {
 # print time since start was set after prompt
  local now=$(($EPOCHREALTIME*1000))
  prompt_start_render=$(($prompt_start_render*1000))
  prompt_start_precmd=$(($prompt_start_precmd*1000))
  PREDISPLAY="[render: ${(r:7::0::0:)$(( $now - $prompt_start_render ))[0,7]}ms; "
  PREDISPLAY+="precmd: ${(r:7::0::0:)$(( $prompt_start_render - $prompt_start_precmd ))[0,7]}ms; "
  PREDISPLAY+="total: ${(r:7::0::0:)$(( $now - $prompt_start_precmd ))[0,7]}ms] "
}
# link the zle-line-init widget to the function of the same name
zle -N zle-line-init my-zle-line-init
