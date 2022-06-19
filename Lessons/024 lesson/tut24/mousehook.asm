.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include mousehook.inc
includelib mousehook.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib

wsprintfA proto C :DWORD,:DWORD,:VARARG
wsprintf TEXTEQU <wsprintfA>
.const
IDD_MAINDLG                     equ 101
IDC_CLASSNAME                   equ 1000
IDC_HANDLE                      equ 1001
IDC_WNDPROC                     equ 1002
IDC_HOOK                        equ 1004
IDC_EXIT                        equ 1005
WM_MOUSEHOOK equ WM_USER+6

DlgFunc PROTO :DWORD,:DWORD,:DWORD,:DWORD
.data
HookFlag dd FALSE
HookText db "&Hook",0
UnhookText db "&Unhook",0
template db "%lx",0
.data?
hInstance dd ?
hHook dd ?
.code
start:
	invoke GetModuleHandle,NULL
	mov hInstance,eax
	invoke DialogBoxParam,hInstance,IDD_MAINDLG,NULL,addr DlgFunc,NULL
	invoke ExitProcess,NULL

DlgFunc proc hDlg:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	LOCAL hLib:DWORD
	LOCAL buffer[128]:byte
	LOCAL buffer1[128]:byte
	LOCAL rect:RECT
	.if uMsg==WM_CLOSE
		.if HookFlag==TRUE
			invoke UninstallHook
		.endif
		invoke EndDialog,hDlg,NULL
	.elseif uMsg==WM_INITDIALOG
		invoke GetWindowRect,hDlg,addr rect
		invoke SetWindowPos,hDlg,HWND_TOPMOST,rect.left,rect.top,rect.right,rect.bottom,SWP_SHOWWINDOW
	.elseif uMsg==WM_MOUSEHOOK
		invoke GetDlgItemText,hDlg,IDC_HANDLE,addr buffer1,128
		invoke wsprintf,addr buffer,addr template,wParam
		invoke lstrcmpi,addr buffer,addr buffer1
		.if eax!=0
			invoke SetDlgItemText,hDlg,IDC_HANDLE,addr buffer
		.endif
		invoke GetDlgItemText,hDlg,IDC_CLASSNAME,addr buffer1,128
		invoke GetClassName,wParam,addr buffer,128
		invoke lstrcmpi,addr buffer,addr buffer1
		.if eax!=0
			invoke SetDlgItemText,hDlg,IDC_CLASSNAME,addr buffer
		.endif
		invoke GetDlgItemText,hDlg,IDC_WNDPROC,addr buffer1,128
		invoke GetClassLong,wParam,GCL_WNDPROC
		invoke wsprintf,addr buffer,addr template,eax
		invoke lstrcmpi,addr buffer,addr buffer1
		.if eax!=0
			invoke SetDlgItemText,hDlg,IDC_WNDPROC,addr buffer
		.endif
	.elseif uMsg==WM_COMMAND
		.if lParam!=0
			mov eax,wParam
			mov edx,eax
			shr edx,16
			.if dx==BN_CLICKED
				.if ax==IDC_EXIT
					invoke SendMessage,hDlg,WM_CLOSE,0,0
				.else
					.if HookFlag==FALSE
						invoke InstallHook,hDlg
						.if eax!=NULL
							mov HookFlag,TRUE
							invoke SetDlgItemText,hDlg,IDC_HOOK,addr UnhookText
						.endif
					.else
						invoke UninstallHook
						invoke SetDlgItemText,hDlg,IDC_HOOK,addr HookText
						mov HookFlag,FALSE
						invoke SetDlgItemText,hDlg,IDC_CLASSNAME,NULL
						invoke SetDlgItemText,hDlg,IDC_HANDLE,NULL
						invoke SetDlgItemText,hDlg,IDC_WNDPROC,NULL
					.endif
				.endif
			.endif
		.endif
	.else
		mov eax,FALSE
		ret
	.endif
	mov eax,TRUE
	ret
DlgFunc endp

end start
