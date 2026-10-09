// The CP instruction only works if In1 is the accumulato/
module Alu (
        input logic NoCarry,
        input logic [3:0] Op,
        input logic [7:0] In1, In2, FlagsIn,
        output logic [7:0] Out, FlagsOut
    );
    logic [8:0] wideResult;
    logic [7:0] bcdOffset;
    logic bcdCarry;
    //logic
    //assign Zero = ~|Out;

    // Notes on the ALU opperations
    // 1, what is halfcarry and what is it used for?
    // * half carry checks if there was a carry from bit 4 to bit 5, (a carry halfway through the number)
    //   Another way of say this is the flag gets set if there is a carry from
    //   one nibble to another. What is a nibble? A nibble is half a byte or
    //   4 bits.  Now whats the point of a halfcarry? The half carry is used
    //   for Binary Coded Decimal (BCD) where 4 bits represent 1 digit, and
    //   the halfcarry shows weather there was a carry in BCD
    // Flags, Zero, Negative (subtract), Half-carry, Carry, in that order
    always_comb begin
        bcdOffset = 0;
        bcdCarry = 0;
        wideResult = 0;
        case (Op)
            4'b0000: begin // ADD
                wideResult = {1'b0, In1} + {1'b0, In2};
                Out = wideResult[7:0]; FlagsOut[4] = wideResult[8];
                FlagsOut = {~|Out, 1'b0, ({1'b0, In1[3:0]}+{1'b0,In2[3:0]})
                                        > 5'b01111, wideResult[8], 4'b0}; end
            4'b0001: begin // ADC
                wideResult = {1'b0, In1} + {1'b0, In2} + FlagsOut[4];
                Out = wideResult[7:0];
                FlagsOut = {~|Out, 1'b0, ({1'b0, In1[3:0]}+{1'b0,In2[3:0]})
                                        > 5'b01111, wideResult[8], 4'b0}; end
            4'b0010: begin // SUB
                Out = In1 - In2;
                FlagsOut = {~|Out, 1'b1, (In2[3:0] > In1[3:0]), (In2 > In1), 4'b0}; end
            4'b0011: begin // SBC
                Out = In1 - In2 - FlagsOut[4];
                FlagsOut = {~|Out, 1'b1, (In2[3:0] > In1[3:0]), (In2 > In1), 4'b0}; end
            4'b0100: begin // AND
                Out = In1&In2;
                FlagsOut = {~|Out, 1'b0, 1'b0, 1'b0, 4'b0}; end
            4'b0101: begin // XOR
                Out = In1^In2;
                FlagsOut = {~|Out, 1'b0, 1'b0, 1'b0, 4'b0}; end
            4'b0110: begin // Or
                Out = In1|In2;
                FlagsOut = {~|Out, 1'b0, 1'b0, 1'b0, 4'b0}; end
            4'b0111: begin // CP (subtraction but don't update the accumulator)
                Out = In1-In2;
                FlagsOut = {~|Out, 1'b1, (In2[3:0] > In1[3:0]), (In2 > In1), 4'b0}; end
            4'b1000: begin
                bcdOffset = 0;
                bcdCarry = 0;
                if(FlagsIn[6] == 0) begin
                    if(In1[3:0] > 9 || FlagsIn[5] == 1)
                        bcdOffset += 8'h06;
                    if(In1 > 8'h99 || FlagsIn[4] == 1)
                        bcdOffset += 8'h60;
                        bcdCarry = 1;
                end else begin
                    if(FlagsIn[5] == 1)
                        bcdOffset -= 8'h06;
                    if(FlagsIn[5] == 1)
                        bcdOffset -= 8'h60;
                end
                Out = In1+bcdOffset;
                FlagsOut = {(Out == 0), FlagsIn[6], 1'b0, bcdCarry, 4'b0000};
            end
            4'b1001: begin
                FlagsOut = {FlagsIn[7], 2'b11, FlagsIn[4], 4'b0};
                Out = ~In1; end
            4'b1010: begin
                FlagsOut = {FlagsIn[7], 3'b001, 4'b0};
                Out = In1; end
            4'b1011: begin
                FlagsOut = {3'b0, ~FlagsIn[4], 4'b0};
                Out = In1; end
            default: begin
                Out = '0;
                FlagsOut = {1'b1, 1'b0, 1'b0, 1'b0, 4'b0}; end
        endcase
        if (NoCarry) FlagsOut[4] = 0;
    end
endmodule
/*
000 = ADD
001 = ADC (add with carry)
010 = SUB
011 = SBC (subtract with carry/borrow)
100 = AND
101 = XOR
110 = OR
111 = CP (compare — like SUB, but discards result, only sets flags)
1000 = DAA
1001 =

11** = bit res set
*/
