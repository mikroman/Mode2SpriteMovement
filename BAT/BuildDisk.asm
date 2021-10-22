ORG &1900

.CodeStart
INCBIN "bin/Program.bin"
.CodeEnd

SAVE "MAIN", CodeStart, CodeEnd
PUTFILE "MASK",&900