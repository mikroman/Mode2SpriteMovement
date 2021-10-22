I have Kick converted the original .swift files for this. I am using this only for
the IRQ code, not the sprite routines.

Below is text from the well-commented file "SpritePlotter.asm"
It can be found at line 1145


The following code enables us to tie our sprite plotting not to Vsync, but to a time
when the bottom of the visible screen has just finished rendernig, Vsync actually
occurs a little later than this (about 2 char rows in mode 2) and doing it this way
gives us vital extra time to render the screen.
The theory is this :
Tie our own interupt handle to the interupt vector
When an interupt occurs check if it has occured because if vsync. If so we set a 
timer running using the hardware timers on the system VIA.
We also set a "End of Display" flag saying that vsync has not occured. 
If however the interupt wasn't vsync then we know it's because our timer we set up
has counted down to zero (as we only permit these two interupts to occur in our set
up code. In this code we set the flag to say that "End of Display" has been 
reached and exit. Where before in our code we'd usuall wait for vysync we now just 
have a loop checking this "End of Display" flag. When it's set we know the CRT has
just finished rendering the display and we should start out plotting code.
The critical part is setting the initial timer value so that when the normal vsync
occurs it fills it with the correct value so that the timer will interupt when the 
CRT beam has just finished the display. This value was found using a rough 
calculation and then trial and error top get it spot on.