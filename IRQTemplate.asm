#import "AcornConstants.asm"

.label EndOfDisplayReached = $7F    // set when CRT has finished rendering visible part
                                    // of disiplay

 *=$1900
SetUpGameScreen:
        // Sets up the game screen to how we want it

        // Switch to mode 2
        lda #$16
        jsr oswrch
        lda #02
        jsr oswrch
        // now in mode 2          

        // turn off the cursor, why not try writing to the 6845 chip directly to do this !      
        lda #23
        jsr oswrch
        lda #01
        jsr oswrch    
        lda #00
        ldx #07

CursorOffLoop:
        jsr oswrch  
        dex
        bpl CursorOffLoop
        
        // redfine logical colour 8 to physical colour 4 (black), as we use logical colour 0
        // as the mask, so 8 becomes the new black
        
        lda #$0C
        ldx #<LogicalColour8ToActualColour0
        ldy #>LogicalColour8ToActualColour0
        jsr osword
        
        // set background colour to blue     
        lda #$0C
        ldx #<LogicalColour0ToActualColour4
        ldy #>LogicalColour0ToActualColour4
        jsr osword

// The following code enables us to tie our sprite plotting not to Vsync, but to a time
// when the bottom of the visible screen has just finished rendernig, Vsync actually
// occurs a little later than this (about 2 char rows in mode 2) and doing it this way
// gives us vital extra time to render the screen.
// The theory is this :
// Tie our own interupt handle to the interupt vector
// When an interupt occurs check if it has occured because if vsync. If so we set a 
// timer running using the hardware timers on the system VIA.
// We also set a "End of Display" flag saying that vsync has not occured. 
// If however the interupt wasn't vsync then we know it's because our timer we set up
// has counted down to zero (as we only permit these two interupts to occur in our set
// up code. In this code we set the flag to say that "End of Display" has been 
// reached and exit. Where before in our code we'd usuall wait for vysync we now just 
// have a loop checking this "End of Display" flag. When it's set we know the CRT has
// just finished rendering the display and we should start out plotting code.
// The critical part is setting the initial timer value so that when the normal vsync
// occurs it fills it with the correct value so that the timer will interupt when the 
// CRT beam has just finished the display. This value was found using a rough 
// calculation and then trial and error top get it spot on.



        sei                                     // first things first turn off interupts when
                                                // programming system via

        // Set the code to execute when an interupt occurs (which will be the vsync interupt)

        lda #<IRQHandler                        // set the interupt request to be ours
        sta InteruptRequestVectorLow            // we don't preserve anything previous
        lda #>IRQHandler                        // note as interupts disabled it's safe to do this
        sta InteruptRequestVectorHi


        // set CA1 to interupt when Vysync occurs

        lda #%01111111                   // disable all 6522 interupts
        sta SysVIA_InteruptEnable        // we just want the ones we're interested in
        lda #%10000010                   // enable CA1 interupt (VSync input from 6845) 
        sta SysVIA_InteruptEnable
        lda #%00000100                   // Set CA1 to interupts when it gets a positive
                                         // edges, i.e. goes from 0 to 1
        sta SysVIA_PeripheralControl  


        // following sets timer 1 to timed interupt each time Timer1 loaded,Shift register
        // disabled,PB,PA Latches disabled      
        lda #00
        sta SysVIA_AuxControl
        sta EndOfDisplayReached
        cli                              // finished setting up via, enable interupts  

        rts
LogicalColour8ToActualColour0:
.byte $08                                // logical colour 8
.byte $00                                // physical colour 0 (black)   
LogicalColour0ToActualColour4:
.byte $00                                // logical colour 8
.byte $04                                // physical colour 0 (black)
   
IRQHandler:

        // fires when the interupt occurs.

        lda SysVIA_InteruptFlag          // look at the interupt flags of the system via
        and #%00000010                   // mask out all but CA1 (which is linked to Vsync 
                                         //  circuit), if set CA1 has had an active edge.
        beq notvsyncInterrupt            // not set check other interupts

        sta SysVIA_InteruptFlag          // is set so vsync occurred, storing back clears interupt flag

        lda #%11000000                   // enable timer 1 interupt
        sta SysVIA_InteruptEnable
        lda #$C8                         // set timer1, this value is critical to the smooth scrolling of the routine
        sta SysVIA_Timer1CounterLatchLow
        lda #$46
        sta SysVIA_Timer1CounterLatchHi

        lda # 0
        sta EndOfDisplayReached          // Set to false            
        lda $FC                          // on entrying interupt A is put in FC, so get back
        rti                              // exit the interupt 
 
notvsyncInterrupt:    
        lda SysVIA_InteruptFlag           
        and #%01000000                   // checking if interupt was timer1
        bne Timer1Interrupt              // it was timer 1 
        lda $F                           // on entrying interupt A is put in FC, so get back
        rti
  
Timer1Interrupt:                        
        // timer 1 has counted down so the CRT has just finished rendering the visible part
        // of the display
        sta SysVIA_InteruptFlag          // clear interupt flags
        sta SysVIA_InteruptEnable
        dec EndOfDisplayReached          // previous value was 0 so this makes it not zero     
        lda $FC                          // on entrying interupt A is put in FC, so get back
        rti