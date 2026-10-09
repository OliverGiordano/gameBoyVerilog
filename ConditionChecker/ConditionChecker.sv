module ConditionChecker(
        input logic [1:0] ConditionSelect,
        input logic Enable,
        input logic [7:0] RegFlags,
        output logic Jump
    );
    
    always_comb begin 
        if(Enable) begin
            case (ConditionSelect)
                2'b00: Jump = ~RegFlags[7];// Not Zero
                2'b01: Jump = RegFlags[7]; // Zero
                2'b10: Jump = ~RegFlags[4];// No Carry
                2'b11: Jump = RegFlags[4]; // Carry
                default: Jump = 0;
            endcase
        end else Jump = 0;
    end
endmodule
