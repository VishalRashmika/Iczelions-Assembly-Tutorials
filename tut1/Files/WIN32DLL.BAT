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
@Echo About to Assemble / Link the DLL first, ...
@Pause
@Echo.
ml /I\Win32ASM\ASMInc /coff /Zi /W3 /Fl /Sn /Sc /Cp /c win32dll.asm
@Echo.

@Echo: Note: If using MASM 6.12, we don't need the link parm /ENTRY:DLLEntryPoint as long as we defined
@Echo:       an END DLLEntryPoint directive at the end of the module containing the DLL entry point.

link /DLL /SUBSYSTEM:CONSOLE /DEBUG /DEBUGTYPE:CV /PDB:none /MAP /LIBPATH:\win32sdk\lib /DEF:win32dll.def /WARN:3 /OUT:win32dll.dll win32dll.obj
@Echo.
@Echo.
@Echo ... now about to assemble / link the DDL test program.
@Pause
@Echo.
ml  /I\win32ASM\ASMInc /coff /Zi /W3 /Fl /Sn /Sc /Cp /c win32dlltest.asm
@Echo.

@Echo: Note: If using MASM 6.12, we don't need the link parm /ENTRY:Start as long as we defined
@Echo:       an END Start directive at the end of the module containing the .EXE entry point.

link /SUBSYSTEM:CONSOLE /DEBUG /DEBUGTYPE:CV /PDB:none /MAP /LIBPATH:\win32sdk\lib /WARN:3 /OUT:win32dlltest.exe win32dlltest.obj
@Echo.
@Echo.
@Echo Hold on to your seat: About to launch the test program...
@Pause
@Echo.
@Echo.
Win32DLLTest
@Echo.
@Echo ... Done.
@Echo The .EXE and DLL might look big, but remember full debugging is ON.
@Echo Remove /DEBUG and /DEBUGTYPE to get slim executables.
@Echo The result will shrink to 3/4K files. This might still be more than
@Echo you expected, but there is a fixed overhead in the .PE file format.
@Pause
