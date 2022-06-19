This is the example from Iczelion's Win32 Assembly Tutorial part 35
In order to assemble the example, you have to have ml.exe, link.exe and nmake.exe in your path.
If they're not in the path, you will have to edit makefile to include the full
path.
You'll have to edit the makefile to correct the path to import libraries in your PC.
Type nmake in the same directory as makefile and the assembly thread will
begin.
If you don't have nmake utility, download it from my site: http://win32asm.cjb.net
If you don't want to use the makefile, you can manually assemble the
example with the commands below:

ml /c /coff /Cp IczEdit.asm
rc IczEdit.rc
link /SUBSYSTEM:WINDOWS /STACK:2000000,2000000 /LIBPATH:c:\masm32\lib IczEdit.obj IczEdit.res

Any problem: contact me at Iczelion@win32asm.cjb.net
