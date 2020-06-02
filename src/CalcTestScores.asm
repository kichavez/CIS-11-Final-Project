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
JSR CLEARSTACK
LEA R0, PROMPT_5SCORES
PUTS
LD R0, NEWLINE
OUT
AND R6, R6, x0		; we will use this to keep track of how many scores are accepted
LOOP_SCORES
LEA R0, PROMPT_ENTERPLS
PUTS
JSR KBNUMIN

HALT

; MAIN ROUTINE DATA
PROMPT_WELCOME	.STRINGZ "Welcome to the Test Score Calculator!"
PROMPT_HITENTER	.STRINGZ "Press the enter button when you are finished typing a score."
PROMPT_5SCORES	.STRINGZ "Please enter 5 test scores."
PROMPT_ENTERPLS	.STRINGZ "Type in the next test score: "
PROMPT_END 	.STRINGZ "Would you like to end the program?"
PROMPT_CLEAR	.STRINGZ "Clear all previously entered scores?"
NEWLINE		.FILL xA
GRADE_LETTERS	.STRINGZ "A"
		.STRINGZ "B"
		.STRINGZ "C"
		.STRINGZ "D"
		.STRINGZ "F"
SCOREARRAY	.BLKW 5
ARRAYSIZE	.FILL x3100	; we will keep count of the array here
NASCII0		.FILL #-48	; we use these to check if keys are 0-9
NASCII9		.FILL #-57

; ---------------------------------------------------------------------------------------------

; Below, you will find various related subroutines and labels grouped

; ---------------------------------------------------------------------------------------------

; main program subroutines

KBNUMIN			; processes KB input and pushes total value to stack
ST R7, MAINR7
ST R1, MAINR1
ST R2, MAINR2
ST R4, MAINR4
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
BR KB_LOOP		; process next character
NOTASCIINUM
LD R2, 0xA
NOT R2, R2
ADD R2, R2, x1		; R2 = -0xA, ASCII value of newline
ADD R1, R2, R3		; check if user entered a newline (i.e. pushed enter)
BRz ENDKBIN
BR KB_LOOP		; User entered a character not newline or enter, so do nothing
ENDKBIN
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
BRnz STCK2ERR		; total was empty or (somehow?) negative
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
TONUMR0	.FILL x0
TONUMR1	.FILL x0
TONUMR2	.FILL x0
TONUMR4	.FILL x0
TONUMR5	.FILL x0
NEG100	.FILL #-100

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

; ASCII SUBROUTINE DATA
; We'll use these to convert numbers to ASCII and vice-versa
ASCIIOFFSET	.FILL #48
NASCIIOFFSET	.FILL #-48
DEC100		.FILL #100

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
