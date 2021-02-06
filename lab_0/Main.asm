    ;Defines, which instruction set will be used
    ;Enables assembly of nonprivileged instructions for the 80386 processor
    ;Disables assembly of instructions introduced with later processors (32-bit MASM only)
.386

    ;Defines, which memory model will be used
    ;.MODEL memory-model [, language-type] [, stack-option]
    ;memory-model - Required parameter that determines the size of code and data pointers
    ;language-type - Optional parameter that sets the calling and naming conventions for procedures and public symbols
    ;stack-option - Optional parameter, but not used if memory-model is FLAT
    ;FLAT model can use only C or STDCALL language types, and is unable to use stack option
    ;But 16-bit programs have far more various combinations than 32-bit
    ;Flat memory model or linear memory model refers to a memory addressing paradigm in which memory appears to the program as a single contiguous address space
    ;The CPU can directly (and linearly) address all of the available memory locations without having to resort to any sort of memory segmentation or paging schemes
.model flat,stdcall

    ;casemap is an option to determine case of identifiers
    ;none - preserves the case of identifiers in PUBLIC, COMM, EXTERNDEF, EXTERN, PROTO, and PROC declarations
    ;thus :none parameter makes identifiers case sensetive
option casemap : none

;include \masm32\include\user32.inc
;include \masm32\include\kernel32.inc
;include \masm32\include\windows.inc

;includelib \masm32\lib\user32.lib ;used in msgbox example
includelib \masm32\lib\kernel32.lib ;used in all examples

    ;The same as #define in C, EQU means 'equals', im assigning value -11 to std console output handle
STDOH EQU -11

    ;PROTO is a directive to prototype the function, label PROTO [distance] [language-type] [, [parameter]:tag ...]
SetConsoleTitleA  PROTO    :DWORD
GetStdHandle      PROTO    :DWORD
WriteConsoleA     PROTO    :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ExitProcess       PROTO    :DWORD
Sleep             PROTO    :DWORD

.const
        ;db Allocates and optionally initializes a byte of storage for each initializer. DB is a synonym of BYTE. Can also be used as a type specifier anywhere a type is legal
        ;dw Allocates and optionally initializes a word (2 bytes) of storage for each initializer. DW is a synonym of WORD. Can also be used as a type specifier anywhere a type is legal
        ;13,10 is a CRLF two bytes sequence
    sConsoleTitle    db 'Console Test',0
    sWriteText       db 'I am testing the console with CRLF!',13,10
    sWriteText2      db 'I am testing the console without CRLF! '
    sWriteText3      db 78,79,32,83,84,82,73,78,71,83,13,10 ;ASCII codes for 'NO STRINGS'

.data
    consoleOutHandle dd ? 
    bytesWritten dd ? 
    message db "Hello World",13,10
    lmessage dd 13

    MsgBoxCaption    db "It's the first your program for Win32",0
	MsgBoxText       db "Assembler language for Windows is a fable!",0

    ;When used with .MODEL, indicates the start of a code segment
    ;.CODE [name], name is optional parameter that specifies the name of the code segment
    ;The default name is _TEXT for tiny, small, compact, and flat models. The default name is modulename_TEXT for other models
.code

