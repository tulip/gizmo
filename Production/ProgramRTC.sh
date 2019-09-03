#!/usr/bin/env bash
set -euxo pipefail

MCP23017_ADDR="0x20"
DS3232_ADDR="0x68"

DS3232_REG_SECONDS="0x00"
DS3232_REG_MINUTES="0x01"
DS3232_REG_HOURS="0x02"
DS3232_REG_AMPM="0x02"
DS3232_REG_DAY="0x03"
DS3232_REG_DATE="0x04"
DS3232_REG_MONTH="0x05"
DS3232_REG_CENTURY="0x05"
DS3232_REG_YEAR="0x06"


seconds=`date +%S`
minutes=`date +%M`
hours=`date +%H`
day_w=`date +%u`
day_m=`date +%d`
month=`date +%m`
year_century=`date +%C`
year=`date +%y`


function get_tens_place(){
    tens_place=`echo "$1" | cut -c 1`
    echo $tens_place
}

function get_ones_place(){
    ones_place=`echo "$1" | cut -c 2`
    echo $ones_place
}

function get_byte(){
lsb=`get_ones_place "$1"`
msb=`get_tens_place "$1"`
printf "0x%x%x\n" "$msb" "$lsb"
}

secs_byte=`get_byte "$seconds"`
mins_byte=`get_byte "$minutes"`
hrs_byte=`get_byte "$hours"`
dayw_byte=`get_byte "$day_w"`
daym_byte=`get_byte "$day_m"`
century_byte=`get_byte "$year_century"`
century_byte_shift=$((year_century << 7))
cent_month_byte=$((century_byte_shift | $month_byte)) #century and month share a register
year_byte=`get_byte "$year"`

# Set GPIOA_0 and GPIOA_1 to INPUT and GPIOA_2 to GPIO_7 to OUTPUT
i2cset -f -y 1 "$MCP23017_ADDR" 0x00 0x03

# Turn on GPIOA_3 to OFF for RTC GND & turn GPIOIOA_4 to ON for RTC PWR
i2cset -f -y 1 "$MCP23017_ADDR" 0x12 0x08

#Program Seconds
i2cset -f -y 1 "$DS3232_ADDR" "$DS3232_REG_SECONDS" $zero

#Program Minutes
i2cset -f -y 1 "$DS3232_ADDR" "$DS3232_REG_MINUTES" $one

#Program Hours
i2cset -f -y 1 "$DS3232_ADDR" "$DS3232_REG_HOURS" $two

#Program the Day of the Week
i2cset -f -y 1 "$DS3232_ADDR" "$DS3232_REG_DAY" $three

#Program the Day of the Month
i2cset -f -y 1 "$DS3232_ADDR" "$DS3232_REG_DATE" $four

#Program the Century and Month 
i2cset -f -y 1 "$DS3232_ADDR" "$DS3232_REG_MONTH" $five

#Program the Year
i2cset -f -y 1 "$DS3232_ADDR" "$DS3232_REG_YEAR" $six




