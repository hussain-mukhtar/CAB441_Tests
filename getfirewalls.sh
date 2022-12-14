# To make this work properly, install the following as .ssh/config in the marker's home directory
#UserKnownHostsFile=/dev/null
#StrictHostKeyChecking=no

source library.sh

print_header "Grabbing /etc/nftables.conf from all VMs"

BASTIONIPADDRESS=10.0.0.10
ROUTERIPADDRESS=172.16.0.254
PROXYIPADDRESS=172.16.0.3
APPIPADDRESS=172.16.1.2
PORTNUM=46753
RET=0

ssh "-p ${PORTNUM}" ${BASTIONIPADDRESS} "sudo systemctl status nftables"
ssh "-p ${PORTNUM}" ${BASTIONIPADDRESS} "sudo cat /etc/nftables.conf"
RET1=$?
[[ ${RET1} -eq 0 ]] || RET=1
print_passfail3 ${RET1}

ssh "-J ${BASTIONIPADDRESS}:${PORTNUM}" ${ROUTERIPADDRESS} "sudo systemctl status nftables"
ssh "-J ${BASTIONIPADDRESS}:${PORTNUM}" ${ROUTERIPADDRESS} "sudo cat /etc/nftables.conf"
RET1=$?
[[ ${RET1} -eq 0 ]] || RET=1
print_passfail3 ${RET1}

ssh "-J ${BASTIONIPADDRESS}:${PORTNUM}" ${PROXYIPADDRESS} "sudo systemctl status nftables"
ssh "-J ${BASTIONIPADDRESS}:${PORTNUM}" ${PROXYIPADDRESS} "sudo cat /etc/nftables.conf"
RET1=$?
[[ ${RET1} -eq 0 ]] || RET=1
print_passfail3 ${RET1}

ssh "-J ${BASTIONIPADDRESS}:${PORTNUM}" ${APPIPADDRESS} "sudo systemctl status nftables"
ssh "-J ${BASTIONIPADDRESS}:${PORTNUM}" ${APPIPADDRESS} "sudo cat /etc/nftables.conf"
RET1=$?
[[ ${RET1} -eq 0 ]] || RET=1
print_passfail3 ${RET1}


print_passfail $RET
