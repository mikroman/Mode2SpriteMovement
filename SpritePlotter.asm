#import "AcornConstants.asm"                      


                                                                                        
 //______________________________________________________________________________________   
 //______________________________________________________________________________________      
 // constants
   
   // general
     
     .const ScreenStartHighByte = $30      // high value of start of screen  
     .const MaskTable = $900               // mask table address. A page aligned table of
                                         // of data to make masked sprite plotting quicker.
                                         // You must ensure this data is loaded into memory
                                         // before the sprite plotting routine is called. 
                                         
     .const ScreenWidth = 80               // width of screen mode in bytes 
                                       
   // SpriteObject Structure              // see structures section
     .const SpriteObjectStructureSize  = 29 // Size of a sprite object. If you add to the 
                                         // structure definition, remember to alter this
                                         // setting to the new structure size. 
                                         
     .const SO_SpriteID = 0                // Sprite ID of sprite                    
     .const SO_XOrd = 1                    // current x ord         
     .const SO_YOrd = 2                    // current y ord  
     .const SO_ScreenAddress = 3           // & 4, low and high bytes of char row screen 
                                         // address to plot at. Storing here saves time 
                                         // in actual plot loop when we need to keep up 
                                         // the speed as much as possible. i.e. this 
                                         // value has been calculated before we start the 
                                         // main sprite plot loop, as at that point we're 
                                         // racing to beat the screen raster.          
     .const SO_LastScreenAddress = 5       // & 6, low and high bytes of last screen 
                                         // address to we ploted Sprite at. This address
                                         // will actually be used for the erase routine.
     .const SO_GraphicData = 7             // index to start of actual graphical data, low
                                         // byte value, high is at this label +1
     .const SO_Width = 9                   // index into sprite structure for width
     .const SO_Height = 10                 // index into sprite structure for height
     .const SO_Behaviour = 11              // index to behaviour id
     .const SO_XMoveAmount = 12            // amount to move in x direction, signed byte
     .const SO_LineIndex  = 13             // index to line part of char row screen adr to 
                                         // plot at  
     .const SO_EraseBottom = 14            // flag, dicates whether there is a part bottom
                                         // of sprite to erase. 0=false else true 
     .const SO_EraseMiddle = 15            // flag, dictates whether there are some middle
                                         // char rows to erase. 0=false else true 
     .const SO_EraseTop = 16               // flag, dicates whether there is a part top row
                                         // to erase. 0=false else true  
     .const SO_LineIndexErase = 17         // index to line part of char row last screen  
                                         // adr to erase at 
     .const SO_NumMiddleRowsToErase = 18   // the number of ful char rows to erase for this
                                         // sprite
     .const SO_CharRowWidth = 19           // width of a char row of the sprite, will 
                                         // always be width * 8.
     .const SO_EraseScrAdrMiddle = 20      // and 21, the erase screen address to start 
                                         // erasing any middle char rows if there are any
     .const SO_PreviousY = 22              // previous Y ord object was plotted at (system)
     .const SO_PreviousX = 23              // previous X ord sprite was plotted at (system)
     .const SO_EraseTopScrAdr = 24         // and 25, the erase screen address to start 
                                         // erasing any top rows if there are any
     .const SO_NumTopRows = 26             // number of top rows to erase (system)
     .const SO_CurrentMoveCount = 27       // used in conjunction with move delay. Counts
                                         // down to zero after being set to move delay
                                         // when 0 hit moves the sprite by SO_XMoveAmount
                                         // only effective is sprite is moving and used 
                                         // to slow down the speed of a sprite as even a
                                         // SO_XMoveAmount of 1 can be quite fast
     .const SO_MoveDelay = 28              // delay to use before a move amount is done.
                                         // max value 127 
     
     
   // Demo
     .const Const_NumSprites = 4           // number of sprites to plot
                                           
            
 //______________________________________________________________________________________  
 
 
 
 
 
 
 
 //______________________________________________________________________________________  
 //______________________________________________________________________________________  
 // memory locations used
    
    // used by ScreenStartAddress
    //         
    
    .label XOrd = $74                   // X ord passed to ScreenStartAddress
    .label YOrd = $75                   // Y ord passed to ScreenStartAddress
    
    
    
    // used by ScreenStartAddress and PlotSprite
    
    .label XYScreenAddress = $78        // and $79, contains the returned calculated 
                                      // screen address from ScreenStartAddress 
                                      
                                      
                                      
    //used by PlotSprite
    .label SpriteObject = $7C           // and $7D, address of the sprite object structure   
    
    
    
    // Used by SetUpSprite
    
    .label SpriteGraphicData = $70      // and $71. Holds the address (low in $70, high 
                                      // in $71) of the sprite graphic data. This is the 
                                      // actual graphic data AFTER the width and height
                                      // bytes of the format for none fixed width column
                                      // order sprites as described in the Swift Sprite  
                                      // Data Formats document.
                                      
                                      
    
    // Used by Demo code
    
    .label SpriteCollection  = $7A      // and 7B, address of the sprite collection. A 
                                      // sprite collection is literally a collection of
                                      // sprites all together in an structured order
                                      // The structure of which should be documented. For
                                      // this demo the structure is described in the 
                                      // Swift Sprite Data Formats document. The 
                                      // particular sprite collection used here is 
                                      // "column order, no fixed width or height"
                                      
    .label NumSprites = $7E             // counter for number of sprites to plot
    
    .label EndOfDisplayReached = $7F    // set when CRT has finished rendering visible part
                                      // of disiplay
                                      
   
                                                          
 //______________________________________________________________________________________  
 
 
 
 
 
 
                                                                                  
 //______________________________________________________________________________________  
 //______________________________________________________________________________________  
  // workspace  
  // memory only used within routines, not as passed or returned params
    
    .label Temp = $9F                   // ScreenStartAddress : holds the high byte
                                      // result of a multiplication of the X ord by 8  
                                    
    .label Width = $72                  // PlotSprite : width of current sprite to plot
    .label Height = $73                 // PlotSprite : height of current sprite to plot  
    .label YStartOffset = $76           // PlotSprite : Offset to add to the screen address
                                      // of a block of column sprite data to get the
                                      // actual screen address to plot at. Used with 
                                      // indexed addressing. See PlotSprite for more info     
  // used by erase code
    .label ScreenEraseAddress = $78     // and $79. Current address to erase at 
    .label RowsLeftToErase    = $9F 
              
 //______________________________________________________________________________________  
 
 
 
 
 
 
 //______________________________________________________________________________________  
 //______________________________________________________________________________________ 
 
 //Structure Definitions
 
   //SpriteObject 
      // Notes : Not to be confused with the sprite data structure as defined in the
      // Swift Sprite data formats document
      
      // A structure containing details of actual sprite objects, these details include
      // X, Y pos, the sprite graphic to use etc. You can add to the structure freely to
      // include data relevent to your own game but do not alter the existing structure
      // unless you really know what you are doing as the sprite plot and erase routines
      // rely on it being in the format it is
      
      // The Structure :
      
      // Byte(s)   Used for
      
      //    0      Sprite graphic ID, the index into the sprite collection for the Sprite
      //           Graphical data to use. Note max sprites in any one collections is 
      //           therefore 256. 
      //    1      Current X position of sprite object
      //    2      Current Y Position of sprite object
      //    3,4    Screen address char row calculated for current X,Y pos of this sprite  
      //    5,6    Last Screen address calculated for last X,Y pos of this sprite 
      //    7,8    Start address of sprite graphic structure, note this is not strictly
      //           required as it can be worked out from the sprite ID. However copying
      //           it here saves some cycles when plotting the same sprite again and 
      //           again. If the sprite changes (animation etc.) then this needs to be 
      //           updated to. But this is handled by the Sprite set up code and need
      //           not be thought about if you use supplied routines.
      //    9      width of sprite graphic. Again, not strictly required here as it's a 
      //           copy of what is in the sprite data. However it speeds up any routines 
      //           that access this value by saving them having to look it up in the  
      //           sprite graphic structure.
      //    10     Height of sprite graphic. Copied here for same reasons as listed for
      //           width.  
      //    11     Behaviour ID. Dictates what behaviour this sprite object performs  
      //    12     X Move amount, a signed byte. If a behaviour is moving the sprite in 
      //           the horizontal plane then this stores how much to move by. Positive
      //           is to the right, negative to the left.
      //    13     Line index of screen address char row
      //    14     flag, dicates whether there is a part bottom  of sprite to erase.
      //           0=false else true 
      //    15     flag, dictates whether there are some middle char rows to erase. 
      //           0=false else true 
      //    16     flag, dicates whether there is a part top row to erase. 0=false else 
      //           true
                                            
      //    17     Line index of screen address char row to erase.      
      //    18     The number of full char rows to erase for this sprite  // 
      //    19     Width of a char row of the sprite, will always be width * 8.
      //    20,21  The erase screen address to start erasing any middle char rows
      //           if there are any.
      //    22     previous Y ord object was plotted at (system)
      //    23     previous X ord sprite was plotted at (system)
      //    24,25  the erase screen address to start erasing any top rows if any
      //    26     number of top rows to erase (system)            
      //    27     used in conjunction with move delay. Counts
      //           down to zero after being set to move delay
      //           when 0 hit moves the sprite by SO_XMoveAmount
      //           only effective is sprite is moving and used 
      //           to slow down the speed of a sprite as even a
      //           SO_XMoveAmount of 1 can be quite fast
      //    28     delay to use before a move amount is done.
                                          
       
      
 //______________________________________________________________________________________ 
 
 
 
 
