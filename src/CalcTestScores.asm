; Program name: Test Score Calculator
; A Team Last Minute program
; Authors: Kevin Chavez, Julissa Mota, Jasmine Gaona, Brian Cabrera
; Description: An LC-3 program that displays the minimum, maximum, and
;	       average grade of 5 test scores and displays the letter
;	       grade associated with the test scores
; Input: User is prompted to input the test scores via keyboard
; Output: Displays maximum, minimum, average score and letter grade
;	  equivalence (0 - 50 = F, 60 - 69 = D, 70 - 79 = C, 
;	  80 - 89 = B, 90 - 100 = A) on the console

; MAIN ROUTINE
.ORIG x3000
LEA R0, PROMPT_WELCOME
PUTS
LD R0, NEWLINE
OUT
START			; where we reset the program if the user chooses
AND R0, R0, x0		; clear R0 to reset array size
ST R0, ARRAYSIZE
JSR CLEARSTACK
LEA R0, PROMPT_5SCORES
PUTS
LD R0, NEWLINE
OUT
LOOP_SCORES
LEA R0, PROMPT_ENTERPLS
PUTS
JSR KBNUMIN
ADD R3, R3, x0		; check if the user left the input blank
BRzp CONT_SCORE_LOOP
LEA R0, PROMPT_NO_IN
PUTS
LD R0, NEWLINE
OUT
LEA R0, PROMPT_END	; ask whether to end program
PUTS
LD R0, NEWLINE
OUT
JSR YESORNO
ADD R3, R3, x0
BRp ENDPROGRAM		; user entered yes, so end program
LEA R0, PROMPT_CLEAR	; ask whether to clear previously entered scores
PUTS
LD R0, NEWLINE
OUT
JSR YESORNO
ADD R3, R3, x0
BRz LOOP_SCORES		; NO: keep all previously entered scores and continue loop
BRp START		; YES: clear all previously entered scores, so restart program
CONT_SCORE_LOOP
JSR STACK2NUM		; try to add the input to the stack
ADD R3, R3, x0		; check if push was successful
BRp LOOP_SCORES_CHK
LEA R0, PROMPT_ERR_IN	; let user know there was an error parsing the input
PUTS
LD R0, NEWLINE
OUT
LOOP_SCORES_CHK
LD R0, ARRAYSIZE
ADD R0, R0, #-5		; check if 5 scores were entered
BRn LOOP_SCORES		; back to top if array size < 5
LEA R0, PROMPT_DISPMAX	; display highest entered score
PUTS
JSR PRINTMAX
LD R0, NEWLINE
OUT
LEA R0, PROMPT_DISPMIN	; display lowest entered score
PUTS
JSR PRINTMIN
LD R0, NEWLINE
OUT
LEA R0, PROMPT_DISPAVG	; display average of all entered scores
PUTS
JSR PRINTAVG
LD R0, NEWLINE
OUT
LEA PROMPT_END		; ask user whether to end the program
PUTS
LD R0, NEWLINE
OUT
JSR YESORNO
ADD R3, R3, x0
BRz START		; user entered yes, so restart program
ENDPROGRAM HALT		; halt program

; MAIN ROUTINE DATA
PROMPT_WELCOME	.STRINGZ "Welcome to the Test Score Calculator!"
PROMPT_HITENTER	.STRINGZ "Press the enter button when you are finished typing a score."
PROMPT_5SCORES	.STRINGZ "Please enter 5 test scores (0-100)."
PROMPT_ENTERPLS	.STRINGZ "Type in the next test score: "
PROMPT_NO_IN	.STRINGZ "No numbers inputed."
PROMPT_END 	.STRINGZ "Would you like to end the program? (Y/N)"
PROMPT_ERR_IN	.STRINGZ "There was an error processing your input. Try again."
PROMPT_CLEAR	.STRINGZ "Clear all previously entered scores? (Y/N)"
PROMPT_DISPMAX	.STRINGZ "Highest score: "
PROMPT_DISPMIN	.STRINGZ "Lowest score: "
PROMPT_DISPAVG	.STRINGZ "Average score: "
NEWLINE		.FILL xA
SCOREARRAY	.BLKW 5
ARRAYSIZE	.FILL x0

; ---------------------------------------------------------------------------------------------

; Below, you will find various related subroutines and labels grouped

; ---------------------------------------------------------------------------------------------

; main program subroutines

