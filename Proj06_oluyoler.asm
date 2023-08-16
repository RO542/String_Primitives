TITLE  String Primitives/Macros     (Proj06_oluyoler)

; Author: Richard Oluyole
; Last Modified: 07/18/2023
; OSU email address: oluyoler@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:      6           Due Date: 07/18/2023
; Description: This program will receive and validate user input as a string, convert and sum the inputs, 
;				and return the summed value/average.



INCLUDE Irvine32.inc

;Macros

mDisplayString	MACRO stringAddress
	push	edx
	mov		edx,stringAddress
	call	WriteString
	call	crlf
	pop		edx
ENDM


mGetString		MACRO prompt,bufferAddress,bufferSize,byteNum
	push	edx
	push	ecx
	push	eax

	mDisplayString	prompt
	mov		edx, bufferAddress
	mov		ecx, bufferSize
	call	ReadString
	mov		[byteNum],eax ; sending back the number of bytes entered 

	;mov		edx, offset bufferAddress
	;call	WriteString
	;mov		byteNum,eax
	;call	WriteDec

	pop eax
	pop ecx
	pop	edx
ENDM

;Constants
MAX_SDWORD =  +2147483647
MIN_SDWORD =  -2147483648
ARRAYSIZE  =  10

.data
ARRAY		SDWORD	ARRAYSIZE DUP (?)
BUFFER		BYTE	12	DUP(0) ; including sign ? 
byteCount	DWORD   ?


average		SDWORD ?
sum			SDWORD ?

tempVar		SDWORD ?
tempVar2	SDWORD ?

intro1		BYTE "The following program takes in 10 user inputs as strings verifies they are valid and returns the rounded average and sum that is represented.",0
intro2		BYTE "The inputs must represent numbers [-2^31,2^31-1] to be valid ",0
intro3		BYTE "After collecting 10 numbers the running sum and rounded average will be displayed.",0

promptUser	BYTE "Enter in a signed number: ",0
rePrompt	BYTE "What you entered is either too large,too small, or not a number.Try again: ",0

YouEntered	BYTE "Here are your 10 inputs",0
showAverage	BYTE "The truncated average is:",0
showSum		BYTE "The calculated sum is:",0
goodbye		BYTE "Thanks for using the program,bye now.",0

invalid		byte "invalid",0
valid		byte "valid",0
testNum		byte "2147483647",0

.code
main PROC

	mDisplayString offset intro1
	mDisplayString offset intro2
	mDisplayString offset intro3
	

	;push	offset	rePrompt
	;push	offset	promptUser
	;push	offset	BUFFER
	;push	sizeof	BUFFER
	;push	offset	byteCount
	;call	ReadVal
	
		
	mov		esi,offset testNum
	mov		ecx,sizeof testNum
	dec		ecx
	mov		eax,0
	CLD
	conv:
		mov		ebx,10
		imul	ebx
		push	eax ; save old remainder times 10
	

		xor		eax,eax
		lodsb
		sub		eax,48
		mov		ebx,eax

		pop		eax
		add		eax,ebx
		
		;call	WriteInt

		LOOP conv
		_break:
		call	WriteInt
		Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

ReadVal	 PROC
	push	ebp
	mov		ebp,esp

	;			+20	       +16			+12			 +8
	;			promptUser,offset BUFFER ,sizeof BUFFER,offset byteCount
	_firstPrompt:
		mGetString [ebp+20],[ebp+16],[ebp+12],[ebp+8]
		JMP		_verify
	
	_subsequentPrompt: ; ebp+24 is the rePrompt
		mGetString [ebp+24],[ebp+16],[ebp+12],[ebp+8]	

	_verify:

	mov		esi,[ebp+16] ;start of number string
	mov		ecx,[ebp+8] ;number of bytes

;	mov		edx,0 ; representing if there is a sign
	mov		eax,0

	verifyChars:	
		lodsb	

		cmp		al,43
		JE		_checkPlus

		cmp		al,45
		JE		_checkNegative
		
		cmp		al,57
		JG		_invalidChar

		cmp		al,48
		JL		_invalidChar
		
		JMP		_continue
		
		_checkPlus:
			cmp		ecx,[ebp+8]; check if this is the first iteration
			JNE		_invalidChar
			;mov		edx,1
			JMP		_continue
		_checkNegative:
			cmp		ecx,[ebp+8]
			JNE		_invalidChar
			;mov		edx,-1
			JMP		_continue

		_continue:
		

		LOOP verifyChars
		JMP		_allValidChars ; nothing invalid found

	_invalidChar:
		mov		edx,offset invalid
		call	WriteString
		call	crlf
		JMP		_subsequentPrompt
	_allValidChars:
		mov		edx,offset valid 
		call	WriteString
		call	crlf
	
	_end:
	pop		ebp
	RET		20
ReadVal	 ENDP

WriteVal PROC	

RET
WriteVal ENDP

END main
