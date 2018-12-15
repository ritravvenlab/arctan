UltraSonic sensor provides distance based on how long Echo is HIGH ( 1 ). Changed vhdl to start counting time after echo is high. 

Distance constraints so far:

shortest distance: 3 cm 
largest distance (no jitter*): 113 cm
largest distance seen (jittered*): 140 cm


*jitter: overlapping signal reads. This may be caused by power issues or timing speed for reading. (Will need to tested on Rover
to see if power causes jitter.)

Fastest time data is available(no jitter): .005 ( shortest distance )
Slowest time data is available(no jitter): .025 ( longest distance )



All values shown here are subject to change as code has not been tested on Rover. Tested with snickerdoodle and HC-SR04 with no power
leveler.


Code still provides just the cm value after all calculations are done. (This can be taken out at anytime. Formula from datasheet is
correct ( uS/58 = distance in cm ) no division by two is required after that.