@Echo.
@Echo This assumes:
@Echo - The Win32ASM tree has been expanded under the root of the
@Echo   current drive,
@Echo - ml and link are somewhere in the path,
@Echo - The Win32sdk import lib files are on the current drive
@Echo   at \Win32SDK\lib
@Echo
@Echo N.B.: No error code checking in the .BAT file, nothing.
@Echo       This is just a brute force example, and I hope you'll use
@Echo       better tools than batch files in the end!
@Echo.
@Echo.
@Echo About to Assemble / Link the EXE, ...
@Pause
@Echo.
ml  /I\Win32ASM\asminc /coff /Zi /W3 /Fl /Sn /Sc /Cp /c w32pabout.asm
ml  /I\Win32ASM\asminc /coff /Zi /W3 /Fl /Sn /Sc /Cp /c w32pinit.asm
ml  /I\Win32ASM\asminc /coff /Zi /W3 /Fl /Sn /Sc /Cp /c w32pmain.asm
ml  /I\Win32ASM\asminc /coff /Zi /W3 /Fl /Sn /Sc /Cp /c w32pmouse.asm
ml  /I\Win32ASM\asminc /coff /Zi /W3 /Fl /Sn /Sc /Cp /c w32pmprocs.asm
ml  /I\Win32ASM\asminc /coff /Zi /W3 /Fl /Sn /Sc /Cp /c w32pprompt.asm
ml  /I\Win32ASM\asminc /coff /Zi /W3 /Fl /Sn /Sc /Cp /c w32pstatbar.asm
ml  /I\Win32ASM\asminc /coff /Zi /W3 /Fl /Sn /Sc /Cp /c w32ptimer.asm
ml  /I\Win32ASM\asminc /coff /Zi /W3 /Fl /Sn /Sc /Cp /c w32ptoolbar.asm
ml  /I\Win32ASM\asminc /coff /Zi /W3 /Fl /Sn /Sc /Cp /c w32putil.asm
@Echo.

@Echo: Note: If using MASM 6.12, we don't need the link parm /ENTRY:WinStart as long as we defined
@Echo:       an END WinStart directive at the end of the module containing the .EXE entry point.


link /DEBUG /DEBUGTYPE:CV /PDB:none /SUBSYSTEM:WINDOWS /MAP /LIBPATH:g:\win32sdk\lib /WARN:3 @w32proto.lk1 >Win32Proto.log
@Echo.
@Echo. ... now about to execute W32Proto.exe...
@Echo
W32Proto
@Echo.
@Echo ... Done.
@Echo The .EXE might look big, but remember full debugging is ON.
@Echo Remove /DEBUG and /DEBUGTYPE to get slim executables.
@Echo The result will shrink to 3/4K files. This might still be more than
@Echo you expected, but there is some fixed overhead in the .PE file format.
@Pause

