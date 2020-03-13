TITLE Programming Assignment #6     (prog06.asm)

; Author: Chelsea Marie Hicks
; OSU email address: hicksche@oregonstate.edu
; Course number/section: CS271-400
; Project Number: Program #6	Due Date: Sunday, March 15 by 11:59 PM
; Description: Program gets 10 valid integers from the user and stores numeric values
;		in an array. These integers are then dislpayed to the screen along with their
;		sum and their average. Program implements ReadVal and WriteVal procedures
;		for signed integers and macros for getting and displaying user data as strings.

INCLUDE Irvine32.inc

;constant definitions
MAXSTRING			EQU		11			;defines constant for max string length entered by user
ARRAYSIZE			EQU		10			;defines constant size for array

;macro definitions below

;------------------------------------------------------------
; getString
;
; MACRO to get a string of input from the user
;
; Receives: message to display (displayMsg) and variable to store string input (storeString) 
; Preconditions: none
; Registers changed: none
; Postconditions: input from user stored in variable
;------------------------------------------------------------
getString	MACRO displayMsg, storeString, stringSize, stringCount
	push	edx
	push	ecx
	mov		edx, displayMsg
	call	WriteString
	mov		edx, storeString				;location to store string input
	mov		ecx, stringSize					;maximum length of string
	call	ReadString						;acquire user input
	mov		stringCount, eax				;counter of sting length
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
displayString	MACRO stringDisplay
	push	edx
	mov		edx, stringDisplay
	call	WriteString
	pop		edx
ENDM


;MAXSTRING			EQU		11			;defines constant for max string length entered by user
;INPUTSIZE			EQU		1			;defines constant for size of input for sum and average
;LOWERLIMIT			EQU		-2147483648	;defines constant lower limit for numeric value
;UPPERLIMIT			EQU		2147483647	;defines constant upper limit for numeric value

.data
;variables used throughout the program
array			SDWORD	ARRAYSIZE	DUP(?)			;array to store signed integers entered by user
inputString		BYTE 20 DUP (?)						;stores input of user
outputString	BYTE 20 DUP (?)						;output post-conversion
stringLength	DWORD	0							;number of characters in the string
;sumVal			SDWORD	?							;stores value of the sum of numbers entered by user
;avgVal			SDWORD	?							;stores the average of the values entered by user

;negativeCheck	DWORD	?							;variable to flag a user input as negative

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
farewellMsg		BYTE	"Thanks for your input, now get outta here!", 0
comma			BYTE	", ", 0


.code
main PROC
	
;Introduce the program
	push	OFFSET progTitle						;pass strings by reference 
	push	OFFSET authName
	call	introduction

	call	Crlf

;Display instructions for the user 
	displayString	OFFSET instruct						;invoke macro to display instructions
	call	Crlf
	call	Crlf

;Get the user's string of digits and convert each string of digits to numeric values
	push	SIZEOF inputString						;pass in var for size of string entered by user
	push	OFFSET inputString						;pass variable for storing string entered
	push	OFFSET stringLength						;pass length of string by reference
	push	OFFSET array							;pass array by reference
	push	OFFSET numPrompt						;pass prompt for getting a number by reference
	push	OFFSET errorMsg							;pass prompt for error by reference
	call	readVal

	call	Crlf

;Print user input to the screen after converting values back to string input from numeric using writeVal
	push	OFFSET arrayMsg							;pass prompt for displaying values to screen
	push	OFFSET	comma							;pass space and comma for listing values
	push	LENGTHOF array							;pass length of array
	push	OFFSET array							;pass actual array filled with user input
	push	OFFSET outputString						;pass string for storing converted values before printing	
	call	printValues
	
	call	Crlf

;Calculate and print to the screen the sum and average of the user entered values
	push	OFFSET sumMsg							;pass prompt for displaying sum by reference
	push	OFFSET avgMsg							;pass prompt for displaying average by reference
	push	OFFSET outputString						;pass string for storing vlues 
	push	LENGTHOF array							;pass length of array
	push	array									;pass actual array
	call	completeCalculations

	call	Crlf

