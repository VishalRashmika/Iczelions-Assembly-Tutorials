+++
authors = [""]
title = "5. More about Text"
description = ""
date = 2024-07-09
[taxonomies]
tags = ["masm32"]
[extra]
toc = false
+++

We will experiment more with text attributes, ie. font and color.

Download the example file here.
Theory:
Windows color system is based on RGB values, R=red, G=Green, B=Blue. If you want to specify a color in Windows, you must state your desired color in terms of these three major colors. Each color value has a range from 0 to 255 (a byte value). For example, if you want pure red color, you should use 255,0,0. Or if you want pure white color, you must use 255,255,255. You can see from the examples that getting the color you need is very difficult with this system since you have to have a good grasp of how to mix and match colors.
For text color and background, you use SetTextColor and SetBkColor, both of them require a handle to device context and a 32-bit RGB value. The 32-bit RGB value's structure is defined as:

RGB_value struct
    unused   db 0
    blue       db ?
    green     db ?
    red        db ?
RGB_value ends

Note that the first byte is not used and should be zero. The order of the remaining three bytes is reversed,ie. blue, green, red. However, we will not use this structure since it's cumbersome to initialize and use. We will create a macro instead. The macro will receive three parameters: red, green and blue values. It'll produce the desired 32-bit RGB value and store it in eax. The macro is as follows:

RGB macro red,green,blue
    xor    eax,eax
    mov  ah,blue
    shl     eax,8
    mov  ah,green
    mov  al,red
endm

You can put this macro in the include file for future use.
You can "create" a font by calling CreateFont or CreateFontIndirect. The difference between the two functions is that CreateFontIndirect receives only one parameter: a pointer to a logical font structure, LOGFONT. CreateFontIndirect is the more flexible of the two especially if your programs need to change fonts frequently. However, in our example, we will "create" only one font for demonstration, we can get away with CreateFont. After the call to CreateFont, it will return a handle to a font which you must select into the device context. After that, every text API function will use the font we have selected into the device context.
 
Content:
.386
.model flat,stdcall
option casemap:none

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib

RGB macro red,green,blue
        xor eax,eax
        mov ah,blue
        shl eax,8
        mov ah,green
        mov al,red
endm

.data
ClassName db "SimpleWinClass",0
AppName  db "Our First Window",0
TestString  db "Win32 assembly is great and easy!",0
FontName db "script",0

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?

.code
 start:
    invoke GetModuleHandle, NULL
    mov    hInstance,eax
    invoke GetCommandLine
    mov CommandLine,eax
    invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
    invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG
    LOCAL hwnd:HWND
    mov   wc.cbSize,SIZEOF WNDCLASSEX
    mov   wc.style, CS_HREDRAW or CS_VREDRAW
    mov   wc.lpfnWndProc, OFFSET WndProc
    mov   wc.cbClsExtra,NULL
    mov   wc.cbWndExtra,NULL
    push  hInst
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
    invoke CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\
           hInst,NULL
    mov   hwnd,eax
    invoke ShowWindow, hwnd,SW_SHOWNORMAL
    invoke UpdateWindow, hwnd
    .WHILE TRUE
                invoke GetMessage, ADDR msg,NULL,0,0
                .BREAK .IF (!eax)
                invoke TranslateMessage, ADDR msg
                invoke DispatchMessage, ADDR msg
    .ENDW
    mov     eax,msg.wParam
    ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL hdc:HDC
    LOCAL ps:PAINTSTRUCT
    LOCAL hfont:HFONT

    .IF uMsg==WM_DESTROY
        invoke PostQuitMessage,NULL
    .ELSEIF uMsg==WM_PAINT
        invoke BeginPaint,hWnd, ADDR ps
        mov    hdc,eax
        invoke CreateFont,24,16,0,0,400,0,0,0,OEM_CHARSET,\
                                       OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,\
                                       DEFAULT_QUALITY,DEFAULT_PITCH or FF_SCRIPT,\
                                       ADDR FontName
        invoke SelectObject, hdc, eax
        mov    hfont,eax
        RGB    200,200,50
        invoke SetTextColor,hdc,eax
        RGB    0,0,255
        invoke SetBkColor,hdc,eax
        invoke TextOut,hdc,0,0,ADDR TestString,SIZEOF TestString
        invoke SelectObject,hdc, hfont
        invoke EndPaint,hWnd, ADDR ps
    .ELSE
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam
        ret
    .ENDIF
    xor    eax,eax
    ret
WndProc endp

end start
 
