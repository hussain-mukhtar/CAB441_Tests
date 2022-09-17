source library.sh

print_header "Web server over https"
IPADDRESS=10.0.0.30
WGETCMD="wget --timeout=3 --tries=3 --no-check-certificate -O - "
${WGETCMD} "https://${IPADDRESS}" > /dev/null
RET=$?

print_passfail ${RET}
