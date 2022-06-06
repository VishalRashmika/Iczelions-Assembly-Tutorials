This is the example from Iczelion's Win32 Assembly Tutorial part 2.
In order to assemble the example, you have to have ml.exe, link.exe and nmake.exe in your path.
If they're not in the path, you will have to edit makefile to include the full
path.
You'll have to edit the makefile to correct the path to the import libraries in your system.
Type nmake in the same directory as makefile and the assembly process will
begin.
If you don't want to use the makefile, you can manually assemble the
example with the commands below:

ml /c /coff /Cp msgbox.asm
link /SUBSYSTEM:WINDOWS /LIBPATH:c:\masm32\lib msgbox.obj

You'll have to correct the path to import libraries, though. In my PC,
they're located at c:\masm32\lib. Yours may be different.

Any problem: contact me at Iczelion@win32asm.cjb.net
