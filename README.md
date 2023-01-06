# Salaga-RV

Salaga family of RISC-V hardware and some GUI software to run on it!

The purpose of this project is to improve my *systems* knowledge by implementing what I learnt in USC's EE356, EE457, and EE402 courses by [Prof. Marco Paolieri](https://qed.usc.edu/paolieri/), [Prof. Gandhi Puvvada](https://viterbi.usc.edu/directory/faculty/Puvvada/Gandhi), and [Prof. Bill Cheng](http://merlot.usc.edu/william/usc/) respectivly.

I want to setup a hardware-software stack where I can run a bare-metal-C GUI program on the hardware I wrote!

**Thanks to** Bruno Levy's [learn-fpga](https://github.com/BrunoLevy/learn-fpga) repository. It has been a **huge** help! It has most of the thing one needs to learn not just about logic-design for FPGAs, but writing bare-metal software as well.

## Tools required
I use Ubuntu, and the following instructions should be similar for other UNIX-like systems.

For now, simulation is done using `iverilog`. However, I soon plan on adding support for `verilator` to speed up simulation time.

### 1) Installing [`iverilog`](http://iverilog.icarus.com/)
```
sudo apt install iverilog
```

### 2) Install [RISC-V GNU Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain#installation-newliblinux-multilib) (*Not required if you plan on just running code under the [tests](tests) directory*)
Follow instructions given at [RISC-V GNU Toolchain GitHub repository](https://github.com/riscv-collab/riscv-gnu-toolchain#installation-newliblinux-multilib). You will need the `riscv64-unknown-elf-*` binaries to be installed to compile software for Salaga-RV.

## Try it out!
Clone the repository
```
git clone https://github.com/ndyashas/Salaga-RV.git
```
```
cd Salaga-RV
```

## 1) Running examples
Examples are split into <!--three--> two categories.
- [gui](README.md#examples-with-gui-output)
- [no-gui](README.md#examples-with-no-gui-output)
<!-- - [no-io](README.md#examples-with-no-io-operations) -->

Go into the [examples](examples) directory
```
cd examples
```

### Examples with GUI output
```
cd no-gui
```
Code under [gui](examples/gui) are examples where the processor supports display functions such as [setting color to a pixel, or drawing a rectangle](https://github.com/ndyashas/Salaga-RV/blob/main/firmware/salagalib/include/slg_display.h)!. Although the drivers are not very realistic, I felt the way it is implemented now is a good stage before I jump into a more realistic driver implementation.

Eg: To run the simple display-testing program, run the [001_display_test](examples/gui/001_display_test) example as follows
```
cd 001_display_test
```
```
make Jala
```
The above command will compile the simulation model, and generate an executable. To run the simulation,
```
./obj_dir/Vtb
```

<!--
### Examples with no IO operations
```
cd no-io
```
[no-io](examples/no-io) examples are again tests and expect the program to leave the dmem in an expected state. To do this, a region of memory is pinned and a C-array is mapped to it. The programs under the example are supposed to manipulate values and put them in the pinned memory region. Once the program concludes, the pinned memory region is checked to verify if it is in the expected state.

Let us take [002_fibonacci_sequence](examples/no-io/002_fibonacci_sequence) for example:
To run the example on Eka:
```
cd 002_fibonacci_sequence
```
```
make Eka
```

If you look into the [program.c](examples/no-io/002_fibonacci_sequence/program.c) file, you will notice a pinned_array as follows

```C
unsigned int pinned_array[20] __attribute__((section(".pinned_array_section")));
```

The `pinned_array` array is kept in the beginning of the memory space - from address `0x00000000` to `0x0000004f` (80 bytes - 20 integers). The fibonacci calculating program - [program.c](examples/no-io/002_fibonacci_sequence/program.c) puts the values in this array and after the simulation, the contents of the dmem is dumped to be checked with what was expected.
-->

### Examples with no GUI output
```
cd no-gui
```
Code under [no-gui](examples/no-gui) are examples where one can use functions such as `putchar`! (I'm yet to add support `printf`). The `putchar` function uses a memory-mapped UART port. The UART output is captured in the simulation and printed onto the console. This procedure is neatly explained in Bruno Levy's project [here](https://github.com/BrunoLevy/learn-fpga/blob/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV/README.md#step-17-memory-mapped-device---lets-do-much-more-than-a-blinky-). Although the `pinned_array` is not required here, I have kept it nevertheless.

The procedure to run the examples are the same as in `no-io`

Eg: Let us simulate running the [print_zig_zag](examples/no-gui/002_print_zig_zag) example on the Jala core.
```
cd 002_print_zig_zag
```
```
make Jala
```
This should print out soomething as follows on your terminal
```
         
  *       
    *     
      *   
        * 
          
        * 
      *   
    *     
  *       
*         
  *       
    *     
      *   
        * 

The program completed in       41108 cycles
```

## 2) Running tests:
Go into the [tests](tests) directory
```
cd tests
```

### Run all tests at once
You can run all the tests at once on a given core by executing the [run_unit_tests.sh](tests/run_unit_tests.sh) script passing one of the processor cores as arguments.

Eg: To run all test cases against the [Eka](RTL/CORES/Eka) core, run the following command. You can test against the [Jala](RTL/CORES/Jala) core as well.
```
./run_unit_tests.sh Eka
```
> *NOTE that `Eka` is passed as an argument to the `run_unit tests.sh` script to run the test against the Eka core.

### Running individual tests
If a test fails, you may go into the directory of that specific test and run it.

Eg: If a test such as the [tests/010_test_sw-junior_lw-senior2](tests/010_test_sw-junior_lw-senior2) fails for [Jala](RTL/CORES/Jala), you can do the following to see why it failed
```
cd 010_test_sw-junior_lw-senior2
```
```
./run_test.sh Jala
```
> *NOTE that `Jala` is passed as an argument to the `run_test.sh` script to run the test against the Jala core.
