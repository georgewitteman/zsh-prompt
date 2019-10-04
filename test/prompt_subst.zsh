TEST_COUNT=200000
STATIC_TEST_VAR=staticvar
psvar[1]=$STATIC_TEST_VAR
echo -n "prompt_subst: "
setopt prompt_subst
_TIMER=$EPOCHREALTIME
for ((i = 0; i < $TEST_COUNT; i++)); do
  TEST_VAR=testvar
  print -P '%(!.true-text.false-text)${STATIC_TEST_VAR}%(!.true-text.false-text)${STATIC_TEST_VAR}%(!.true-text.false-text)${STATIC_TEST_VAR}%(!.true-text.false-text)${STATIC_TEST_VAR}%(!.true-text.false-text)${STATIC_TEST_VAR}%(!.true-text.false-text)${TEST_VAR}%(!.true-text.false-text)${TEST_VAR}%(!.true-text.false-text)${TEST_VAR}%(!.true-text.false-text)${TEST_VAR}%(!.true-text.false-text)${TEST_VAR}%(!.true-text.false-text)${TEST_VAR}%(!.true-text.false-text)${TEST_VAR}' > /dev/null
done
now=$(($EPOCHREALTIME*1000))
_TIMER=$(($_TIMER*1000))
startup_diff=$((($now - $_TIMER) / $TEST_COUNT))
echo "${startup_diff[0,7]}ms"

echo -n "no prompt_subst: "
unsetopt prompt_subst
_TIMER=$EPOCHREALTIME
for ((i = 0; i < $TEST_COUNT; i++)); do
  psvar[2]=testvar
  print -P '%(!.true-text.false-text)%1v%(!.true-text.false-text)%1v%(!.true-text.false-text)%1v%(!.true-text.false-text)%1v%(!.true-text.false-text)%1v%(!.true-text.false-text)%2v%(!.true-text.false-text)%2v%(!.true-text.false-text)%2v%(!.true-text.false-text)%2v%(!.true-text.false-text)%2v%(!.true-text.false-text)%2v%(!.true-text.false-text)%2v' > /dev/null
done
now=$(($EPOCHREALTIME*1000))
_TIMER=$(($_TIMER*1000))
startup_diff=$((($now - $_TIMER) / $TEST_COUNT))
echo "${startup_diff[0,7]}ms"
setopt prompt_subst
