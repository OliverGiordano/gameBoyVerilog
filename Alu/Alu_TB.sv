module Alu_TB;
    logic [2:0] Op;
    logic [7:0] In1, In2, Out;
    logic CIn, COut, Zero, HCOut, Subtraction;

    Alu dut(.Op, .In1, .In2, .Out, .CIn, .COut, .Zero, .HCOut, .Subtraction);

    initial begin;
        $dumpfile("Alu.vcd");
        $dumpvars(0, Alu_TB);
        for(int i = 0; i < 16; i++) begin
            Op = i[2:0];
            CIn = i[3];
            In1 = $random%8;
            In2 = $random%8;
            #10;
        end
        Op = 3'b011;
        In1 = 5;
        In2 = 5;
        #10;
        $finish;
    end;
endmodule