.const Dif = 9 
 
 //______________________________________________________________________________________  
 //______________________________________________________________________________________ 
 // Sprite data
 
 // data for the two sprites involved in the demo's. Structure is as definied for Sprite
 // in the Structure definitions at the start of the file.
 
GameSprites: 
 
   // Bub
   .byte 0                 // graphic to use
   .byte 10                // X Pos
   .byte 17                // Y Pos
   .byte 0,0,0,0,0,0,0,0   // Work space reserved  
   .byte 01                // No behaviour
   .byte 255               // X move amount
   .byte 0,0,0,0,0,0,0,0,0 // reserved
   .byte 0,0,0,0,0,0       // reserved   
   .byte 1                 // used by horizontal move, higher the value slower the speed 
   
   // Minisoku                                                          
   .byte 3                 // graphic to use 
   .byte 10                // X Pos
   .byte 207               // Y Pos
   .byte 0,0,0,0,0,0,0,0   // Work space reserved   
   .byte 1                 // Horizontal move behaviour
   .byte 1                 // move 1 byte at a time, i.e. go left 1 byte at a time. 
                           // Rememeber this is being interpreted as a signed byte and 255
                           // is the signed equivelent of -1 for a byte. 
   .byte 0,0,0,0,0,0,0,0,0 // reserved   
   .byte 0,0,0,0,0,0       // reserved 
   .byte 4                 // used by horizontal move, higher the value slower the speed 
                       
    // Minisoku                                                          
   .byte 2                 // graphic to use 
   .byte 60                // X Pos
   .byte 104               // Y Pos
   .byte 0,0,0,0,0,0,0,0   // Work space reserved    
   .byte 1                 // Horizontal move behaviour
   .byte 255               // move 1 byte at a time, i.e. go left 1 byte at a time. 
                           // Rememeber this is being interpreted as a signed byte and 255
                           // is the signed equivelent of -1 for a byte. 
   .byte 0,0,0,0,0,0,0,0,0 // reserved   
   .byte 0,0,0,0,0,0         // reserved     
   .byte 0                 // used by horizontal move, higher the value slower the speed 
   
   // Minisoku
   .byte 3                 // graphic to use 
   .byte 0                // X Pos
   .byte 207               // Y Pos
   .byte 0,0,0,0,0,0,0,0   // Work space reserved  
   .byte 1                 // No behaviour
   .byte 1                 // no X move amount
   .byte 0,0,0,0,0,0,0,0,0 // reserved
   .byte 0,0,0,0,0,0       // reserved     
   .byte 3                 // used by horizontal move, higher the value slower the speed 
   
   
                     
   
 
 
 
 
 
 
 

 //______________________________________________________________________________________   
 //______________________________________________________________________________________ 
   *=$1900
Main:
  lda #<Sprite                                // Get low byte of Sprite collection data
  sta SpriteCollection                        // store in out low byte zero page location
  lda #>Sprite                                // Do the same with hi byte
  sta SpriteCollection+1
  
  
  jsr SetUpGameScreen
  jsr SetUpSprites   
  
  // the next code is the main game engine loop
GameEngineLoop:  
    jsr PlotSprites                      
    jsr Behaviours 
  beq GameEngineLoop                         // constantly loop around forever ! Note
                                             // zero flag is set on exit from Behaviours 
  
  rts
 
 //______________________________________________________________________________________  
 
  
  
  
  
  
  
 //______________________________________________________________________________________  
 //______________________________________________________________________________________  
SetUpSprites:
  //set up sprites prior to first run
  
  lda #Const_NumSprites
  sta NumSprites
  
  lda #<GameSprites
  sta SpriteObject  
  lda #>GameSprites
  sta SpriteObject+1  
   
SetUpSpriteLoop:
    jsr SetUpSprite
    // move to next sprite to set up 
    clc 
    lda SpriteObject
    adc #SpriteObjectStructureSize
    sta SpriteObject  
    bcc SetUpSpriteLoop_NoCarry
    inc SpriteObject+1
SetUpSpriteLoop_NoCarry: 
    dec NumSprites
  bne SetUpSpriteLoop      
  rts  
 //______________________________________________________________________________________  
 
 
 
 
 
 
 
 //______________________________________________________________________________________  
 //______________________________________________________________________________________  
Behaviours:
 // processes the behaviours of sprites, for this demo it is primative and only 1 type of
 // behaviour is allowed to be attached to a sprite object. However this is adequate for
 // many games
 
 // on Entry
 //   No entry params
 
 // On Exit
 //   Zero flag set.    Note this must never be changed as other code relies on this flag
 //                     being set on exit.
  
  lda #Const_NumSprites
  sta NumSprites
  
  lda #<GameSprites
  sta SpriteObject  
  lda #>GameSprites
  sta SpriteObject+1  
   
BehavioursLoop:
    // before doing the behaviours for ewach sprite need to preserve the previous X,Y 
    // values. These are used in erasing to erase the sprite at it's old position before
    // the new one is plotted at the new position
    
    ldy #SO_YOrd
    lda (SpriteObject),Y
    ldy #SO_PreviousY
    sta (SpriteObject),Y   
    ldy #SO_XOrd
    lda (SpriteObject),Y
    ldy #SO_PreviousX
    sta (SpriteObject),Y
    
    // now process the behaviours    
    ldy #SO_Behaviour
    lda (SpriteObject),Y
    cmp #1
    bne No_Behaviour_HorizontalMove
    jsr Behaviour_HorizontalMove          
    jsr SpriteStoreScreenAdrForXY                        
No_Behaviour_HorizontalMove:
    // move to next sprite to set up  
    // after all behaviours applied to a sprite we update the screen address and other
    // vars that are needed for erasing and plotting.  
    clc 
    lda SpriteObject
    adc #SpriteObjectStructureSize
    sta SpriteObject  
    bcc BehavioursLoop_NoCarry
    inc SpriteObject+1
BehavioursLoop_NoCarry: 
    dec NumSprites
  bne BehavioursLoop      
  rts  
 
 //______________________________________________________________________________________  
  
  
  
  
  
  
  
  
  
 //______________________________________________________________________________________  
 //______________________________________________________________________________________  
