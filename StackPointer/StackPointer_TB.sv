module StackPointer_TB;
    logic Clock;
    logic Reset;
    logic [15:0] SpNext;
    logic [15:0] Sp;
    
    StackPointer dut(.Clock, .Reset, .SpNext, .Sp);
    initial begin
        $dumpfile("StackPointer.vcd");
        $dumpvars(0, StackPointer_TB);
        Reset = 0;
        Clock = 0;
        SpNext = $random;
        #10;
        Clock = 1; #10; Clock =0; #10;
        SpNext = $random;
        #10;
        Clock = 1; #10; Clock =0; #10;
        SpNext = $random;
        Reset = 1;
        #10;
        Clock = 1; #10; Clock =0; #10;
        SpNext = $random;
        Reset = 0;
        #10;
        Clock = 1; #10; Clock =0; #10;
        $finish;
    end
endmodule
