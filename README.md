# x86-assembly
This repository is a showcase of the AT&amp;T x86 Assembly code written as part of TU Delft's course Computer Organisation (CSE 1400).

The assignments are the following:

# 1. Power ([power.s](codes/power.s))

The subroutine should take two inputs a, b and return a raised to the b'th power.

# 2. Factorial ([factorial.s](codes/factorial.s))

Calculate the factorial of the input number using recursion.

# 3. Decoder ([decoder.s](codes/decoder.s))

Decode the memory files [abc_sorted.s](codes/abc_sorted.s), [helloWorld.s](codes/helloWorld.s) and [final.s](codes/final.s).

For each memory block:
Bytes 1-2: background and foreground color respectively, using ANSI Escape Codes;
Bytes 3-6: next memory block to visit;
Byte 7: the amount of times that character should be printed;
Byte 8: the ASCII character to be printed.

# 4. SHA-1 ([sha1 folder](codes/ti1406-sha1))

Implement the sha-1 hashing algorithm for one 512-bit chunk.

# 5. Brainfuck interpreter ([brainfuck folder](codes/brainfuck))

Build a Brainfuck interpreter. After building, run
```
./brainfuck <filename>
```
to execute the interpreter on the file.

Test files: [hello.b](codes/brainfuck/hello.b), [cat.b](codes/brainfuck/cat.b), [hanoi.b](codes/brainfuck/hanoi.b), [mandelbrot.b](codes/brainfuck/mandelbrot.b).
