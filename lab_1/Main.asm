.386
.model flat,stdcall

option casemap : none

includelib \masm32\lib\kernel32.lib ;used in all examples

STDOH EQU -11
ASCIIOFFSET EQU 48
RANDOMNUMBER EQU 12345

GetStdHandle      PROTO    :DWORD
WriteConsoleA     PROTO    :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ExitProcess       PROTO    :DWORD
Sleep             PROTO    :DWORD

.data
    msglength dd 0
    numberstring db 256 dup(0) ;max length 256 and all are zeroed

.code
WriteToConsole PROC
    LOCAL ConsoleOutputHandle :DWORD
    invoke GetStdHandle, STDOH
    mov ConsoleOutputHandle, eax
    .while msglength > 0
        mov edx, offset numberstring
        add msglength, -1
        add edx, msglength
        invoke WriteConsoleA, ConsoleOutputHandle, edx, 1, 0, 0
    .endw
    xor eax, eax
    ret
WriteToConsole ENDP

ConvertToString PROC number:DWORD
    mov eax, number
    .while eax > 0
        xor edx, edx
        mov eax, number
        mov ecx, 10
        div ecx
        mov number, eax                 ;save the result
        mov ebx, offset numberstring    ;ebx now stores the pointer to string
        add ebx, msglength
        add dl, ASCIIOFFSET
        mov [ebx], dl                   ;move number (1 byte) to string
        add msglength, 1
        mov eax, number
    .endw
    ret
ConvertToString ENDP

Main PROC
    invoke ConvertToString, RANDOMNUMBER
    invoke WriteToConsole
    invoke Sleep, 4000
    invoke ExitProcess, 0
Main ENDP 
END Main