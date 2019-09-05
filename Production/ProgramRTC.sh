#!/usr/bin/env bash
set -euxo pipefail

MCP23017_ADDR="0x20"
DS3232_ADDR="0x68"

DS3232_REG_SECONDS="0x00"
DS3232_REG_MINUTES="0x01"
DS3232_REG_HOURS="0x02"
DS3232_REG_DAY="0x03"
DS3232_REG_DATE="0x04"
DS3232_REG_CENTURY_MONTH="0x05"
DS3232_REG_YEAR="0x06"

DS3232_ADDR_BLOCK=($DS3232_REG_SECONDS $DS3232_REG_MINUTES $DS3232_REG_HOURS $DS3232_REG_DAY $DS3232_REG_DATE $DS3232_R$

# This bit signifies that the year has overflowed which means that we are in the 21st century
DS3232_CENTURY_2000="80"

function get_tens_place(){
    tens_place=`echo "$1" | cut -c 1`
    if [[ ${#1} -le 1 ]]
    then
           tens_place="0"
    fi
    echo $tens_place
}
function get_ones_place(){
    ones_place=`echo "$1" | cut -c 2`
    if [[ ${#1} -le 1 ]]
    then
           ones_place="$1"
    fi
    echo $ones_place
}

function get_byte(){
lsb=`get_ones_place "$1"`
msb=`get_tens_place "$1"`
printf "0x%x%x\n" "$msb" "$lsb"
}

function join_century_month(){
    month="${date_array[5]}"
    century_month=$((10#$DS3232_CENTURY_2000|10#$month))
    date_array[5]=$century_month
}

#date in the format: seconds minutes hours day_week day_month century year
date_string=$(date +%S" "%M" "%H" "%u" "%d" "%m" "%y)

date_array=($date_string)
echo ${date_array[@]}

#Append the century bit to the MSB of the month register
join_century_month

# Set GPIOA_0 and GPIOA_1 to INPUT, set GPIOA_2 to GPIO_7 to OUTPUT
# to initialize banks for power and prevent errors if resistors to MCP23017 are populated
i2cset -f -y 1 "$MCP23017_ADDR" 0x00 0x03

# Turn on GPIOA_3 to OFF for RTC GND & turn GPIOIOA_4 to ON for RTC PWR
i2cset -f -y 1 "$MCP23017_ADDR" 0x12 0x08

#Loop through the address block and program each register of the DS3231
for i in "${DS3232_ADDR_BLOCK[@]}"
do
   byte=$(get_byte ${date_array[$i]})
   echo $byte
   i2cset -f -y 1 $DS3232_ADDR "${DS3232_ADDR_BLOCK[$i]}" $byte
done



