module Shifter(
        input logic [7:0] FlagsIn,
        input logic [2:0] ShiftMode,
        input logic [7:0] Din,
        input logic ForceZero,
        output logic [7:0] FlagsOut, Dout
    );

    always_comb begin
        case (ShiftMode)
            3'b000: begin
                Dout = {Din[6:0], Din[7]};// circular shift
                FlagsOut = {~|Dout, 2'b00, Din[7], 4'b0}; end
            3'b001: begin
                Dout = {Din[0], Din[7:1]};
                FlagsOut = {~|Dout, 2'b00, Din[0], 4'b0}; end
            3'b010: begin
                Dout = {Din[6:0], FlagsIn[4]};
                FlagsOut = {~|Dout, 2'b00, Din[7], 4'b0}; end
            3'b011: begin
                Dout = {FlagsIn[4], Din[7:1]};
                FlagsOut = {~|Dout, 2'b00, Din[0], 4'b0}; end
            3'b100: begin
                Dout = {Din[6:0], 1'b0};
                FlagsOut = {~|Dout, 2'b00, Din[7], 4'b0}; end
            3'b101: begin
                Dout = {Din[7], Din[7:1]};
                FlagsOut = {~|Dout, 2'b00, Din[0], 4'b0}; end
            3'b111: begin
                Dout = {1'b0, Din[7:1]};
                FlagsOut = {~|Dout, 2'b00, Din[0], 4'b0}; end
            3'b110: begin // swap
                Dout = {Din[3:0], Din[7:4]};
                FlagsOut = {~|Dout, 3'b0, 4'b0}; end
            default: begin
                Dout = Din;
                FlagsOut = 8'b0; end
        endcase
        if (ForceZero) FlagsOut[7] = 0;
    end
endmodule
