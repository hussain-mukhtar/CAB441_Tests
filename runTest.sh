#!/usr/bin/env bash

#./runTest.sh  exampleTest 99 | tee test_runTest.log
#RETURNVALUE=${PIPESTATUS[0]}
#echo $RETURNVALUE

sha1sum markerlogin.sh
./markerlogin.sh
sha1sum markerloginsudo.sh
./markerloginsudo.sh
sha1sum aptupdate.sh
./aptupdate.sh
sha1sum openvpnmarkerssh.sh
./openvpnmarkerssh.sh
sha1sum web.sh
./web.sh
sha1sum snort.sh
./snort.sh
sha1sum getfirewalls.sh
./getfirewalls.sh