#!/bin/bash

ZNLISTCMD="zelcash-cli listzelnodes |jq -r '[.[] |{(.txhash):(.status+" "+(.version|tostring)+" "+.addr+" "+(.lastseen|tostring)+" "+(.activetime|tostring)+" "+(.lastpaid|tostring)+" "+.ipaddress)}]|add'
 2>/dev/null"

ZNADDR=$1

if [ -z $ZNADDR ]; then
    echo "usage: $0 <zelnode address>"
    exit -1
fi

function _cache_command(){

    # cache life in minutes
    AGE=2

    FILE=$1
    AGE=$2
    CMD=$3

    OLD=0
    CONTENTS=""
    if [ -e $FILE ]; then
        OLD=$(find $FILE -mmin +$AGE -ls | wc -l)
        CONTENTS=$(cat $FILE);
    fi
    if [ -z "$CONTENTS" ] || [ "$OLD" -gt 0 ]; then
        echo "REBUILD"
        CONTENTS=$(eval $CMD)
        echo "$CONTENTS" > $FILE
    fi
    echo "$CONTENTS"
}



ZN_LIST=$(_cache_command /tmp/cached_znlistfull 2 "$ZNLISTCMD")
SORTED_ZN_LIST=$(echo "$ZN_LIST" | sed -e 's/[}|{]//' -e 's/"//g' -e 's/,//g' | grep -v ^$ | \
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
