module StackPointer(
        input logic Clock,
        input logic [15:0] SpNext,
        input logic Reset,
        input logic LoadEnable,
        output logic [15:0] Sp
    );

    always_ff @(posedge Clock, posedge Reset) begin
        if(Reset) Sp <= 16'hFFFE;
        else if (LoadEnable) Sp <= SpNext;
    end
endmodule