Behaviour_HorizontalMove:
 // horizontal move behaviour
 // moves the sprite until it reaches edge of screen, then reverses direction
 
 // on entry
 //   SpriteObject                  Pointer to sprite obect to apply this behaviour to   
 
 // on exit 
 //   A,Y,X,SR undefined
 

 // check if the move amount is only applied every so often (helps give a slower min 
 // speed)
 
 ldy #SO_MoveDelay
 lda (SpriteObject),Y
 beq NoMoveDelay                    
 tax                                  // save for possible use a little later
 // ok, we're delay the move, check the counter
 ldy #SO_CurrentMoveCount            // get the current counter
 lda (SpriteObject),Y
 sec
 sbc #1                              // subtract 1
 sta (SpriteObject),Y
 bpl Behaviour_HorizontalMoveEnd     // not a zero exit routine
 // is at zero, rest counter and we'll allow the move
 txa                                 // get the value we saved earlier
 sta (SpriteObject),Y                // reset counter back to start
 
 
NoMoveDelay:
 
 ldy #SO_XMoveAmount               // index into structure for the amount to move
 lda (SpriteObject),Y              // Get amount to move which is a signed byte
 bpl BHM_MoveRight                 // positive so moving right
 
 
 // move the sprite to the left by the move amount, reversing when left edge of screen
 // reached
 
 //  the bounds we need to check is the left side of screen (pos 0)
 
 ldy #SO_XOrd               // we're going to add the movement to the current x pos
 clc
 adc (SpriteObject),Y              // which of course, if we add a negative number to a
                                   // positive it's the same as taking it away.
 
 // we need to check if taking the movement away has gone past the left side of the 
 // screen, i.e. below zero. 
 
 bpl BHM_AllowMove                 // not gone past left part of screen, allow full move
 
 // ok we've gone past left side, there may be a small amount of movement to allow to 
 // get the sprite to the left hand side edge, depending on the size of the move. All we
 // need do is set it's X pos to 0 to move it there

 // reverse the move by making the move amount the positive opposite of the current value
 // to do this is basic signed byte maths. A number is it's signed opposite equivalent
 // if you invert it and add 1. This is called 2's complement, if you are not sure about
 // it look it up in any good assembler book for 8 bit micros.
 
 
 ldy #SO_XMoveAmount               // index into structure for the amount to move
 lda (SpriteObject),Y              // Get amount to move which is a signed byte
 eor #%11111111                    // EORing all 8 bits will invert the current value
 clc
 adc #1                            // add 1 to the inverted result and we've not got the
 sta (SpriteObject),Y              // positive opposite of the negative value we were 
                                   // using. And we store it back in the move amount loc.
 
  // swap the sprite for the one facing left, this is sprite id+1

 ldy #SO_SpriteID                             
 lda (SpriteObject),Y
 clc
 adc #1                             // set to previous sprite which is always right 
 sta (SpriteObject),Y                // facing one
   
 jsr SetSpriteGraphicAddress        // set the address of this sprite in the structure   
 
 ldy #SO_XOrd                               // XOrd
 lda #0                            //  set x pos to 0 position (left hand edge)
 
BHM_AllowMove:
 sta (SpriteObject),Y              // store new x pos back in current x position               
 
 rts                               // ** EXIT ROUTINE **
 
 
BHM_MoveRight:   
 // move the sprite to the right by the move amount, reversing when right edge of screen
 // reached
 
 ldy #SO_XOrd               // we're going to add the movement to the current x pos
 clc
 adc (SpriteObject),Y              
 tax                               // preserve the value calculated
 
 // now this check is a little tricker, as we need to add the sprite width too
 ldy #SO_Width
 adc (SpriteObject),Y              // we've now got the right hand edge of the sprite  
 
 cmp #ScreenWidth                  // check if equal or greater to the right hand side of 
                                   // the screen
 bpl BHM_PastRightEdge             // right edge of sprite is past right edge of screen
 
 // Not passed right edge, get the original value for x calculated baxk out of X register
 // and store in X Pos
 
 txa
 ldy #SO_XOrd    
 sta (SpriteObject),Y              // store new x pos back in current x position   
 rts                               // ** EXIT ROUTINE **
 
 
BHM_PastRightEdge:                // Reverse the  movement of the sprite and set the x 
                                   // pos to the max it can be to bring the sprite to the
                                   // right hand side of the screen
 sec
 sbc #ScreenWidth                  // take away screen width
                                   // the result is now the amount to take from x ord to
                                   // make the sprite sit neatly at the right hand edge
                                   // of screen
 sta Temp                          // preserve
 txa                               // get the preserved x ord value back
 sbc Temp                          // take the distance we are from right hand edge from
                                   // the current X ord value
 ldy #SO_XOrd   
 sta (SpriteObject),Y               // store in the x ord   
 
 // swap the sprite for the one facing left, this is sprite id-1

 dey                                // sets to sprite ID
 lda (SpriteObject),Y
 sec
 sbc #1                             // set to next sprite which is always left facing one
 sta (SpriteObject),Y
   
 jsr SetSpriteGraphicAddress        // set the address of this sprite in the structure  
 // reverse the move
                                                                
 ldy #SO_XMoveAmount               // index into structure for the amount to move
 lda (SpriteObject),Y              // Get amount to move which is a signed byte
 eor #%11111111                    // EORing all 8 bits will invert the current value
 clc
 adc #1                            // add 1 to the inverted result and we've not got the
 sta (SpriteObject),Y              // positive opposite of the negative value we were 
                                   // using. And we store it back in the move amount loc.  
                                   
  
                                   
 // now ensure the sprite is move to the last position it can to make it's right hand 
 // edge be at the right hand edge of the screen.
        
Behaviour_HorizontalMoveEnd:
 rts
                                                                                         
 //______________________________________________________________________________________  
  
  
  
  
  
  
 
 //______________________________________________________________________________________  
 //______________________________________________________________________________________   
SpriteSetEraseData:                                                         
  
  // first copy the current screen address to the last screen address location
  // this is the address used by any erase routine prior to plotting at the new address
  
  // On Entry
  //    SpriteObject
  
  
  // reset all flags that indicate which parts of sprite need erasing
  
  lda #0
  ldy #SO_EraseBottom          // part bottom char row erase flags
  sta (SpriteObject),Y
  iny                          // middle rows to erase
  sta (SpriteObject),Y
  iny                          // part top char row erase flags
  sta (SpriteObject),Y
  
  
  // transfer previous char row address that was plotted at to vars used by erase. We 
  // have to use seperate vars for erase and plot as any movement of the sprite is done
  // outside of any plot routine. The plot routine then plots the sprite in the new 
  // position but we need to erase the old sprite first so must store details of where
  // it was and what to erase etc.
  
 
  ldy #SO_ScreenAddress           
  lda (SpriteObject),Y             
  ldy #SO_LastScreenAddress       
  sta (SpriteObject),Y
  dey  
  lda (SpriteObject),Y 
  ldy #SO_LastScreenAddress+1
  sta (SpriteObject),Y     
  
  ldy #SO_Height                   // actually 1 less than true height as used as index
  lda (SpriteObject),Y                                                            
  clc                              // so add 1 to get true valeu that we need for this 
                                   // routine
  adc #1                           // need to add one as 1 to small
  sta RowsLeftToErase              // save the rows left to erase, initially all of them
 
  // copy the line index value
  
  ldy #SO_LineIndex               
  lda (SpriteObject),Y      

  // if Y<>7 then we hve some rows at bottom to erase in our erase routine else
  // if 7 it's a full row and we don't do a part bottom erase.
  cmp #7
  
  beq NoBottomPartRowsErased            
  ldy #SO_LineIndexErase        // only bother setting if a bottom erase is going to 
  sta (SpriteObject),Y          // occur
  ldy #SO_EraseBottom         
  lda #1                        // set the part bottom row flag to true
  sta (SpriteObject),Y
  
  // now subtract num rows that will be erased from height
  ldy #SO_Height
  lda (SpriteObject),Y                 
  ldy #SO_LineIndexErase             // take away any rows aleady plotted
  sec                                // Note that the value actually in SO_LineIndexErase
                                     // is actually 1 less than the number of rows 
                                     // erased as it is an index value, but height is
                                     // also 1 less than true height s it's an index also
                                     // As they are both 1 less than true values the 
                                     // result is actually the correct amount of rows
                                     // left to erase.
  sbc (SpriteObject),Y     
  sta RowsLeftToErase                // save the rows left to erase,
  
    
