# To make this work properly, install the following as .ssh/config in the marker's home directory
#UserKnownHostsFile=/dev/null
#StrictHostKeyChecking=no

source library.sh

print_header "Testing ssh login as kali, using ProxyJump via bastion"

BASTIONIPADDRESS=10.0.0.10
ROUTERIPADDRESS=172.16.0.254
PROXYIPADDRESS=172.16.0.3
APPIPADDRESS=172.16.1.2
PORTNUM=46753
RET=0

ssh "-p ${PORTNUM}" ${BASTIONIPADDRESS} "true"
RET1=$?
[[ ${RET1} -eq 0 ]] || RET=1
print_passfail3 ${RET1}

ssh "-J ${BASTIONIPADDRESS}:${PORTNUM}" ${ROUTERIPADDRESS} "true"
RET1=$?
[[ ${RET1} -eq 0 ]] || RET=1
print_passfail3 ${RET1}

ssh "-J ${BASTIONIPADDRESS}:${PORTNUM}" ${PROXYIPADDRESS} "true"
RET1=$?
[[ ${RET1} -eq 0 ]] || RET=1
print_passfail3 ${RET1}

ssh "-J ${BASTIONIPADDRESS}:${PORTNUM}" ${APPIPADDRESS} "true"
RET1=$?
[[ ${RET1} -eq 0 ]] || RET=1
print_passfail3 ${RET1}


print_passfail $RET
