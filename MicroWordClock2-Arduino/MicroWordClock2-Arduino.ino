#include <Wire.h>
#include "RTClib.h"
#include "TimeLib.h"


// Local includes
#include "pindefs.h"
#include "otherdefs.h"

// Customizable options
#include "english.h" // exchange this for the language you need
boolean blink_enable = true;
boolean blinknow = false;
boolean setonce = false;
#define FREQ_DISPLAY 490 // Hz
#define FREQ_TIMEUPDATE  490 // Hz

volatile int cols[]={ // PC0,PD4,PB6!,PB3,PD5,PB4,PC2,PC3
  MTX_COL1,MTX_COL2,MTX_COL3,MTX_COL4,MTX_COL5,MTX_COL6,MTX_COL7,MTX_COL8}; // ON=LOW
volatile int rows[]={ // PB2,PC1,PD7,PB5,PD2,PD6,PD3,PB7!
  MTX_ROW1,MTX_ROW2,MTX_ROW3,MTX_ROW4,MTX_ROW5,MTX_ROW6,MTX_ROW7,MTX_ROW8}; // ON=HIGH

enum ClockMode {
  NORMAL,
  SET_MIN,
  SET_HRS,
  END,
};

ClockMode clockmode = NORMAL;


volatile char disp[8]={
  0B11111111,
  0B11111111,
  0B11111111,
  0B11111111,
  0B11111111,
  0B11111111,
  0B11111111,
  0B11111111,
};

char testdisp[8]={
  0B11111111,
  0B11111111,
  0B11111111,
  0B11111111,
  0B11111111,
  0B11111111,
  0B11111111,
  0B11111111,
};

// RTC stuff
RTC_DS1307 rtc;
unsigned long disp_sec;
unsigned long disp_min;
unsigned long disp_hrs;

volatile boolean updatenow = false;

boolean buttonState = LOW;
unsigned long buttonMillis = 0;
boolean buttonHandled = true;

void loop() {
  if(updatenow) {
    if ((rtc.isrunning() && disp_min == 3 && clockmode == NORMAL) || (rtc.isrunning() && disp_min == 9 && clockmode == NORMAL)){
      TCNT1 = 0;
    }
    updateTime();
    prepareDisplay();
    updatenow = false;
  }

  if(!rtc.isrunning() && !setonce){
    clockmode = SET_HRS;
  }
  if(digitalRead(PIN_BUTTON) != buttonState) {
    buttonState = digitalRead(PIN_BUTTON);
    if(buttonState == LOW) { // button was pressed
      buttonMillis = millis();
      buttonHandled = false;
      setonce = true;
    }
    else { // button was released
      buttonHandled = true;
      unsigned long buttonDelay = millis() - buttonMillis;
      if(buttonDelay > 01) { // debounce
        if(buttonDelay < 750) { // simple press
          updatenow = true;
          switch(clockmode) {
          case NORMAL:
            blink_enable = !blink_enable;
            blinknow = true;
            TCNT1 = 0;
            break;
          case SET_MIN:
            if(rtc.isrunning())
              rtc.adjust(rtc.now().unixtime() + 1*60);
            else
              adjustTime(60);
            blinknow = true;
            TCNT1 = 0;
            break;
          case SET_HRS:
            if(rtc.isrunning())
              rtc.adjust(rtc.now().unixtime() + 1*60*60);
            else
              adjustTime(60*60);
            blinknow = true;
            TCNT1 = 0;
            break;
          }
        }
      }
    }
  }
  else {
    if(buttonState == LOW && !buttonHandled) { // button is being pressed
      unsigned long buttonDelay = millis() - buttonMillis;
      if(buttonDelay > 2000) {
        blinknow = false;
        TCNT1 = 0;
        clockmode = (ClockMode)((int)clockmode + 1);
        if(clockmode == END)
          clockmode = NORMAL;
        buttonHandled = true;
        updatenow = true;
      }
    }
  }
}

void updateTime() {
  // Adjust 2.5 minutes = 150 seconds forward
  // So at 12:03 it already reads "five past 12"
  
  if(rtc.isrunning()){
    DateTime now = rtc.now().unixtime() + 150;
    disp_sec = now.second();
    disp_min = now.minute();
    disp_hrs = now.hour();
  }
  else{
    disp_sec = second();
    disp_min = minute();
    disp_hrs = hour();
  }
    
  disp_min /= 5;

  if(disp_min >= min_offset)
    ++disp_hrs %= 12;
  else
    disp_hrs   %= 12;
  
}

void prepareDisplay() {
  blinknow = !blinknow;
  FOR_ALLROWS {
    disp[r]=B00000000;
    FOR_ALLCOLS {
      if((clockmode != SET_MIN || !blinknow))
          disp[r] |= minutes[disp_min][r] & (B10000000 >> c);
      if((clockmode != SET_HRS || !blinknow))
          disp[r] |= hours  [disp_hrs][r] & (B10000000 >> c); 
      if(clockmode == NORMAL && blink_enable && !blinknow)
        disp[r] |= blinky[r];
    }
  }
}
