module BitManipulator(
        input logic [7:0] Opperation,
        input logic [7:0] RegFlagsIn, Din,
        output logic [7:0] RegFlagsOut, Dout
    );

    always_comb begin
        case(Opperation[7:6])
            2'b01: begin
                Dout = Din;
                RegFlagsOut = {(Din[Opperation[5:3]] == 0),1'b0, 1'b1, RegFlagsIn[4:0]};
                end
            2'b10: begin
                Dout = Din & ~(1 << (Opperation[5:3]));
                RegFlagsOut = RegFlagsIn; end
            2'b11: begin
                Dout = Din | (1 << (Opperation[5:3]));
                RegFlagsOut = RegFlagsIn; end
            default: begin
                RegFlagsOut = RegFlagsIn;
                Dout = Din; end
        endcase
    end
endmodule
