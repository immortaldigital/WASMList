# WasmList
Basic LinkedList coded from scratch in WebAssembly Text.

I was interested to learn some basic assembly (not having any previous experience programming in ASM before)
What started out as some basic arithmetic functions quickly turned into creating complete data structures and memory managment (didnt have any experience with that before either).
While I have no idea if I followed proper convention with memory managment, I did what I needed to make it work using what knowledge I had.

## Usage
```
fetch('./WASMList.wasm').then(response =>
  response.arrayBuffer()
).then(bytes => WebAssembly.instantiate(bytes)).then(results => {
  instance = results.instance;


	var wasm = instance.exports;

	var list = wasm.listNew(1);
	wasm.listAdd(list, 3);
	wasm.listAdd(list, 5);

	var result = wasm.listSum(list);


}).catch(console.error);

```

## Todo
* Add deallocation
* Add functions nodeDelete, listDelete
* Add following functionality
	* Sorting
	* Removing items
	* Iterating through list

# Nitty Gritty

## Structures
This is how the structures are laid out in memory. This isnt actually defined anywhere in the program, it is implicitly assumed by all functions that use these objects.
```
class Node
  i32 next;
  i32 prev;
  i32 data;

class List
  i32 head;
  i32 tail;
  i32 temp;
```
So really a node object is just 3 integers. The first two contain the addresses of the previous and next nodes and the third contains the data it holds. When you call any of the node functions and give it the address of the first integer, it will expect the other two to follow

## Functions
This is the pseudo code I wrote out when planning this (after a basic introduction to WASM)
```
allocate(i32) := //finds first contiguous addresses of length i32*4(after point 256)  (allocates i32 integers)
	amountToAllocate = i32
	candidateAddress = 0 + ALLOCATE OBJECTLENGTH; (12 bytes)
	go through memory byte by byte
	if byte !=0, jump forward by its value (since its a class definition), set currentStreak to 0
		else
	currentStreak += 1
	if currentStreak = amountToAllocate then return candidateAddress - amountToAllocate


deallocate(i32a i32b) := zeroes out i32b*4 values from address at i32a
delete(i32) := calls deallocate(i32, i32.value)

nodeNew(i32) :=
	+0  = allocate(4)
	+0  = 3 //size of object
	+4  = NULL
	+8  = NULL
	+12 = i32
    returns +0

nodeGetNext(i32) := return i32 + 0
nodeGetPrev(i32) := return i32 + 4
nodeGetData(i32) := return i32 + 8
nodeSetNext(i32a i32b) := i32a + 0 = i32b
nodeSetPrev(i32a i32b) := i32a + 4 = i32b
nodeSetData(i32a i32b) := i32a + 8 = i32b
nodeDelete(i32) := deallocate(i32, 3)

listNew(i32) :=
	+0  = allocate(4)
	+0  = 3 //size of object
	+4  = nodeCreate(i32) //pointer to head
	+8  = +4 //pointer to tail
	+12 = +4
	returns +0

listGetHead(i32) := return i32 + 0
listGetTail(i32) := return i32 + 4
listGetTemp(i32) := return i32 + 8
listSetHead(i32a i32b) := i32a + 0 = i32b
listSetTail(i32a i32b) := i32a + 4 = i32b
listSetTemp(i32a i32b) := i32a + 8 = i32b

listDelete(i32) :=
	ITERATE THROUGH LIST AND CALL nodeDelete
    deallocate(i32, 3)

listAdd(i32a i32b) :=
	listGetTemp(i32a) = nodeCreate(i32b) //temporary pointer to brand new list
    
    nodeSetNext(listGetTail(i32a), listGetTemp(i32a) ) //current tail points to new node
    nodeSetPrev(listGetTemp(i32a), listGetTail(i32a) ) // new object points back to current tail
    listSetTail(i32a, listGetTemp(i32a)) //make tail point to new object

listSum(i32a) :=
	ITERATE THROUGH LIST, sum all DATA values and return that
  ```


## Memory Managment
You only have 2 memory locations that you can use (as far as I can tell), the parameters passed to a function, and the memory object (which is basically just a byte array).
I arbitrarily defined the first 32 bytes as temporary variable space for functions to use. You should only use the memory here for variables that will go out of scope when the functions ends as other functions may overwrite it.

Next I came up with a neat little way of allocating memory. Basically the first integer defines the length of the data structure and the following N 32-bit sections are all reserved.
For example:
```
C =  class definition, M = class memory E = empty
if the following was in the memory 0 0 1 2 4 1 0 0 0 0 0 5 0 0 0 1 2 0 0
then this legend would apply       E E C M C M M M M E E C M M M M M E E
```

The allocation function starts at byte 32 and int by int moves along the memory. Whilever it is finding zeroes it increases a streak counter by 1. If it finds a class definition the it resets the streak counter and jumps to the end of the class.
When the streak counter equals the amount specified to set aside, it returns the start of that contiguous section and also sets the first number to the length (as per class definition)

```
So if you wanted to allocate 3 then 4 then 3 you would get this:
3 0 0 0 4 0 0 0 0 3 0 0 0
Then you delete the 4:
3 0 0 0 0 0 0 0 0 3 0 0 0
Then to allocate 2, it gets to the first 3, jumps to position 4, scans position 5 (2 streak)
3 0 0 0 2 0 0 0 0 3 0 0 0 
You could then allocate a 1 after the 2, but any larger number would have to go after
```

# Conclusion
I had a lot of fun making this project. Assembly is even more different then I expected it to be but that's the enjoyable part, learning new things. Next steps are coding a neural network and maybe making my own programming language/compiler :D

Also check out [WebAssembly Studio](https://webassembly.studio/), it was the best option I found to quickly get started with .wat to .wasm and executing it.
