.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
includelib DLLSkeleton.lib
includelib \masm32\lib\kernel32.lib

TestHello PROTO

.code
start:
        invoke TestHello
        invoke ExitProcess,NULL
end start
