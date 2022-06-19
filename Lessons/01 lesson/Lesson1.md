# The Basics

This tutorial assumes that the reader knows how to use MASM. If you're not familiar with MASM, download <a href="https://github.com/VishalRashmika/Iczelions-Assembly-Tutorials/blob/main/Lessons/01%20lesson/win32asm.zip" download>Win32asm.zip</a> and study the text inside the package before going on with the tutorial. Good. You're now ready. Let's go!

## Theory:
==========
Win32 programs run in protected mode which is available since 80286. But 80286 is now history. So we only have to concern ourselves with 80386 and its descendants. Windows runs each Win32 program in separated virtual space. That means each Win32 program will have its own 4 GB address space. However, this doesn't mean every win32 program has 4GB of physical memory, only that the program can address any address in that range. Windows will do anything necessary to make the memory the program references valid. Of course, the program must adhere to the rules set by Windows, else it will cause the dreaded General Protection Fault. Each program is alone in its address space. This is in contrast to the situation in Win16. All Win16 programs can *see* each other. Not so under Win32. This feature helps reduce the chance of one program writing over other program's code/data.

Memory model is also drastically different from the old days of the 16-bit world. Under Win32, we need not be concerned with memory model or segments anymore! There's only one memory model: Flat memory model. There's no more 64K segments. The memory is a  large continuous space of 4 GB. That also means you don't have to play with segment registers. You can use any segment register to address any point in the memory space. That's a GREAT help to programmers. This is what makes Win32 assembly programming as easy as C.

When you program under Win32, you must know some important rules. One such rule is that, Windows uses esi, edi, ebp and ebx internally and it doesn't expect the values in those registers to change. So remember this rule first: if you use any of those four registers in your callback function, don't ever forget to restore them before returning control to Windows. A callback function is your own function which is called by Windows. The obvious example is the windows procedure. This doesn't mean that you cannot use those four registers, you can. Just be sure to restore them back before passing control back to Windows.

## Content:
===========
Here's the skeleton program. If you don't understand some of the codes, don't panic. I'll explain each of them later.

```
.386
.MODEL Flat, STDCALL
.DATA
    <Your initialized data>
    ......
.DATA?
   <Your uninitialized data>
   ......
.CONST
   <Your constants>
   ......
.CODE
   <label>
    <Your code>
   .....
    end <label>
```

That's all! Let's analyze this skeleton program.

### .386
--------
This is an assembler directive, telling the assembler to use 80386 instruction set. You can also use .486, .586 but the safest bet is to stick to .386. There are actually two nearly identical forms for each CPU model. .386/.386p, .486/.486p. Those "p" versions are necessary only when your program uses privileged instructions. Privileged instructions are the instructions reserved by the CPU/operating system when in protected mode. They can only be used by privileged code, such as the virtual device drivers. Most of the time, your program will work in non-privileged mode so it's safe to use non-p versions.

### .MODEL FLAT, STDCALL
------------------------
#### .MODEL 
is an assembler directive that specifies memory model of your program. Under Win32, there's only on model, ***FLAT*** model.
#### STDCALL 
tells MASM about parameter passing convention. Parameter passing convention specifies the order of  parameter passing, left-to-right or right-to-left, and also who will balance the stack frame after the function call.

> Under Win16, there are two types of calling convention, ***C*** and ***PASCAL***

##### C
calling convention passes parameters from right to left, that is , the rightmost parameter is pushed first. The caller is responsible for balancing the stack frame after the call. For example, in order to call a function named foo(int first_param, int second_param, int third_param) in C calling convention the asm codes will look like this:

```
push  [third_param]             ; Push the third parameter
push  [second_param]            ; Followed by the second
push  [first_param]             ; And the first
call    foo
add    sp, 12                   ; The caller balances the stack frame
```

##### PASCAL 
calling convention is the reverse of C calling convention. It passes parameters from left to right and the callee is responsible for the stack balancing after the call.
> Win16 adopts ***PASCAL*** convention because it produces smaller codes. C convention is useful when you don't know how many parameters will be passed to the function as in the case of wsprintf(). In the case of wsprintf(), the function has no way to determine beforehand how many parameters will be pushed on the stack, so it cannot do the stack balancing.

##### STDCALL 
is the hybrid of C and PASCAL convention. It passes parameter from right to left but the callee is responsible for stack balancing after the call.Win32 platform use ***STDCALL*** exclusively. Except in one case: wsprintf(). You must use C calling convention with wsprintf().

### .DATA
### .DATA?
### .CONST
### .CODE

All four directives are what's called section. You don't have segments in Win32, remember? But you can divide your entire address space into logical sections. The start of one section denotes the end of the previous section. There'are two groups of section: data and code. Data sections are divided into 3 categories:

- **.DATA** : This section contains initialized data of your program.
- **.DATA?** : This section contains uninitialized data of your program. Sometimes you just want to preallocate some memory but don't want to initialize it. This section is for that purpose. The advantage of uninitialized data is: it doesn't take space in the executable file. For example, if you allocate 10,000 bytes in your .DATA? section, your executable is not bloated up 10,000 bytes. Its size stays much the same. You only tell the assembler how much space you need when the program is loaded into memory, that's all.
- **.CONST** : This section contains declaration of constants used by your program. Constants in this section can never be modified in your program. They are just *constant*.

You don't have to use all three sections in your program. Declare only the section(s) you want to use.

There's only one section for code: ***.CODE***. This is where your codes reside.
***<label>***
***end <label>***
where <label> is any arbitrary label is used to specify the extent of your code. Both labels must be identical.  All your codes must reside between ***<label>*** and ***end <label>***

