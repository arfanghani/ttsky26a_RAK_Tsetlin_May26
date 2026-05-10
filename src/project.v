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
    // FEATURE STORAGE
    // -------------------------
    reg [7:0] feature_vector;
    reg [4:0] bit_count;

    wire load_en   = ui_in[1];
    wire infer_req = ui_in[2];

    integer i;

    // -------------------------
    // LOAD FEATURES (serial)
    // -------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            feature_vector <= 0;
            bit_count <= 0;
        end else if (ena && load_en) begin
            feature_vector <= {feature_vector[6:0], ui_in[0]};
            bit_count <= bit_count + 1;
        end
    end

    wire loaded = (bit_count >= 8);

    // -------------------------
    // SIMPLE CLAUSE ENGINE (SAFE WIDTHS)
    // -------------------------
    wire clause0 = feature_vector[0] & feature_vector[1];
    wire clause1 = feature_vector[2] & ~feature_vector[3];
    wire clause2 = feature_vector[4] & feature_vector[5];
    wire clause3 = feature_vector[6] | feature_vector[7];

    wire [3:0] vote_sum =
        {3'b0, clause0} +
        {3'b0, clause1} +
        {3'b0, clause2} +
        {3'b0, clause3};

    // -------------------------
    // LATCH INFERENCE (FIXED CRITICAL BUG)
    // -------------------------
    reg infer_latched;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            infer_latched <= 0;
        else if (ena && infer_req && loaded)
            infer_latched <= 1;
        else
            infer_latched <= 0;
    end

    // -------------------------
    // CLASSIFICATION
    // -------------------------
    reg [1:0] class;

    always @(*) begin
        if (!loaded)
            class = 2'b00;
        else if (vote_sum <= 1)
            class = 2'b00; // NORMAL
        else if (vote_sum == 2)
            class = 2'b01; // REFER
        else
            class = 2'b10; // URGENT
    end

    // -------------------------
    // OUTPUT REGISTER
    // -------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uo_out <= 0;
        end else begin
            uo_out[1:0] <= class;
            uo_out[2]   <= infer_latched;
            uo_out[3]   <= loaded;
            uo_out[7:4] <= vote_sum;
        end
    end

    assign uio_out = feature_vector;
    assign uio_oe  = 8'b0;

endmodule