StackStdHandle PROC
        ;In the first directive, within a macro, LOCAL defines labels that are unique to each instance of the macro
        ;In the second directive, within a procedure definition (PROC), LOCAL creates stack-based variables that exist for the duration of the procedure
        ;The labelId may be a simple variable or an array containing count elements, where count is a constant expression
    LOCAL hStdout :DWORD

        ;PUSH var is simply pushing the variable on the stack.
        ;PUSH [var] is dereferencing the variable, if it is a pointer, this code will push the value at the address on the stack
        ;PUSH OFFSET var is pushing the address of that variable on the stack
        ;PUSH reads the contents of the register and puts it on the stack, it makes a copy leaving register untouched, thus register keeps what it had in it before the push
        ;POP does modify the register taking what is on the stack and writing it in the register
        ;---------------------EXAMPLE-------------------------
        ;pushd 0             ; pushes the dword value 0 onto the stack
        ;push dword ptr [0]  ; push the dword at address 0 onto the stack and it will likely crash your program
        ;And similarly for register operands:
        ;push eax              ; push the value of eax register onto the stack
        ;push dword ptr [eax]  ; push the value at the address that eax register points to
        ;-----------------------------------------------------
        ;It's important to remember that on x86 the stack grows downwards in memory
    push offset sConsoleTitle

        ;BOOL WINAPI SetConsoleTitle(_In_ LPCTSTR lpConsoleTitle)
        ;CALL should be used if a real single processor instruction shall be used to invoke a subroutine.
        ;INVOKE should be used if the assembler shall calculate the stack PUSH/POP instructions automatically depending on the calling conventions like __cdecl, __fastcall, __stdcall and so on.
        ;INVOKE is preferred as calling method if you call Windows-API and C-API functions mixed up.
        ;If you decide to use CALL only you have to bother about the parameters pushed on/popped from the stack which makes the code more unreliable.
    call SetConsoleTitleA

        ;HANDLE WINAPI GetStdHandle(_In_ DWORD nStdHandle)
        ;We push the nStdHandle on the stack and then call for a GetStdHandle() function, which gets arg from stack
        ;Possible values of nStdHandle:
        ;STD_INPUT_HANDLE (DWORD) -10	The standard input device. Initially, this is the console input buffer, CONIN$.
        ;STD_OUTPUT_HANDLE (DWORD) -11	The standard output device. Initially, this is the active console screen buffer, CONOUT$.
        ;STD_ERROR_HANDLE (DWORD) -12	The standard error device. Initially, this is the active console screen buffer, CONOUT$.
        ;Here we use -11 because we want the hadle of the output of the console
    push STDOH ;EQU -11
    call GetStdHandle

        ;The MOV instruction copies the data item referred to by its second operand (register contents, memory contents, or a constant value) into the location referred to by its first operand (register or memory)
        ;While register-to-register moves are possible, direct memory-to-memory moves are not
        ;In cases where memory transfers are desired, the source memory contents must first be loaded into a register, then can be stored to the destination memory address
        ;---------------------EXAMPLE-------------------------
        ;mov eax, [ebx]	;Move the 4 bytes in memory at the address contained in EBX into EAX
        ;mov [var], ebx	;Move the contents of EBX into the 4 bytes at memory address var. (Note, var is a 32-bit constant)
        ;mov eax, [esi-4]	;Move 4 bytes at memory address ESI + (-4) into EAX
        ;mov [esi+eax], cl  ;Move the contents of CL into the byte at address ESI+EAX
        ;mov edx, [esi+4*ebx]   ;Move the 4 bytes of data at address ESI+4*EBX into EDX
        ;-----------------------------------------------------
    mov hStdout, EAX

        ;Here we make 5 pushes because WriteConsoleA takes 5 args (5 DWORD's)
        ;BOOL WINAPI WriteConsole(_In_ HANDLE hConsoleOutput, _In_ const VOID *lpBuffer, _In_ DWORD nNumberOfCharsToWrite, _Out_opt_ LPDWORD lpNumberOfCharsWritten, _Reserved_ LPVOID lpReserved)
        ;But as I mentioned earlier, it's importand to remember that x86 stack is growing DOWNWARDS, so we push all our args backwards
    push 0                                                                      ;lpReserved
    push 0                                                                      ;lpNumberOfCharsWritten
    pushd 37                                                                    ;nNumberOfCharsToWrite
    push offset sWriteText                                                      ;*lpBuffer, this is a pointer, thus we use PUSH OFFSET instruction in order to put the address in the stack, not the value
    push hStdout                                                                ;hConsoleOutput
    call WriteConsoleA                                                          ;call for a function, the data will be popped from stack itself

    push 0
    push 0
    pushd 39
    push offset sWriteText2
    push hStdout
    call WriteConsoleA

    push 0;
    push 0;
    push 12;
    push offset sWriteText3
    push hStdout
    call WriteConsoleA

        ;It doesnt matter whether it will be pushd var or push vard
        ;We push our timeout in ms on the stack and then call for a Sleep() function
    pushd 4000
    call Sleep
    xor eax, eax                                                                ;null the EAX register
    ret                                                                         ;return
StackStdHandle ENDP

RegistersStdHandle PROC
    ;In this example we use registers instead of stack in order to operate data
    ;Registers are more convinient when some operations are needed, because data transfers reg-reg, reg-mem, mem-reg are possible, but not the mem-mem transfer
    invoke GetStdHandle, STDOH                                                  ;calling a function and automatically pushing arg on the stack, the result will be stored on EAX register
    mov consoleOutHandle,eax                                                    ;copy the result from EAX register to a variable
    mov edx,offset message                                                      ;copy message pointer address to a EDX register

        ;pushad pushes the contents of the general-purpose registers onto the stack
        ;The registers are stored on the stack in the following order:
        ;EAX, ECX, EDX, EBX, EBP, ESP (original value), EBP, ESI, and EDI, if the current operand-size attribute is 32
        ;These instructions perform the reverse operation of the POPA/POPAD instructions
        ;The value pushed for the ESP or SP register is its value before prior to pushing the first register
        ;pusha (push-all) is an instruction for 16-bit, pushad (push-all-double) is for 32-bit
    pushad
    mov eax, lmessage                                                           ;copy predefined message's text length into a EAX register
    invoke WriteConsoleA, consoleOutHandle, edx, eax, offset bytesWritten, 0    ;invoke a fucntion, it is done the same way as the CALL instruction

        ;popad is the same as pushad
        ;Pops doublewords (POPAD) or words (POPA) from the stack into the general-purpose registers
        ;The registers are loaded in the following order:
        ;EDI, ESI, EBP, EBX, EDX, ECX, and EAX, if the operand-size attribute is 32
        ;These instructions reverse the operation of the PUSHA/PUSHAD instructions
        ;The value on the stack for the ESP or SP register is ignored, instead, the ESP or SP register is incremented after each register is loaded
    popad
    pushd 4000
    call Sleep
    xor eax, eax
    ret
RegistersStdHandle ENDP

MsgBox PROC
    ;
    ;
    xor eax, eax
    ret
MsgBox ENDP

PrintMacro PROC
    ;
    ;
    xor eax, eax
    ret
PrintMacro ENDP

    ;PROC marks start and end of a procedure block called label. The statements in the block can be called with the CALL instruction or INVOKE directive
Main PROC
    call StackStdHandle
    call RegistersStdHandle
    call MsgBox
    call PrintMacro

        ;We push our arg (exit code) on the stack and then call for an ExitProcess() function
        ;The other way to call a function is to invoke it:
        ;invoke ExitProcess, 0
    push 0
    call ExitProcess

    ;ENDP Marks the end of procedure name previously begun with PROC.
Main ENDP 

    ;The END Main marks the end of the file, specifying an entry point for the program (this is optional). END is a directive for END OF FILE command.
END Main