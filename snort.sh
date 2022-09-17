source library.sh

print_header "Testing ssh brute force snort alert"

IPADDRESS=10.0.0.3
ROUTERIPADDRESS=172.16.0.254
BASTIONIPADDRESS=10.0.0.10
PORTNUM=46753
RET1=0

print_header3 "Trying 3 times to ssh to ${IPADDRESS}, 5 second timeout.  This should fail."
ssh "-o ConnectTimeout=5" ${IPADDRESS} "true"
ssh "-o ConnectTimeout=5" ${IPADDRESS} "true"
ssh "-o ConnectTimeout=5" ${IPADDRESS} "true"

print_header3 "Grabbing /var/log/snort/alert.log last 10 lines"
ALERTS=$( ssh "-J ${BASTIONIPADDRESS}:${PORTNUM}" ${ROUTERIPADDRESS} "sudo tail /var/log/snort/alert.log" )
echo "${ALERTS}"
print_header3 "Looking for ssh alert"
echo -n "${ALERTS}" | grep -q -E "Potential SSH Brute Force Attack" || RET1=1

print_passfail ${RET1}
