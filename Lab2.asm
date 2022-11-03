.386
.MODEL flat, stdcall
 STD_OUTPUT_HANDLE EQU -11 
 GetStdHandle PROTO, nStdHandle: DWORD 
 WriteConsoleA PROTO, handle: DWORD, lpBuffer:PTR BYTE, nNumberOfBytesToWrite:DWORD, lpNumberOfBytesWritten:PTR DWORD, lpReserved:DWORD
 ExitProcess PROTO, dwExitCode: DWORD 

 .data
 consoleOutHandle dd ? 
 bytesWritten dd ? 
 message db "Hello World",13,10
 lmessage dd 13

 .code
 main PROC
  push STD_OUTPUT_HANDLE	; function argument
  call GetStdHandle
  add esp, 4	; clean the unnecessary STD_OUTPUT from the stack
  mov consoleOutHandle, eax 
  mov edx,offset message 
  pushad    
  mov eax, lmessage
  push 0
  push offset bytesWritten
  push eax
  push edx
  push consoleOutHandle
  call WriteConsoleA
  add esp, 20	; forget about the function parameters from the previous step
  popad
  call testproc
  call endprog
 main ENDP

 endprog PROC
   push 0
   call ExitProcess
   add esp, 4
   ret
  endprog endp

  testproc PROC
    ret
  testproc endp
END main