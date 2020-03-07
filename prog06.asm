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
; Receives: displayMsg - OFFSET to the message to display 
;			stringAddr - variable to store string input from user
; Preconditions: none
; Registers changed: none
; Postconditions: input from user stored in variable
;------------------------------------------------------------
getString	MACRO displayMsg, stringAddr
	push	edx
	push	ecx
	push	eax
	mov		edx, OFFSET displayMsg
	call	WriteString
	mov		edx, stringAddr					;location of user input in memory
	mov		ecx, MAX_STRING_LENGTH			;limits number of characters allowed by user
	call	ReadString						;acquire user input
	pop		eax
	pop		ecx
	pop		edx
ENDM

;------------------------------------------------------------
; displayString
;
; MACRO to print a string stored in specific memory location
;
; Receives: addrStrDisplay - address if the string to be displayed
; Preconditions: none
; Registers changed: none
; Postconditions: input from user stored in variable
;------------------------------------------------------------
displayString	MACRO addrStrDisplay
	push	edx
	mov		edx, OFFSET addrStrDisplay
	call	WriteString
	pop		edx
ENDM

;constant definitions
ARRAYSIZE			EQU		10			;defines constant size for array
MAX_STRING_LENGTH	EQU		100			;defines constant for max string length entered by user

.data
array			DWORD	ARRAYSIZE	DUP(?)			;array to store signed integers entered by user
stringInput		BYTE	MAX_STRING_LENGTH+1	DUP(?)	;stores user input string
stringLength	DWORD	LENGTHOF stringInput		
convertInt		DWORD	0							;stores integer value after converted from string input

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

;Get user's string of digits and convert to numeric values
	push	OFFSET array
	push	OFFSET stringInput
	push	SIZEOF stringInput
	push	OFFSET numPrompt
	push	OFFSET errorMsg 
	call	ReadVal

	displayString	instruct						;invoke macro to display prompt and get user input
													;stored in specified memory location

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
; Registers changed:
; Postconditions: 
;------------------------------------------------------------
ReadVal PROC
	push	ebp
	mov		ebp, esp
	pop		ebp
	ret		20
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
