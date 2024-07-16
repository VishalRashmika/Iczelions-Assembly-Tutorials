+++
authors = [""]
title = "3. A Simple Window"
description = ""
date = 2024-07-09
[taxonomies]
tags = ["masm32"]
[extra]
toc = false
+++

In this tutorial, we will build a Windows program that displays a fully functional window on the desktop.
Download the example file here
Theory:
Windows programs rely heavily on API functions for their GUI. This approach benefits both users and programmers. For users, they don't have to learn how to navigate the GUI of each new programs, the GUI of Windows programs are alike. For programmers, the GUI codes are already there,tested, and ready for use. The downside for programmers is the increased complexity involved. In order to create or manipulate any GUI objects such as windows, menu or icons, programmers must follow a strict recipe. But that can be overcome by modular programming or OOP paradigm.
I'll outline the steps required to create a window on the desktop below:

    Get the instance handle of your program (required)
    Get the command line (not required unless your program wants to process a command line)
    Register window class (required ,unless you use predefined window types, eg. MessageBox or a dialog box)
    Create the window (required)
    Show the window on the desktop (required unless you don't want to show the window immediately)
    Refresh the client area of the window
    Enter an infinite loop, checking for messages from Windows
    If messages arrive, they are processed by a specialized function that is responsible for the window
    Quit program if the user closes the window

As you can see, the structure of a Windows program is rather complex compared to a DOS program. But the world of Windows is drastically different from the world of DOS. Windows programs must be able to coexist peacefully with each other. They must follow stricter rules. You, as a programmer, must also be more strict with your programming style and habit.
Content:
Below is the source code of our simple window program. Before jumping into the gory details of Win32 ASM programming, I'll point out some fine points which will ease your programming.

    You should put all Windows constants, structures and function prototypes in an include file and include it at the beginning of your .asm file. It'll save you a lot of effort and typo. Currently, the most complete include file for MASM is hutch's windows.inc which you can download from his page or my page. You can also define your own constants & structure definitions but you should put them into a separate include file.
    Use includelib directive to specify the import library used in your program. For example, if your program calls MessageBox, you should put the line:
        includelib user32.lib at the beginning of your .asm file. This directive tells MASM that your program will make uses of functions in that import library. If your program calls functions in more than one library, just add an includelib for each library you use. Using IncludeLib directive, you don't have to worry about import libraries at link time. You can use /LIBPATH linker switch to tell Link where all the libs are.
    When declaring API function prototypes, structures, or constants in your include file, try to stick to the original names used in Windows include files, including case. This will save you a lot of headache when looking up some item in Win32 API reference.
    Use makefile to automate your assembling process. This will save you a lot of typing.

.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib            ; calls to functions in user32.lib and kernel32.lib
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

.DATA                     ; initialized data
ClassName db "SimpleWinClass",0        ; the name of our window class
AppName db "Our First Window",0        ; the name of our window

.DATA?                ; Uninitialized data
hInstance HINSTANCE ?        ; Instance handle of our program
CommandLine LPSTR ?
.CODE                ; Here begins our code
start:
invoke GetModuleHandle, NULL            ; get the instance handle of our program.
                                                                       ; Under Win32, hmodule==hinstance mov hInstance,eax
mov hInstance,eax
invoke GetCommandLine                        ; get the command line. You don't have to call this function IF
                                                                       ; your program doesn't process the command line.
mov CommandLine,eax
invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT        ; call the main function
invoke ExitProcess, eax                           ; quit our program. The exit code is returned in eax from WinMain.

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
    LOCAL wc:WNDCLASSEX                                            ; create local variables on stack
    LOCAL msg:MSG
    LOCAL hwnd:HWND

    mov   wc.cbSize,SIZEOF WNDCLASSEX                   ; fill values in members of wc
    mov   wc.style, CS_HREDRAW or CS_VREDRAW
    mov   wc.lpfnWndProc, OFFSET WndProc
    mov   wc.cbClsExtra,NULL
    mov   wc.cbWndExtra,NULL
    push  hInstance
    pop   wc.hInstance
    mov   wc.hbrBackground,COLOR_WINDOW+1
    mov   wc.lpszMenuName,NULL
    mov   wc.lpszClassName,OFFSET ClassName
    invoke LoadIcon,NULL,IDI_APPLICATION
    mov   wc.hIcon,eax
    mov   wc.hIconSm,eax
    invoke LoadCursor,NULL,IDC_ARROW
    mov   wc.hCursor,eax
    invoke RegisterClassEx, addr wc                       ; register our window class
    invoke CreateWindowEx,NULL,\
                ADDR ClassName,\
                ADDR AppName,\
                WS_OVERLAPPEDWINDOW,\
                CW_USEDEFAULT,\
                CW_USEDEFAULT,\
                CW_USEDEFAULT,\
                CW_USEDEFAULT,\
                NULL,\
                NULL,\
                hInst,\
                NULL
    mov   hwnd,eax
    invoke ShowWindow, hwnd,CmdShow               ; display our window on desktop
    invoke UpdateWindow, hwnd                                 ; refresh the client area

    .WHILE TRUE                                                         ; Enter message loop
                invoke GetMessage, ADDR msg,NULL,0,0
                .BREAK .IF (!eax)
                invoke TranslateMessage, ADDR msg
                invoke DispatchMessage, ADDR msg
   .ENDW
    mov     eax,msg.wParam                                            ; return exit code in eax
    ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    .IF uMsg==WM_DESTROY                           ; if the user closes our window
        invoke PostQuitMessage,NULL             ; quit our application
    .ELSE
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam     ; Default message processing
        ret
    .ENDIF
    xor eax,eax
    ret
WndProc endp

end start
Analysis:
You may be taken aback that a simple Windows program requires so much coding. But most of those codes are just *template* codes that you can copy from one source code file to another. Or if you prefer, you could assemble some of these codes into a library to be used as prologue and epilogue codes. You can write only the codes in WinMain function. In fact, this is what  C compilers do. They let you write WinMain codes without worrying about other housekeeping chores. The only catch is that you must have a function named WinMain else C compilers will not be able to combine your codes with the prologue and epilogue. You do not have such restriction with assembly language. You can use any function name instead of WinMain or no function at all.
Prepare yourself. This's going to be a long, long tutorial. Let's analyze this program to death!

    .386
    .model flat,stdcall
    option casemap:none

    WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

    include \masm32\include\windows.inc
    include \masm32\include\user32.inc
    include \masm32\include\kernel32.inc
    includelib \masm32\lib\user32.lib
    includelib \masm32\lib\kernel32.lib

The first three lines are "necessities". .386 tells MASM we intend to use 80386 instruction set in this program. .model flat,stdcall tells MASM that our program uses flat memory addressing model. Also we will use stdcall parameter passing convention as the default one in our program.
Next is the function prototype for WinMain. Since we will call WinMain later, we must define its function prototype first so that we will be able to invoke it.
We must include windows.inc at the beginning of the source code. It contains important structures and constants that are used by our program. The include file , windows.inc, is just a text file. You can open it with any text editor. Please note that windows.inc does not contain all structures, and constants (yet). hutch and I are working on it. You can add in new items if they are not in the file.
Our program calls API functions that reside in user32.dll (CreateWindowEx, RegisterWindowClassEx, for example) and kernel32.dll (ExitProcess), so we must link our program to those two import libraries. The next question : how can I know which import library should be linked to my program? The answer: You must know where the API functions called by your program reside. For example, if you call an API function in gdi32.dll, you must link with gdi32.lib.
This is the approach of MASM. TASM 's way of import library linking is much more simpler: just link to one and only one file: import32.lib.

    .DATA
        ClassName db "SimpleWinClass",0
        AppName  db "Our First Window",0

    .DATA?
    hInstance HINSTANCE ?
    CommandLine LPSTR ?

Next are the "DATA" sections.
In .DATA, we declare two zero-terminated strings(ASCIIZ strings): ClassName which is the name of our window class and AppName which is the name of our window. Note that the two variables are initialized.
In .DATA?, two variables are declared: hInstance (instance handle of our program) and CommandLine (command line of our program). The unfamiliar data types, HINSTANCE and LPSTR, are really new names for DWORD. You can look them up in windows.inc. Note that all variables in .DATA? section are not initialized, that is, they don't have to hold any specific value on startup, but we want to reserve the space for future use.

    .CODE
     start:
         invoke GetModuleHandle, NULL
         mov    hInstance,eax
         invoke GetCommandLine
         mov    CommandLine,eax
         invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
         invoke ExitProcess,eax
         .....
    end start

.CODE contains all your instructions. Your codes must reside between <starting label>: and end <starting label>. The name of the label is unimportant. You can name it anything you like so long as it is unique and doesn't violate the naming convention of MASM.
Our first instruction is the call to GetModuleHandle to retrieve the instance handle of our program. Under Win32, instance handle and module handle are one and the same. You can think of instance handle as the ID of your program. It is used as parameter to several API functions our program must call, so it's generally a good idea to retrieve it at the beginning of our program.
Note: Actually under win32, instance handle is the linear address of your program in memory.
Upon returning from a Win32 function, the function's return value, if any, can be found in eax. All other values are returned through variables passed in the function parameter list you defined for the call.
A Win32 function that you call will nearly always preserve the segment registers and the ebx, edi, esi and ebp registers. Conversely, ecx and edx are considered scratch registers and are always undefined upon return from a Win32 function.
Note: Don't expect the values of eax, ecx, edx to be preserved across API function calls.
The bottom line is that: when calling an API function, expects return value in eax. If any of your function will be called by Windows, you must also play by the rule: preserve and restore the values of the segment registers, ebx, edi, esi and ebp upon function return else your program will crash very shortly, this includes your window procedure and windows callback functions.
The GetCommandLine call is unnecessary if your program doesn't process a command line. In this example, I show you how to call it in case you need it in your program.
Next is the WinMain call. Here it receives four parameters: the instance handle of our program, the instance handle of the previous instance of our program, the command line and window state at first appearance. Under Win32, there's NO previous instance. Each program is alone in its address space, so the value of hPrevInst is always 0. This is a leftover from the day of Win16 when all instances of a program run in the same address space and an instance wants to know if it's the first instance. Under win16, if hPrevInst is NULL, then this instance is the first one.
Note: You don't have to declare the function name as WinMain. In fact, you have complete freedom in this regard. You don't have to use any WinMain-equivalent function at all. You can paste the codes inside WinMain function next to GetCommandLine and your program will still be able to function perfectly.
Upon returning from WinMain, eax is filled with exit code. We pass that exit code as the parameter to ExitProcess which terminates our application.

WinMain proc Inst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD

The above line is the function declaration of WinMain. Note the parameter:type pairs that follow PROC directive. They are parameters that WinMain receives from the caller. You can refer to these parameters by name instead of by stack manipulation. In addition, MASM will generate the prologue and epilogue codes for the function. So we don't have to concern ourselves with stack frame on function enter and exit.

    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG
    LOCAL hwnd:HWND

LOCAL directive allocates memory from the stack for local variables used in the function. The bunch of LOCAL directives must be immediately below the PROC directive. The LOCAL directive is immediately followed by <the name of local variable>:<variable type>. So LOCAL wc:WNDCLASSEX tells MASM to allocate memory from the stack the size of WNDCLASSEX structure for the variable named wc. We can refer to wc in our codes without any difficulty involved in stack manipulation. That's really a godsend, I think. The downside  is that local variables cannot be used outside the function they're created and will be automatically destroyed when the function returns to the caller. Another drawback is that you cannot initialize local variables automatically because they're just stack memory allocated dynamically when the function is entered . You have to manually assign them with desired values after LOCAL directives.

    mov   wc.cbSize,SIZEOF WNDCLASSEX
    mov   wc.style, CS_HREDRAW or CS_VREDRAW
    mov   wc.lpfnWndProc, OFFSET WndProc
    mov   wc.cbClsExtra,NULL
    mov   wc.cbWndExtra,NULL
    push  hInstance
    pop   wc.hInstance
    mov   wc.hbrBackground,COLOR_WINDOW+1
    mov   wc.lpszMenuName,NULL
    mov   wc.lpszClassName,OFFSET ClassName
    invoke LoadIcon,NULL,IDI_APPLICATION
    mov   wc.hIcon,eax
    mov   wc.hIconSm,eax
    invoke LoadCursor,NULL,IDC_ARROW
    mov   wc.hCursor,eax
    invoke RegisterClassEx, addr wc

The inimidating lines above are really simple in concept. It just takes several lines of instruction to accomplish. The concept behind all these lines is  window class. A window class is nothing more than a blueprint or specification of a window. It defines several important characteristics of a window such as its icon, its cursor, the function responsible for it, its color etc. You create a window from a window class. This is some sort of object oriented concept. If you want to create more than one window with the same characteristics, it stands to reason to store all these characteristics in only one place and refer to them when needed. This scheme will save lots of memory by avoiding duplication of information. Remember, Windows is designed in the past when memory chips are prohibitive and most computers have 1 MB of memory. Windows must be very efficient in using the scarce memory resource. The point is: if you define your own window, you must fill the desired characteristics of your window in a WNDCLASS or WNDCLASSEX structure and call RegisterClass or RegisterClassEx before you're able to create your window. You only have to register the window class once for each window type you want to create a window from.
Windows has several predefined Window classes, such as button and edit box. For these windows (or controls), you don't have to register a window class, just call CreateWindowEx with the predefined class name.
The single most important member in the WNDCLASSEX is lpfnWndProc. lpfn stands for long pointer to function. Under Win32, there's no "near" or "far" pointer, just pointer because of the new FLAT memory model. But this is again a leftover from the day of Win16. Each window class must be associated with a function called window procedure. The window procedure is responsible for message handling of all windows created from the associated window class. Windows will send messages to the window procedure to notify it of important events concerning the windows it 's responsible for,such as user keyboard or mouse input. It's up to the window procedure to respond intelligently to each window message it receives. You will spend most of your time writing event handlers in window procedure.
I describe each member of WNDCLASSEX below:

WNDCLASSEX STRUCT DWORD
  cbSize            DWORD      ?
  style             DWORD      ?
  lpfnWndProc       DWORD      ?
  cbClsExtra        DWORD      ?
  cbWndExtra        DWORD      ?
  hInstance         DWORD      ?
  hIcon             DWORD      ?
  hCursor           DWORD      ?
  hbrBackground     DWORD      ?
  lpszMenuName      DWORD      ?
  lpszClassName     DWORD      ?
  hIconSm           DWORD      ?
WNDCLASSEX ENDS

cbSize: The size of WNDCLASSEX structure in bytes. We can use SIZEOF operator to get the value.
style: The style of windows created from this class. You can combine several styles together using "or" operator.
lpfnWndProc: The address of the window procedure responsible for windows created from this class.
cbClsExtra: Specifies the number of extra bytes to allocate following the window-class structure. The operating system initializes the bytes to zero. You can store window class-specific data here.
cbWndExtra: Specifies the number of extra bytes to allocate following the window instance. The operating system initializes the bytes to zero. If an application uses the WNDCLASS structure to register a dialog box created by using the CLASS directive in the resource file, it must set this member to DLGWINDOWEXTRA.
hInstance: Instance handle of the module.
hIcon: Handle to the icon. Get it from LoadIcon call.
hCursor: Handle to the cursor. Get it from LoadCursor call.
hbrBackground: Background color of windows created from the class.
lpszMenuName: Default menu handle for windows created from the class.
lpszClassName: The name of this window class.
hIconSm: Handle to a small icon that is associated with the window class. If this member is NULL, the system searches the icon resource specified by the hIcon member for an icon of the appropriate size to use as the small icon.

    invoke CreateWindowEx, NULL,\
                                                ADDR ClassName,\
                                                ADDR AppName,\
                                                WS_OVERLAPPEDWINDOW,\
                                                CW_USEDEFAULT,\
                                                CW_USEDEFAULT,\
                                                CW_USEDEFAULT,\
                                                CW_USEDEFAULT,\
                                                NULL,\
                                                NULL,\
                                                hInst,\
                                                NULL

After registering the window class, we can call CreateWindowEx to create our window based on the submitted window class. Notice that there are 12 parameters to this function.

CreateWindowExA proto dwExStyle:DWORD,\
   lpClassName:DWORD,\
   lpWindowName:DWORD,\
   dwStyle:DWORD,\
   X:DWORD,\
   Y:DWORD,\
   nWidth:DWORD,\
   nHeight:DWORD,\
   hWndParent:DWORD ,\
   hMenu:DWORD,\
   hInstance:DWORD,\
   lpParam:DWORD

Let's see detailed description of each parameter:
dwExStyle: Extra window styles. This is the new parameter that is added to the old CreateWindow. You can put new window styles for Windows 95 & NT here.You can specify your ordinary window style in dwStyle but if you want some special styles such as topmost window, you must specify them here. You can use NULL if you don't want extra window styles.
lpClassName: (Required). Address of the ASCIIZ string containing the name of window class you want to use as template for this window. The Class can be your own registered class or predefined window class. As stated above, every window you created must be based on a window class.
lpWindowName: Address of the ASCIIZ string containing the name of the window. It'll be shown on the title bar of the window. If this parameter is NULL, the title bar of the window will be blank.
dwStyle:  Styles of the window. You can specify the appearance of the window here. Passing NULL  is ok but the window will have no system menu box, no minimize-maximize buttons, and no close-window button. The window would not be of much use at all. You will need to press Alt+F4 to close it. The most common window style is WS_OVERLAPPEDWINDOW. A window style is only a bit flag. Thus you can combine several window styles by "or" operator to achieve the desired appearance of the window. WS_OVERLAPPEDWINDOW style is actually a combination of the most common window styles by this method.
X,Y: The coordinate of the upper left corner of the window. Normally this values should be CW_USEDEFAULT, that is, you want Windows to decide for you where to put the window on the desktop.
nWidth, nHeight: The width and height of the window in pixels. You can also use CW_USEDEFAULT to let Windows choose the appropriate width and height for you.
hWndParent: A handle to the window's parent window (if exists). This parameter tells Windows whether this window is a child (subordinate) of some other window and, if it is, which window is the parent. Note that this is not the parent-child relationship of multiple document interface (MDI). Child windows are not bound to the client area of the parent window. This relationship is specifically for Windows internal use. If the parent window is destroyed, all child windows will be destroyed automatically. It's really that simple. Since in our example, there's only one window, we specify this parameter as NULL.
hMenu: A handle to the window's menu. NULL if the class menu is to be used. Look back at the a member of WNDCLASSEX structure, lpszMenuName. lpszMenuName specifies *default* menu for the window class. Every window created from this window class will have the same menu by default. Unless you specify an *overriding* menu for a specific window via its hMenu parameter. hMenu is actually a dual-purpose parameter. In case the window you want to create is of a predefined window type (ie. control), such control cannot own a menu. hMenu is used as that control's ID instead. Windows can decide whether hMenu is really a menu handle or a control ID by looking at lpClassName parameter. If it's the name of a predefined window class, hMenu is a control ID. If it's not, then it's a handle to the window's menu.
hInstance: The instance handle for the program module creating the window.
lpParam: Optional pointer to a data structure passed to the window. This is used by MDI window to pass the CLIENTCREATESTRUCT data. Normally, this value is set to NULL, meaning that no data is passed via CreateWindow(). The window can retrieve the value of this parameter by the call to GetWindowLong function.

    mov   hwnd,eax
    invoke ShowWindow, hwnd,CmdShow
    invoke UpdateWindow, hwnd

On successful return from CreateWindowEx, the window handle is returned in eax. We must keep this value for future use. The window we just created is not automatically displayed. You must call ShowWindow with the window handle and the desired *display state* of the window to make it display on the screen. Next you can call UpdateWindow to order your window to repaint its client area. This function is useful when you want to update the content of the client area. You can omit this call though.

    .WHILE TRUE
                invoke GetMessage, ADDR msg,NULL,0,0
                .BREAK .IF (!eax)
                invoke TranslateMessage, ADDR msg
                invoke DispatchMessage, ADDR msg
   .ENDW

At this time, our window is up on the screen. But it cannot receive input from the world. So we have to *inform* it of relevant events. We accomplish this with a message loop. There's only one message loop for each module. This message loop continually checks for messages from Windows with GetMessage call. GetMessage passes a pointer to a MSG structure to Windows. This MSG structure will be filled with information about the message that Windows want to send to a window in the module. GetMessage function will not return until there's a message for a window in the module. During that time, Windows can give control to other programs. This is what forms the cooperative multitasking scheme of Win16 platform. GetMessage returns FALSE if WM_QUIT message is received which, in the message loop, will terminate the loop and exit the program.
TranslateMessage is a utility function that takes raw keyboard input and generates a new message (WM_CHAR) that is placed on the message queue. The message with WM_CHAR contains the ASCII value for the key pressed, which is easier to deal with than the raw keyboard scan codes. You can omit this call if your program doesn't process keystrokes.
DispatchMessage sends the message data to the window procedure responsible for the specific window the message is for.

    mov     eax,msg.wParam
    ret
WinMain endp

If the message loop terminates, the exit code is stored in wParam member of the MSG structure. You can store this exit code into eax to return it to Windows. At the present time, Windows does not make use of the return value, but it's better to be on the safe side and plays by the rule.

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

This is our window procedure. You don't have to name it WndProc. The first parameter, hWnd, is the window handle of the window that the message is destined for. uMsg is the message. Note that uMsg is not a MSG structure. It's just a number, really. Windows defines hundreds of messages, most of which your programs will not be interested in. Windows will send an appropriate message to a window in case something relevant to that window happens. The window procedure receives the message and reacts to it intelligently. wParam and lParam are just extra parameters for use by some messages. Some messages do send accompanying data in addition to the message itself. Those data are passed to the window procedure by means of lParam and wParam.

    .IF uMsg==WM_DESTROY
        invoke PostQuitMessage,NULL
    .ELSE
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam
        ret
    .ENDIF
    xor eax,eax
    ret
WndProc endp

Here comes the crucial part. This is where most of your program's intelligence resides. The codes that respond to each Windows message are in the window procedure. Your code must check the Windows message to see if it's a message it's interested in. If it is, do anything you want to do in response to that message and then return with zero in eax. If it's not, you MUST call  DefWindowProc, passing all parameters you received to it for default processing.. This DefWindowProc is an API function that processes the messages your program are not interested in.
The only message that you MUST respond to is WM_DESTROY. This message is sent to your window procedure whenever your window is closed. By the time your window procedure receives this message, your window is already removed from the screen. This is just a notification that your window was destroyed, you should prepare yourself to return to Windows. In response to this, you can perform housekeeping prior to returning to Windows. You have no choice but to quit when it comes to this state. If you want to have a chance to stop the user from closing your window, you should process WM_CLOSE message. Now back to WM_DESTROY, after performing housekeeping chores, you must call PostQuitMessage which will post WM_QUIT back to your module. WM_QUIT will make GetMessage return with zero value in eax, which in turn, terminates the message loop and quits to Windows. You can send WM_DESTROY message to your own window procedure by calling DestroyWindow function.

[Iczelion's Win32 Assembly HomePage]