;Print farewell message to the screen
	displayString OFFSET farewellMSg
	exit	; exit to operating system
main ENDP

;additional procedures for program below

;------------------------------------------------------------
; introduction
;
; Procedure introduces the program and programmer
; Receives: address of progTitle and authName to print to screen
; Preconditions: none
; Registers changed: edx
; Postconditions: introduction printed to screen
;------------------------------------------------------------
introduction PROC
	push	ebp									;setup stack frame
	mov		ebp, esp
	displayString [ebp+12]						;print title to screen
	call	Crlf
	displayString [ebp+8]						;print authName to screen
	call	Crlf
	call	Crlf
	pop		ebp
	ret		8
introduction	ENDP

;------------------------------------------------------------
; readVal
;
; Procedure gets user's string of digits and converts string to numeric
; Receives: parameters on system stack
; Preconditions: none
; Registers changed: none
; Postconditions: 10 validated string of digits entered by user converted
;	to numeric values stored in array
;------------------------------------------------------------
readVal PROC
	push	ebp									;setup stack frame
	mov		ebp, esp
	
	push	eax
	mov		eax, 0
	push	edi
	mov		edi, [ebp+16]						;point to address of array
	mov		ecx, 10						

getUserInput:
	getString [ebp+12], [ebp+24], [ebp+28], [ebp+20] ;call MACRO to display numPrompt and acquire a string

evaluateString:
	push	ecx									;save counter for outer loop
	mov		ecx, [ebp+20]						;stringCount used to track chars for lodsb
	mov		esi, [ebp+24]						;point to start of string input by user
	push	edi									;use edi for placing numeric value
	mov		edi, 0
	push	ebx									;use ebx as temp storage for each byte
	mov		ebx, 0
	cld											;clear direction flag to read data going forward

validateLength:
	mov		eax, [ebp+20]						;check that length isn't greater than alloted amount
	cmp		eax, MAXSTRING
	jg		error

beginConversion:								;look at single byte and determine if it's a number
	lodsb
	cmp		al, 48								
	jae		noSign
	;jmp		checkSign

noSign:
	cmp		al, 57
	jg		error								;input is invalid and user needs to enter again
	mov		bl, al				
	
;utilizes code from Lecture #23
	mov		eax, 0
	mov		eax, edi
	mov		edi, 10
	mul		edi
	mov		edi, eax
	mov		eax, 0
	mov		eax, ebx
	sub		eax, 48
	add		eax, edi
	mov		edi, eax
	loop	beginConversion

completeConversion:
	mov		eax, edi
	pop		ebx									;restore registers
	pop		edi
	pop		ecx
	jmp		insertInArray

;invalid input entered, display message to user and acquire new input
error:
	pop		ebx
	pop		edi
	pop		ecx
	push	edx
	displayString [ebp+8]
	call	Crlf
	pop		edx
	jmp		getUserInput

insertInArray:
	mov		[edi], eax							;insert numeric value in array
	add		edi, 4								;move to next element position
	dec		ecx
	cmp		ecx, 0								;continue to acquire user input until 10 numbers acquired
	jne		getUserInput
	

;2bh or 43 = +, 2dh or 45d = -, 30h - 39h or 48d-57d
;checkSign:											;check if first val in string is + or - sign
;must check if this is first val or not, if not first val, error
	;cmp		eax, 43
	;je		positiveSign
	;cmp		eax, 45
	;je		negativeSign



userInputComplete:
	pop		edi										;restore registers						
	pop		eax
	pop		ebp
	ret		24
readVal	ENDP

