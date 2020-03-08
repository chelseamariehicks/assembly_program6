TITLE Programming Assignment #6     (prog06.asm)

; Author: Chelsea Marie Hicks
; OSU email address: hicksche@oregonstate.edu
; Course number/section: CS271-400
; Project Number: Program #6	Due Date: Sunday, March 15 by 11:59 PM
; Description: Program gets 10 valid integers from the user and stores numeric values
;		in an array. These integers are then dislpayed to the screen along with their
;		sum and their average. Program implements ReadVal and WriteVal procedures
;		for signed integers and macros for getting and displaying user data.

INCLUDE Irvine32.inc

;macro definitions below

;------------------------------------------------------------
; getString
;
; MACRO to get a string of input from the user
;
; Receives: message to display (displayMsg), variable to store string input (strAddr),
;		and 
; Preconditions: none
; Registers changed: none
; Postconditions: input from user stored in variable
;------------------------------------------------------------
getString	MACRO displayMsg, strAddr, maxLength, strLength
	push	edx
	push	ecx
	push	eax
	mov		edx, displayMsg
	call	WriteString
	mov		edx, strAddr					;location to store string input
	mov		ecx, maxLength					;limits number of characters allowed by user
	call	ReadString						;acquire user input
	mov		strLength, eax					;store length of string in variable
	pop		eax
	pop		ecx
	pop		edx
ENDM

;------------------------------------------------------------
; displayString
;
; MACRO to print a string stored in specific memory location
;
; Receives: address of the string to be displayed (addrStrDisplay)
; Preconditions: none
; Registers changed: none
; Postconditions: input from user stored in variable
;------------------------------------------------------------
displayString	MACRO addrStrDisplay
	push	edx
	mov		edx, addrStrDisplay
	call	WriteString
	call	Crlf
	pop		edx
ENDM

;constant definitions
ARRAYSIZE			EQU		10			;defines constant size for array
MAXSTRING			EQU		20			;defines constant for max string length entered by user
LOWERLIMIT			EQU		-2147483648	;defines constant lower limit for numeric value
UPPERLIMIT			EQU		2147483647	;defines constant upper limit for numeric value

.data
array			SDWORD	ARRAYSIZE	DUP(?)			;array to store signed integers entered by user
stringInput		BYTE	MAXSTRING+1	DUP(?)			;stores user input string
stringLength	DWORD	?							;number of characters in the string	
numericVal		SDWORD	0							;stores integer value after converted from string input

;messages to be printed to the screen
progTitle		BYTE	"Designing Low-Level I/O Procedures", 0
authName		BYTE	"Written by Chelsea Marie Hicks", 0
instruct		BYTE	"Please enter 10 integers. These values can be positive or negative and in the", 10, 13		 
				BYTE	"range of -2,147,483,648 to 2,147,483,647, as these values can fit inside a ", 10, 13
				BYTE	"32-bit register. After you complete number entry, I will display your list ", 10, 13
				BYTE	"of valid values entered, their sum, and their average.", 0
numPrompt		BYTE	"Please enter a signed integer: ", 0
errorMsg		BYTE	"ERROR! The number you entered was invalid.", 10, 13
				BYTE	"Enter a signed integer within the specified range: ", 0
arrayMsg		BYTE	"You entered the following numbers:", 0
sumMsg			BYTE	"The sum of the numbers entered is: ", 0
avgMsg			BYTE	"The rounded average of the numbers entered is: ", 0



comma			BYTE	", ", 0


.code
main PROC
	
;Introduce the program
	push	OFFSET progTitle						;pass strings by reference 
	push	OFFSET authName
	call	introduction

;Display instructions for the user 
	displayString	OFFSET instruct						;invoke macro to display instructions

;Get user's string of digits and convert to numeric values
	push	OFFSET array							;pass array, location to store string input,
	push	OFFSET stringInput						;size of string, and prompts by reference
	push	SIZEOF stringInput
	push	stringLength							;pass length of string by value
	push	ARRAYSIZE								;pass array size limit by value
	push	OFFSET numPrompt
	push	OFFSET errorMsg 
	call	ReadVal


	exit	; exit to operating system
main ENDP

;additional procedures for program below

;------------------------------------------------------------
; introduction
;
;Procedure introduces the program and programmer
; Receives:address of parameters on system stack
; Preconditions: none
; Registers changed: edx
; Postconditions: none
;------------------------------------------------------------
introduction PROC
	push	ebp									;setup stack frame
	mov		ebp, esp
	mov		edx, [ebp+12]						;print title to screen
	call	WriteString
	call	Crlf
	mov		edx, [ebp+8]						;print authName to screen
	call	WriteString
	call	Crlf
	call	Crlf
	pop		ebp
	ret		8
introduction	ENDP

;------------------------------------------------------------
; ReadVal
;
; Procedure gets user's string of digits and converts string to numeric
; Receives: parameters on system stack
; Preconditions: none
; Registers changed: ecx, 
; Postconditions: validated string of digits entered by user converted to numeric 
;------------------------------------------------------------
ReadVal PROC
	push	ebp										;setup stack frame
	mov		ebp, esp
	mov		ecx, [ebp+16]							;number of elements allowed, ARRAYSIZE, in loop counter
	mov		edi, [ebp+28]							;first element in the array

getUserInput:
	push	ecx										;save loop counter
	getString [ebp+12], [ebp+28], [ebp+24], [ebp+20] ;call macro to display numPrompt and get user input string
	mov		esi, [ebp+28]							;place the input string in esi
	mov		ecx, [ebp+20]							;length of string entered
	cld												;clear direction flag to read data going forward

	xor		eax, eax								;clear registers
	xor		ebx, ebx
validateInput:										
	lodsb											;load a byte from the user string to check
	cmp		eax, 48									;if the byte valure is >= 48, the sign doesn't need checking
	jae		noSign

;2bh or 43 = +, 2dh or 45d = -, 30h - 39h or 48d-57d
checkSign:											;check if first val in string is + or - sign
;must check if this is first val or not, if not first val, error
	;cmp		eax, 43
	;je		positiveSign
	;cmp		eax, 45
	;je		negativeSign

noSign:												;if byte is greater than 57, it isn't integer value
	cmp		eax, 57
	ja		error
	sub		eax, 48									;convert ascii value to int
	push	eax										;FIGURE OUT WHAT'S HAPPENING HERE
	mov		eax, ebx
	mov		ebx, [ebp+16]
	mul		ebx
	mov		ebx, eax
	pop		eax
	add		ebx, eax
	mov		eax, ebx

	xor		eax, eax
	loop	validateInput

	mov		eax, ebx
	stosd											;add eax to array

	add		esi, 4									;move to next element
	pop		ecx
	loop	getUserInput
	jmp		userInputComplete

error:
	pop		ecx
	displayString [ebp+8]							;print error message
	jmp		getUserInput							;require user to enter valid input

userInputComplete:

	pop		ebp
	ret		28
ReadVal	ENDP


;------------------------------------------------------------
; WriteVal
;
;
; Receives:
; Preconditions:
; Registers changed:
; Postconditions:
;------------------------------------------------------------
WriteVal PROC
	push	ebp
	mov		ebp, esp
	pop		ebp
	ret
WriteVal	ENDP


END main
