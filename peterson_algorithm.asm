; Multithreading Lab 2
; Peterson Algorithm on Assembler
; Use it on your own risk
; Created by a.kicha@knu.ua
; on 02.11.2022

; Compiler Configuration
.386	; the program is written for at least .386 family of processors
.model flat, stdcall	; each segment takes 64kB space	
.stack 80h	; stack size is precisely 128 bytes

; user32.lib procedures
extern MessageBoxA@16:near

; External libraries
includelib C:\masm32\lib\user32.lib

; Data Segment
data segment
	msg db 'Hello, World!', 0	; define bytes
data ends

; Code Segment
text segment

; Start of the program
start:
	push 0	; the last argument of the MessageBoxA - type of window
	push offset msg ; the second last argument of the MessageBoxA function - window head
	push offset msg ; the second argument of the MessageBoxA function - window message
	push 0	; the first argument of the MessageBoxA function - related window identifier
	call MessageBoxA@16 ; call the function, it takes the parameters from the stack
	ret ; exit the program
text ends
end start