#!/usr/bin/env bash
set -euxo pipefail

seconds=`date +%S`
minutes=`date +%M`
hours=`date +%H`
day_w=`date +%u`
day_m=`date +%d`
month=`date +%m`
year_century=`date +%C`
year=`date +%y`


function get_tens_place(){
    tens_place=`echo $1 | cut -c 1`
    echo $tens_place
}

function get_ones_place(){
    ones_place=`echo $1 | cut -c 2`
    echo $ones_place
}

function get_byte(){
lsb=`get_ones_place $1`
msb=`get_tens_place $1`
printf "0x%x%x\n" $msb $lsb
}

zero=`get_byte $seconds`
one=`get_byte $minutes`
two=`get_byte $hours`
three=`get_byte $day_w`
four=`get_byte $day_m`
#five=`get_byte $month`
six=`get_byte $year`

i2cset -f -y 1 0x68 0x00 $zero
i2cset -f -y 1 0x68 0x01 $one
i2cset -f -y 1 0x68 0x02 $two
i2cset -f -y 1 0x68 0x03 $three
i2cset -f -y 1 0x68 0x04 $four
#i2cset -f -y 1 0x68 0x05 $five
i2cset -f -y 1 0x68 0x06 $six