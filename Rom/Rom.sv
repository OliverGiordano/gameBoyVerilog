module Rom
    (
        input logic [15:0] Addr,
        input logic [15:0] AddrMmu,
        output logic [7:0] DataMmu,
        output logic [7:0] DataOut
    );
    logic [7:0] rom [262143];
    //logic [7:0] rom [65535];

    initial $readmemh("../Rom/01-special.hex", rom); //write the program to rom
    //initial $readmemh("../Rom/tetris.hex", rom); //write the program to rom
    assign DataOut = rom[Addr];
    assign DataMmu = rom[AddrMmu];
endmodule