NoBottomPartRowsErased:
  
MiddleCharRows:
  // work out how many full chars rows to plot and the width in bytes of a char row if 
  // there are any to erase.   
  // for this we need the number of rows left to erase 
  // and divide by 8 (as 8 line rows per char row) to give number of middle char rows to 
  // plot. 

  
  lda RowsLeftToErase 
  tax    
  lsr
  lsr
  lsr
  beq NoMiddleRowsToErase           // and there were none to erase
  // some to erase, store the remainder left for any top erase
                 
  
  ldy #SO_NumMiddleRowsToErase    
  sta (SpriteObject),Y
  ldy #SO_EraseMiddle               // this will set the flag  
  sta (SpriteObject),Y              // as A is not zero         
  
  txa                               // get original rows to erase value back to remove
  and #%00000111                    // the char rows part leaving just the top rows part
  sta RowsLeftToErase               // in the var
                                      
  // now work out how many bytes per char row, for this it's the sprite width *8
  // but for the erase routine it wants it as an index to the byte so make 1 less
  ldy #SO_Width
  lda (SpriteObject),Y
  asl
  asl
  asl
  sec
  sbc #1                            // make 1 less to use it as an index to byte to erase
  ldy #SO_CharRowWidth
  sta (SpriteObject),Y
  
  // now store the char row for the middle erase rows part to work from initially
  // if no bottom row erase then it's just the same as the last row plotted at. If
  // there are bottom rows being erase then it's a char row line less ($280 bytes)
  
  ldy #SO_EraseBottom         
  lda (SpriteObject),Y
  beq NoBottomRows     
  // there were some bottom rows, get the screen address and subtract $280 to get start
  // for middle rows.            
  ldy #SO_LastScreenAddress           
  lda (SpriteObject),Y    
  sec     
  sbc #$80         
  ldy #SO_EraseScrAdrMiddle       
  sta (SpriteObject),Y        
  ldy #SO_LastScreenAddress+1   
  lda (SpriteObject),Y 
  sbc #2  
  ldy #SO_EraseScrAdrMiddle+1
  sta (SpriteObject),Y
  bne TopRowSection     
  
NoBottomRows:
  // there were not bottom rows erased so set erase char row start for middle section
  // to the last screen address
  
  ldy #SO_ScreenAddress           
  lda (SpriteObject),Y             
  ldy #SO_EraseScrAdrMiddle       
  sta (SpriteObject),Y
  ldy #SO_ScreenAddress+1  
  lda (SpriteObject),Y 
  ldy #SO_EraseScrAdrMiddle+1
  sta (SpriteObject),Y     
  
NoMiddleRowsToErase:
  
TopRowSection:
  // Work out the top section erase values for the erase routine.
  // first is there any rows to plot on top row
  lda RowsLeftToErase
  beq NoTopRowsToErase
  // some top rows to erase
  ldy #SO_EraseTop
  sta (SpriteObject),Y         // will set this flag to true
  // store the number of rows to erase
  ldy #SO_NumTopRows
  sec                          // needs to be less one as we use it as an index
  sbc #1
  sta (SpriteObject),Y
  
  // we need to work out the screen address to start this top section print. This is just
  // the previous Y and X ord values converted to screen address
  ldy #SO_PreviousY
  lda (SpriteObject),Y
  sta YOrd
  iny
  lda (SpriteObject),Y
  sta XOrd
  jsr ScreenStartAddress//
  ldy #SO_EraseTopScrAdr
  lda XYScreenAddress
  sta (SpriteObject),Y
  iny
  lda XYScreenAddress+1
  sta (SpriteObject),Y
  // this is the height-LineIdx
NoTopRowsToErase:
  rts 
 //______________________________________________________________________________________  
 
  
  
  
  
  
  
 //______________________________________________________________________________________  
 //______________________________________________________________________________________  
SpriteStoreScreenAdrForXY:
  // after any code that modifies the x and y ordintanates this code should be called
  // it updates the screen address to plot at for these ords. Done here rather than in 
  // the sprite plot loop to save time there where speed is more critical due to vsync.
 
  // The YOrd of the sprite is altered to the bottom of the sprite as plotting sprite to 
  // screen works more quickly if we plot from the bottom of the sprite back to the top 
  // (visually  upwards but actually going downwards in the sprite data and screen 
  // memory). The speed increase is due to flags that get automatically set when o
  // perations hit zero. So counting down in data rather than upwards is usually quicker 
  // and more effiecient on memory as we save on a CMP instruction. So we manipulate the  
  // YOrd here to be the value of Y at the bottom of the sprite. There is obviously a  
  // small time penalty for doing this here, but it saves more then we lose in the main 
  // loop of plotting.   
  
  
  // set up the erase data
  jsr SpriteSetEraseData  
  
  
  ldy #SO_Height         
  lda (SpriteObject),Y         // got height           
  clc                          // clear for addition  
  ldy #SO_YOrd                             
  adc (SpriteObject),Y          // add YOrd
                                                                                     
  sta YOrd                      // store result in YOrd. 
             
  dey                          // X ord is just before Y in structure                 
  lda (SpriteObject),Y          
  sta XOrd                     
  
  jsr ScreenStartAddress       // we've now got eh YOrds we wish to start plotting at
                               // so jump to this routine to get the address of that 
                               // part of the screen in memory.     
  
  lda XYScreenAddress 
  tax
  and #%00000111               // get the line part of the char row.
  ldy #SO_LineIndex            // used by sprite plotter, saves it working it out during
  sta (SpriteObject),Y         // the plot.
 
  
  txa                          // store char row start of where to plot
  and #%11111000               // saves the plot routine working it out during the plot
  ldy #SO_ScreenAddress  
  sta (SpriteObject),Y
  iny                  
  lda XYScreenAddress+1        // store high byte of char row address to start plot
  sta (SpriteObject),Y
  
  rts//            
 //______________________________________________________________________________________  
  
 

 
 
 
 
  
  
 //______________________________________________________________________________________  
 //______________________________________________________________________________________  
PlotSprites:
  // plots sprites to screen, erases any previous sprites first 
 
 
  //erase sprites first before re-plotting 
 
  lda #Const_NumSprites
  sta NumSprites
  
  lda #<GameSprites
  sta SpriteObject  
  lda #>GameSprites
  sta SpriteObject+1
  
WaitForEndOfDisplay:
  lda EndOfDisplayReached                     // loop round here until this location gets
  beq WaitForEndOfDisplay                     // set to not zero, indicating CRT has just
                                              // finished rendering end of visible screen  

EraseSpriteLoop:                          
    jsr EraseSprite     
   // move to next sprite to set up 
    clc 
    lda SpriteObject
    adc #SpriteObjectStructureSize
    sta SpriteObject  
    bcc EraseSpritesLoop_NoCarry
    inc SpriteObject+1
EraseSpritesLoop_NoCarry:    
    dec NumSprites
  bne EraseSpriteLoop       
 
  //plot
  lda #Const_NumSprites
  sta NumSprites
  
  lda #<GameSprites
  sta SpriteObject  
  lda #>GameSprites
  sta SpriteObject+1
  
