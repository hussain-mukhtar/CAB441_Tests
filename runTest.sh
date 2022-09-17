#!/usr/bin/env bash

#./runTest.sh  exampleTest 99 | tee test_runTest.log
#RETURNVALUE=${PIPESTATUS[0]}
#echo $RETURNVALUE

./markerlogin.sh
./markerloginsudo.sh
./aptupdate.sh
./openvpn.sh
./openvpnmarkerssh.sh
./web.sh
./snort.sh
./getfirewalls.sh