.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib

.data
LibName db "DLLSkeleton.dll",0
FunctionName db "TestHello",0
DllNotFound db "Cannot load library",0
AppName db "Load Library",0
FunctionNotFound db "TestHello function not found",0

.data?
hLib dd ?
TestHelloAddr dd ?

.code
start:
        invoke LoadLibrary,addr LibName
        .if eax==NULL
                invoke MessageBox,NULL,addr DllNotFound,addr AppName,MB_OK
        .else
                mov hLib,eax
                invoke GetProcAddress,hLib,addr FunctionName
                .if eax==NULL
                        invoke MessageBox,NULL,addr FunctionNotFound,addr AppName,MB_OK
                .else
                        mov TestHelloAddr,eax
                        call [TestHelloAddr]
                .endif
                invoke FreeLibrary,hLib
        .endif
        invoke ExitProcess,NULL
end start
