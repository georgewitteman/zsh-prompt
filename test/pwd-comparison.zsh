TEST_COUNT=2500
CMD_COLS=13
printf "%${CMD_COLS}.${CMD_COLS}s: " '_TST=$(pwd)'
_TIMER=$EPOCHREALTIME
for ((i = 0; i < $TEST_COUNT; i++)); do
  _TST=$(pwd)
done
startup_diff=$(((($EPOCHREALTIME * 1000) - ($_TIMER * 1000)) / $TEST_COUNT))
echo "${startup_diff[0,7]}ms"

printf "%${CMD_COLS}.${CMD_COLS}s: " '_TST="$(pwd)"'
_TIMER=$EPOCHREALTIME
for ((i = 0; i < $TEST_COUNT; i++)); do
  _TST="$(pwd)"
done
startup_diff=$(((($EPOCHREALTIME * 1000) - ($_TIMER * 1000)) / $TEST_COUNT))
echo "${startup_diff[0,7]}ms"

printf "%${CMD_COLS}.${CMD_COLS}s: " '(pwd)'
_TIMER=$EPOCHREALTIME
(for ((i = 0; i < $TEST_COUNT; i++)); do
  (pwd)
done) > /dev/null
startup_diff=$(((($EPOCHREALTIME * 1000) - ($_TIMER * 1000)) / $TEST_COUNT))
echo "${startup_diff[0,7]}ms"

mypwd() { echo $PWD }
printf "%${CMD_COLS}.${CMD_COLS}s: " 'mypwd'
_TIMER=$EPOCHREALTIME
(for ((i = 0; i < $TEST_COUNT; i++)); do
  mypwd
done) > /dev/null
startup_diff=$(((($EPOCHREALTIME * 1000) - ($_TIMER * 1000)) / $TEST_COUNT))
echo "${startup_diff[0,7]}ms"

printf "%${CMD_COLS}.${CMD_COLS}s: " 'pwd'
_TIMER=$EPOCHREALTIME
(for ((i = 0; i < $TEST_COUNT; i++)); do
  pwd
done) > /dev/null
startup_diff=$(((($EPOCHREALTIME * 1000) - ($_TIMER * 1000)) / $TEST_COUNT))
echo "${startup_diff[0,7]}ms"

printf "%${CMD_COLS}.${CMD_COLS}s: " '_TST=$PWD'
_TIMER=$EPOCHREALTIME
for ((i = 0; i < $TEST_COUNT; i++)); do
  _TST=$PWD
done
startup_diff=$(((($EPOCHREALTIME * 1000) - ($_TIMER * 1000)) / $TEST_COUNT))
echo "${startup_diff[0,7]}ms"

printf "%${CMD_COLS}.${CMD_COLS}s: " '_TST="$PWD"'
_TIMER=$EPOCHREALTIME
for ((i = 0; i < $TEST_COUNT; i++)); do
  _TST="$PWD"
done
startup_diff=$(((($EPOCHREALTIME * 1000) - ($_TIMER * 1000)) / $TEST_COUNT))
echo "${startup_diff[0,7]}ms"
