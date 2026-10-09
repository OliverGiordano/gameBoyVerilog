#!/bin/bash
cd Processor
rm -rf obj_dir

verilator --cc \
    Processor.sv \
    ../Rom/Rom.sv \
    ../Alu/Alu.sv \
    ../ProgramCounter/ProgramCounter.sv \
    ../RegisterFile/RegisterFile.sv \
    ../ControlUnit/ControlUnit.sv \
    ../SignExtender/SignExtender.sv \
    ../Ram/Ram.sv \
    ../Shifter/Shifter.sv \
    ../ConditionChecker/ConditionChecker.sv \
    ../StackPointer/StackPointer.sv \
    ../Alu16Bit/Alu16Bit.sv \
    ../Mmu/Mmu.sv \
    ../Ppu/Ppu.sv \
    ../Vram/Vram.sv \
    ../BitManipulator/BitManipulator.sv \
    --exe ../main.cpp --top-module Processor --build -Wno-fatal \
    -O3 -CFLAGS "-O3 $(sdl2-config --cflags)"

# The --build step still fails at the link, so link by hand as before, now with SDL
cd obj_dir
clang++ -Wl,-U,__Z15vl_time_stamp64v,-U,__Z13sc_time_stampv,-U,_vlog_startup_routines \
    main.o verilated.o verilated_threads.o VProcessor__ALL.o \
    $(sdl2-config --libs) -pthread -lpthread -o VProcessor
cd ..

# Run from Processor/ so ../Rom/tetris.hex resolves
./obj_dir/VProcessor
