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
five=`get_byte $month`
six=`get_byte $year`

# Set GPIOA_0 and GPIOA_1 to INPUT and GPIOA_2 to GPIO_7 to OUTPUT
i2cset -f -y 1 0x20 0x00 0x03

# Turn on GPIOA_3 to OFF for RTC GND & turn GPIOIOA_4 to ON for RTC PWR
i2cset -f -y 1 0x20 0x12 0x08

#Program Seconds
i2cset -f -y 1 0x68 0x00 $zero

#Program Minutes
i2cset -f -y 1 0x68 0x01 $one

#Program Hours
i2cset -f -y 1 0x68 0x02 $two

#Program the Day of the Week
i2cset -f -y 1 0x68 0x03 $three

#Program the Day of the Month
i2cset -f -y 1 0x68 0x04 $four

#Program the Month
#i2cset -f -y 1 0x68 0x05 $five

#Program the Year
i2cset -f -y 1 0x68 0x06 $six




