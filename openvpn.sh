# marker sudo test

source library.sh

print_header "Testing OpenVPN server Connection"

BASTIONIPADDRESS=10.0.0.10
PORTNUM=46753
OVPNDIR=$( mktemp -d )
RET=0


print_header2 "Configuration under /home/kali/vpn.conf on bastion?"
scp -P ${PORTNUM} ${BASTIONIPADDRESS}:/home/kali/vpn.conf ${OVPNDIR}/vpn.conf
RET1=$?
[[ ${RET1} -eq 0 ]] || RET=1
print_passfail3 ${RET1}


print_header2 "VPN connects?"
print_header3 "running openvpn ${OVPNDIR}/vpn.conf.  Waiting for connection... "

OVPNPIDFILE=${OVPNDIR}/pid
TUNDEV=tun0
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
