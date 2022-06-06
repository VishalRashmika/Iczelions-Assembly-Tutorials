This is the example from Iczelion's Win32 Assembly Tutorial part 10 part 2.
In order to assemble the example, you have to have ml.exe, link.exe
,nmake.exe and rc.exe in your path.
If they're not in the path, you will have to edit makefile to include the full
path.
You'll have to edit the makefile to correct the path to import libraries in your PC.
Type nmake in the same directory as makefile and the assembly process will
begin.
If you don't want to use the makefile, you can manually assemble the
example with the commands below:

ml /c /coff /Cp dialog.asm
rc dialog.rc
link /SUBSYSTEM:WINDOWS /LIBPATH:c:\masm\lib dialog.obj dialog.res

You'll have to correct the path to import libraries, though. In my PC,
they're located at c:\masm\lib. Yours may be different.
The resource script, dialog.rc, requires winuser.h. In my PC, it's
located in "c:\masm\include". Yours may be different. You may have to
edit dialog.rc to correct the path to winuser.h

Any problem: contact me at Iczelion@galaxycorp.com
