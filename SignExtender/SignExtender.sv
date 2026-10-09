module SignExtender(
        input logic [7:0] Number,
        output logic [15:0] ExtendedNumber
    );
    assign ExtendedNumber = {{8{Number[7]}}, Number};
endmodule
