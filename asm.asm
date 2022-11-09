
.386
.xmm
.MODEL flat, stdcall

STD_OUTPUT_HANDLE EQU -11 
GetStdHandle PROTO, nStdHandle: DWORD 
WriteConsoleA PROTO, handle: DWORD, lpBuffer:PTR BYTE, nNumberOfBytesToWrite:DWORD, lpNumberOfBytesWritten:PTR DWORD, lpReserved:DWORD

extern CreateThread@24:near
ExitProcess PROTO, dwExitCode: DWORD 

.data
 flag1 db 0 ; whether or not thread 1 wants to reach out to the critical section
 flag2 db 0 ; whether or not thread 2 wants to reach out to the critical section
 turn db 2 ; who's turn it is to reach out to the critical section

 consoleOutHandle dd ? ; handle to use console to print debug messages
 bytesWritten dd ? ; reserve a place for the console output
 msg1 db "LOG_1", 13, 10
 msg2 db "LOG_2", 13, 10

.code
 proc1 PROC
  mov flag1, 1 ; mark that that thread 1 needs access to the critical section
  MFENCE
  mov turn, 2 ; give a chance for the other thread to work with the critical section
  MFENCE

  lp1:
   cmp flag2, 1 ; check if other thread wants to reach out to the critical section
   jne proc1_critical_section ; another thread doesn't want to work with the critical section, jump to the critical section
   cmp turn, 2 ; check it it’s other thread’s turn to work with the critical section
   jne proc1_critical_section ; work with critical section if it’s the current thread’s turn
   jmp lp1

  proc1_critical_section:
   mov flag1, 0 ; done, mark that the current thread doesn’t need to work with the critical section anymore
   MFENCE

   push offset msg1
   call consoleLog
   add esp, 4

   ret ; simply return from the function as it is just a simulation of working with a critical section
 proc1 ENDP

 proc2 PROC
  mov flag2, 1 ; mark that that thread 1 needs access to the critical section
  MFENCE
  mov turn, 1 ; give a chance for the other thread to work with the critical section
  MFENCE
  
  lp2:
   cmp flag1, 1 ; check if other thread wants to reach out to the critical section
   jne proc2_critical_section ; work with critical section if another thread doesn’t required working with the critical section
   cmp turn, 1 ; check it it’s other thread’s turn to work with the critical section
   jne proc2_critical_section ; work with critical section if it’s this thread’s turn
   jmp lp2
  
  proc2_critical_section:
   mov flag2, 0 ; done, mark that the current thread doesn’t need to work with the critical section anymore
   MFENCE
   
   push offset msg2
   call consoleLog
   add esp, 4

   ret ; simply return from the function as it is just a simulation of working with crit. section
 proc2 ENDP

 main PROC
  push STD_OUTPUT_HANDLE	; function argument
  call GetStdHandle
  add esp, 4	; clean the unnecessary STD_OUTPUT from the stack
  mov consoleOutHandle, eax 

   push 0 ; start passing parameters to the Win32 CreateThread function
          ; thread ID
   push 0 ; default creation flags
   push 0 ; argument to thread function
   push offset proc1 ; procedure to be called in the thread
   push 0 ; use default stack size
   push 0 ; use default security attributes
          ; 24 bytes

   call CreateThread@24

   add esp, 24 ; remove arguments for the CreateThread function from the stack as they are not necessary anymore

   push 0 ; start passing parameters to the Win32 CreateThread function
          ; thread ID
   push 0 ; default creation flags
   push 0 ; argument to thread function
   push offset proc2 ; procedure to be called in the thread
   push 0 ; use default stack size
   push 0 ; use default security attributes
          ; 24 bytes

   call CreateThread@24

   add esp, 24 ; remove arguments for the CreateThread function from the stack as they are not necessary anymore

   ;push 0
   ;call ExitProcess
 main ENDP

 ; parameters in stack
 ; 1 - message string
 consoleLog PROC
   push eax ; save the old value of the eax register
   mov eax, [esp + 8] ; function argument: message. 0 bytes = eax value + 4 bytes = return address + 4 bytes = procedure argument = 8 bytes

   push 0
   push offset bytesWritten
   push 5 ; lmessage
   push eax; message
   push consoleOutHandle

   call WriteConsoleA
   add esp, 20	; forget about the function parameters from the previous step

   ; 20 bytes - arguments to the WriteConsoleA procedure

   pop eax
   add esp, 4

   ; 4 bytes - saved old value of the eax register

   ret
 consoleLog ENDP
 END main
