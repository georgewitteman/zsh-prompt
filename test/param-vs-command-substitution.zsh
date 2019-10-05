TEST_COUNT=1000
echo -n "command substitution twice: "
_TIMER=$EPOCHREALTIME
for ((i = 0; i < $TEST_COUNT; i++)); do
  VAR=$(dirname $(pwd))
done
now=$(($EPOCHREALTIME*1000))
_TIMER=$(($_TIMER*1000))
startup_diff=$((($now - $_TIMER) / $TEST_COUNT))
echo "${startup_diff[0,7]}ms"

echo -n "command substitution: "
_TIMER=$EPOCHREALTIME
for ((i = 0; i < $TEST_COUNT; i++)); do
  VAR=$(dirname $PWD)
done
now=$(($EPOCHREALTIME*1000))
_TIMER=$(($_TIMER*1000))
startup_diff=$((($now - $_TIMER) / $TEST_COUNT))
echo "${startup_diff[0,7]}ms"

echo -n "parameter expansion: "
_TIMER=$EPOCHREALTIME
for ((i = 0; i < $TEST_COUNT; i++)); do
  VAR=${PWD:h}
done
now=$(($EPOCHREALTIME*1000))
_TIMER=$(($_TIMER*1000))
startup_diff=$((($now - $_TIMER) / $TEST_COUNT))
echo "${startup_diff[0,7]}ms"
