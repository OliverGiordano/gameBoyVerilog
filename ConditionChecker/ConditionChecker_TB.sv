module ConditionChecker_TB;
    logic [1:0] ConditionSelect;
    logic [7:0] RegFlags;
    logic Enable;
    logic Jump;

    ConditionChecker dut(.ConditionSelect, .RegFlags, .Jump);
    initial begin
        $dumpfile("ConditionChecker.vcd");
        $dumpvars(0, ConditionChecker_TB);
        Enable = 1;
        for(int i = 0; i < 4; i++) begin
            ConditionSelect = i;
            RegFlags = 8'b10101010;
            #10;
        end
        for(int i = 0; i < 4; i++) begin
            ConditionSelect = i;
            RegFlags = 8'b00000000;
            #10;
        end
    end
endmodule
