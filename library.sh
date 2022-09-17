# All variables in this file start with LIB to avoid clobbering variables from the test scripts

#Important! When using ssh, need redirect input from /dev/null or it will grab the rest of the script and it will stop!
LIBSSHCMD="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o connectTimeout=5"


echoE() {
   echo "$1" 1>&2
}

print_header() {
   echoE "-------------------------------------------------------------------------------"
   echoE "---- $1"
   echoE "-------------------------------------------------------------------------------"
}

print_header2() {
   echoE "----------------------------------------------------"
   echoE "---- $1"
   echoE "----------------------------------------------------"
}

print_header3() {
   echoE "----"
   echoE "---- $1"
   echoE "----"
}

print_passfail() {
   if [[ $1 == 0 ]]
   then
      print_header2 "PASSED"
   else
      print_header2 "FAILED"
   fi
   return $1
}

print_passfail3() {
   if [[ $1 == 0 ]]
   then
      print_header3 "subtest PASSED"
   else
      print_header3 "subtest FAILED"
   fi
   return $1
}

#this is here because we are just piping commands into ssh, not actually running
#a script, so we can't return from inside the test scripts.  But we can from here
return_value() {
   return $1
}


host_basics() {
   LIBIPADDRESS=$1

   #ping_test ${LIBIPADDRESS}
   #[[ $? -eq 0 ]] || return 1

   test_host_ssh ${LIBIPADDRESS}
   [[ $? -eq 0 ]] || return 2

   test_host_ssh_sudo ${LIBIPADDRESS}
   [[ $? -eq 0 ]] || return 3

   print_header3 "Trying apt update"
   LIBDETAILS=$( host_run_command_sudo ${LIBIPADDRESS} "apt update" )
   LIBRET=$?
   echo "${LIBDETAILS}"
   if [[ ${LIBRET} -ne 0 ]]; then
     print_header3 "Apt update unsuccessful"
     print_passfail3 1
     return 4
   else
     echo -n "${LIBDETAILS}"  | grep -E "^W: |^Err:|^E: " > /dev/null
     if [[ $? -eq 0 ]]; then
       print_header3 "Warnings or errors found"
       print_passfail3 1
       return 5
     else
       print_header3 "Apt update successful"
     fi
   fi

   print_passfail3 0
   return 0
}



host_run_command_opts() {
   LIBSSHOPTS=$1
   LIBIPADDRESS=$2
   LIBCOMMAND=$3
   print_header3 "Running \"$LIBCOMMAND\" on $LIBIPADDRESS"
   $LIBSSHCMD ${LIBSSHOPTS} ${LIBIPADDRESS} "timeout 60 ${LIBCOMMAND}" < /dev/null 2>&1
}

host_run_command() {
  host_run_command_opts " " $1 $2
}

host_run_command_sudo() {
   LIBIPADDRESS=$1
   LIBCOMMAND=$2
   print_header3 "Running $LIBCOMMAND on $LIBIPADDRESS with sudo"
   $LIBSSHCMD $LIBIPADDRESS "timeout 60 sudo $LIBCOMMAND" < /dev/null 2>&1
}

ping_test() {
  LIBIPADDRESS=$1
  print_header3 "Trying to ping ${LIBIPADDRESS} from WAN"
  ping -W 1 -c 3 ${LIBIPADDRESS}
  LIBRET=$?
  print_passfail3 ${LIBRET}
  return ${LIBRET}
}

ping_from() {
  LIBIPADDRESS=$2
  LIBSOURCE=$1
  print_header3 "Trying to ping ${LIBIPADDRESS} from ${LIBSOURCE}"
  host_run_command_sudo ${LIBSOURCE} "ping -W 1 -c 3 ${LIBIPADDRESS}"
  LIBRET=$?
  print_passfail3 ${LIBRET}
  return ${LIBRET}
}

test_host_ssh() {
  LIBIPADDRESS=$1
  print_header3 "Trying to ssh to ${LIBIPADDRESS} as marker"
  host_run_command ${LIBIPADDRESS} "true"
  LIBRET=$?
  print_passfail3 ${LIBRET}
}

test_host_ssh_sudo() {
  LIBIPADDRESS=$1
  print_header3 "Trying to ssh to ${LIBIPADDRESS} as marker with sudo"
  host_run_command_sudo ${LIBIPADDRESS} "true"
  LIBRET=$?
  print_passfail3 ${LIBRET}
}

