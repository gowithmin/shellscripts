#!/bin/sh
# 2014.12.12
# hyunmin hwang, gowithmin@gmail.com
# Calculating factorial

checkNum(){
    tempNum=$1
    if [ ! -z `echo $tempNum | tr -d 0-9` ];then
        echo "[CRIT] $tempNum is not a number"
        exit
    else
	if [ $tempNum -eq 0 ];then
	    tempNum=1
	    echo ""
	    echo "[WARN] $1 replaced to 1, 0!=1"
	    echo ""
	fi
    fi
}

readNum() {
    echo -n "Start number of range : "
    read StartNum
    checkNum $StartNum
    StartNum=$tempNum

    echo -n "End number of range : "
    read EndNum
    checkNum $EndNum
    EndNum=$tempNum

    if [ $StartNum -eq $EndNum ];then
       echo "Factorial $StartNum!/$EndNum! = $StartNum/$EndNum = 1"
       exit
    elif [ $StartNum -gt $EndNum ];then
       echo "[CRIT] It does not support : $StartNum!/$EndNum!"
       exit
    fi
}

calcNum() {
    LimitNum="9223372036854775807"
    stopped=0
    for ((i=$StartNum;i<$EndNum;i++))
    do
	NextNum=$((i+1))
#echo $i:$Value # for probing
	if [ $i -eq $StartNum ];then
# initialize
	    Value=$((StartNum*NextNum))
	    CalcMSG="$StartNum*$NextNum"
	else
	    MagicNum=$((LimitNum/$Value))
	    if [ $MagicNum -lt 1 ];then
		NextNum=$((i-1))
		CalcMSG="$CalcMSG*$NextNum"
		stopped=1
		break
	    else
		tempValue=$Value
		Value=$((Value*NextNum))
		CalcMSG="$CalcMSG*$NextNum"
	    fi
	fi
    done

    if [ $tempValue -gt 1 ];then
	Value=$tempValue
	Num=$NextNum
    fi

}

## main
readNum
echo ""
echo "calculating..."
calcNum # $StartNum $EndNum
echo "============================================="
echo -n "Calculate factorial : "

if [ $stopped -eq 1 ];then
    echo "[ Failed ]"
    echo "Reason     : The calculation has reached limit:$LimitNum"
    echo "You want   : $StartNum!/$EndNum!"
    echo "Stopped    : $CalcMSG"
    echo "Last value : $Value"
else
    echo "[ Success ]"
    echo "You want   : $StartNum!/$EndNum!"
    echo "Cacluate   : $CalcMSG"
    echo "Result     : $Value"
fi

echo "============================================="
