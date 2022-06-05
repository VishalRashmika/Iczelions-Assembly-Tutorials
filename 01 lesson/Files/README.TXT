Win32Proto is an example program built using MASM.

This Win32 prototype program is an example of what can be done 
programming to the Win32 API using assembly language. Understanding
what it does assumes that you have some good base knowledge and 
understanding of Win32 programming. 
If you do not, you might want to study a good introductory textbook
about Win32 (Petzold's "Programming Windows 95" comes to mind.)

The whole Win32Proto program could have been implemented in a single 
source file, saving many lines of repetitive text (mainly the base 
framework ahead of each .ASM source file).

We instead chose to break the program into several separate modules, 
leaving as little code as possible in the main module, in order to 
demonstrate one possible way a large project could be handled to 
remain manageable.

This small program is by no way ideal, and it can be improved in
many ways.
But just as it is, it can be used as a framework to start developing
a "real" program.

Finally, the WinProtoB.bat file contains the instructions needed
to build the executable.

