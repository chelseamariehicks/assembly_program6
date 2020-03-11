readVal PROC
	push	ebp										;setup stack frame
	mov		ebp, esp
	mov		ecx, [ebp+16]							;number of elements allowed, ARRAYSIZE, in loop counter
	mov		edi, [ebp+24]							;first element in the converted array

getUserInput:
	push	ecx										;save loop counter
	getString [ebp+12], [ebp+28], [ebp+20]			;call macro to display numPrompt and get user input string
	mov		esi, [ebp+28]							;place the input string in esi
	mov		ecx, [ebp+20]							;length of string entered
	cld												;clear direction flag to read data going forward

	xor		eax, eax								;clear registers
	xor		ebx, ebx								;ebx used to put integer together
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
	push	eax										;push int value on stack
	mov		eax, ebx								;clear eax
	mov		ebx, 10									;multiply by ten
	mul		ebx
	mov		ebx, eax
	pop		eax
	add		ebx, eax								;add new number
	mov		eax, ebx

	xor		eax, eax								;clear register
	loop	validateInput							;move to next digit

	mov		eax, ebx
	stosd											;add eax into array

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
readVal	ENDP
