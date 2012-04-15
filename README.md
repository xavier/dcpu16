# DCPU-16

This is yet another [DCPU-16](http://0x10c.com/doc/dcpu-16.txt) bytecode interpreter written in Ruby.

## This is a Fun Experiment

I wrote this *for fun* over half a weekend, without taking hints from any other existing implementation, as part of my deliberate practice routine.

I just wanted to see what kind of design would emerge when tackling such a low-level problem while keeping a focus on testability and methods working at a single level of abstraction.

Although the interpreter is functional, this is just a toy project with no aim to compete against any of the [fully featured](https://github.com/noname22/dtools) [packages](https://github.com/judofyr/rcpu) [out there](http://dcpu.ru).


## This is Work in Progress

The code is surely **not as clean as I want it to be**, parts of the VM are still under construction

* The **external API will change** (especially code loading and the ugly parameters to the run method)
* **Instrumentation** must to be improved to allow easy stepping, tracing, watching and snapshots
* Verify the correctness of the cycles calcultions
* ...


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

This code is released under the MIT license:

* [www.opensource.org/licenses/MIT](http://www.opensource.org/licenses/MIT)