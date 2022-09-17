# To make this work properly, install the following as .ssh/config in the marker's home directory
#UserKnownHostsFile=/dev/null
#StrictHostKeyChecking=no

print_header "Testing ssh login as kalu, using ProxyJump via bastion, with sudo"

BASTIONIPADDRESS=10.0.0.10
ROUTERIPADDRESS=172.16.0.254
PROXYIPADDRESS=172.16.0.3
APPIPADDRESS=172.16.1.2
PORTNUM=46753
RET=0

host_run_command_opts "-p ${PORTNUM}" ${BASTIONIPADDRESS} "sudo true"
RET1=$?
[[ ${RET1} -eq 0 ]] || RET=1
print_passfail3 ${RET1}

host_run_command_opts "-J ${BASTIONIPADDRESS}:${PORTNUM}" ${ROUTERIPADDRESS} "sudo true"
RET1=$?
[[ ${RET1} -eq 0 ]] || RET=1
print_passfail3 ${RET1}

host_run_command_opts "-J ${BASTIONIPADDRESS}:${PORTNUM}" ${PROXYIPADDRESS} "sudo true"
RET1=$?
[[ ${RET1} -eq 0 ]] || RET=1
print_passfail3 ${RET1}

host_run_command_opts "-J ${BASTIONIPADDRESS}:${PORTNUM}" ${APPIPADDRESS} "sudo true"
RET1=$?
[[ ${RET1} -eq 0 ]] || RET=1
print_passfail3 ${RET1}


print_passfail $RET
