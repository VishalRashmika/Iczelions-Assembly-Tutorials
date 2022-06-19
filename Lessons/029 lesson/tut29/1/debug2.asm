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
AppName db "Win32 Debug Example no.2",0
ClassName db "SimpleWinClass",0
SearchFail db "Cannot find the target process",0
TargetPatched db "Target patched!",0
buffer dw 9090h

.data?
DBEvent DEBUG_EVENT <>
ProcessId dd ?
ThreadId dd ?
align dword
context CONTEXT <>

.code
start:
	invoke FindWindow, addr ClassName, NULL
	.if eax!=NULL
		invoke GetWindowThreadProcessId, eax, addr ProcessId
		mov ThreadId, eax
		invoke DebugActiveProcess, ProcessId
		.while TRUE
			invoke WaitForDebugEvent, addr DBEvent, INFINITE
			.break .if DBEvent.dwDebugEventCode==EXIT_PROCESS_DEBUG_EVENT
			.if DBEvent.dwDebugEventCode==CREATE_PROCESS_DEBUG_EVENT
				mov context.ContextFlags, CONTEXT_CONTROL
				invoke GetThreadContext,DBEvent.u.CreateProcessInfo.hThread, addr context
				invoke WriteProcessMemory,  DBEvent.u.CreateProcessInfo.hProcess, context.regEip ,addr buffer, 2, NULL
				invoke MessageBox, 0, addr TargetPatched, addr AppName, MB_OK+MB_ICONINFORMATION
			.elseif DBEvent.dwDebugEventCode==EXCEPTION_DEBUG_EVENT
				.if DBEvent.u.Exception.pExceptionRecord.ExceptionCode==EXCEPTION_BREAKPOINT
					invoke ContinueDebugEvent, DBEvent.dwProcessId,DBEvent.dwThreadId,DBG_CONTINUE	
					.continue
				.endif
			.endif			
			invoke ContinueDebugEvent, DBEvent.dwProcessId,DBEvent.dwThreadId,DBG_EXCEPTION_NOT_HANDLED
		.endw
	.else
		invoke MessageBox, 0, addr SearchFail, addr AppName,MB_OK+MB_ICONERROR
	.endif
	invoke ExitProcess, 0
end start
