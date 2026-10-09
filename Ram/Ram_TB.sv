module Ram_TB;
    logic Clock;
    logic We;
    logic [15:0] Addr;
    logic [7:0] Din;
    logic [7:0] Dout;
 
    Ram dut(.Clock, .We, .Addr, .Din, .Dout);
 
    initial begin
        $dumpfile("Ram.vcd");
        $dumpvars(0, Ram_TB);
 
        Clock = 0;
        We = 0;
        Addr = 0;
        Din = 0;
 
        // write a distinct value to each of 8 addresses
        for (int i = 0; i < 8; i++) begin
            Addr = i;
            Din = i + 8'h10;   // some easily recognizable pattern
            We = 1;
            Clock = 1; #5; Clock = 0; #5;
        end
 
        // read them back and confirm
        We = 0;
        for (int i = 0; i < 8; i++) begin
            Addr = i;
            #10;
            if (Dout !== (i + 8'h10))
                $display("FAIL: Addr=%0d Dout=0x%0h expected=0x%0h", i, Dout, i + 8'h10);
            else
                $display("PASS: Addr=%0d Dout=0x%0h", i, Dout);
        end
 
        $finish;
    end
endmodule
 

