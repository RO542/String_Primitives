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
	;call	crlf
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

	pop eax
	pop ecx
	pop	edx
ENDM

;Constants
MAX_SDWORD =  +2147483647
MIN_SDWORD =  -2147483648
ARRAYSIZE  =  10



testVal =	892433


.data
ARRAY		SDWORD	ARRAYSIZE DUP (?)
BUFFER		BYTE	40	DUP(0) ;allow up to 40 chars, but anything above 11 is later rejected in ReadVal
byteCount	SDWORD   ?


testBuffer	BYTE	13	DUP(?)

average		SDWORD ?
sum			SDWORD 0
subtotal	SDWORD ?


intro1		BYTE "The following program takes in 10 user inputs as strings verifies they are valid and returns the rounded average and sum that is represented.",0
intro2		BYTE "The inputs must represent numbers [-2^31,2^31-1] to be valid ",0
intro3		BYTE "After collecting 10 numbers the running sum and rounded average will be displayed.",0

promptUser	BYTE "Enter in a signed number: ",0
rePrompt	BYTE "What you entered is either too large,too small, or not a number.Try again: ",0

YouEntered	BYTE "Here are your 10 inputs",0
showAverage	BYTE "The truncated average is:",0
showSum		BYTE "The calculated sum is:",0
goodbye		BYTE "Thanks for using the program,bye now.",0


.code
main PROC

;	mDisplayString offset intro1
;	call crlf
;	mDisplayString offset intro2
;	call crlf
;	mDisplayString offset intro3
;	call crlf
	
	

;	JMP		_testWriteVal
	
	;prepare to fill the array
	mov		ecx,ARRAYSIZE
	mov		edi,offset ARRAY
	fillArray:
		push	offset	rePrompt
		push	offset	promptUser
		push	offset	BUFFER
		push	sizeof	BUFFER
		push	offset	byteCount
		call	ReadVal
		mov		[edi],ebx
		add		edi,4
		add		sum,ebx

		LOOP fillArray

	_sum_avg:
		mov		eax,sum

		xor		eax,eax
		xor		edx,edx
		
		mov		eax,sum
		mov		ebx,10
		idiv	ebx
		mov		average,eax

		mov		eax,sum
		call	WriteInt
		call	crlf

	_testWriteVal:
		push	sum
		push	offset testBuffer
		call	WriteVal
		call	crlf
	
	mov		esi,offset ARRAY
	mov		ecx,ARRAYSIZE
	l3:
		push	[esi]
		push	offset	testBuffer
		call	WriteVal

		add		esi,4
		LOOP l3

		Invoke ExitProcess,0	; exit to operating system
main ENDP


WriteVal	PROC
	push	ebp
	mov		ebp,esp
	push	ecx
	push	esi
	push	edi
	
	;clear  leftover in used registers just in case
	xor		eax,eax
	xor		ebx,ebx
	xor		edx,edx
	

	;finding the number of digits
	mov		eax,[ebp+12]
	mov		ebx,10
	xor		ecx,ecx
	_getLen:
		cmp		eax,0
		JE		_foundLen	
		xor		edx,edx
		idiv	ebx
		mov		ebx,10
		inc		ecx
		JMP		_getLen
	_foundLen:	;ecx has the length
	
	push		ecx

	;load number and divide
	mov		eax, [ebp+12]
	xor		edx,edx
	mov		ebx,10
	mov		edi, [ebp+8];offset testBuffer

	l:
		idiv	ebx
		push	eax

		mov		eax,edx
		add		eax,48
		stosb

		xor		edx,edx
		pop		eax
		LOOP l

	pop		ecx
	mov		esi,[ebp+8];offset testBuffer
	add		esi,ecx
	sub		esi,1

	STD	 
	reversePrint:	
		lodsb
		call	WriteChar
		LOOP	reversePrint
	mov		al," "
	call	WriteChar
	
	pop		edi
	pop		esi
	pop		ecx
	pop		ebp
	RET		8
WriteVal	ENDP


; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Repeatedly takes user input until the user enters a valid SDWORD and converts the
;	the ASCII characters to an integer.
;
; Preconditions: None 
;	
; Receives:
; [ebp+8]  = the prompt passed to mGetString the first time
; [ebp+12] = the size of the character buffer/string 
; [ebp+16] = the address of the character buffer/string
; [ebp+20] = the count of bytes in the chracter buffer
; [ebp+24] = an alternate prompt when the user enters an invalid string
;
; Returns:
;	ebx will contain the valid and converted integer
; ---------------------------------------------------------------------------------
ReadVal	 PROC
	push	ebp
	mov		ebp,esp
	push	ecx
	push	edi

	;				+20	       +16				+12			 +8
	;			promptUser,offset BUFFER ,sizeof BUFFER,offset byteCount
	_firstPrompt:
		mGetString [ebp+20],[ebp+16],[ebp+12],[ebp+8]
		JMP		_verifyLength
	
	_subsequentPrompt: ; ebp+24 is the rePrompt
		mGetString [ebp+24],[ebp+16],[ebp+12],[ebp+8]

	_verifyLength:
		mov		eax,[ebp+8]
		cmp		eax,12
		JG		_subsequentPrompt

		; preparing to loop over the string
		mov		esi,[ebp+16] 
		mov		ecx,[ebp+8] 

		;prepare eax to store converted int, and edi to represent the sign
		mov		eax,0
		mov		edi,0

	verifyChars:	
		lodsb	
		
		;check for + sign
		cmp		al,43
		JE		_checkPlus
		
		;check for - sign
		cmp		al,45
		JE		_checkNegative
		
		; check the char is an ASCII digit
		cmp		al,57
		JG		_invalidChar
		cmp		al,48
		JL		_invalidChar
		
		JMP		_continue
		_checkPlus:
			cmp		ecx,[ebp+8]
			JNE		_invalidChar ;+ not at start, string invalid
			mov		edi,1
			JMP		_continue
		_checkNegative:
			cmp		ecx,[ebp+8]
			JNE		_invalidChar ;- not at start, string invalid
			mov		edi,2
			JMP		_continue
		_continue:
			LOOP	 verifyChars

		JMP		_allValidChars ;valid string, proceed to conversion
	_invalidChar:
		JMP	_subsequentPrompt

	_allValidChars:
		;prepare to loop over string once again
		mov		esi,[ebp+16] 
		mov		ecx,[ebp+8] 
		mov		eax,0
		;CLD
		
		;skip first char if it is +/-
		cmp		edi,2 
		JE		_skipFirstChar
		cmp		edi,1
		JE		_skipFirstChar
		JMP		convChars
		
		
		_skipFirstChar:
			inc		esi
			dec		ecx
		
	
		convChars:
			mov		ebx,10
			xor		edx,edx
			imul	ebx ;shift char digit left
			jo		_subsequentPrompt

			push	eax 
			xor		eax,eax
			lodsb

			sub		eax,48; ASCII subtraction 
			mov		ebx,eax
			pop		eax
			
			;if edi is 2 subtract from eax otherwise add 
			cmp		edi,2
			JE		_subtract
			add		eax,ebx
			JMP		_checkOverflow
			_subtract:
				sub		eax,ebx
			_checkOverflow:
				jo		_subsequentPrompt
			LOOP convChars

	;ebx now contains the valid SDWORD for the input string
	mov		ebx,eax

	pop		edi
	pop		ecx
	pop		ebp
	RET		20
ReadVal	 ENDP



END main
