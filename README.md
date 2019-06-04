# WASMList
Basic LinkedList coded from scratch in WebAssembly Text (WAT).

I was interested to learn some basic assembly (not having any previous experience programming in ASM before)
What started out as some basic arithmetic functions quickly turned into creating complete data structures and memory managment (didnt have any experience with that before either).
While I have no idea if I followed proper convention with memory managment, I did what I needed to make it work using what knowledge I had.

You only have 2 memory locations that you can use (as far as I can tell), the parameters passed to a function, and the memory object (which is basically just a byte array).
I arbitrarily defined the first 32 bytes as temporary variable space for functions to use. You should only use the memory here for variables that will go out of scope when the functions ends as other functions may overwrite it.

Next I came up with a neat little way of allocating memory. Basically the first integer defines the length of the data structure and the following N 32-bit sections are all reserved.
For example:
'''
C =  class definition, M = class memory E = empty
if the following was in the memory 0 0 1 2 4 1 0 0 0 0 0 5 0 0 0 1 2 0 0
then this legend would apply       E E C M C M M M M E E C M M M M M E E
'''

The allocation function starts at byte 32 and int by int moves along the memory. Whilever it is finding zeroes it increases a streak counter by 1. If it finds a class definition the it resets the streak counter and jumps to the end of the class.
When the streak counter equals the amount specified to set aside, it returns the start of that contiguous section and also sets the first number to the length (as per class definition)


So if you wanted to allocate 3 then 4 then 3 you would get this:
3 0 0 0 4 0 0 0 0 3 0 0 0
Then you delete the 4:
3 0 0 0 0 0 0 0 0 3 0 0 0
Then to allocate 2, it gets to the first 3, jumps to position 4, scans position 5 (2 streak) and returns 6 - 2
3 0 0 0 2 0 0 0 0 3 0 0 0 
You could then allocate a 1 after the 2, but any larger number would have to go after
