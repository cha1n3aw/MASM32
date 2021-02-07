.386
.model flat,stdcall

option casemap : none

includelib \masm32\lib\kernel32.lib ;used in all examples

STDOH EQU -11
ASCIIOFFSET EQU 48

GetStdHandle      PROTO    :DWORD
WriteConsoleA     PROTO    :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ExitProcess       PROTO    :DWORD
Sleep             PROTO    :DWORD

.const
    CRLF db 13,10

.data
    signed db 0
    msglength dd 0
    numberstring db 32 dup(0)           ;max length 32 and all are zeroed
    arr0 db -1, -2, -3, -4
    arr1 dw 1001, 2002, 3003, 4004
    arr2 dd 4 dup (0)                 ;max length is 255, [0] byte is a counter for an araay length

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
    invoke WriteConsoleA, consoleOutHandle, offset CRLF, 2, 0, 0 ;send CRLF
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
    invoke WriteToConsole
    xor eax, eax
    ret
negative:
    mov cl, 45
    mov signed, cl
    neg eax
    mov number, eax
    jmp positive
ConvertToString ENDP

FillArray PROC arr0ptr:DWORD, arr1ptr:DWORD, arr2ptr:DWORD
    LOCAL counter :DWORD

        ;multiplication of arr0
    mov counter, lengthof arr0
    mov [arr2ptr], 1
    .while counter > 0
        add counter, -1
        mov ebx, arr0ptr
        add ebx, counter                ;select the last item in array
        mov eax, [arr2ptr]
        xor edx,edx
        mov cl, [ebx]
        movsx edx, cl
        imul eax, edx                   ;perform signed multiplication
        mov [arr2ptr], eax              ;fetch the result from eax to arr2[0]
    .endw
    invoke ConvertToString, [arr2ptr]

        ;sum of arr1
    mov counter, lengthof arr1
    mov [arr2ptr+4], 0
    .while counter > 0
        add counter, -1
        mov ebx, arr1ptr
        mov eax, counter
        mov ecx, 2
        mul ecx
        add ebx, eax
        xor ecx, ecx
        mov cx, [ebx]
        movsx edx, cx
        mov eax, [arr2ptr+4]
        add eax, edx
        mov [arr2ptr+4], eax
    .endw
    invoke ConvertToString, [arr2ptr+4]

        ;diff between arr2[1] and arr2[0]
    mov eax, [arr2ptr+4]
	sub eax, [arr2ptr]
	mov [arr2ptr+8], eax
    invoke ConvertToString, [arr2ptr+8]
     
        ;diff between arr2[0] and arr2[1]
    mov eax, [arr2ptr]
	sub eax, [arr2ptr+4]
	mov [arr2ptr+12], eax
    invoke ConvertToString, [arr2ptr+12]

        ;sum of multiplied items of arr0 and arr1
    mov [arr2ptr+16], 0
    mov counter, lengthof arr0
    .while counter > 0
        add counter, -1
        mov esi, arr0ptr
        add esi, counter                ;get pointer on arr0 last item, esi
        mov eax, counter
        mov edi, 2
        mul edi
        mov edi, arr1ptr
        add edi, eax                    ;get pointer on arr1 last item, edi
        mov bl, [esi]
        mov cx, [edi]
        movsx eax, bl
        movsx edx, cx
        imul eax, edx
        add eax, [arr2ptr+16]
        mov [arr2ptr+16], eax
    .endw
    invoke ConvertToString, [arr2ptr+16]
    xor eax, eax
    ret
FillArray ENDP

Main PROC
    invoke FillArray, offset arr0, offset arr1, offset arr2
    invoke Sleep, 5000
    invoke ExitProcess, 0
Main ENDP 
END Main