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
    arr dd 100,90,80,70,60,50,40,30,20,10 ;could be db, dw, dd

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

BubbleSort PROC arrptr:DWORD, arrsize:DWORD, arrlength:DWORD
    local changed :SBYTE
    local elementsize :SBYTE
    xor eax, eax
    mov changed, al
    xor edx, edx
    mov eax, arrsize
    mov ebx, arrlength
    div ebx
    mov elementsize, al
bubbleloop:
        xor ecx, ecx
        xor eax, eax
        xor ebx, ebx
        xor edx, edx
        mov changed, al
    comparetwo:
            movsx eax, elementsize
            mul ecx
            add eax, arrptr
            mov ebx, eax
            movsx edx, elementsize
            add eax, edx
            mov edi, [eax]
            mov esi, [ebx]
            cmp edi, esi
            jg nochanges
            mov edx, edi
            mov [eax], esi
            mov [ebx], edx
            mov al, 1
            mov changed, al
        nochanges:
            inc ecx
            mov eax, arrlength
            add eax, -1
            cmp ecx, eax
            jl comparetwo
        cmp changed, 1
        je bubbleloop
    xor eax, eax
    ret
BubbleSort ENDP

Main PROC
    invoke GetAvg, offset arr, sizeof arr, lengthof arr
    invoke WriteLineArray, offset arr, sizeof arr, lengthof arr
    invoke BubbleSort, offset arr, sizeof arr, lengthof arr
    invoke WriteLineArray, offset arr, sizeof arr, lengthof arr
    invoke Sleep, 5000
    invoke ExitProcess, 0
Main ENDP 
END Main