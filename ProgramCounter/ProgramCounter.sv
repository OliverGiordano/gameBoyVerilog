module ProgramCounter(
        input logic Clock,
        input logic [15:0] PcNext,
        input logic Reset,
        output logic [15:0] Pc
    );

    always_ff @(posedge Clock, posedge Reset) begin
        //if(Reset) Pc <= 16'h0000;
        if(Reset) Pc <= 16'h0100;
        else Pc <= PcNext;
    end
endmodule