KBNUMIN			; processes KB input and pushes total value to stack
ST R7, MAINR7		; set R3 to 1 if at least 1 value is on the stack, -1 otherwise
ST R1, MAINR1
ST R2, MAINR2
ST R4, MAINR4
AND R4, R4, x0		; we use this to check if the user entered no values
KB_LOOP
GETC
ADD R1, R0, x0		; copy keyboard input to parameter
JSR FROMASCII
LD R2, NASCII0
ADD R1, R2, R3		; check if the character is below ASCII 0
BRn NOTASCIINUM
LD R2, NASCII9
ADD R1, R2, R3
BRp NOTASCIINUM		; check if character is above ASCII 9
OUT			; Mirror the character back to the console
ADD R0, R3, x0		; copy R3 to R0 to be pushed
JSR PUSH
ADD R3, R3, x0
BRz ENDKBIN		; return if there was an error pushing to the stack
ADD R4, R4, x1		; add to R4 to signify at least 1 value is in the stack
BR KB_LOOP		; process next character
NOTASCIINUM
LD R2, 0xA
NOT R2, R2
ADD R2, R2, x1		; R2 = -0xA, ASCII value of newline
ADD R1, R2, R3		; check if user entered a newline (i.e. pushed enter)
BRz ENDKBIN
BR KB_LOOP		; User entered a character not newline or enter, so do nothing
ENDKBIN
AND R3, R3, x0		; here we will set R3 to indicate whether there is a value on the stack
ADD R3, R3, #-1
ADD R4, R4, x0
BRz ENDKBIN2		; if R4 is zero, then no characters were enterred
ADD R3, R3, x2		; add 2 since R4 != 0, making R3 = 1
ENDKBIN2
LD R1, MAINR1
LD R2, MAINR2
LD R4, MAINR4
LD R7, MAINR7
RET
MAINR7	.FILL x0
MAINR1	.FILL X0
MAINR2	.FILL x0
MAINR4	.FILL x0

STACK2NUM		; turns values in the stack into integer and adds to input array
ST R0, TONUMR0		; put 1 into R3 if successful, -1 otherwise
ST R1, TONUMR1
ST R2, TONUMR2
ST R4, TONUMR4
ST R5, TONUMR5		; save registers
LD R5, NEG100		; we will be using this multiple times
AND R2, R2, x0
ADD R2, R2, x1		; R2 = 1
AND R4, R4, x0		; we will store the total from parsing here
POPPIN_LOOP
JSR POP
ADD R3, R3, x0
BRn STACKEMPT		; stack empty, so break out from loop
ADD R1, R3, x0		; copy R3 to R1 to be multiplied
JSR MULT
ADD R4, R3, R4		; add result to total
ADD R1, R4, R5		; check if R4 < 100
BRp STCK2ERR
AND R1, R1, x0
ADD R1, R1, #10
JSR MULT		; we move up by a factor of 10, the first number is in the 1's place
ADD R2, R3, x0		; copy result to R2 for next loop iteration
BR POPPIN_LOOP
STACKEMPT
ADD R4, R4, x0
BRn STCK2ERR		; total was somehow negative
LD R1, ARRAYSIZE	; array size doubles as an offset
LEA R2, SCOREARRAY	; R2 now holds address of SCOREARRAY
STR R4, R2, R1		; store total to address of SCOREARRAY + R1
ADD R1, R1, x1		; increase array size by 1
ST R1, ARRAYSIZE	; save new array size
AND R3, R3, x0
ADD R3, R3, x1		; R3 = 1, siginifying successful addition to array
S2NFIN
LD R0, TONUMR0
LD R1, TONUMR1
LD R2, TONUMR2
LD R4, TONUMR4
LD R5, TONUMR5		; restore registers
RET
STCK2ERR
AND R3, R3, x0		; stack was empty
ADD R3, R3, #-1		; or value was going to be larger than 100
BR S2NFIN		; return without adding to the array
; STACK2NUM subroutine data
TONUMR0	.FILL x0
TONUMR1	.FILL x0
TONUMR2	.FILL x0
TONUMR4	.FILL x0
TONUMR5	.FILL x0
NASCII0		.FILL #-48	; we use these to check if keys are 0-9
NASCII9		.FILL #-57
NEG100		.FILL #-100	; 100 is the max score

