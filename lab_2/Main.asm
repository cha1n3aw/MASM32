.386
.model flat,stdcall

option casemap : none

includelib \masm32\lib\kernel32.lib ;used in all examples

RANDOMNUMBER EQU -12345
STDOH EQU -11
ASCIIOFFSET EQU 48

GetStdHandle      PROTO    :DWORD
WriteConsoleA     PROTO    :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ExitProcess       PROTO    :DWORD
Sleep             PROTO    :DWORD

.data
    signed db 0
    msglength dd 0
    numberstring db 256 dup(0)          ;max length 256 and all are zeroed

.code
WriteToConsole PROC
    LOCAL consoleOutHandle :DWORD
    invoke GetStdHandle, STDOH
    mov consoleOutHandle, eax
    .if signed > 0                      ;also could be text eax, eax & js somewhere
        mov edx, offset signed
        invoke WriteConsoleA, consoleOutHandle, edx, 1, 0, 0
    .endif
    .while msglength > 0
        mov edx, offset numberstring
        add msglength, -1
        add edx, msglength
        invoke WriteConsoleA, consoleOutHandle, edx, 1, 0, 0
    .endw
    xor eax, eax
    ret
WriteToConsole ENDP

ConvertToString PROC number:DWORD
    mov eax, number
    test eax, eax
    js negative
positive:
    .while eax > 0
        xor edx, edx
        mov eax, number
        mov ecx, 10
        div ecx
        mov number, eax                 ;save the result
        mov ebx, offset numberstring    ;EBX now stores the pointer to string
        add ebx, msglength
        add dl, ASCIIOFFSET
        mov [ebx], dl                   ;move number (1 byte) to string
        add msglength, 1
        mov eax, number
    .endw
    ret
negative:
    mov cl, 45
    mov signed, cl
    neg eax
    mov number, eax
    jmp positive
ConvertToString ENDP

Main PROC
    invoke ConvertToString, RANDOMNUMBER
    invoke WriteToConsole
    invoke Sleep, 4000
    invoke ExitProcess, 0
Main ENDP 
END Main