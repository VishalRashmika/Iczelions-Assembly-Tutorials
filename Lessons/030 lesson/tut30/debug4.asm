.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\comdlg32.inc
include \masm32\include\user32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\comdlg32.lib
includelib \masm32\lib\user32.lib

.data
AppName db "Win32 Debug Example no.4",0
ofn   OPENFILENAME <>
FilterString db "Executable Files",0,"*.exe",0
             db "All Files",0,"*.*",0,0
ExitProc db "The debuggee exits",0Dh,0Ah
		 db "Total Instructions executed : %lu",0
TotalInstruction dd 0

.data?
buffer db 512 dup(?)
startinfo STARTUPINFO <>
pi PROCESS_INFORMATION <>
DBEvent DEBUG_EVENT <>
align dword
context CONTEXT <>

.code
start:
	mov ofn.lStructSize,SIZEOF ofn
	mov  ofn.lpstrFilter, OFFSET FilterString
	mov  ofn.lpstrFile, OFFSET buffer
	mov  ofn.nMaxFile,512
	mov  ofn.Flags, OFN_FILEMUSTEXIST or \
                       OFN_PATHMUSTEXIST or OFN_LONGNAMES or\
                       OFN_EXPLORER or OFN_HIDEREADONLY
	invoke GetOpenFileName, ADDR ofn
	.if eax==TRUE
		invoke GetStartupInfo,addr startinfo
		invoke CreateProcess, addr buffer, NULL, NULL, NULL, FALSE, DEBUG_PROCESS+ DEBUG_ONLY_THIS_PROCESS, NULL, NULL, addr startinfo, addr pi
		.while TRUE
			invoke WaitForDebugEvent, addr DBEvent, INFINITE
			.if DBEvent.dwDebugEventCode==EXIT_PROCESS_DEBUG_EVENT
				invoke wsprintf, addr buffer, addr ExitProc, TotalInstruction
				invoke MessageBox, 0, addr buffer, addr AppName, MB_OK+MB_ICONINFORMATION
				.break
			.elseif DBEvent.dwDebugEventCode==EXCEPTION_DEBUG_EVENT
				.if DBEvent.u.Exception.pExceptionRecord.ExceptionCode==EXCEPTION_BREAKPOINT
					mov context.ContextFlags, CONTEXT_CONTROL
					invoke GetThreadContext, pi.hThread, addr context
					or context.regFlag,100h
					invoke SetThreadContext,pi.hThread, addr context
					invoke ContinueDebugEvent, DBEvent.dwProcessId,DBEvent.dwThreadId,DBG_CONTINUE	
					.continue
				.elseif DBEvent.u.Exception.pExceptionRecord.ExceptionCode==EXCEPTION_SINGLE_STEP
					inc TotalInstruction
					invoke GetThreadContext,pi.hThread,addr context
					or context.regFlag,100h
					invoke SetThreadContext,pi.hThread, addr context
					invoke ContinueDebugEvent, DBEvent.dwProcessId,DBEvent.dwThreadId,DBG_CONTINUE	
					.continue
				.endif
			.endif
			invoke ContinueDebugEvent, DBEvent.dwProcessId,DBEvent.dwThreadId,DBG_EXCEPTION_NOT_HANDLED
		.endw
	.endif	
	invoke CloseHandle,pi.hProcess
	invoke CloseHandle,pi.hThread
	invoke ExitProcess, 0
end start
