module Alu16Bit(
        input logic [15:0] Num1,
        input logic [15:0] Num2,
        input logic Control,
        input logic [7:0] FlagsIn,
        output logic [15:0] Out,
        output logic [7:0] FlagsOut
    );
    logic H, C, Z;
    always_comb begin
        Out = Num1 + Num2;
        if(Control) begin
            H = (Num1[7:0] + Num2[7:0] > 255) ? 1 : 0;
            C = (Num1 + Num2 > 65535) ? 1 : 0;
            Z =  FlagsIn[7];
        end else begin
            H = (Num1[3:0] + Num2[3:0] > 15) ? 1 : 0;
            C = (Num1[7:0] + Num2[7:0] > 255) ? 1 : 0;
            Z = 0;
        end
        FlagsOut = {Z, 1'b0, H, C, 4'b0000};
    end
endmodule