;------------------------------------------------------------
; printValues
;
; Procedure uses writeVal to convert numeric values to strings and print to screen
;		all elements entered into the array in readVal
; Receives: arrayMsg to print to screen (reference), array (reference), length of 
;		the array (value), comma for spacing elements (reference), and variable for 
;		storing the string to be printed (reference)
; Preconditions: array contains user input as numeric values
; Registers changed: none
; Postconditions: user input converted to strings and printed to screen
;------------------------------------------------------------
printValues PROC
	push	ebp									;setup stack frame
	mov		ebp, esp
	push	ecx
	mov		ecx, [ebp+16]						;ecx acts as counter with length of array
	push	edi
	mov		edi, [ebp+12]						;first element in the array
	displayString [ebp+24]						;display arrayMsg
	call	Crlf

;call on writeVal to convert each element in the array and print each element
printEach:
	push	[edi]								;numeric element in array
	push	[ebp+8]								;points to address of string for output
	call	writeVal
	displayString [ebp+20]						;insert a comma and space before moving to next value
	add		edi, 4								;move to next element in the arry
	loop	printEach

	pop		edi									;restore registers
	pop		ecx
	pop		ebp
	ret		20
printValues	ENDP

;------------------------------------------------------------
; writeVal
;
; Procedure converts numeric value to string of digits and invokes macro to display output
; Receives: numeric value to convert to string (reference) and address of string 
;		for storing output (reference)
; Preconditions: recieves parameters on stack
; Registers changed: none
; Postconditions: value converted from numeric to string and displayed to screen
;------------------------------------------------------------
writeVal PROC
	push	ebp
	mov		ebp, esp
	push	eax
	push	ebx
	push	edx
	push	edi

	mov		ebx, 10								;divisor for conversion
	mov		eax, [ebp+12]						;element from array to be converted
	mov		edi, [ebp+8]						;outputString setup for stosb
	cld

	push	0									;end of string terminating 0

beginConversion:
	mov		edx, 0								;clear edx register for division
	idiv	ebx									;divide by 10
	add		edx, 48								;convert single digit value in edx to ascii char
	push	edx									;push ascii char to stack
	cmp		eax, 0
	jne		beginConversion						;continue until end of value is reached

;pop stack to place in output string the values in order
inOrder:
	pop		eax
	stosb
	cmp		eax, 0								;check if 0
	jne		inOrder								;continuing popping until terminating 0 on stack reached

printAsString:
	displayString [ebp+8]						;print string in outputString to screen

	pop		edi									;restore registers
	pop		edx
	pop		ebx
	pop		eax
	pop		ebp
	ret		8
writeVal	ENDP

;------------------------------------------------------------
; completeCalculations
;
; Procedure calculates the sum and the average of numbers entered by the user
;		and print the values to the screen after converting to strings in writeVal
; Receives: messages to print to the screen for sum and average (reference), variable 
;		for storing the string to be printed (reference), length of array (value), and 
;		the actual array
; Preconditions: array filled with values 
; Registers changed: none
; Postconditions: sum and average are calculated and printed to the screen
;------------------------------------------------------------
completeCalculations PROC
	push	ebp
	mov		ebp, esp							;setup stack frame
	mov		eax, 0
	mov		ecx, 10								;loop counter for summing elements
	mov		esi, [ebp+8]

calculateSum:
	add		eax, [esi]							;continue to add an array value
	add		esi, 4								;move to next element in the array
	loop	calculateSum
	call	WriteDec

	;mov		edi, 0							;initialize edi to 0 for calculating sum
	;mov		edi, [ebp+8]						;first element in the array
	;mov		ecx, 10								;use lengthof the array as counter
	;mov		eax, 0
	;displayString [ebp+24]						;display message for printing the sum

;calculateSum:
	;mov		ebx, [esi]							;continue to add an array value
	;add		eax, ebx
	;add		esi, 4								;move to next element in the array
	;loop	calculateSum

;displaySum:
	;push	[eax]									;sum stored in edi and pushed on stack
	;push	[ebp+16]							;push address of outputString on stack
	;call	writeVal							;use writeVal to convert sum and print

	call	Crlf
	displayString [ebp+20]						;display message for printing the average
	
	
												;restore registers
	pop		ebp
	ret		20
completeCalculations	ENDP


END main
