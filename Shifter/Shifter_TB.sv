module Shifter_TB;
    logic [7:0] FlagsIn;
    logic [3:0] ShiftMode;
    logic [7:0] Din;
    logic [7:0] FlagsOut;
    logic [7:0] Dout;

    Shifter dut(.FlagsIn, .ShiftMode, .Din, .FlagsOut, .Dout);
    initial begin
        $dumpfile("Shifter.vcd");
        $dumpvars(0, Shifter_TB);
        for(int i = 0; i < 7; i++) begin
            FlagsIn = $random;
            ShiftMode = i;
            Din = $random;
            #10;
        end
        $finish;
    end
endmodule
