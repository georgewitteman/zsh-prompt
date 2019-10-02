nice_exit_code() {
  unset RETVAL
  local exit_status="$1";
  [[ -z $exit_status || $exit_status == 0 ]] && return;

  case $exit_status in
    129)  RETVAL=HUP && return ;;
    130)  RETVAL=INT && return ;;
    131)  RETVAL=QUIT && return ;;
    132)  RETVAL=ILL && return ;;
    134)  RETVAL=ABRT && return ;;
    136)  RETVAL=FPE && return ;;
    137)  RETVAL=KILL && return ;;
    139)  RETVAL=SEGV && return ;;
    141)  RETVAL=PIPE && return ;;
    143)  RETVAL=TERM && return ;;
    -1)   RETVAL=FATAL && return ;;
    1)    RETVAL=WARN && return ;; # Miscellaneous errors, such as "divide by zero"
    2)    RETVAL=BUILTINMISUSE && return ;; # misuse of shell builtins (pretty rare)
    126)  RETVAL=CCANNOTINVOKE && return ;; # cannot invoke requested command (ex : source script_with_syntax_error)
    127)  RETVAL=CNOTFOUND && return ;; # command not found (ex : source script_not_existing)
    19)  RETVAL=STOP && return ;;
    20)  RETVAL=TSTP && return ;;
    21)  RETVAL=TTIN && return ;;
    22)  RETVAL=TTOU && return ;;
  esac
}