PlotSpritesLoop:                        
    jsr PlotSprite     
   // move to next sprite to set up 
    clc 
    lda SpriteObject
    adc #SpriteObjectStructureSize
    sta SpriteObject  
    bcc PlotSpritesLoop_NoCarry
    inc SpriteObject+1
PlotSpritesLoop_NoCarry:   
    dec NumSprites
  bne PlotSpritesLoop            
  rts 
  
 //______________________________________________________________________________________  
 
 
 
 
 
 
 
 
 //______________________________________________________________________________________ 
 //______________________________________________________________________________________  
EraseSprite:
 // erases a sprite to the background colour (0)   
  // entry params
    // SpriteObject                // 2 zero page bytes holding address of the sprite 
                                  // structure of the sprite to erase        
  // workspace
    // Width                       : Width of sprite
    // Height                      : Height of sprite       
    // YStartOffset                :  Offset to add to the screen address toget bottom of
    //                             : of where to start a char row byte plot 
    // XYScreenAddress             : Temp location to plot erase bytes at 
 
 
  // we erase a sprite in 3 stages (for better performance).
  // the first part called BottomRow is any part character row at the bottom
  // the second (MiddleRows) stage are all the remaining full character rows above the 
  // bottom row and finally any part top row ( TopRow stage).
  
  ldy #SO_EraseBottom
  lda (SpriteObject),Y
  beq MiddleRows                   // no part bottom to erase

  ldy #SO_LastScreenAddress+1     // Get the hi value for the screen address for 
  lda (SpriteObject),Y            // the bottom of the  sprite, where erase starts.
  sta BottomRowEraseLoop+2        // now at start of char row, store in code below
  dey                             // Get the low value for the screen address for 
  lda (SpriteObject),Y            // the bottom of the  sprite, where erase starts.
  sta BottomRowEraseLoop+1        // store in code below
  
  ldy #SO_LineIndexErase          // part bottom rows to erase
  lda (SpriteObject),Y
  tax                             // put in x as our index counter
  stx Height                      // preserve for use in erase code

  // store the number of columns to erase
  ldy #SO_Width                   // Get the hi value for the screen address for 
  lda (SpriteObject),Y            // the bottom of the  sprite, where erase starts.
  sta Width
  tay                             // preserve width for use later
  
  lda #0                          // byte to write to screen to erase
BottomRowEraseLoop:
  sta $FFFF,X                     // usual dummy address filled in by code
  dex
  bpl BottomRowEraseLoop
  
  // start new column
  dec Width                             // decrement columns to plot
  beq EndBottomRowErase                 // no more to plot exit this part
  ldx Height                            // reset height 
  
  // next move screen address to plot at across one column
  lda BottomRowEraseLoop+1
  clc
  adc #8                                // adding 8 moves to next column
  sta BottomRowEraseLoop+1     
  lda #0                          // byte to write to screen to erase
  bcc BottomRowEraseLoop                // no carry go back to main loop
  inc BottomRowEraseLoop+2              // a carry, add it. Only occurs once every 32
  bcs BottomRowEraseLoop                // columns across the screen so overall speed
                                        // saved. Carry always set so branh occurs     
    
EndBottomRowErase:
MiddleRows:   
  
  // first check what we have left to plot, may not be a complete row, if not jump to
  // Top Rows stage    
   
  ldy #SO_EraseMiddle
  lda (SpriteObject),Y
  beq TopRows                           // no full middle rows to erase 
  
                          
  // store where to plot in our erase loop for speed
  ldy #SO_EraseScrAdrMiddle
  lda (SpriteObject),Y
  sta MiddleEraseLoop+1  
  iny 
  lda (SpriteObject),Y
  sta MiddleEraseLoop+2

  ldy #SO_CharRowWidth          // number of bytes to erase per char row, result of width
  lda (SpriteObject),Y          // * 8
  
  tax                           // put into loop counter
  sta Width                     // preserve here for later
 
  ldy #SO_NumMiddleRowsToErase          // number of char rows to erase  
  lda (SpriteObject),Y
  tay                               // Y contains num char rows to erase
MiddleEraseHeightLoop:
  lda #0                           // erase colour   
MiddleEraseLoop: 
  sta $FFFF,X                      // usual dummy address filled in by code
  dex
  bpl MiddleEraseLoop
  dey
  beq EndMiddleRowsErase           
  ldx Width                        // reload x ready for next char row to plot (if any)
  // ajdust screen address to next column up
  lda MiddleEraseLoop+1
  sec
  sbc #$80
  sta MiddleEraseLoop+1
  lda MiddleEraseLoop+2
  sbc #2
  sta MiddleEraseLoop+2
  bne MiddleEraseHeightLoop
  
  EndMiddleRowsErase:
    
  TopRows:   
  ldy #SO_EraseTop  
  lda (SpriteObject),Y
  beq EndErase                    // none to do
  ldy #SO_EraseTopScrAdr
  lda (SpriteObject),Y
  sta TopRowEraseLoop+1
  iny             
  lda (SpriteObject),Y
  sta TopRowEraseLoop+2

  ldy #SO_NumTopRows              // get width in bytes
  lda (SpriteObject),Y            //
  tax                             // use in X
  sta Height

  ldy #SO_Width                   // get width in bytes
  lda (SpriteObject),Y            //
  tay                             // use in Y
  
  lda #0                          // byte to write to screen to erase
TopRowEraseLoop:
  sta $FFFF,X                      // usual dummy address filled in by code
  dex
  bpl TopRowEraseLoop
  
  // start new column
  dey                            // decrement columns to plot
  beq EndTopRowErase             // no more to plot exit this part
  ldx Height                     // reset height 
  
  // next move screen address to plot at across one column
  lda TopRowEraseLoop+1
  clc
  adc #8                                // adding 8 moves to next column
  sta TopRowEraseLoop+1     
  lda #0                          // byte to write to screen to erase
  bcc TopRowEraseLoop                // no carry go back to main loop
  inc TopRowEraseLoop+2              // a carry, add it. Only occurs once every 32
  bcs TopRowEraseLoop                // columns across the screen so overall speed
                                        // saved. Carry always set so branh occurs     
    
EndTopRowErase:    
  
EndErase:
  rts 
 //______________________________________________________________________________________   
 
 
 
 
 
 
 
 
 //______________________________________________________________________________________ 
 //______________________________________________________________________________________   
SetUpGameScreen:
   // Sets up the game screen to how we want it
   
  // Switch to mode 2
  lda #$16
  jsr oswrch
  lda #2
  jsr oswrch
  // now in mode 2          
  
  // turn off the cursor, why not try writing to the 6845 chip directly to do this !

  lda #23
  jsr oswrch
  lda #1
  jsr oswrch    
  lda #0
  ldx #7
CursorOffLoop:
  jsr oswrch  
  dex
  bpl CursorOffLoop
 
  // redfine logical colour 8 to physical colour 4 (black), as we use logical colour 0
  // as the mask, so 8 becomes the new black
  
  lda #$C
  ldx #<LogicalColour8ToActualColour0
  ldy #>LogicalColour8ToActualColour0
  jsr osword
  
  // set background colour to blue     
  lda #$C
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
                                           
  lda #<IRQHandler                      // set the interupt request to be ours
  sta InteruptRequestVectorLow             // we don't preserve anything previous
  lda #>IRQHandler                      // note as interupts disabled it's safe to do this
  sta InteruptRequestVectorHi
   
  
  // set CA1 to interupt when Vysync occurs
  
  lda #%01111111                          // disable all 6522 interupts
  sta SysVIA_InteruptEnable               // we just want the ones we're interested in
  lda #%10000010                          // enable CA1 interupt (VSync input from 6845) 
  sta SysVIA_InteruptEnable
  lda #%00000100                          // Set CA1 to interupts when it gets a positive
                                          // edges, i.e. goes from 0 to 1
  sta SysVIA_PeripheralControl  
  
  
   // following sets timer 1 to timed interupt each time Timer1 loaded,Shift register
  // disabled,PB,PA Latches disabled      
  lda #0        
  sta SysVIA_AuxControl
  sta EndOfDisplayReached//
  cli                                     // finished setting up via, enable interupts  
  
  rts
