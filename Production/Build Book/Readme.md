# Production Tools for Gizmo

## Using the Hex File

### Uploading the Hex File Using `avrdude`

You should type the following to program it:
From the top level directory, navigate to the hex file in the production folder: 
`cd Micro-Word-Clock/Production`

Then, connect everything according to the [Top Level Readme](https://github.com/tulip/gizmo) instructions. Once everything is connected, you can run the following: 
`avrdude -c avrispmkII -p ATmega328P -e -U flash:w:MicroWordClock2-Arduino.ino.hex`

### Expected Behavior
You should be able to tell your gizmo has flashed correctly if you can perform the following tasks:
- **No Flicker** - Watch for 1min and see no flicker
- **MCU HB** - Blinks first tulip something to confirm MCUs are programmed correctly - this is also the behavior of a broken/not-programmed RTC
- **Minutes Good** - Long button press (>2s)  the minute value blink. Each minute is a press, so pressing 5 times should change the value of the minute.
- **Hours Good** - Long button press (>2s) makes the minute value blink. Another long hold makes the hours blink. Will program - long hold will set it, press quickly to change numbers. 
- **RTC Good** - RTC time persists after a restart
- **NO RTC Programmable** - If there is no RTC, will initialize as blinking"TWELVE" and still be able to be set normally. Should keep time normally. 
- **ADD RTC OK** - Adding a known good RTC should immediately switch the time to the time programmed on the RTC.

NOTE: No RTC hot unplugging! Hot unplugging can induce a complete reset of the RTC. This behavior can be replicated in the original code and seems to occur after multiple hot unplugs. If you need to remove the RTC, unplug the device completely and then remove the RTC.

## RTC Programmer

### How to Connect the RTC to the Gateway

This script is meant to be used on a Tulip Gateway. The gateway should be in the following configuration:
- The gateway should be authenticated so that it will have the correct time. 
- **The gateway should have IO500A and IO500B removed and IO501A and IO501B added. Otherwise it will not work.** See page 12 of the gateway schematic included in this directory.
- You should plug the RTC into the following pins. Note that the gateway pins numbers refer to the ones in silk on the gateway.

| Gateway Pin | RTC Pin |
|-------------|---------|
| GPIOA - 1   | SCL     |
| GPIOA - 2   | SDA     |
| GPIOA - 4   | PWR     | 
| OUTPUT- GND | GND     |


### How to Program the RTC
Pre-conditions:
- You have the `ProgramRTC.sh` program on the gateway
- You have changed `ProgramRTC.sh` to an executable: `chmod +x ProgramRTC.sh`
- You are logged in as the `root` user.
- You have connected the RTC to the gateway following the above instructions.

### Confirm that the RTC is Plugged in Correctly

Run `i2cdetect -r -y 1`

You should see the following:
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

### Confirm the Date
Make sure that the date is what you expect it to be by running `date`

### Program the RTC!
If everything looks good, you will want to run `./ProgramRTC.sh`

It will output a bunch of text which you can read through to debug. Now you should be able to plug in your RTC to the Gizmo! It is accurate to the second! 

## Notes on i2cset
This programmer works mostly via the command `i2cset`.

A quick example of what is happening: 
`i2cset -f -y 1 0x68 0x00 0x01`
`i2cset -force -no-interactive i2caddress chipaddress value`

- `-f` forces `i2cset` to set a value
- `-y` turns off interactive mode because this is inside a script 
- `0x68` is the i2c address on the gateway (which you can find by using the `i2cdetect` command)
- `0x00` is the address on the chip you're writing to. You will need to reference the [DS3231's datasheet](https://datasheets.maximintegrated.com/en/ds/DS3231.pdf). On page 11 you will see that the the address 00h corresponds to the "Seconds" of the RTC.
- This in sum, means that you are writing it is 1 seconds (0x01) to the  address for seconds (0x00) of the DS3231 which is located at the 0x68 address of the i2cbus on th gateway.





