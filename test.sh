#!/bin/bash
S1='string'
S2='teString'
if [ "$S1" != "$S2" ];
then
	echo "S1('$S1') is equal to S2('$S2')"
fi

if [ $S1=$S1 ];
then
		echo "S1('$S1') is equal to S1('$S1')"
fi