PRINTAVG
ST R0, AVGR0
ST R1, AVGR1
ST R2, AVGR2
ST R3, AVGR3
ST R4, AVGR4
ST R7, AVGR7		; save registers
AND R4, R4, x0		; we will keep track of the loop iteration in R4
AND R0, R0, x0		; we will store our total here
LEA R2, SCOREARRAY	; put the address of the score array in R2
AVERAGE_LOOP
LDR R1, R2, R4		; put nth element of array into R1
ADD R0, R1, R0		; add to total
ADD R4, R4, x1		; increment counter
ADD R3, R4, #-5		; loop condition check
BRn AVERAGE_LOOP	; back to top of loop if we've looped < 5 times
ADD R1, R0, x0
AND R2, R2, x0
ADD R2, R2, x5		; load parameters for division subroutine
JSR DIV			; get mean by dividing total by 5
ADD R3, R3, x0		; copy result to R0
JSR PRINTNUM		; print R0 to console
LD R0, AVGR0
LD R1, AVGR1
LD R2, AVGR2
LD R3, AVGR3
LD R4, AVGR4
LD R7, AVGR7		; restore registers
RET
AVGR0	.FILL x0
AVGR1	.FILL x0
AVGR2	.FILL x0
AVGR3	.FILL x0
AVGR4	.FILL x0
AVGR7	.FILL x0

PRINTMAX
ST R1, MAXR1
ST R2, MAXR2
ST R3, MAXR3
ST R4, MAXR4
ST R5, MAXR5
ST R7, MAXR7		; save registers
AND R4, R4, x0		; loop counter
AND R0, R0, x0		; we will store the maximum found here
LEA R1, SCOREARRAY	; load address of score array into R1
MAX_LOOP
LDR R2, R1, R4		; load SCOREARRAY[R4] into R2
NOT R2, R3
ADD R3, R3, x1		; R3 = -R2
ADD R3, R3, R0		; compare R3 to R0
BRzp MAXLCHECK		; current loop value is smaller or equal if R3 isn't negative
ADD R0, R2, x0		; update to new maximum
MAXLCHECK
ADD R4, R4, x1		; increment counter
ADD R3, R4, #-5		; continue looping if counter < 5
BRn MAX_LOOP
JSR PRINTNUM		; print R0
LD R1, MAXR1
LD R2, MAXR2
LD R3, MAXR3
LD R4, MAXR4
LD R5, MAXR5
LD R7, MAXR7		; restore registers
RET
MAXR1 .FILL x0
MAXR2 .FILL x0
MAXR3 .FILL x0
MAXR4 .FILL x0
MAXR5 .FILL x0
MAXR7 .FILL x0

PRINTMIN
ST R1, MINR1
ST R2, MINR2
ST R3, MINR3
ST R4, MINR4
ST R5, MINR5
ST R7, MINR7		; save registers
AND R4, R4, x0		; loop counter
AND R0, R0, x0		; we will store the minimum found here
LEA R1, SCOREARRAY	; load address of score array into R1
MIN_LOOP
LDR R2, R1, R4		; load SCOREARRAY[R4] into R2
NOT R2, R3
ADD R3, R3, x1		; R3 = -R2
ADD R3, R3, R0		; compare R3 to R0
BRn MINLCHECK		; current loop value is smaller or equal if R3 isn't negative
ADD R0, R2, x0		; update to new minimum
MINLCHECK
ADD R4, R4, x1		; increment counter
ADD R3, R4, #-5		; continue looping if counter < 5
BRn MIN_LOOP
JSR PRINTNUM		; print R0
LD R1, MINR1
LD R2, MINR2
LD R3, MINR3
LD R4, MINR4
LD R5, MINR5
LD R7, MINR7		; restore registers
RET
MINR1 .FILL x0
MINR2 .FILL x0
MINR3 .FILL x0
MINR4 .FILL x0
MINR5 .FILL x0
MINR7 .FILL x0

DISPLAYGRADES		; display letter grade of each score in SCOREARRAY
ST R0, DGR0
ST R1, DGR1
ST R2, DGR2
ST R3, DGR3
ST R4, DGR4
ST R5, DGR5
ST R7, DGR7		; save registers
AND R4, R4, x0		; we will use R4 as our counter
LEA R5, SCOREARRAY	; put the address of the scores array in R5
AND R2, R2, x0
ADD R2, R2, #10		; R2 = 10 for modulo operation
DG_LOOP
LDR R1, R5, R4		; load SCOREARRAY[R4] into R1
JSR MOD
LD R0, DGR0
LD R1, DGR1
LD R2, DGR2
LD R3, DGR3
LD R4, DGR4
LD R5, DGR5
LD R7, DGR7		; restore registers
RET
ASCIIA	.FILL x41
ASCIIB	.FILL x42
ASCIIC	.FILL x43
ASCIID	.FILL x44
ASCIIF	.FILL x46
DGR0	.FILL x0
DGR1	.FILL x0
DGR2	.FILL x0
DGR3	.FILL x0
DGR4	.FILL x0
DGR5	.FILL x0
DGR7	.FILL x0