Analysis:
        invoke CreateFont,24,16,0,0,400,0,0,0,OEM_CHARSET,\
                                       OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,\
                                       DEFAULT_QUALITY,DEFAULT_PITCH or FF_SCRIPT,\
                                       ADDR FontName

CreateFont creates a logical font that is the closest match to the given parameters and the font data available. This function has more parameters than any other function in Windows. It returns a handle to logical font to be used by SelectObject function. We will examine its parameters in detail.

CreateFont proto nHeight:DWORD,\
                            nWidth:DWORD,\
                            nEscapement:DWORD,\
                            nOrientation:DWORD,\
                            nWeight:DWORD,\
                            cItalic:DWORD,\
                            cUnderline:DWORD,\
                            cStrikeOut:DWORD,\
                            cCharSet:DWORD,\
                            cOutputPrecision:DWORD,\
                            cClipPrecision:DWORD,\
                            cQuality:DWORD,\
                            cPitchAndFamily:DWORD,\
                            lpFacename:DWORD

nHeight   The desired height of the characters . 0 means use default size.
nWidth   The desired width of the characters. Normally this value should be 0 which allows Windows to match the width to the height. However, in our example, the default width makes the characters hard to read, so I use the width of 16 instead.
nEscapement   Specifies the orientation of the next character output relative to the previous one in tenths of a degree. Normally, set to 0. Set to 900 to have all the characters go upward from the first character, 1800 to write backwards, or 2700 to write each character from the top down.
nOrientation   Specifies how much the character should be rotated when output in tenths of a degree. Set to 900 to have all the characters lying on their backs, 1800 for upside-down writing, etc.
nWeight   Sets the line thickness of each character. Windows defines the following sizes:

    FW_DONTCARE     equ 0
    FW_THIN                  equ 100
    FW_EXTRALIGHT  equ 200
    FW_ULTRALIGHT  equ 200
    FW_LIGHT                equ 300
    FW_NORMAL          equ 400
    FW_REGULAR         equ 400
    FW_MEDIUM           equ 500
    FW_SEMIBOLD       equ 600
    FW_DEMIBOLD      equ 600
    FW_BOLD                 equ 700
    FW_EXTRABOLD   equ 800
    FW_ULTRABOLD   equ 800
    FW_HEAVY              equ 900
    FW_BLACK              equ 900

cItalic   0 for normal, any other value for italic characters.
cUnderline   0 for normal, any other value for underlined characters.
cStrikeOut   0 for normal, any other value for characters with a line through the center.
cCharSet  The character set of the font. Normally should be OEM_CHARSET which allows Windows to select font which is operating system-dependent.
cOutputPrecision  Specifies how much the selected font must be closely matched to the characteristics we want. Normally should be OUT_DEFAULT_PRECIS which defines default font mapping behavior.
cClipPrecision  Specifies the clipping precision. The clipping precision defines how to clip characters that are partially outside the clipping region. You should be able to get by with CLIP_DEFAULT_PRECIS which defines the default clipping behavior.
cQuality  Specifies the output quality. The output quality defines how carefully GDI must attempt to match the logical-font attributes to those of an actual physical font. There are three choices: DEFAULT_QUALITY, PROOF_QUALITY and  DRAFT_QUALITY.
cPitchAndFamily  Specifies pitch and family of the font. You must combine the pitch value and the family value with "or" operator.
lpFacename  A pointer to a null-terminated string that specifies the typeface of the font.

The description above is by no means comprehensive. You should refer to your Win32 API reference for more details.

        invoke SelectObject, hdc, eax
        mov    hfont,eax

After we get the handle to the logical font, we must use it to select the font into the device context by calling SelectObject. SelectObject puts the new GDI objects such as pens, brushs, and fonts into the device context to be used by GDI functions. It returns the handle to the replaced object which we should save for future SelectObject call. After SelectObject call, any text output function will use the font we just selected into the device context.

        RGB    200,200,50
        invoke SetTextColor,hdc,eax
        RGB    0,0,255
        invoke SetBkColor,hdc,eax

Use RGB macro to create a 32-bit RGB value to be used by SetColorText and SetBkColor.

        invoke TextOut,hdc,0,0,ADDR TestString,SIZEOF TestString

Call TextOut function to draw the text on the client area. The text will be in the font and color we specified previously.

        invoke SelectObject,hdc, hfont

When we are through with the font, we should restore the old font back into the device context. You should always restore the object that you replaced in the device context.
[Iczelion's Win32 Assembly HomePage]
