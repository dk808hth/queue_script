#!/bin/bash

ZNTIER=$1
ZNADDR=$2

if [ -z $ZNTIER ]; then
    echo ""
    echo "usage  : $0 <tier> <zelnode address>"
    echo ""
    echo "example: $0 -basic t1cUKkWws83twyvAbj6fWEAfsvp14JDjr87"
	echo "example: $0 -super t1U4mLtUuiSwfVFS8rHCY1nANXD5fweP911"
	echo "example: $0 -bamf t1MK2mtU8Wuoq22Z2FsMUMN41DsrGcFxcCo"
	echo ""
    exit -1
fi



if [ -z $ZNADDR ]; then
    echo ""
    echo "usage  : $0 <tier> <zelnode address>"
    echo ""
    echo "example: $0 -basic t1cUKkWws83twyvAbj6fWEAfsvp14JDjr87"
        echo "example: $0 -super t1U4mLtUuiSwfVFS8rHCY1nANXD5fweP911"
        echo "example: $0 -bamf t1MK2mtU8Wuoq22Z2FsMUMN41DsrGcFxcCo"
    echo ""
    exit -1
fi

if [ $ZNTIER == -basic ] ; then
    ZNTIER=BASIC
fi

if [ $ZNTIER == -super ] ; then
    ZNTIER=SUPER
fi

if [ $ZNTIER == -bamf ] ; then
    ZNTIER=BAMF
fi

ZNLISTCMD_TMP="`zelcash-cli listzelnodes 2>/dev/null`"
ZNLISTCMD="`echo "$ZNLISTCMD_TMP" | jq -r '[.[] |select(.tier=="'${ZNTIER}'") |{(.txhash):(.status+" "+(.version|tostring)+" "+.addr+" "+(.lastseen|tostring)+" 
"+(.activetime|tostring)+" "+(.lastpaid|tostring)+" "+.ipaddress)}]|add'`"


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

echo ""
echo "Zelnode :" $ZNADDR
if [ $ZN_VISIBLE -gt 0 ]; then
    echo "Tier    : $ZNTIER"
        echo "         -> queue position $ZN_QUEUE_POSITION/$ZN_QUEUE_LENGTH"
        echo ""
    if [ $ZN_QUEUE_IN_SELECTION -gt 0 ]; then
        echo " -> SELECTION PENDING"
    fi
else
    echo "is not in Zelnode list"
fi
