# c compiler comparison
A size comparison of executables generated by multiple C compilers.

## Code

**hello.c**
```c
#include <stdio.h>

int main()
{
    char hello_str[] = "Hello C\n";
    printf("%s", hello_str);
}
```

## GCC

**Compiler:**
GCC 9.3 - Linux 64-bit build

**Command:**
```sh
gcc -Os hello.c -o gcc-hello
```

**Size:**
16,760 bytes or nearly 17K 

**Command:**
```sh
gcc -Os hello.c -o gcc-hello -s
```

**Size (stripped binary):**
14,472 bytes or nearly 15K

**Explanation:**

* [-Os](https://gcc.gnu.org/onlinedocs/gcc-10.2.0/gcc/Optimize-Options.html#Optimize-Options) optimizes for size.
* [-o](https://gcc.gnu.org/onlinedocs/gcc-10.2.0/gcc/Overall-Options.html#Overall-Options) allows you to specify the output file name like *gcc-hello*.
* [-s](https://gcc.gnu.org/onlinedocs/gcc-10.2.0/gcc/Link-Options.html#Link-Options) strips the binary of debug information.

## Musl libc
You can further reduce binary size by leveraging [musl libc](https://musl.libc.org/). Becuase our program is already so small and dynamically linked, we shouldn't expect to see a large improvement over the starting size of 14,472 bytes (a little over 14K).

Here we are leveraging musl-gcc, part of the *[musl-tools](https://packages.ubuntu.com/focal/musl-tools)* package, to easily consume musl libc.

**Command:**
```sh
musl-gcc -Os hello.c -o musl-hello -s
```

We reduced our binary size to 14,024 bytes by using the slimmer musl C library implementation. Where musl really shines though is with static builds. Static builds can be preferred because they will not rely on specific versions of libraries on a given system. Because of this, they are also more portable.

**Command:**
```sh
gcc -Os hello.c -o gcc-hello -s -static
```

**Size (GCC static build):**
798,480 bytes or roughly 780K

**Command:**
```sh
musl-gcc -Os hello.c -o musl-hello -s -static
```

**Size (Musl-gcc static build):**
26,048 bytes or roughly 26K

The GCC statically linked build is **roughly 30x larger!**

## TCC

**Warning!** Trade-offs will be made to achieve even smaller binaries. In this example, we're going to use [TCC](https://bellard.org/tcc/tcc-doc.html), the Tiny C Compiler. It supports ANSI C (C89), but also most of the C99 standard. That means that anything beyond C99 will likely never be supported in this compiler. It's up to you to decide if that's an issue. From what I can tell, it only supports dynamic builds so that's what we'll be comparing.

**Command:**
```sh
tcc hello.c -o tcc-hello
```

**Size (TCC dynamic build):**
3,132 bytes or roughly 3.1K

The TCC dynamically linked build is **roughly 4x smaller** than our musl dynamic build!

## Sstrip to the rescue!
We can get binaries even smaller with [sstrip](https://github.com/aunali1/super-strip). We may have stripped our binaries with the **-s** flag, but we haven't super-stripped them. Sstrip removes everything it can from an ELF (Executable and Linkable Format) binary while keeping it intact. That means sstrip should work on all systems that have adopted it. Examples can be found [here](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format#Applications).

### GCC
**Size (before sstrip):**
14,472 bytes or roughly 15K

**Command:**
```sh
./sstrip gcc-hello
```

**Size (after sstrip):**
12,304 bytes or roughly 12K

### Musl libc
**Size (before sstrip):**
14,024 bytes or roughly 14K

**Command:**
```sh
./sstrip musl-hello
```

**Size (after sstrip):**
12,296 bytes or roughly 12K

### TCC
**Size (before sstrip):**
3,116 bytes or roughly 3.1K

**Command:**
```sh
./sstrip tcc-hello
```

**Size (after sstrip):**
1,672 bytes or roughly 1.7K

## MSVC with Crinkler

**Windows-only.** We will be performing the potentially daunting task of replacing our linker to see further reduction of binary size. We will be leveraging [Crinkler](https://github.com/runestubbe/Crinkler), a truly impressive executable file compressor famous in the demoscene for compressing 1k/4k/8k intros. Enough with the introduction, let's see how it compares.

**Compiler:**
Visual Studio 2019 16.7 - MSVC 19.27 - amd64 - Windows 64-bit release build

**Size:**
11K

**Size (with UPX compression):**
8K

<br/>

**Compiler:**
Visual Studio 2019 16.7 - MSVC 19.27 - x86 - Windows 32-bit release build

**Size:**
9K

**Size (with UPX compression):**
7K

<br/>

**Compiler:**
Visual Studio 2019 16.7 - MSVC 19.27 - x86 - Windows 32-bit build

**Size (with Crinkler):**
531 bytes

Our build using Crinkler is **roughly 13x smaller** than our build with UPX compression! So far, this takes the cake as far as optimizations go. I've seen other interesting optimizations in the past, but I find that most start using assembly and slowly rip out the most useful parts of C to further reduce size. I tend to believe that kind of defeats the point. Replacing your linker may be considered a bit hacky by some, but I never had to rip out the C standard library to achieve these results.

**Command:**
```sh
cl.exe /c /O1 /GS- hello.c && C:\Users\your_username_here\Downloads\crinkler23\crinkler23\Win64\Crinkler.exe /SUBSYSTEM:CONSOLE /ENTRY:main hello.obj kernel32.lib user32.lib ucrt.lib
```

**Explanation:**

* [/c](https://docs.microsoft.com/en-us/cpp/build/reference/c-compile-without-linking?view=msvc-160) compiles without linking (generates object files rather than executables).
* [/O1](https://docs.microsoft.com/en-us/cpp/build/reference/o1-o2-minimize-size-maximize-speed?view=msvc-160) minimize size.
* [/GS-](https://docs.microsoft.com/en-us/cpp/build/reference/gs-buffer-security-check?view=msvc-160) disables buffer overrun detection.
* [/SUBSYSTEM:CONSOLE](https://docs.microsoft.com/en-us/cpp/build/reference/subsystem-specify-subsystem?view=msvc-160) specifies that the executable is a Win32 console application.
