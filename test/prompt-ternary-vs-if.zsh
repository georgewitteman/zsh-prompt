zmodload zsh/datetime
TEST_COUNT=300000
echo -n "print -P : "
_TIMER=$EPOCHREALTIME
for ((i = 0; i < $TEST_COUNT; i++)); do
  print -P "%(!.true-text.false-text)" > /dev/null
done
now=$(($EPOCHREALTIME*1000))
_TIMER=$(($_TIMER*1000))
startup_diff=$((($now - $_TIMER) / $TEST_COUNT))
echo "${startup_diff[0,7]}ms"

echo -n "if : "
_TIMER=$EPOCHREALTIME
for ((i = 0; i < $TEST_COUNT; i++)); do
  if [[ $UID == 0 ]]; then
    print "true-text" > /dev/null
  else
    print "false-text" > /dev/null
  fi
done
now=$(($EPOCHREALTIME*1000))
_TIMER=$(($_TIMER*1000))
startup_diff=$((($now - $_TIMER) / $TEST_COUNT))
echo "${startup_diff[0,7]}ms"
