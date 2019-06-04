(module
    (memory 1)

    ;;first 32 memory addresses are free for all to use whenever

    (func $allocate (param $amount i32) (result i32)
        i32.const 0
        get_local $amount ;;amountToAllocate
        i32.const 1
        i32.add ;;store amountToAllocate + 1 (to make sure there's enough for the class definition)
        i32.store

        i32.const 4
        i32.const 32 ;;candidateAddress starts at 32
        i32.store

        i32.const 8
        i32.const 0 ;;currentStreak of zeros is 0 of course
        i32.store

        ;;loop forwards, checking if candidateAddress = 0
        ;;stack size = 0

        (block
            (loop
                i32.const 4 ;;pointer to candidateAddress
                i32.load ;;actual addr
                i32.load ;;load whatever data is found at candidateAddress
                i32.const 0
                i32.eq ;;compare to 0

                (if
                    (then ;;current space is empty
                        ;;currentStreak += 1;
                        i32.const 8
                        i32.const 1
                        i32.const 8
                        i32.load
                        i32.add
                        i32.store

                        ;;candidateAddress += 4;
                        i32.const 4 ;;addr
                        i32.const 4 ;;jump amount
                        i32.const 4 ;;addr
                        i32.load
                        i32.add
                        i32.store
                    )
                    (else ;;start of an object, set currentStreak to 0 and jump candidateAddress forwards
                        ;;currentStreak = 0;
                        i32.const 8
                        i32.const 0
                        i32.store

                        i32.const 4
                        i32.const 4
                        i32.load
                        i32.const 4
                        i32.load
                        i32.load ;;load whatever data is found at candidateAddress
                        i32.const 4
                        i32.mul
                        i32.add ;;add it to the current candidateAddress
                        i32.const 4
                        i32.add ;;jump forward 1 extra place (cause streak reasons)
                        i32.store ;;set the new candidateAddress pointer
                    )
                )

                i32.const 8 ;;currentStreak
                i32.load
                i32.const 0 ;;amountToAllocate
                i32.load
                i32.eq ;;compare to 0

                br_if 1 ;;we have enough space then allocate it!

                br 0 ;;continue looping
            )
        )

        i32.const 4 ;;candidateAddress
        i32.const 4 ;;candidateAddress
        i32.load
        i32.const 8
        i32.load
        i32.const 4
        i32.mul
        i32.sub ;;remove streak offset*4
        i32.store ;;store final addr

        i32.const 4
        i32.load ;;load final address
        i32.const 0
        i32.load ;;load data length (in bytes)
        i32.const 1
        i32.sub ;;subtract 1 (we dont want to include the front byte)
        i32.store ;;store class definition in first byte

        i32.const 4
        i32.load ;;return candidateAddress
    )


    (func $nodeNew (param $data i32) (result i32)
        i32.const 12
        i32.const 3 ;;size of this object in integers
        call $allocate
        i32.store

        ;;offset + 0 will be the size of this object, next 3 variables are the private properties

        i32.const 12 ;;load this.
        i32.load
        i32.const 0 ;;init value to null
        call $nodeSetNext

        i32.const 12 ;;load this.
        i32.load
        i32.const 0 ;;init value to null
        call $nodeSetPrev

        i32.const 12 ;;load this.
        i32.load
        get_local $data ;;init value to our data
        call $nodeSetData

        i32.const 12 ;;load this.
        i32.load
    )

    (func $nodeGetNext (param $node i32) (result i32)
        get_local $node
        i32.const 4 ;;move to 1st variable NEXT
        i32.add
        i32.load
    )
    (func $nodeGetPrev (param $node i32) (result i32)
        get_local $node
        i32.const 8 ;;move to 1st variable NEXT
        i32.add
        i32.load
    )
    (func $nodeGetData (param $node i32) (result i32)
        get_local $node
        i32.const 12 ;;move to 1st variable NEXT
        i32.add
        i32.load
    )

    (func $nodeSetNext (param $node i32) (param $next i32)
        get_local $node
        i32.const 4 ;;move to 1st variable NEXT
        i32.add
        get_local $next
        i32.store
    )
    (func $nodeSetPrev (param $node i32) (param $prev i32)
        get_local $node
        i32.const 8 ;;move to 1st variable NEXT
        i32.add
        get_local $prev
        i32.store
    )
    (func $nodeSetData (param $node i32) (param $data i32)
        get_local $node
        i32.const 12 ;;move to 1st variable NEXT
        i32.add
        get_local $data
        i32.store
    )


    (func $listNew (param $data i32) (result i32)
        i32.const 16
        i32.const 3 ;;size of this object in integers
        call $allocate
        i32.store


        i32.const 16 ;;load this.
        i32.load
        i32.const 4 ;;move to 1st variable HEAD
        i32.add
        
        get_local $data
        call $nodeNew ;;create head node with DATA
        i32.store ;;pointer to head


        i32.const 16 ;;load this.
        i32.load
        i32.const 8 ;;move to 2nd variable TAIL
        i32.add
        i32.const 16 ;;load this.
        i32.load
        i32.const 4 ;;move to 1st variable HEAD
        i32.add
        i32.load
        i32.store ;;pointer to tail is pointer to head


        i32.const 16 ;;load this.
        i32.load
        i32.const 12 ;;move to 2nd variable TAIL
        i32.add
        i32.const 16 ;;load this.
        i32.load
        i32.const 4 ;;move to 1st variable HEAD
        i32.add
        i32.load
        i32.store ;;pointer to tail is pointer to head

        i32.const 16 ;;load this.
        i32.load
    )

    (func $listGetHead (param $list i32) (result i32)
        get_local $list
        i32.const 4
        i32.add
        i32.load
    )
    (func $listGetTail (param $list i32) (result i32)
        get_local $list
        i32.const 8
        i32.add
        i32.load
    )
    (func $listGetTemp (param $list i32) (result i32)
        get_local $list
        i32.const 12
        i32.add
        i32.load
    )
    (func $listGetTempRef (param $list i32) (result i32)
        get_local $list
        i32.const 12
        i32.add
    )

    (func $listSetHead (param $list i32) (param $head i32)
        get_local $list
        i32.const 4
        i32.add
        get_local $head
        i32.store
    )
    (func $listSetTail (param $list i32) (param $tail i32)
        get_local $list
        i32.const 8
        i32.add
        get_local $tail
        i32.store
    )
    (func $listSetTemp (param $list i32) (param $temp i32)
        get_local $list
        i32.const 12
        i32.add
        get_local $temp
        i32.store
    )

    (func $listAdd (param $list i32) (param $data i32)
      get_local $list
      get_local $data
      call $nodeNew ;;create new node with data
      call $listSetTemp

      get_local $list
      call $listGetTemp ;;address of new node
      get_local $list
      call $listGetTail ;;address of new tail
      call $nodeSetPrev

      get_local $list
      call $listGetTail ;;address of new tail
      get_local $list
      call $listGetTemp ;;address of new node
      call $nodeSetNext

      get_local $list
      get_local $list
      call $listGetTemp ;;address of new node
      call $listSetTail
    )

    (func $listSum (param $list i32) (result i32)
      i32.const 0
      i32.const 0
      i32.store ;;running total 

      get_local $list
      get_local $list
      call $listGetHead
      call $listSetTemp
      
      (block
        (loop
          i32.const 0
            get_local $list
            call $listGetTemp
            call $nodeGetData
            i32.const 0
            i32.load
            i32.add
          i32.store

          get_local $list
          get_local $list
          call $listGetTemp
          call $nodeGetNext
          call $listSetTemp

          get_local $list
          call $listGetTemp ;;see if null pointer
          i32.const 0
          i32.eq

          br_if 1

          br 0 ;;keep looping
        )
      )

      i32.const 0
      i32.load
    )

    (export "allocate" (func $allocate))
    (export "listNew" (func $listNew))
    (export "listAdd" (func $listAdd))
    (export "listSum" (func $listSum))
    (export "memory" (memory 0))
)
