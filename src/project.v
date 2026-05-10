`default_nettype none

module tt_um_arfanghani_tsetlin_top (
    input  wire [7:0] ui_in,
    output reg  [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire ena,
    input  wire clk,
    input  wire rst_n
);

    // -------------------------
    // SIMPLE FEATURE SHIFT REGISTER
    // -------------------------
    reg [7:0] features;

    wire load_en   = ui_in[1];
    wire infer_req = ui_in[2];
    wire bit_in    = ui_in[0];

    reg [3:0] count;

    // -------------------------
    // LOAD FEATURES
    // -------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            features <= 8'd0;
            count    <= 4'd0;
        end else if (ena && load_en) begin
            features <= {features[6:0], bit_in};
            if (count < 8)
                count <= count + 1;
        end
    end

    wire loaded = (count >= 8);

    // -------------------------
    // TSETLIN-LIKE CLAUSES (SAFE)
    // -------------------------
    wire c0 = features[0] & features[1];
    wire c1 = features[2] & ~features[3];
    wire c2 = features[4] & features[5];
    wire c3 = features[6] | features[7];

    wire [3:0] vote =
        c0 + c1 + c2 + c3;

    // -------------------------
    // CLASSIFICATION
    // -------------------------
    reg [1:0] class;

    always @(*) begin
        if (!loaded)
            class = 2'b00;
        else if (vote <= 1)
            class = 2'b00;
        else if (vote == 2)
            class = 2'b01;
        else
            class = 2'b10;
    end

    // -------------------------
    // OUTPUT
    // -------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uo_out <= 8'd0;
        end else begin
            uo_out[1:0] <= class;
            uo_out[3]   <= loaded;
            uo_out[7:4] <= vote;
        end
    end

    assign uio_out = features;
    assign uio_oe  = 8'b0;

endmodule

`default_nettype wire
