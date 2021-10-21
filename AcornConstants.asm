
// ****************** Operating system **********************
.label oswrch = $ffee  
.label osbyte = $fff4
.label osword = $fff1
.label InteruptRequestVectorLow = $204   
.label InteruptRequestVectorHi = $205 
// **************** end Operating System ********************

                                       
//*********************** Hardware **************************
// 6845 Video Controller  FE00 TO FE01
.label CRTC_AccessRegister = $FE00
.label CRTC_RegisterValue = $FE01   
.label ACCCON = $FE34 // access control register, shadow ram etc.

// System VIA FE40 TO FE4F               
.label SysVIA_PortB = $FE40   // lower 3 bits point to 8 bit addressable latch, 4th bit is the value to put in latch
.label SysVia_PortAHandshake = $FE41    
.label SysVIA_DataDirectionPortB = $FE42
.label SysVIA_DataDirectionPortA = $FE43
.label SysVIA_Timer1CounterLatchLow = $FE44  // Read, get counter value, write set latch value
.label SysVIA_Timer1CounterLatchHi = $FE45   // NB : 44,45 & 45,47 seem very similer and indeed are
.label SysVIA_Timer1LatchLow = $FE46      // but fe46,47 do subtly different things, i.e. reading 46 does not rest Timer 1 Interupt flag
.label SysVIA_Timer1LatchHi = $FE47     // see a 6522 description for more information. in general use 44,45
.label SysVIA_Timer2Low = $FE48
.label SysVIA_Timer2Hi = $FE49         // Timer 2 is simpler, always resets it's interupts etc.
.label SysVIA_ShiftRegister = $FE4A
.label SysVIA_AuxControl = $FE4B
.label SysVIA_PeripheralControl = $FE4C
.label SysVIA_InteruptFlag = $FE4D
.label SysVIA_InteruptEnable = $FE4E
.label SysVIA_PortANoHandshake = $FE4F


//********************* End Hardware ***********************

//*************** internal Key numbers *********************
                     
.const Key_L = $56    
.const Key_X = $42   
.const Key_Z = $61        
.const Key_Shift = $0
.const Key_Colon = $48
.const Key_SemiColon = $57  
.const Key_ForwardSlash = $68
//************* end Internal key numbers *******************   