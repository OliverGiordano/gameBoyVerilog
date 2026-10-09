module Rom_TB;
    logic [15:0] Addr;
    logic [7:0] DataOut;

    Rom dut(.Addr, .DataOut);
    initial begin
        $dumpfile("Rom.vcd");
        $dumpvars(0, Rom_TB);
        for(int i = 0; i < 8; i++) begin
            Addr = i;
            #10;
        end
        $finish;
    end
endmodule
