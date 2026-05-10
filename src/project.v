`default_nettype none

module tt_um_arfanghani_tsetlin_top (
    input  wire [7:0] ui_in,
    input  wire [7:0] uio_in,
    output reg  [7:0] uo_out,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire clk,
    input  wire ena,
    input  wire rst_n
);

    // Internal storage
    reg [7:0] features;
    reg [3:0] count;

    // Input decoding
    wire bit_in   = ui_in[0];
    wire load_en  = ui_in[1];
    wire infer_en = ui_in[2];

    // Load feature bits serially
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            features <= 8'b0;
            count    <= 4'b0;
        end else if (ena && load_en) begin
            features <= {features[6:0], bit_in};

            if (count < 8)
                count <= count + 1'b1;
        end
    end

    // Loaded flag
    wire loaded;
    assign loaded = (count >= 8);

    // Simple Tsetlin-style clauses
    wire c0;
    wire c1;
    wire c2;
    wire c3;

    assign c0 = features[0] & features[1];
    assign c1 = features[2] & ~features[3];
    assign c2 = features[4] & features[5];
    assign c3 = features[6] | features[7];

    // Vote accumulator
    wire [3:0] vote;

    assign vote =
        {3'b000, c0} +
        {3'b000, c1} +
        {3'b000, c2} +
        {3'b000, c3};

    // Classification
    reg [1:0] class_out;

    always @(*) begin
        if (!loaded)
            class_out = 2'b00;
        else if (vote <= 1)
            class_out = 2'b00;
        else if (vote == 2)
            class_out = 2'b01;
        else
            class_out = 2'b10;
    end

    // Outputs
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uo_out <= 8'b0;
        end else begin
            uo_out[1:0] <= class_out;
            uo_out[2]   <= infer_en;
            uo_out[3]   <= loaded;
            uo_out[7:4] <= vote;
        end
    end

    assign uio_out = features;
    assign uio_oe  = 8'b0;

endmodule

`default_nettype wire
