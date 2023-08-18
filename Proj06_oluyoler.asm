TITLE  String Primitives/Macros     (Proj06_oluyoler)

; Author: Richard Oluyole
; Last Modified: 08/18/2023
; OSU email address: oluyoler@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:      6           Due Date: 08/18/2023
; Description: This program will receive and validate user input as a string, convert and sum the inputs, 
;				and return the summed value/average.


INCLUDE Irvine32.inc

;Macros
; ---------------------------------------------------------------------------------
; Name: mDisplayString
; Prints a string to the console using WriteString. 
;	NOTE: mDisplayString is used a subprocedure within main and mGetString
;
;
; Preconditions: None
; Postconditions: None
;	
; Receives:
; stringAddress = address of the string being printed
; 
;Returns:
;	None but the converted string is printed to the console.
; ---------------------------------------------------------------------------------
mDisplayString	MACRO stringAddress
	push	edx
	mov		edx,stringAddress
	call	WriteString
	;call	crlf
	pop		edx
ENDM


; ---------------------------------------------------------------------------------
; Name: mGetString
; Prompts a user to enter a string and then stores the entered string in a memory
;	location.
;
; Preconditions: The string is assumed to contain byte values.
; Postconditions: None
;	
; Receives:
; 	prompt = prompt displayed to user before reading their string
;	bufferAddress = a character buffer used to display a string such as prompt
;	bufferSize = the size of the buffer mentioned above
; 
;Returns:
;	byteNum = an address with the number of bytes counted from the user's input	
; ---------------------------------------------------------------------------------
mGetString		MACRO prompt,bufferAddress,bufferSize,byteNum

	;save registers that might be affected
	push	edx
	push	ecx
	push	eax

	mDisplayString	prompt
	mov		edx, bufferAddress
	mov		ecx, bufferSize
	call	ReadString
	mov		[byteNum],eax ; sending back the number of bytes entered 
	
	;return saved registered to their prior state
	pop eax
	pop ecx
	pop	edx
ENDM

;Constants
ARRAYSIZE  =  10

.data
array		SDWORD	ARRAYSIZE DUP (?)
readBuffer	BYTE	40	DUP(0) ;allow up to 40 chars, but anything above 11 is later rejected in ReadVal
byteCount	SDWORD   ?
charBuffer	BYTE	12	DUP(?)
average		SDWORD	?
sum			SDWORD	0
minSDWORD	BYTE	"-2147483648",0

intro1		BYTE "The following program takes in 10 user inputs as strings verifies they are valid and returns the rounded average and sum that is represented.",0
intro2		BYTE "The inputs must represent numbers [-2^31,2^31-1] to be valid. ",0
intro3		BYTE "After collecting 10 numbers the sum,average, and numbers used to find them will be displayed.",0
promptUser	BYTE "Enter in a signed number: ",0
rePrompt	BYTE "Too big/small or non-number entered: ",0
youEntered	BYTE "Here are your 10 inputs",0
showAverage	BYTE "The truncated average is: ",0
showSum		BYTE "The calculated sum is: ",0
goodbye		BYTE "Thanks for using the program,bye now.",0

.code
main PROC

	;displaying an introduction and short explanation
	mDisplayString offset intro1
	call crlf
	mDisplayString offset intro2
	call crlf
	mDisplayString offset intro3
	call crlf
	

	;prepare and fill the array of SDWORDs
	mov		ecx,ARRAYSIZE
	mov		edi,offset array
	fillArray:
		push	offset	rePrompt
		push	offset	promptUser
		push	offset	readBuffer
		push	sizeof	readBuffer
		push	offset	byteCount
		call	ReadVal

		;ebx now has the valid converted integer
		mov		[edi],ebx
		add		edi,4
		add		sum,ebx
		LOOP	fillArray
	
	;prepare and do signed division for average
	xor		eax,eax
	xor		edx,edx
	mov		eax,sum
	cdq		
	mov		ebx,ARRAYSIZE
	idiv	ebx
	mov		average,eax

	
	call	crlf
	;convert and print the user's integer inputs
	mDisplayString	offset youEntered
	call	crlf
	mov		esi,offset array ; which stores the sdwords to be printed
	mov		ecx,ARRAYSIZE ; number of elements
	printInts:
		push	offset minSDWORD
		push	[esi]
		push	offset charBuffer
		call	WriteVal
		add		esi,4
		LOOP	printInts


	;print the sum calculated
	call	crlf
	call	crlf
	mDisplayString offset showSum
	push	offset minSDWORD
	push	sum
	push	offset charBuffer
	call	WriteVal
	call	crlf
	
	
	;print the average calculated
	call	crlf
	mDisplayString offset showAverage
	push	offset minSDWORD
	push	average
	push	offset charBuffer
	call	WriteVal
	call	crlf
	call	crlf

	;display goodbye message
	mDisplayString offset goodbye
	call	crlf
	call	crlf


		Invoke ExitProcess,0	; exit to operating system
