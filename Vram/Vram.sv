module Vram(
        input logic We, Clock,
        input logic [15:0] Addr1,
        input logic [15:0] Addr2,
        input logic [7:0] Din,
        output logic [7:0] Dout1, Dout2
    );
    logic [7:0] mem [8191];
    always_ff @(posedge Clock) begin
        if (We) mem[Addr1[12:0]] <= Din;
    end
    assign Dout1 = mem[Addr1[12:0]];
    assign Dout2 = mem[Addr2[12:0]];
    initial for (int i = 0; i < 8192; i++) mem[i] = 8'h00;
endmodule