LogicalColour8ToActualColour0:
  .byte 8                                 // logical colour 8
  .byte 0                                 // physical colour 0 (black)   
LogicalColour0ToActualColour4:
  .byte 0                                 // logical colour 8
  .byte 4                                 // physical colour 0 (black)
   
  
    
 //______________________________________________________________________________________ 
 
 
 
 
 
 
 
 //______________________________________________________________________________________  
 //______________________________________________________________________________________  
IRQHandler:  
 // fires when the interupt occurs.
 
  lda SysVIA_InteruptFlag           // look at the interupt flags of the system via
  and #%00000010                    // mask out all but CA1 (which is linked to Vsync 
                                    //  circuit), if set CA1 has had an active edge.
  beq notvsyncInterrupt             // not set check other interupts
                            
  sta SysVIA_InteruptFlag           // is set so vsync occurred, storing back clears interupt flag
  
  lda #%11000000                    // enable timer 1 interupt
  sta SysVIA_InteruptEnable
  lda #$C8                          // set timer1, this value is critical to the smooth scrolling of the routine
  sta SysVIA_Timer1CounterLatchLow
  lda #$46
  sta SysVIA_Timer1CounterLatchHi
  
  lda # 0
  sta EndOfDisplayReached           // Set to false            
  lda $FC                     // on entrying interupt A is put in FC, so get back
  rti                               // exit the interupt 
 
notvsyncInterrupt:    
  lda SysVIA_InteruptFlag           
  and #%01000000                    // checking if interupt was timer1
  bne Timer1Interrupt               // it was timer 1 
  lda $FC                     // on entrying interupt A is put in FC, so get back
 rti
  
Timer1Interrupt:                        
    // timer 1 has counted down so the CRT has just finished rendering the visible part
    // of the display
    sta SysVIA_InteruptFlag         // clear interupt flags
    sta SysVIA_InteruptEnable
    dec EndOfDisplayReached         // previous value was 0 so this makes it not zero     
  lda $FC                     // on entrying interupt A is put in FC, so get back
  rti
 
 //______________________________________________________________________________________ 
 
 
 
 
 
 
 
 //______________________________________________________________________________________  
 //______________________________________________________________________________________  
 
SetSpriteGraphicAddress:
 // sets the sprite graphic address in the structure for the sprite id in the structure
 
 // entry params
    // SpriteObject                 // 2 zero page bytes pointing to the sprite object
                                   // structure
                                   
                                   
    ldy #SO_SpriteID               // set index to sprite graphic ID (index into sprite
                                   // sprite collection structure).   
    lda (SpriteObject),Y           // got the sprite graphic ID (index)
    asl                            // x2 as two bytes per entry in sprite collections
    tay 
    lda Sprite,Y                   // get low order value of the offset to the graphic
                                   // data.  
    clc                                   
    adc #<Sprite                   // add to start of collection to get correct address
                                   // for the sprite graphic structure                      
    sta SpriteGraphicData          
    iny
    lda Sprite,Y                   // get hi order value of the offset to the graphic
                                   // data.       
    adc #>Sprite                   // add to start of collection to get correct address
                                   // for the sprite graphic structure
    sta SpriteGraphicData+1         
    
     
    // now we've got the pointer to the sprite graphic data, of which the first two bytes
    // are width and height, get these and put in the structure
    ldy #0
    lda (SpriteGraphicData),Y      // width
    ldy #SO_Width
    sta (SpriteObject),Y    
    ldy #1
    lda (SpriteGraphicData),Y      // height   
    sec                            // but for use later on we actually set the height to
    sbc #1                         // one less than it actually is. This is because later
                                   // we want  to add the height to the start of the 
                                   // sprite data later on for each column of data in the
                                   // sprite. This will give the index into the sprite
                                   // data where we want to pull data from. So if height
                                   // is 1 for example this would actually mean read from
                                   // the sprite data +1 which would actually be one
                                   // greater than where we wish to actualy get data from
                                   // So it needs to be one less. By using 4 cycles here
                                   // we save 10 cyles (using a DEY) later in our column
                                   // loop for a typical 5 byte wide sprite. Not much at a
                                   // all, but better saved than wasted ! 
                                   // we'd lose on a 1 byte wide sprite but break even on
                                   // just a 2 byte wide sprite and save more cycles on
                                   // anything above that, an most sprites are move than
                                   // 2 byte wide in a typical game. Anything less and you
                                   // should consider a specialised plot routine.
    ldy #SO_Height
    sta (SpriteObject),Y
    // stored the width and height, now store the start of the sprite graphical data
    // which is just after height
    lda SpriteGraphicData          // get low value of start of graphical structure
    clc
    adc #2                         // add 2 to move past width and height
    ldy #SO_GraphicData            // store low value in the low byte of the address
    sta (SpriteObject),Y           // stored low value of address
    lda SpriteGraphicData+1        // high byte       
    adc #0                         // add in any carry
    ldy #SO_GraphicData+1          // store hi value in the low byte of the address
    sta (SpriteObject),Y           // stored hi value of address
  rts     
 //______________________________________________________________________________________  
 
 
 
 
  
 
 //______________________________________________________________________________________  
 //______________________________________________________________________________________   
SetUpSprite:
  // Sets up the sprite structure with values that need to be copied from the sprite
  // i.e. sprite graphic structure address, width and height
  
  // entry params
    // SpriteObject                 // 2 zero page bytes pointing to the sprite object
                                   // structure
  // on exit
    // SpriteObject                 // various parts of structure filled with values
    // Y corrupted
    
    // First let's get the address of the sprite graphic structure
    
    jsr SetSpriteGraphicAddress
    
    // now set up initial screen address
    jsr SpriteStoreScreenAdrForXY
    // note when a sprite is intially set up the last screen address it plotted at will
    // be invalid, even after calling SpriteStoreScreenAdrForXY as there was no previous
    // screen address.
    // so we callt the erase code that is called within the screen address code again 
    // There is a slight speed penatly using a JSR here and within the ScreenAdr routine.
    // We could for example just repeat the code that copies the erase stuff in the
    // screenadr rotuine to here. but it was a significant amount and when updating code
    // it was easy to forget to do it again here. Also we only repeat when setting up the
    // sprite and never when we're plotting to screen after a vsync event.
    jsr SpriteSetEraseData
       
  rts  
   
 //______________________________________________________________________________________  
 
 
 
 
 
 
 
 
 //______________________________________________________________________________________  
 //______________________________________________________________________________________ 
 
