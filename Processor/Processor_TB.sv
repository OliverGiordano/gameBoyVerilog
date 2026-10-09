module Processor_TB;
    logic Clock, Reset;
    logic Clock25 = 0;
    int nonzero = 0;
    int writes = 0, xvalid = 0, xpout = 0;

    Processor dut (.Clock, .Reset, .Clock25);
    always #5 Clock25 = ~Clock25;

    always @(posedge Clock) begin
        if (dut.pValid === 1'bx) xvalid++;
        else if (dut.pValid && dut.lcdY == 10) begin
            writes++;
            if ((^dut.pOut) === 1'bx) xpout++;
        end
    end

    initial begin
        $dumpfile("Processor.vcd");
        $dumpvars(0, Processor_TB);
        $dumpvars(0, Processor_TB.dut.rf.registers[0]);
        $dumpvars(0, Processor_TB.dut.rf.registers[1]);
        $dumpvars(0, Processor_TB.dut.rf.registers[2]);
        $dumpvars(0, Processor_TB.dut.rf.registers[3]);
        $dumpvars(0, Processor_TB.dut.rf.registers[4]);
        $dumpvars(0, Processor_TB.dut.rf.registers[5]);
        $dumpvars(0, Processor_TB.dut.rf.registers[6]);
        $dumpvars(0, Processor_TB.dut.rf.registers[7]);
        $dumpvars(0, Processor_TB.dut.mmu.ifData);
        $dumpvars(0, Processor_TB.dut.mmu.ieData);

        // reset first
        Clock = 0;
        Reset = 1;
        Clock = 1; #10; Clock = 0; #10;
        Reset = 0;

        // then run about one frame
        for (int i = 0; i < 65700; i++) begin
            Clock = 1; #10; Clock = 0; #10;
        end

        // then report
        for (int y = 0; y < 144; y++)
            for (int x = 0; x < 160; x++)
                if (dut.frameBuffer[y][x] != 0) nonzero++;
        $display("nonzero pixels: %0d", nonzero);

        $write("row 10: ");
        for (int x = 0; x < 16; x++) $write("%0d ", dut.frameBuffer[10][x]);
        $display("");
        $display("line10 writes=%0d  xvalid=%0d  xpout=%0d", writes, xvalid, xpout);
        $finish;
    end
endmodule
