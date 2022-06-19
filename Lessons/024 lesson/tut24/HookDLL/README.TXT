This is the example from Iczelion's Win32 Assembly Tutorial part 24.
In order to assemble the example, you have to have ml.exe, link.exe and nmake.exe in your path.
If they're not in the path, you will have to edit makefile to include the full
path.
You'll have to edit the makefile to correct the path to import libraries in your PC.
Type nmake in the same directory as makefile and the assembly process will
begin.
If you don't want to use the makefile, you can manually assemble the
example with the commands below:

ml /c /coff /Cp mousehook.asm
link /section:.bss,S /DLL /DEF:mousehook.def /SUBSYSTEM:WINDOWS /LIBPATH:c:\masm32\lib mousehook.obj

Any problem: contact me at Iczelion@galaxycorp.com
