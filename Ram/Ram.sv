module Ram(
        input logic We, Clock,
        input logic [15:0] Addr,
        input logic [7:0] Din,
        input logic [15:0] Pc,
        output logic [7:0] Dout, RamInstr
    );
    logic [7:0] mem [65536];
    always_ff @(posedge Clock) begin
        if (We) mem[Addr] <= Din;
    end
    assign Dout = mem[Addr];
    assign RamInstr = mem[Pc];
endmodule


