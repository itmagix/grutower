#!/bin/bash
CLUSTER="gru minion1 minion2 minion3 minion4 minion5"
for i in $CLUSTER ; do ssh $i init 0 ; done
