TEST_COUNT=300000
echo -n "print -P : "
_TIMER=$(($EPOCHREALTIME*1000000))
for ((i = 0; i < $TEST_COUNT; i++)); do
  print -P "%(!.true-text.false-text)" > /dev/null
done
now=$(($EPOCHREALTIME*1000000))
now=$now[0,-2]
_TIMER=$_TIMER[0,-2]
startup_diff=$((($now - $_TIMER) / $TEST_COUNT))
echo "${startup_diff}ns"

echo -n "if : "
_TIMER=$(($EPOCHREALTIME*1000000))
for ((i = 0; i < $TEST_COUNT; i++)); do
  if [[ $UID == 0 ]]; then
    print "true-text" > /dev/null
  else
    print "false-text" > /dev/null
  fi
done
now=$(($EPOCHREALTIME*1000000))
now=$now[0,-2]
_TIMER=$_TIMER[0,-2]
startup_diff=$((($now - $_TIMER) / $TEST_COUNT))
echo "${startup_diff}ns"

