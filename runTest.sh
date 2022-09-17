#!/usr/bin/env bash

TESTTORUN=$1
GROUPNUM=$2

#MARKERIP="10.255.2.$GROUPNUM"
MARKERIP="localhost"

TEST_LIBDIR="lib"
TEST_DIR="."

#RUNCMD="bash"
#RUNCMD="cat"
RUNCMD="ssh $MARKERIP bash"

#here we cat together all commands that we want to run so that we can pipe them through a single ssh session
echo "GROUPNUM=$GROUPNUM" |
cat - $TEST_LIBDIR/* $TEST_DIR/$TESTTORUN |
$RUNCMD 2>&1
#At this point, the return value of the stuff piped into ssh will be returned