; ---------------------------------------------------------------------------------------------

; ASCII subroutines

TOASCII			; convert value in R1 to ASCII and store in R3
ST R2, ASCIISAVEREG
LD R2, ASCIIOFFSET
ADD R1, R1, R2
LD R2, ASCIISAVEREG
RET
ASCIISAVEREG .FILL x0

FROMASCII 		; convert ASCII in R1 to integer and store in R3
ST R2, ASCIISAVEREG
LD R2, NASCIIOFFSET
ADD R3, R1, R2
LD R2, ASCIISAVEREG
RET

PRINTNUM		; prints integer in R0 as series of ASCII numbers to console
ST R0, PR0
ST R1, PR1
ST R2, PR2
ST R3, PR3
ST R4, PR4
ST R5, PR5
ST R6, PR6
ST R7, PR7		; save registers
LD R2, DEC100		; we will skip printing the 100s and 10s place if they are 0
ADD R1, R0, x0		; copy R0 to register to be used as divisor
JSR DIV
ADD R1, R3, x0
BRz PRINTTENS		; skip printing this if result is 0
JSR TOASCII		; print hundreds place
ADD R0, R3, x0
OUT			; put character to console
PRINTTENS
LD R2, DEC100
LD R1, PR0
JSR MOD			; R3 = parameter % 100
ADD R1, R3, x0		; copy result of modulo to first parameter
JSR DIV
ADD R1, R3, x0
BRz PRINTONES		; skip to printing 1s place if this is 0
JSR TOASCII		; print tens place
ADD R0, R3, x0
OUT			; put character to console
PRINTONES
LD R1, PR0		; get original value
AND R2, R2, x0
ADD R2, R2, #10
JSR MOD			; R3 = parameter % 10
ADD R1, R3, x0		; copy result to R1
JSR TOASCII
ADD R0, R3, x0		; R3 should now have ASCII value of value in ones
OUT			; output character to console
LD R0, PR0
LD R1, PR1
LD R2, PR2
LD R3, PR3
LD R4, PR4
LD R5, PR5
LD R6, PR6
LD R7, PR7		; restore registers
RET
PR0	.FILL x0
PR1	.FILL x0
PR2	.FILL x0
PR3	.FILL x0
PR4	.FILL x0
PR5	.FILL x0
PR6	.FILL x0
PR7	.FILL x0	; we will restore these before returning

YESORNO			; store whether user entered Y or N (case-insensitive)
ST R0, YNR0		; 1 = yes, 0 = no, stored in R3
ST R1, YNR1
ST R2, YNR2		; save registers
YN_LOOP
GETC
ADD R1, R0, x0		; copy user input to parameter
JSR FROMASCII
LD R2, NEGCAPY
ADD R2, R2, R3		; check if input is 'Y'
BRz VALIDYES
LD R2, NEGLOWY
ADD R2, R2, R3		; check if input is 'y'
BRz VALIDYES
LD R2, NEGCAPN
ADD R2, R2, R3		; check if input is 'N'
BRz VALIDNO
LD R2, NEGLOWN
ADD R2, R2, R3		; check if input is 'n'
BRz VALIDNO
BR YN_LOOP		; user input was not valid, so get new character
VALIDYES
AND R3, R3, x0
ADD R3, R3, x1		; R3 = 1
BR ENDYORN
VALIDNO
AND R3, R3, x0		; R3 = 0
ENDYORN
OUT			; echo keyboard input
LD R0, YNR0
LD R1, YNR1
LD R2, YNR2		; restore registers
RET
YNR0	.FILL x0
YNR1	.FILL x0
YNR2	.FILL x0

; ASCII SUBROUTINE DATA
; We'll use these to convert numbers to ASCII and vice-versa
ASCIIOFFSET	.FILL #48
NASCIIOFFSET	.FILL #-48
DEC100		.FILL #100
NEGCAPY		.FILL #-89
NEGLOWY		.FILL #-121
NEGCAPN		.FILL #-78
NEGLOWN		.FILL #-110

; ---------------------------------------------------------------------------------------------

; STACK OPERATIONS

CLEARSTACK		; set stack size to 0
ST R0, CLRSAVREG	; save R0
LD R0, STACK_BEGIN
ST R0, SP		; reset stack pointer
LD R0, CLRSAVREG	; restore R0
RET
CLRSAVREG .FILL x0

