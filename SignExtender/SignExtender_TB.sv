module SignExtender_TB;
    logic [7:0] Number;
    logic [15:0] NumberOut;

    SignExtender dut(.Number, .ExtendedNumber(NumberOut));
    initial begin
        $dumpfile("SignExtender.vcd");
        $dumpvars(0, SignExtender_TB);
        Number = 8'b11111111;
        #10;
        Number = 8'b01111111;
        #10;
    end
endmodule
