# DCPU16

This is yet another [DCPU-16](http://0x10c.com/doc/dcpu-16.txt) bytecode interpreter written in Ruby.

## This is a Fun Experiment

I wrote this *for fun* over half a weekend, without taking hints from any other existing implementation, as part of my deliberate practice routine.

I just wanted to see what kind of design would emerge when tackling such a low-level problem while keeping a focus on testability and methods working at a single level of abstraction.

Although the interpreter is functional, this is just a toy project with no aim to compete against any of the [fully featured](https://github.com/noname22/dtools) [packages](https://github.com/judofyr/rcpu) [out](http://dcpu.ru) [there](http://0x10co.de).


## This is Work in Progress

The code is surely **not as clean as I want it to be**, parts of the VM are still under construction

* The **external API will change** (especially code loading and the ugly parameters to the run method)
* **Instrumentation** must to be better documented, perhaps provider an observer class skeletton
* Verify the correctness of the cycles calculations
* ...

## Extensions

The interpreted supports the following proprietary features:

### INT (opcode 0x33)

This new non-basic opcode will invoke a user-defined hook in the interpreter (there can up to 0x40 of them).

In Ruby:

```ruby
cpu = DCPU16::CPU.new
cpu.interrupts[0x12] = Proc.new { |cpu| cpu.regset(:X, 42) }
```

in DASM16:

```DASM16
  ; ...
  INT 0x12
  IFE X, 42   ; true, will perform the next instruction
  ; ...
```

## Playing Around

### Running programs

It's still very crude at the moment, programs need to be input as arrays of words.

A simple test script running a couple of programs for a few hundred cycles:

`ruby examples/test.rb`

### Running the tests

You know the deal:

1. `bundle install`
2. `bundle exec rspec`

## License

Copyright © 2012, Xavier Defrang

This code is released under the MIT license:

* [www.opensource.org/licenses/MIT](http://www.opensource.org/licenses/MIT)