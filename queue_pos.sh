#!/bin/bash

ZNLISTCMD_TMP="`zelcash-cli listzelnodes 2>/dev/null`"
ZNLISTCMD=`echo "$ZNLISTCMD_TMP" | jq -r '[.[] |select(.tier=="BAMF") |{(.txhash):(.status+" "+(.version|tostring)+" "+.addr+" "+(.lastseen|tostring)+" 
"+(.activetime|tostring)+" "+(.lastpaid|tostring)+" "+.ipaddress)}]|add'`

ZNADDR=$1

if [ -z $ZNADDR ]; then
    echo "usage: $0 <zelnode address>"
    exit -1
fi

SORTED_ZN_LIST=$(echo "$ZNLISTCMD" | sed -e 's/[}|{]//' -e 's/"//g' -e 's/,//g' | grep -v ^$ | \
awk ' \
{
    if ($7 == 0) {
        TIME = $6
        print $_ " " TIME
    }
    else {
        xxx = ("'$NOW'" - $7)
        if ( xxx >= $6) {
            TIME = $6
        }
        else {
            TIME = xxx
        }
        print $_ " " TIME
    }
}' |  sort -k10 -n)

ZN_VISIBLE=$(echo "$SORTED_ZN_LIST" | grep $ZNADDR | wc -l)
ZN_QUEUE_LENGTH=$(echo "$SORTED_ZN_LIST" | wc -l)
ZN_QUEUE_POSITION=$(echo "$SORTED_ZN_LIST" | grep -A9999999 $ZNADDR | wc -l)
ZN_QUEUE_IN_SELECTION=$(( $ZN_QUEUE_POSITION <= $(( $ZN_QUEUE_LENGTH / 10 )) ))

echo "zelnode $ZNADDR"
if [ $ZN_VISIBLE -gt 0 ]; then
    echo " -> queue position $ZN_QUEUE_POSITION/$ZN_QUEUE_LENGTH"
    if [ $ZN_QUEUE_IN_SELECTION -gt 0 ]; then
        echo " -> SELECTION PENDING"
    fi
else
    echo "is not in Zelnode list"
fi
