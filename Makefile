IVFLAGS = -g2012
 
regfile_test: RegisterFile/RegisterFile.sv RegisterFile/RegisterFile_TB.sv
	cd RegisterFile && iverilog $(IVFLAGS) -o regfile_test RegisterFile.sv RegisterFile_TB.sv
	cd RegisterFile && vvp regfile_test
	cd RegisterFile && surfer RegisterFile.vcd &

pc_test: ProgramCounter/ProgramCounter.sv ProgramCounter/ProgramCounter_TB.sv
	cd ProgramCounter && iverilog $(IVFLAGS) -o pc_test ProgramCounter.sv ProgramCounter_TB.sv
	cd ProgramCounter && vvp pc_test
	cd ProgramCounter && surfer ProgramCounter.vcd &

sp_test: StackPointer/StackPointer.sv StackPointer/StackPointer_TB.sv
	cd StackPointer && iverilog $(IVFLAGS) -o sp_test StackPointer.sv StackPointer_TB.sv
	cd StackPointer && vvp sp_test
	cd StackPointer && surfer StackPointer.vcd &
 
alu_test: Alu/Alu.sv Alu/Alu_TB.sv
	cd Alu && iverilog $(IVFLAGS) -o alu_test Alu.sv Alu_TB.sv
	cd Alu && vvp alu_test
	cd Alu && surfer Alu.vcd &

rom_test: Rom/Rom.sv Rom/Rom_TB.sv
	cd Rom && iverilog $(IVFLAGS) -o rom_test Rom.sv Rom_TB.sv
	cd Rom && vvp rom_test
	cd Rom && surfer Rom.vcd &

extender_test: SignExtender/SignExtender.sv SignExtender/SignExtender_TB.sv
	cd SignExtender && iverilog $(IVFLAGS) -o extender_test SignExtender.sv SignExtender_TB.sv
	cd SignExtender && vvp extender_test
	cd SignExtender && surfer SignExtender.vcd &

condcheck_test: ConditionChecker/ConditionChecker.sv ConditionChecker/ConditionChecker_TB.sv
	cd ConditionChecker && iverilog $(IVFLAGS) -o condcheck_test ConditionChecker.sv ConditionChecker_TB.sv
	cd ConditionChecker && vvp condcheck_test
	cd ConditionChecker && surfer ConditionChecker.vcd &

ram_test: Ram/Ram.sv Ram/Ram_TB.sv
	cd Ram && iverilog $(IVFLAGS) -o ram_test Ram.sv Ram_TB.sv
	cd Ram && vvp ram_test
	cd Ram && surfer Ram.vcd &

shift_test: Shifter/Shifter.sv Shifter/Shifter_TB.sv
	cd Shifter && iverilog $(IVFLAGS) -o shift_test Shifter.sv Shifter_TB.sv
	cd Shifter && vvp shift_test
	cd Shifter && surfer Shifter.vcd &

processor_test: Processor/Processor.sv Processor/Processor_TB.sv Rom/Rom.sv Alu/Alu.sv ProgramCounter/ProgramCounter.sv RegisterFile/RegisterFile.sv ControlUnit/ControlUnit.sv SignExtender/SignExtender.sv Ram/Ram.sv Shifter/Shifter.sv ConditionChecker/ConditionChecker.sv StackPointer/StackPointer.sv Alu16Bit/Alu16Bit.sv Mmu/Mmu.sv BitManipulator/BitManipulator.sv Vram/Vram.sv Ppu/Ppu.sv
	cd Processor && \
	iverilog $(IVFLAGS) -o processor_test \
		Processor.sv Processor_TB.sv \
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
		../BitManipulator/BitManipulator.sv
		#2>&1 | grep -v "sorry:"
	cd Processor && vvp processor_test 
	cd Processor && surfer Processor.vcd &



processor_test2: Processor/Processor.sv Processor/Processor_TB.sv Rom/Rom.sv Alu/Alu.sv ProgramCounter/ProgramCounter.sv RegisterFile/RegisterFile.sv ControlUnit/ControlUnit.sv SignExtender/SignExtender.sv Ram/Ram.sv Shifter/Shifter.sv ConditionChecker/ConditionChecker.sv StackPointer/StackPointer.sv Alu16Bit/Alu16Bit.sv Mmu/Mmu.sv BitManipulator/BitManipulator.sv Vram/Vram.sv Ppu/Ppu.sv
	cd Processor && \
	iverilog $(IVFLAGS) -o processor_test2 \
		Processor.sv Processor_TB2.sv \
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
		../BitManipulator/BitManipulator.sv
		#2>&1 | grep -v "sorry:"
	cd Processor && vvp processor_test2
	cd Processor && surfer Processor.vcd &

verilator_test:
	cd Processor && \
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
		--exe main.cpp --top-module Processor --build -Wno-fatal
	cd Processor && ./obj_dir/VProcessor



 clean:
	rm -f RegisterFile/regfile_test *.vcd
	rm -f ProgramCounter/pc_test *.vcd
	rm -f StackPointer/sp_test *.vcd
	rm -f Alu/alu_test *.vcd
	rm -f Rom/rom_test *.vcd
	rm -f Processor/processor_test *.vcd
	rm -f SignExtender/extender_test *.vcd
	rm -f Ram/ram_test *.vcd
	rm -f Shifter/shift_test *.vcd
	rm -f ConditionalChecker/condcheck_test *.vcd
	rm -rf Processor/obj_dir
	rm -f Processor/verilator_output.ppm

.PHONY: clean
