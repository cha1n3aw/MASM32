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
    arr1 db 100,90,80,70,60,50,40,30,20,10 ;can be either db, dw or dd
    arr2 dw 1,2,3,4,5,6,7,8,9,10 ;can be either db, dw or dd
    arr3 dd 10 dup (0) ;can be either db, dw or dd

.code
WriteNum PROC uses eax ebx edx ecx number :DWORD
    local string[32] :SBYTE
    local strlen :DWORD
    local handle :DWORD
    local signed :SBYTE
    xor eax, eax
    mov strlen, eax
    invoke GetStdHandle, STDOH
    mov handle, eax
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
        lea ebx, string                 ;EBX now stores the pointer to string   
        add ebx, strlen
        add dl, ASCIIOFFSET
        mov [ebx], dl                   ;move number (1 byte) to string
        add strlen, 1
        mov eax, number
    .endw
    .if signed > 0                      
        lea edx, signed
        invoke WriteConsoleA, handle, edx, 1, 0, 0
    .endif
    .while strlen > 0
        lea edx, string
        add strlen, -1
        add edx, strlen
        invoke WriteConsoleA, handle, edx, 1, 0, 0
    .endw
    xor eax, eax
    ret
negative:
    mov cl, 45
    mov signed, cl
    neg eax
    mov number, eax
    jmp positive
WriteNum ENDP

WriteLineNum PROC uses eax ebx edx ecx numbercrlf :DWORD 
    invoke WriteNum, numbercrlf
    invoke GetStdHandle, STDOH
    invoke WriteConsoleA, eax, offset CRLF, 2, 0, 0
    xor eax, eax
    ret
WriteLineNum ENDP

GetAvg PROC uses eax ebx edx ecx arrptr :DWORD, arrsize :DWORD, arrlength :DWORD
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    mov eax, arrsize
    mov ebx, arrlength
    div ebx
    xor ebx, ebx
    cmp eax, 4
    je equalsdword
    cmp eax, 2
    je equalsword
    cmp eax, 1
    je equalsbyte
    jmp ifend
equalsdword:
        mov eax, ecx
        mov edx, 4
        mul edx
        add eax, arrptr
        add ebx, [eax]
        inc ecx
        cmp ecx, arrlength 
        jl equalsdword
        jmp ifend
equalsword:
        mov eax, ecx
        mov edx, 2
        mul edx
        add eax, arrptr
        mov dx, [eax]
        movsx eax, dx
        add ebx, eax
        inc ecx
        cmp ecx, arrlength 
        jl equalsword
        jmp ifend
equalsbyte:
        mov eax, ecx
        add eax, arrptr
        mov dl, [eax]
        movsx eax, dl
        add ebx, eax
        inc ecx
        cmp ecx, arrlength 
        jl equalsbyte
        jmp ifend
ifend:
    xor edx, edx
    mov eax, ebx
    mov ebx, arrlength
    div ebx
    invoke WriteLineNum, eax
    xor eax, eax
    ret
GetAvg ENDP

WriteLineArray PROC arrptr:DWORD, arrsize:DWORD, arrlength:DWORD
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    mov eax, arrsize
    mov ebx, arrlength
    div ebx
    xor ebx, ebx
    cmp eax, 4
    je writedword
    cmp eax, 2
    je writeword
    cmp eax, 1
    je writebyte
    jmp ifend
writedword:
        mov eax, ecx
        mov edx, 4
        mul edx
        add eax, arrptr
        invoke WriteLineNum, [eax]
        inc ecx
        cmp ecx, arrlength 
        jl writedword
        jmp ifend
writeword:
        mov eax, ecx
        mov edx, 2
        mul edx
        add eax, arrptr
        mov dx, [eax]
        movsx eax, dx
        invoke WriteLineNum, [eax]
        inc ecx
        cmp ecx, arrlength 
        jl writeword
        jmp ifend
writebyte:
        mov eax, ecx
        add eax, arrptr
        mov dl, [eax]
        movsx eax, dl
        invoke WriteLineNum, [eax]
        inc ecx
        cmp ecx, arrlength 
        jl writebyte
        jmp ifend
ifend:
    xor eax, eax
    ret
WriteLineArray ENDP

SumArrays PROC arr1ptr:DWORD, arr1size:DWORD, arr1length:DWORD, arr2ptr:DWORD, arr2size:DWORD, arr2length:DWORD, arr3ptr:DWORD, arr3size:DWORD, arr3length:DWORD
    local arr1itemsize dd
    local arr2itemsize dd
    local arr3itemsize dd
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    mov eax, arr3size
    mov ebx, arr3length
    div ebx
    mov eax, arr3itemsize
    mov ecx, eax
    xor edx, edx
    mov eax, arr1size
    mov ebx, arr1length
    div ebx
    mov eax, arr1itemsize
    cmp ecx, eax
    jl greatersource
    xor edx, edx
    mov eax, arr2size
    mov ebx, arr2length
    div ebx
    mov eax, arr2itemsize
    cmp ecx, eax
    jl greatersource



greatersource:
    warning_message db "Warning: source arrays are greater than destination array! The result will be truncated to the size of a destination array!",0


    xor eax, eax
    ret
SumArrays ENDP

Main PROC
        ;all three arrays could be both local (on stack) and global (in memory)
        ;locals should be passed as a lea instead of an offset
    invoke SumArrays, offset arr1, sizeof arr1, lengthof arr1, offset arr2, sizeof arr2, lengthof arr2, offset arr3, sizeof arr3, lengthof arr3
    invoke WriteLineArray, offset arr3, sizeof arr3, lengthof arr3
    invoke GetAvg, offset arr3, sizeof arr3, lengthof arr3
    invoke Sleep, 5000
    invoke ExitProcess, 0
Main ENDP 
END Main