detect_bgp_route() {
  LIBSUBNET=$1
  print_header3 "Detecting route to ${LIBSUBNET} on ISP router"
  host_run_command_sudo 10.0.0.254 "vtysh -c 'show ip bgp'" | grep ${LIBSUBNET}
  LIBPIPERET=("${PIPESTATUS[@]}")

  LIBRET=0
  if [[ ${LIBPIPERET[0]} -ne 0 ]]
  then
    print_header3 "Problem with SSH."
    LIBRET=1
  elif [[ ${LIBPIPERET[1]} -eq 0 ]]
  then
     print_header3 "Found route to ${SUBNET} on ISP router."
  else
     print_header3 "Route to ${SUBNET} missing from ISP router."
     LIBRET=1
  fi
  print_passfail3 ${LIBRET}
  return ${LIBRET}
}


check_hostname() {
  LIBHOSTNAME=$1
  LIBIPADDRESS=$2
  LIBDNSTYPE=$3
  if [[ ${LIBDNSTYPE} == "" ]]; then
    LIBDNSTYPE="A"
  fi

  print_header3 "Looking for ${LIBHOSTNAME} DNS ${LIBDNSTYPE} entry, should be ${LIBIPADDRESS}"
  LIBDETAILS=$( host -t ${LIBDNSTYPE} ${LIBHOSTNAME} )
  echo
  echo "${LIBDETAILS}"
  LIBRET1=$?
  if [[ ${LIBRET1} -eq 0 ]]; then
    echo -n "${LIBDETAILS}" | grep ${LIBIPADDRESS} > /dev/null
    if [[ $? -eq 0 ]]; then
      print_header3 "Found correct DNS entry"
      LIBRET=0
    else
      print_header3 "Found incorrect DNS entry"
      LIBRET=1
    fi
  else
    print_header3 "Didn't find hostname"
    LIBRET=1
  fi
  print_passfail3 ${LIBRET}
}

check_hostname_from() {
  LIBREMOTE=$1
  LIBHOSTNAME=$2
  LIBIPADDRESS=$3
  print_header3 "Looking from ${LIBREMOTE} for ${LIBHOSTNAME} DNS entry, should be ${LIBIPADDRESS}"
  LIBDETAILS=$( host_run_command ${LIBREMOTE} "host ${LIBHOSTNAME}" )
  LIBRET1=$?
  echo "${LIBDETAILS}"
  if [[ ${LIBRET1} -eq 0 ]]; then
    echo -n "${LIBDETAILS}" | grep ${LIBIPADDRESS} > /dev/null
    if [[ $? -eq 0 ]]; then
      print_header3 "Found correct DNS entry"
      LIBRET=0
    else
      print_header3 "Found incorrect DNS entry"
      LIBRET=1
    fi
  else
    print_header3 "DNS lookup failed"
    LIBRET=1
  fi
  print_passfail3 ${LIBRET}
}

check_port_blocked() {
  LIBIPADDRESS=$1
  LIBPORT=$2

  LIBRET=0
  LIBSSHERRORFILE=$( mktemp )

  print_header3 "Checking whether port ${LIBPORT} is blocked to ${LIBIPADDRESS} from the WAN"
  print_header3 "Listening on port ${LIBPORT} on ${LIBIPADDRESS}"
  {
    timeout 7 \
      ${LIBSSHCMD} -o ConnectTimeout=4 ${LIBIPADDRESS} \
      "echo 'Connected' |  sudo timeout 7 nc -n -v -l -p ${LIBPORT}"
    echo "$?" > $LIBSSHERRORFILE
  }  < /dev/null &
  sleep 5

  LIBSSHRET=$(cat ${LIBSSHERRORFILE})
  rm ${LIBSSHERRORFILE}

  if [[ ${LIBSSHRET} -eq "" ]]; then
    print_header3 "Trying to connect to ${LIBIPADDRESS}"
    nc -n -v -w 1 ${LIBIPADDRESS} ${LIBPORT} < /dev/null
    LIBCLIENTRET=$?
    if [[ ${LIBCLIENTRET} -eq 0 ]]; then
      LIBRET=1
      print_header3 "Connection succeeded, but it should have been blocked"
    else
      print_header3 "Could not connect to port."
    fi

  else
    LIBRET=1
    print_header3 "Problem with server subprocess: ${LIBSSHRET}"
  fi
  print_passfail3 ${LIBRET}
}
