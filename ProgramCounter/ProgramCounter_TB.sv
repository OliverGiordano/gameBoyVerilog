module ProgramCounter_TB;
    logic Clock;
    logic Reset;
    logic [15:0] PcNext;
    logic [15:0] Pc;
    
    ProgramCounter dut(.Clock, .Reset, .PcNext, .Pc);
    initial begin
        $dumpfile("ProgramCounter.vcd");
        $dumpvars(0, ProgramCounter_TB);
        Reset = 0;
        Clock = 0;
        PcNext = $random;
        #10;
        Clock = 1; #10; Clock =0; #10;
        PcNext = $random;
        #10;
        Clock = 1; #10; Clock =0; #10;
        PcNext = $random;
        Reset = 1;
        #10;
        Clock = 1; #10; Clock =0; #10;
        PcNext = $random;
        Reset = 0;
        #10;
        Clock = 1; #10; Clock =0; #10;
        $finish;
    end
endmodule



