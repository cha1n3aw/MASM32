.386
.model flat,stdcall

option casemap : none

includelib \masm32\lib\kernel32.lib

GetStdHandle      PROTO    :DWORD
WriteConsoleA     PROTO    :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ExitProcess       PROTO    :DWORD
Sleep             PROTO    :DWORD

.data
    msglength dd 0
    numberstring db 256 dup(0)

.code
WriteToConsole PROC
    LOCAL ConsoleOutputHandle :DWORD
    invoke GetStdHandle, -11
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
        mov number, eax
        mov ebx, offset numberstring
        add ebx, msglength
        add dl, 48
        mov [ebx], dl
        add msglength, 1
        mov eax, number
    .endw
    ret
ConvertToString ENDP

Main PROC
    invoke ConvertToString, 12345
    invoke WriteToConsole
    invoke Sleep, 4000
    invoke ExitProcess, 0
Main ENDP 
END Main