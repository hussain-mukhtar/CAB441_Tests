print_header "OpenVPN server"

BASTIONIPADDRESS=10.0.0.10
PORTNUM=46753
OVPNDIR=$( mktemp -d )
RET=0


print_header2 "Configuration under /home/marker/vpn.conf on bastion?"
scp -P ${PORTNUM} ${BASTIONIPADDRESS}:/home/marker/vpn.conf ${OVPNDIR}/vpn.conf
RET1=$?
[[ ${RET1} -eq 0 ]] || RET=1
print_passfail3 ${RET1}


print_header2 "VPN connects?"
print_header3 "running openvpn ${OVPNDIR}/vpn.conf.  Waiting for connection... "

OVPNPIDFILE=${OVPNDIR}/pid
TUNDEV=tun${GROUPNUM}
OVPNLOGFILE=${OVPNDIR}/openvpn.log
cat ${OVPNDIR}/vpn.conf
sudo -n /usr/sbin/openvpn \
  --config ${OVPNDIR}/vpn.conf \
  --dev ${TUNDEV} \
  --connect-retry-max 1 --connect-timeout 5 \
  --writepid ${OVPNPIDFILE} \
  --daemon --log ${OVPNLOGFILE} \

RET1=$?
sleep 6
sudo cat ${OVPNLOGFILE}
read OVPNPID < ${OVPNPIDFILE}
if [[ ${OVPNPID} != "" ]] && ps -p ${OVPNPID} > /dev/null; then
  print_header3 "openvpn daemon seems to be OK"
else
  print_header3 "openvpn daemon has died"
  RET1=1
fi

[[ ${RET1} -eq 0 ]] || RET=1

print_passfail3 ${RET1}

rm -rf ${OVPNDIR}
[[ ${OVPNPID} == "" ]] || sudo kill ${OVPNPID}
print_passfail ${RET}
