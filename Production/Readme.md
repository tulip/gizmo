# Production Tools for Gizmo

### Using the Hex File

## Uploading the Hex File Using `avrdude`

You should type the following to program it:
From the top level directory, navigate to the hex file in the production folder: 
`cd Micro-Word-Clock/Production`

Then, connect everything according to the [OTHER README's](linkssss) instructions. Once everything is connected, you can run the following: 
`avrdude -c avrispmkII -p ATmega328P -e -U flash:w:MicroWordClock2-Arduino.ino.hex`

## Expected Behavior
You should be able to tell your gizmo has flashed correctly if you can perform the following tasks:
| Test        | Description 	|
|-------------|-----------------| 
| No flicker | Watch for 1min and see no flicker | 
| MCU HB | Blinks first tulip something to confirm MCUs are programmed correctly - this is also the behavior of a broken/not-programmed RTC | 
| Minutes Program | Long hold makes the minute value blink. Each minute is a press, so pressing 5 times should change the value of the minute. |
| Hours Program | Long hold makes the minute value blink. Another long hold makes the hours blink. Long hold will set it, press quickly to change numbers. |
| RTC Works | RTC time persists after a restart | 


### RTC Programmer

## How to Connect the RTC to the Gateway

This script is meant to be used on a Tulip Gateway. The gateway should be in the following configuration:
- The gateway should be authenticated so that it will have the correct time. 
- The gateway should have IO500A and IO500B removed and IO501A and IO501B added. Otherwise it will not work.
- You should plug the RTC into the following pins. Note that the gateway pins numbers refer to the ones in silk on the gateway.

| Gateway Pin | RTC Pin |
|-------------|---------|
| GPIOA - 1   | SCL     |
| GPIOA - 2   | SDA     |
| GPIOA - 4   | PWR     |
| OUTPUT- GND | GND     |

[INSERT PICTURES OF GATEWAY SETUP](linkssss)

## How to Program the RTC
Pre-conditions:
- You have the `ProgramRTC.sh` program on the gateway
- You have changed `ProgramRTC.sh` to an executable: `chmod +x ProgramRTC.sh`
- You are logged in as the `root` user.
- You have connected the RTC to the gateway following the above instructions.

**Confirm that the RTC is Plugged in Correctly** 

Run `i2cdetect -r -y 1`

```
     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
00:          -- -- -- -- -- -- -- -- -- -- -- -- --
10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
20: 20 21 -- -- -- -- -- -- -- -- -- -- -- -- -- --
30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
40: -- -- -- -- -- -- -- -- 48 -- -- -- -- -- -- --
50: 50 -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
60: -- -- -- -- -- -- -- -- 68 -- -- -- -- -- -- --
70: -- -- -- -- -- -- -- -- 
```

Note the 68! If you don't have this your RTC is plugged in incorrectly. 

**Confirm the Date**
Make sure that the date is what you expect it to be by running `date`

**Program the RTC!**
If everything looks good, you will want to run `./ProgramRTC.sh`

It will output a bunch of text which you can read through to debug. Now you should be able to plug in your RTC to the Gizmo! It is accurate to the second! 






