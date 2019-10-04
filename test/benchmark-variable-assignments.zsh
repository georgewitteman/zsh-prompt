TEST_COUNT=200000
echo -n "Testing lots of short variable assignments (BLAH='1' over and over again): "
_TIMER=$EPOCHREALTIME
for ((i = 0; i < $TEST_COUNT; i++)); do
  BLAH=''
  BLAH='1'
  BLAH='2'
  BLAH='3'
  BLAH='4'
  BLAH='5'
  BLAH='6'
  BLAH='7'
  BLAH='8'
  BLAH='9'
  BLAH='0' #10
  BLAH='1'
  BLAH='2'
  BLAH='3'
  BLAH='4'
  BLAH='5'
  BLAH='6'
  BLAH='7'
  BLAH='8'
  BLAH='9'
  BLAH='0' #20
  BLAH='1'
  BLAH='2'
  BLAH='3'
  BLAH='4'
  BLAH='5'
  BLAH='6'
  BLAH='7'
  BLAH='8'
  BLAH='9'
  BLAH='0' #30
  BLAH='1'
  BLAH='2'
  BLAH='3'
  BLAH='4'
  BLAH='5'
  BLAH='6'
  BLAH='7'
  BLAH='8'
  BLAH='9'
  BLAH='0' #40
  BLAH='1'
  BLAH='2'
  BLAH='3'
  BLAH='4'
  BLAH='5'
  BLAH='6'
  BLAH='7'
  BLAH='8'
  BLAH='9'
  BLAH='0' #50
  BLAH='1'
  BLAH='2'
  BLAH='3'
  BLAH='4'
  BLAH='5'
  BLAH='6'
  BLAH='7'
  BLAH='8'
  BLAH='9'
  BLAH='0' #60
  BLAH='1'
  BLAH='2'
  BLAH='3'
  BLAH='4'
  BLAH='5'
  BLAH='6'
  BLAH='7'
  BLAH='8'
  BLAH='9'
  BLAH='0' #70
  BLAH='1'
  BLAH='2'
  BLAH='3'
  BLAH='4'
  BLAH='5'
  BLAH='6'
  BLAH='7'
  BLAH='8'
  BLAH='9'
  BLAH='0' #80
  BLAH='1'
  BLAH='2'
  BLAH='3'
  BLAH='4'
  BLAH='5'
  BLAH='6'
  BLAH='7'
  BLAH='8'
  BLAH='9'
  BLAH='0' #90
  BLAH='1'
  BLAH='2'
  BLAH='3'
  BLAH='4'
  BLAH='5'
  BLAH='6'
  BLAH='7'
  BLAH='8'
  BLAH='9'
  BLAH='0' #100
  BLAH='1'
  BLAH='2'
  BLAH='3'
  BLAH='4'
  BLAH='5'
  BLAH='6'
  BLAH='7'
  BLAH='8'
  BLAH='9'
  BLAH='0' #110
  BLAH='1'
  BLAH='2'
  BLAH='3'
  BLAH='4'
  BLAH='5'
  BLAH='6'
  BLAH='7'
  BLAH='8'
  BLAH='9'
  BLAH='0' #120
done
now=$(($EPOCHREALTIME*1000))
_TIMER=$(($_TIMER*1000))
startup_diff=$((($now - $_TIMER) / $TEST_COUNT))
echo "${startup_diff[0,7]}ms"

echo -n "Testing a few medium length assignments (BLAH='1234567890'): "
_TIMER=$EPOCHREALTIME
for ((i = 0; i < $TEST_COUNT; i++)); do
  BLAH=''
  BLAH='1234567890'
  BLAH='1234567890'
  BLAH='1234567890'
  BLAH='1234567890'
  BLAH='1234567890'
  BLAH='1234567890'
  BLAH='1234567890'
  BLAH='1234567890'
  BLAH='1234567890'
  BLAH='1234567890'
  BLAH='1234567890'
  BLAH='1234567890'
done
now=$(($EPOCHREALTIME*1000))
_TIMER=$(($_TIMER*1000))
startup_diff=$((($now - $_TIMER) / $TEST_COUNT))
echo "${startup_diff[0,7]}ms"

echo -n "Testing one long variable assignment: "
_TIMER=$EPOCHREALTIME
for ((i = 0; i < $TEST_COUNT; i++)); do
  BLAH=''
  BLAH='123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890'
done
now=$(($EPOCHREALTIME*1000))
_TIMER=$(($_TIMER*1000))
startup_diff=$((($now - $_TIMER) / $TEST_COUNT))
echo "${startup_diff[0,7]}ms"

echo -n "Testing one 10x longer variable assignment: "
_TIMER=$EPOCHREALTIME
for ((i = 0; i < $TEST_COUNT; i++)); do
  BLAH=''
  BLAH='123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890'
done
now=$(($EPOCHREALTIME*1000))
_TIMER=$(($_TIMER*1000))
startup_diff=$((($now - $_TIMER) / $TEST_COUNT))
echo "${startup_diff[0,7]}ms"
