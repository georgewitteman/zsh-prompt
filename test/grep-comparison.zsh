TEST_COUNT=750
TESTFILE="${0:a:h}/testfile.txt"
echo -n 'cat $TESTFILE | grep searchstring: '
_TIMER=$EPOCHREALTIME
for ((i = 0; i < $TEST_COUNT; i++)); do
  MYVAR=$(cat $TESTFILE | grep searchstring)
done
now=$(($EPOCHREALTIME*1000))
_TIMER=$(($_TIMER*1000))
startup_diff=$((($now - $_TIMER) / $TEST_COUNT))
echo "${startup_diff[0,7]}ms"

echo -n 'grep searchstring $TESTFILE: '
_TIMER=$EPOCHREALTIME
for ((i = 0; i < $TEST_COUNT; i++)); do
  MYVAR=$(grep searchstring $TESTFILE)
done
now=$(($EPOCHREALTIME*1000))
_TIMER=$(($_TIMER*1000))
startup_diff=$((($now - $_TIMER) / $TEST_COUNT))
echo "${startup_diff[0,7]}ms"

echo -n 'fgrep searchstring $TESTFILE: '
_TIMER=$EPOCHREALTIME
for ((i = 0; i < $TEST_COUNT; i++)); do
  MYVAR=$(fgrep searchstring $TESTFILE)
done
now=$(($EPOCHREALTIME*1000))
_TIMER=$(($_TIMER*1000))
startup_diff=$((($now - $_TIMER) / $TEST_COUNT))
echo "${startup_diff[0,7]}ms"
