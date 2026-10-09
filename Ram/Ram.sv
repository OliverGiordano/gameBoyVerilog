module Ram(
        input logic We, Clock,
        input logic [15:0] Addr,
        input logic [7:0] Din,
        output logic [7:0] Dout
    );
    logic [7:0] mem [65536];
    always_ff @(posedge Clock) begin
        if (We) mem[Addr] <= Din;
    end
    assign Dout = mem[Addr];
endmodule