main ENDP



; ---------------------------------------------------------------------------------
; Name: WriteVal 
; WriteVal takes in an integer and converts it to a string that can be shown on 
; the console.
; 
;	mDisplayString is used a subprocedure
;
; Preconditions: The integer entered must be an SDWORD.
; Postconditions: The character buffer will contain the the last int as a string.
;	
; Receives:
; [ebp+8]  = The integer being converted
; [ebp+12] = address character buffer used to display the converted number
; [ebp+16] = address of a string representation of the smallest SDWORD
; 
;Returns:
;	None but the converted integer is printed to the console.
; ---------------------------------------------------------------------------------

WriteVal	PROC
	push	ebp
	mov		ebp,esp
	
	;saving many registers 
	push	ecx
	push	eax
	push	ebx
	push	edx
	push	esi
	push	edi

	;clear registers that will be used
	xor		eax,eax
	xor		ebx,ebx
	xor		edx,edx
	xor		ecx,ecx
	
	;clear the character buffer 
	mov edi, [ebp+8]
	mov ecx, 12
	xor eax, eax
	rep stosb
	
	;preparing for division/conversion to string
	mov		eax,[ebp+12]
	cmp		eax,0
	je		_zeroEdgeCase

	mov		ebx,10
	mov		edi,[ebp+8]
	cmp		eax,0
	JNL		_getLen
	neg		eax 	;take absolute value for conversion
	jo		_minEdgecase


	_getLen:
		cmp		eax,0
		JLE		_foundLen	
		idiv	ebx
		push	edx ; save remainder to stack
		xor		edx,edx
		inc		ecx
		JMP		_getLen

	_foundLen:	; ecx contains the number of digits
		mov		eax,[ebp+12]
		cmp		eax,0
		JNL		loadBuffer
		push	 "-" -48
		inc		ecx


	CLD
	loadBuffer:
		pop		edx
		add		edx,48
		mov		eax,edx
		stosb
		LOOP	loadBuffer
	mov		BYTE PTR [edi], 0 ; null termination
	JMP		_end

		
	_zeroEdgeCase:

		mov		edi,[ebp+8]
		mov		ebx,[edi]
		add		ebx,48
		mov		[edi],ebx
		mov		 BYTE PTR [edi+1], 0 ; null termination
		JMP		_end


	_minEdgecase:
	; -------------------------------------------------------------------------------
	; This is a case of an SDWORD where the value is minimum possible -2147483648.
	; This number is a valid SDWORD but the conversion to a string only uses
	;	positive numbers and negates negative numbers first .
	; The maximum allowed SDWORD is 2147483647 and so the negation causes an overflow.
	; The code below handles this case specifically by assuming that the integer was
	;	already verified as valid in a different procedure.
	; -------------------------------------------------------------------------------
		mov		esi,[ebp+16]
		mov		ecx,11
		rep		movsb


	_end:
		mDisplayString	[ebp+8]
		;space output for visibility 
		mov		al," "
		call	WriteChar
	

	;restoring many registers
	pop		edi
	pop		esi
	pop		edx
	pop		ebx
	pop		eax
	pop		ecx

	pop		ebp
	RET		12
WriteVal	ENDP


; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Repeatedly takes user input until the user enters a valid SDWORD and converts the
;	the ASCII characters to an integer.
;
; Registers changed : ebx
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
	push	eax

	_firstPrompt:
		mGetString [ebp+20],[ebp+16],[ebp+12],[ebp+8]
		JMP		_verifyLength
	
	_subsequentPrompt: ; ebp+24 is the rePrompt
		mGetString [ebp+24],[ebp+16],[ebp+12],[ebp+8]

	_verifyLength:
		mov		eax,[ebp+8]
		cmp		eax,11
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
		mov		esi,[ebp+16] ;start of string in memory
		mov		ecx,[ebp+8] 
		mov		eax,0
		CLD
		
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
			;shift char digit left using multiplication
			mov		ebx,10
			xor		edx,edx
			imul	ebx
			jo		_subsequentPrompt
			
			;turn character to integer 
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

	; return registers back to their original state
	pop		eax
	pop		edi
	pop		ecx
	pop		ebp
	RET		20
ReadVal	 ENDP



END main
