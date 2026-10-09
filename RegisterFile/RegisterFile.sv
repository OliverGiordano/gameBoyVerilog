// the gameboys register file, a couple interesting things,
// 1, each register is 8 bits, but they are addressed as if they
// were 16 bits by pairing the registers together
// Registers are, A (acculmulator), F (flags), B, C, D, E, H, and L
module RegisterFile (
        input logic Clock,
        input logic [2:0] Addr1, Addr2, Addr3,
        input logic [7:0] RegIn,
        input logic [15:0] WideRegIn,
        input logic We, WideRead, WideWrite, Reset,
        input logic [7:0] FlagsIn,
        output logic [7:0] Out1, Out2, FlagsOut,
        output logic [15:0] WideRegOut, WideRegOut2
    );

    typedef enum {
        B, C, D, E, H, L, F, A
    } register_t;

    logic [7:0] registers [8];
    assign FlagsOut = registers[F];

    always_ff @(posedge Clock, posedge Reset) begin
        if (Reset) begin
            registers[B] <= 8'b0;
            registers[C] <= 8'b0;
            registers[D] <= 8'b0;
            registers[E] <= 8'b0;
            registers[H] <= 8'b0;
            registers[L] <= 8'b0;
            registers[A] <= 8'b0;
            registers[F] <= 8'b0;
        end else if (We) begin
            if (WideWrite) begin
                case (Addr3)
                    3'b000: begin
                        registers[B] <= WideRegIn[15:8];
                        registers[C] <= WideRegIn[7:0]; end
                    3'b001: begin
                        registers[D] <= WideRegIn[15:8];
                        registers[E] <= WideRegIn[7:0]; end
                    3'b010: begin
                        registers[H] <= WideRegIn[15:8];
                        registers[L] <= WideRegIn[7:0]; end
                    3'b011: begin
                        registers[A] <= WideRegIn[15:8];
                        registers[F] <= {WideRegIn[7:4], 4'b0}; end
                    default:;
                endcase
            end else registers[Addr3] <= RegIn;
            registers[F] <= {FlagsIn[7:4], 4'b0};
        end
    end

    always_comb begin
        if (WideRead) begin
            case (Addr1)
                3'b000: WideRegOut = {registers[B], registers[C]};
                3'b001: WideRegOut = {registers[D], registers[E]};
                3'b010: WideRegOut = {registers[H], registers[L]};
                3'b011: WideRegOut = {registers[A], registers[F]};
                default: WideRegOut = 16'b0;
            endcase
            Out2 = registers[Addr2];
            Out1 = 8'b0;
        end else begin
            WideRegOut = 16'b0;
            Out1 = registers[Addr1];
            Out2 = registers[Addr2];
        end
        WideRegOut2 = {registers[H], registers[L]};
    end
endmodule