PUSH			; push R0 to top of stack, set R3 to 1 if successful and -1 otherwise
ST R1, PSHR1
ST R2, PSHR2		; save registers we'll be using
LD R1, STACK_END
LD R2, SP
LD R1, STACK_BEGIN_N
ADD R1, R2, R1
BRn NOPUSH		; stack underflow
ADD R2, R2, x1		; go to potential next stack slot
ADD R1, R2, R1		; check for stack size maxed out
BRp NOPUSH 		; stack too big
STR R0, R2, x0		; push to the top of stack
AND R3, R3, x0
ADD R3, R3, x1		; set R3 to 1 to indicate successful push
BR ENDPUSH		; finish function
NOPUSH
AND R3, R3, x0
ADD R3, R3, #-1
ENDPUSH			
LD R1, PSHR1
LD R2, PSHR2		; restore registers
RET
PSHR1 .FILL x0
PSHR2 .FILL x0

POP			; set R3 to top of stack and pop, set to -1 if empty
ST R1, POPR1
ST R2, POPR2		; save registers we'll be using
LD R1, STACK_END
LD R2, SP
LD R1, STACK_BEGIN_N
ADD R1, R2, R1
BRn EMPTY		; stack underflow
LDR R3, R2, x0		; get top of stack
ADD R2, R2, #-1		; pop
BR ENDPOP
EMPTY
AND R3, R3, x0
ADD R3, R3, #-1		; Tried to pop empty stack, return -1
ENDPOP
LD R1, POPR1
LD R2, POPR2		; restore registers
RET
POPR1 .FILL x0
POPR2 .FILL x0

; STACK DATA
STACK_BEGIN	.FILL x3500
STACK_BEGIN_N	.FILL xCB00	; negative 3500
STACK_END	.FILL xCAF0	; negative x3510
SP		.FILL x0	; points to top of stack

; ---------------------------------------------------------------------------------------------

; MATH SUBROUTINES
; Nothing should be negative here, so if they are, we return negative 1 on these functions
; Same goes for any other invalid result (e.g., dividing by 0)

MULT			; multiply R1 by R2 and store in R3
ST R1, MSAV1
ST R2, MSAV2		; save registers
AND R3, R3, R0
ADD R1, R1, x0
BRn MULTNEG		; skip to end of function if either parameter is negative
BRz MULTEND		; skip to end with R3 as 0 if R1 is 0
ADD R2, R2, x0	
BRn MULTNEG
BRz MULTEND		; skip to end with R3 as 0 if R2 is 0
MULT_LOOP		; Add R1 to R3 R2 times
ADD R3, R1, R3
ADD R2, R2, #-1		; decrement counter
BRp MULT_LOOP		; if R2 > 0, keep adding
BR MULTEND		; end function
MULTNEG
ADD R3, R3, #-1
MULTEND
LD R1, MSAV1		; restore registers
LD R2, MSAV2
RET
MSAV1 .FILL x0
MSAV2 .FILL x0

DIV			; integer division of R1 by R2 and store in R3
ST R1, DSAV1
ST R2, DSAV2		; save registers
AND R3, R3, R0
ADD R1, R1, x0
BRn DIVNEG		; skip to end of function if either parameter is negative
BRz DIVEND		; skip to end with R3 as 0 if R1 is 0
ADD R2, R2, x0	
BRnz DIVNEG		; return -1 if R2 is negative or 0, since we can't divide by 0
NOT R2, R2
ADD R2, R2, x1		; 2's complement R2
DIV_LOOP
ADD R3, R3, x1
ADD R1, R1, R2
BRzp DIV_LOOP
ADD R3, R3, #-1 	; our loop always "over" counts by 1, so we correct it here
BR DIVEND
DIVNEG
ADD R3, R3, #-1
DIVEND
LD R1, DSAV1
LD R2, DSAV2		; restore registers
RET
DSAV1 .FILL x0
DSAV2 .FILL x0

MOD			; stores R1 % R2 in R3, stores -1 if error occurred
ST R1, MODSAV1
ST R2, MODSAV2
ST R7, MODSAV7		; save registers
JSR DIV
ADD R1, R3, x0
BRn ENDMOD		; error ocurred when dividing
JSR MULT
LD R1, MSAV1
ADD R3, R3, x0		; check for error when dividing
BRn ENDMOD
NOT R3, R3
ADD R3, R3, x1		; 2's complement
ADD R3, R3, R1		; R3 should now have remainder
ENDMOD
LD R1, MODSAV1
LD R2, MODSAV2
LD R7, MODSAV7		; restore registers
RET
MODSAV1	.FILL x0
MODSAV2	.FILL x0
MODSAV7	.FILL x0

.END
