`default_nettype none
`timescale 1ns / 1ps

module tb;

    reg clk;
    reg rst_n;
    reg ena;

    reg [7:0] ui_in;
    reg [7:0] uio_in;

    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    tt_um_arfanghani_tsetlin_top dut (
        .ui_in(ui_in),
        .uio_in(uio_in),
        .uo_out(uo_out),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    always #5 clk = ~clk;

    task shift_feature;
        input bit v;
        begin
            ui_in[0] = v;
            ui_in[1] = 1;
            #10;
        end
    endtask

    integer i;

    initial begin

        $dumpfile("tb.vcd");

        $dumpvars(0, tb);

        clk = 0;
        rst_n = 0;
        ena = 1;

        ui_in = 0;
        uio_in = 0;

        #20;
        rst_n = 1;

        // Load feature vector
        for (i = 0; i < 32; i = i + 1) begin

            if (i < 12)
                shift_feature(1'b1);
            else
                shift_feature(1'b0);
        end

        ui_in[1] = 0;

        #20;

        // Start inference
        ui_in[2] = 1;

        #50;

        $finish;
    end

endmodule
