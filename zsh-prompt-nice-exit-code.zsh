nice_exit_code() {
  # unset psvar[$2]
  local exitstatus="$1";
  [[ -z $exitstatus || $exitstatus == 0 ]] && return;

  [[ $exitstatus -ge 128 ]] && psvar[$2]="$signals[$exitstatus-127]" && return;

  case $exitstatus in
    -1)   psvar[$2]=FATAL && return ;;
    1)    psvar[$2]=WARN && return ;; # Miscellaneous errors, such as "divide by zero"
    2)    psvar[$2]=BUILTINMISUSE && return ;; # misuse of shell builtins (pretty rare)
    126)  psvar[$2]=CCANNOTINVOKE && return ;; # cannot invoke requested command (ex : source script_with_syntax_error)
    127)  psvar[$2]=CNOTFOUND && return ;; # command not found (ex : source script_not_existing)
    19)  psvar[$2]=STOP && return ;;
    20)  psvar[$2]=TSTP && return ;;
    21)  psvar[$2]=TTIN && return ;;
    22)  psvar[$2]=TTOU && return ;;
  esac
}