PlotSprite:
  // Plots a masked Mode 2 sprite to mode 2 screen. 0 denotes a masked pixel.
  // your sprite most wholly fit on the screen, partly off the screen in any direction is
  // not permitted and will break the code. However this is suitable for a lot of games.
  
  // entry params
    // SpriteObject                // 2 zero page bytes holding address of the sprite 
                                  // structure of the sprite to plot        
  // workspace
    // Width                       : Width of sprite
    // Height                      : Height of sprite       
    // YStartOffset                :  Offset to add to the screen address toget bottom of
    //                             : of where to start a char row byte plot    
    
  ldy #SO_Width                   // set index to where width is stored
  
  lda (SpriteObject),Y            // get width
  sta Width                       // of this sprite and store it
  
  iny                             // move to height (always after width)
  
  lda (SpriteObject),Y             // get height, which is 1 less than true height    
  sta Height                      // Store it.                               
                               
  ldy #SO_LineIndex               // line part of start of char row to plot at
  lda (SpriteObject),Y                                     
  tax                             // transfer to X as we're using this in indexed 
                                  // addressing later on.
                                     
  sta YStartOffset                // Preserve the row line component for use later, 
                                  // as we'll need it again when plotting the next 
                                  // column of sprite data.      
                                     
  ldy #SO_ScreenAddress+1        // hi byte of address of char row start address
  lda (SpriteObject),Y
  sta XYScreenAddress+1
  dey   
  lda (SpriteObject),Y
  sta XYScreenAddress
  
  // now we come to something that can throw some people off....
  // To move blocks of data in memory (in this case sprite data to screen) we need to
  // used indexed addressing. There are two main types available to use for what we need
  // to do. "Post indexed indirect addressing" and "Absolute Indexed Addressing". Look
  // them up in the advanced user guide. To use post indexed to read from the sprite
  // memory and write to the screen memory would take 6 cycles per instruction, so 12 
  // cycles all together for the read from sprite and write to screen combined.
  
  // However Ablsolute Indexed would take 5 cycles per instruction, or a saving of 2 
  // cycles per read/write to screen. May not sound much ? But that saving is for every
  // single byte of sprite data. An average sprite of say 5 bytes (10 pixels across) by
  // 20 bytes down would be 100 bytes of data to read and write for one sprite, or 200
  // cycles to potentially save, multiply this again by the number of sprites you have
  // in your game, say 5 and that's 1000 CPU cycles saved. You could certainly write
  // a lot of your game logic code in the time saved in your sprite plotter !
  
  // The slight downside is that there is some setting up to do per sprite which equates
  // to about 40 cycles per sprite. But still a large saving overall. If however you 
  // were plotting a lot of small sprites (less than 20 bytes in size) this might not
  // be the most efficient way to plot and you would need to re-evaluate whether to
  // have a second more optimsed plotter for small sprites.
  
  // The other downside is that the Absolute Addressing technique has to write it's base
  // address into the code (so it's basically self modifing code). This would make this
  // tehnique absolutly useless if ran from ROM where you cannot have self modifing code
  // as you cannot write to ROM. But in mose games this is not an issue.
  
  // ok, all that said, we need to copy our screen start address to plot at and our 
  // sprite address to read from into our plotting code.
  
  sta ScreenPixelAddress+1          // A has screen address low byte, Store in the 
                                    // memory location of the STA $FFFF instruction below  
                                               
  sta ScreenPixelAddressForLoad+1   // store here also, this is part of the code that
                                    // pulls in the current byte on the screen for use
                                    // when working out which pixels to plot (as this is
                                    // a masked sprite).
                                    
  lda XYScreenAddress+1             // Get high byte of screen address and store in
  sta ScreenPixelAddress+2          // high byte of address to plot at in the code below
  
  sta ScreenPixelAddressForLoad+2   // and in this location too. this is part of the code 
                                    // that pulls in the current byte on the screen for 
                                    // use when working out which pixels to plot (as this 
                                    // is a masked sprite).
 
  // we need to store the start of the actual graphic data into the code so it can
  // read from it.
  
  // note we are not clearing the carry flag prior to this addition as it is set to 
  // cleared on exit from the ScreenAddressStart routine which was called above.
  
  ldy #SO_GraphicData               // get the graphical data start stored in structure
  lda (SpriteObject),Y              // get low byte value of sprite data address
  sta SpritePixelAddress+1          // store in code below as discussed for ABS indexed
                                    // addressing
  
  iny                                                                           
  lda (SpriteObject),Y              // get high byte value of sprite data address
  sta SpritePixelAddress+2          // store in code below as discussed for ABS indexed
                                    // addressing
  
  // ok the main plot bit, X register cotains index to start of screen location when 
  // combined with the character row address in XYScreenAddress, which itself has been
  // transferred to ScreenPixelAddress+1,2 and ScreenPixelAddressForLoad+1,2 below
  
  // Y register is uised to index into the sprite data, initially set to height as we
  // are plotting from the bottom of the sprite upwards.
  
  // we plot 1 column of sprite data at a time.
  
  PlotXLoop:                                    // the column to plot loop
    ldy Height                                  // set Y to the height of the sprite, in
                                                // fact height is set to height less 1,
                                                // so Y will be height less 1 also. See
                                                // notes above, but basically we save
                                                // 2 cycles per pass of the column loop
                                                // here by not having a DEY instruction.
      
    PlotLoop:                                   // plots the full column of data
      SpritePixelAddress:
      lda $FFFF,Y                               // dummy address, will be filled in by 
                                                // code, loads the sprite pixel
      sta pokeme+1                              // store it to LSB of this address, so it
                                                // acts as an index into a mask table for 
                                                // this byte 
      ScreenPixelAddressForLoad:
      lda $FFFF,X                               // dummy screen address, will be filled 
                                                // in by code, get's byte at screen 
                                                // location to plot at
      pokeme:       
      and MaskTable                             // and the byte at the screen address 
                                                // with the mask table, this address has 
                                                // been altered by the above code
                                                // note that because we're using the LSB 
                                                // of this address to act as an index the
                                                // Mask tabel must be aligned on a page 
                                                // boundary for this to work
      ora pokeme+1                              // now OR the sprite pixel byte with the 
                                                // masked byte from the screen, remember
                                                // it was stored at pokeme+1 to act as an
                                                // index into the mask table
      ScreenPixelAddress:
      sta $FFFF,x                               // finally store the combination of 
                                                // screen and sprite byte back to screen
      dex                                       // move to next byte up
      bmi MoveToNextScreenAddresBlockUp         // New column ? if yes branch to code to 
                                                // alter addresses.
      ReturnFrom_MoveToNextScreenAddresBlockUp: // return from above jump, note quicker 
                                                // overall to have a return branch here 
                                                // as it will only occur once in 8 DEX's,
                                                // saving the 7 cycles for the loss of 3
                                                // braching if not 0 would have cost 7 
                                                // cycles for the gain of 3, so overall 4
                                                // cycles faster
      dey                                       // decrement the pointer to the sprite 
                                                // data, if it hits zero we need to 
                                                // adjust to start of next column
    bpl PlotLoop                                // keep on plotting, still got pixels 
                                                // left in the column to plot
    dec Width                                   // decrement width in bytes
    beq EndPlotSprite                           // has all sprite been plotted out, if so
                                                // exit
    
    // still got some columns to plot so adjust sprite data to start at top of next 
    // column (we add the Y index on later to get to bottom of column data)
    
    sec                                        // note height is actually 1 less than the
    lda SpritePixelAddress+1                   // real height, so we actually set the 
    adc Height                                 // carry flag here instead of clearing it
    sta SpritePixelAddress+1                   // to effectivly add the real height
                                               // See above as to why height is 1 less
                                               // than real height (saves us some time
                                               // at start of column plot loop).
    bcc NoIncToSpritePixelHighByte
    inc SpritePixelAddress+2           
    clc
    NoIncToSpritePixelHighByte:    
    lda XYScreenAddress                        // move to next column on screen
    adc #8                                     
    sta XYScreenAddress
    sta ScreenPixelAddress+1   
    sta ScreenPixelAddressForLoad+1
    bcc NoIncToXYScreenAddressHiByte            // the vast majority of times (31 out of 
                                                // 32) this jump occurs, so save 3 cycles
                                                // 31 times by not having to add any carry
                                                // to the hi byte of the Screen Address.
                                                // Every 32 positions we use 2 extra
                                                // cycles. If a sprite is split over a 
                                                // boundary then will always plot a bit
                                                // slower. But generally performance will
                                                // be quicker.
    inc XYScreenAddress+1                       // if here carry is set, increment the hi
                                                // byte to relect this carry. We don't do
                                                // a normal ADC as this would be overall
                                                // slower when your just adding a carry
                                                // and no other value     
    
    NoIncToXYScreenAddressHiByte:  
    lda XYScreenAddress+1       
    sta ScreenPixelAddress+2   
    sta ScreenPixelAddressForLoad+2
    ldx YStartOffset           
  bpl PlotXLoop                                 // The overflow flag (negative flag) 
                                                // will never be set here as the max
                                                // Y offset that can occur is 7 so it's 
                                                // always a positive loaded into X, note 
                                                // 0 counts as positive also    
  EndPlotSprite:         
  rts                   
MoveToNextScreenAddresBlockUp:

  // yes we moved to another character row up on screen, so change base address of screen
  // start and start plotting from that
  
  sec                                         // we do this by subbing $280 from value to 
                                              // get to next row
  lda ScreenPixelAddress+1
  sbc #$80
  sta ScreenPixelAddress+1                    // again we need ot store these in the two
  sta ScreenPixelAddressForLoad+1             // locations required.
  lda ScreenPixelAddress+2
  sbc #2        
  sta ScreenPixelAddress+2  
  sta ScreenPixelAddressForLoad+2
 
  ldx #7                                      // reset X to 7  (bottom of screen column)
  bne ReturnFrom_MoveToNextScreenAddresBlockUp  
  // end  MoveToNextBlockUp  
  
 //______________________________________________________________________________________ 
  
  
 
 
 
 
 
  
 //______________________________________________________________________________________ 
 //______________________________________________________________________________________      
  
ScreenStartAddress:
    // calculates the screen start address for a mode 2 screen given X,Y ords
    // no check is made to see if X and Y are valid on screen ords, if they are not then
    // the address returned will not be valid and writing to it could well corrupt the
    // main program
    
    // entry params
      // XOrd is X
      // YOrd is Y, 
    
    // exit results  
      // XYScreenAddress,XYScreenAddress+1   contain the calculated screen address 
      // Carry flag will be cleared.  
        
    // workspace
      // Temp                              
  
    // The calculation for this routine is :
    // result=ScreenStartAddress+((((Y div 8)*640)+(Y and 7)) + X * 8)           
      
   
    // first we are going to perform the (Y div 8)*640 part of the calculation   
    // this will give us the character row start (not the pixel row yet)
                                                                   
    // The Y ord is actually in pixels (0 to 255 down the screen) There are 8 pixel rows 
    // per character row (see screen layout diagram)
    // so divide Y by 8 to get character rows  
    
    lda YOrd                          // load A with the value of the Y ordinate 
    and #248                          // make lower three bits zero (see next paragraph)
    lsr                               // effect divide by 2
    lsr                               // effect divide by 4
    
    // but hang on... we need to divide by 8 but we've only divided by 4 !
    // well the 640 lookup table is a table of 2 byte values, so to index into it we
    // need to set the index to 2 times it's value to index to the correct value
    // by only dividing by 4 effectivly means our value is already 2 times bigger
    // so we save on an ASL instructionm =1 byte and 2 cycles. 
    // The and #248 at the begining ensured that the last bit not LSR's out of the 
    // accumulator is set to zero, in fact we could have just used AND #251 if we'd
    // wanted to jsut to zero the bit that would be left
                                                                     
    // we use a 640 multiplication look up table to speed things up. Referring to the
    // screen layout, the start of each character row jumps by 640 in memory compared
    // to the previous and there are 32 character rows down the screen (256 pixel rows)
    // so we need 32 entries in our multiplication table and as each entry is two bytes
    // each (as results can go beyond what a single byte can hold), the total table size
    // is 64 bytes. To look up 0 * 640 would mean the low byte of the result is in the
    // very first byte and the high byte is in the second byte of the table. 
    // 1 *640, would have the result in byte 2 and 3 etc. etc.        
                                      
    tay                               // we will use register Y to index into the table
                                      // so move the index value into Y
    lda LookUp640,Y                   // look up low byte value first
    sta XYScreenAddress               // and store in low byte of result
    iny                               // move the index to point to the high byte in the
                                      // table
    lda LookUp640,Y                   // get the high byte result of the mulitplication
    sta XYScreenAddress+1             // store in the high byte of the result
    
    // we have now got the value of (Y div 8)*640 in our result bytes
    
    // now add (Y AND 7) to the result bytes, this will give us the pixel (rather than
    // character row) value. All we are doing is wanting to add in the lowe 3 bits of Y
    // to the result of the character row. See the screen layout diagram if unsure.
    
    lda YOrd                          // get the Y
    and #7                            // strip out all but lower 3 bits
                                      
    // note that normally you would ensure the carry flag is clear here by having a CLC
    // instruction. However right at the begining of this routine we masked out the lower
    // 3 bits of A and then used LSR, this would ensure the carry flag is currently clear
    // as no other instructions have been used that effect it since then
    // Note that it's critical the AND #248 occurred before the LSR, you could have had
    // code that came to the same result if you'd LSR, LSR then AND #1 to set bit 0 to 0
    // but you would have then not known the state of the carry flag
    
    adc XYScreenAddress               // add lower 3 bits of Y to result. Even though the
                                      // current result is a 16 bit value we only need to  
                                      // add to low byte as will never trigger a carry as
                                      // only adds a max value of 7 to a value that will 
                                      // always be at least 8 less than 255
    sta XYScreenAddress               // store the new result
    
    // now add this result to the ScreenStartAddress
    // note again we know that the carry is clear, so no CLC
    // also note the screen start address is $3000 (i.e. lower value is 00) we need
    // only add the high byte value to the high byte of our current result (no point
    // adding 0 to anything as the result would not change !)
    
    lda #ScreenStartHighByte             // high byte value of screen start address
    adc XYScreenAddress+1                // add to current high byte value
    sta XYScreenAddress+1                // store result back in high byte value
    
    // now add the result of X*8 to the current result 
    // For every X pixel we need to add 8 bytes, for this we won't use
    // a look of table as it's quite easy and quickish to multiply by 8. 
    // It is true that it would be quicker with a look up table but it would take
    // about 320 bytes for only a small gain
    
    // first X*8    
    
    // carry will still be clear, no need to clear
    
    lda #0
    sta Temp     // temp store for hi byte value of result
    lda XOrd   
    asl          // effective * 2
                 // no need to do a rol for high byte as max result at this point is 
                 // 79 *2 =158
    asl          // effective * 4
                 // the max result now will be 79*4=316 ( $13C), so the carry contains
                 // the high byte if any to add to the high byte of the result, put it in
                 // a temp var
    rol Temp     // will effectivly clear carry as well, see below     
    asl          // effective * 8
    rol Temp     // could be another carry so roll into temp
                 // will effectivly clear carry as well (as temp was 0 at start and max 
                 // two shifts occurred, see below for use of cleared carry   
    
    // ok got result of X*8, now add to current result
    // no need for CLC as carry flag will be 0 as we know that the max result possible is 
    // 79 *8 =632 which is $278, so only ever will have a max value of 2 in Temp so all 
    // that would  have been ROL'd out when doing the "rol Temp" into carry will have 
    // been 0's
   
    adc XYScreenAddress               // add A (low value of multiply to low value of
                                      // result
    sta XYScreenAddress               // store in low value of result
    lda Temp                          // high byte result of multiplication
    adc XYScreenAddress+1             // add to high byte of result with any carry
    sta XYScreenAddress+1             // store in high byte of result
    rts
  // end ScreenStartAddress   
   
 //______________________________________________________________________________________ 
  
  
LookUp640:                          // a 640x multiplication table
.import binary "LookUpTable640.bin"
  
Sprite:                             // The sprites we're plotting
.import binary  "Sprite.bin"                    // "column order, no fixed width or height"
                                      // Swift format byte will have been stripped from
                                      // start.
  
  
   