`default_nettype none

module tt_um_arfanghani_tsetlin_top (
    input  wire [7:0] ui_in,
    output reg  [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // ============================================================
    // SERIAL FEATURE LOADER
    // ============================================================

    wire serial_in   = ui_in[0];
    wire load_enable = ui_in[1];
    wire infer_start = ui_in[2];

    reg [31:0] feature_vector;
    reg [5:0]  bit_count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            feature_vector <= 32'd0;
            bit_count <= 0;
        end
        else if (ena && load_enable) begin

            feature_vector <= {
                feature_vector[30:0],
                serial_in
            };

            if (bit_count < 32)
                bit_count <= bit_count + 1;
        end
    end

    // ============================================================
    // FEATURE STATISTICS
    // ============================================================

    reg [7:0] activation_count;
    reg [7:0] confidence;

    integer i;

    always @(*) begin

        activation_count = 0;

        for (i = 0; i < 32; i = i + 1) begin
            activation_count = activation_count + feature_vector[i];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            confidence <= 0;
        else
            confidence <= activation_count << 2;
    end

    // ============================================================
    // TSETLIN-LIKE CLAUSE ENGINE
    // ============================================================

    wire clause0 =
        feature_vector[0] &
        feature_vector[2] &
        ~feature_vector[5];

    wire clause1 =
        feature_vector[7] &
        feature_vector[8] &
        feature_vector[9];

    wire clause2 =
        feature_vector[10] &
        ~feature_vector[11] &
        feature_vector[12];

    wire clause3 =
        feature_vector[15] &
        feature_vector[16];

    wire clause4 =
        feature_vector[18] &
        feature_vector[19] &
        feature_vector[20];

    wire clause5 =
        feature_vector[22] &
        ~feature_vector[23];

    wire clause6 =
        feature_vector[24] &
        feature_vector[25] &
        feature_vector[26];

    wire clause7 =
        feature_vector[28] &
        feature_vector[29] &
        feature_vector[30];

    // ============================================================
    // VOTING NETWORK
    // ============================================================

    wire [3:0] positive_votes =
        clause0 +
        clause1 +
        clause2 +
        clause3;

    wire [3:0] negative_votes =
        clause4 +
        clause5 +
        clause6 +
        clause7;

    wire signed [4:0] vote_sum =
        positive_votes - negative_votes;

    // ============================================================
    // TRIAGE CLASSIFIER
    // ============================================================

    reg [1:0] triage_state;

    localparam NORMAL  = 2'b00;
    localparam REFER   = 2'b01;
    localparam URGENT  = 2'b10;

    always @(*) begin

        if (!rst_n)
            triage_state = NORMAL;

        else if (vote_sum <= 0)
            triage_state = NORMAL;

        else if (vote_sum < 3)
            triage_state = REFER;

        else
            triage_state = URGENT;
    end

    // ============================================================
    // GLAUCOMA DETECTION
    // ============================================================

    wire glaucoma_flag =
        feature_vector[3] &
        feature_vector[13] &
        feature_vector[21];

    // ============================================================
    // CLAUSE DEBUG VECTOR
    // ============================================================

    wire [7:0] clause_debug = {
        clause7,
        clause6,
        clause5,
        clause4,
        clause3,
        clause2,
        clause1,
        clause0
    };

    // ============================================================
    // OUTPUTS
    // ============================================================

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            uo_out <= 0;
        end
        else if (infer_start) begin

            uo_out[1:0] <= triage_state;

            uo_out[2] <= glaucoma_flag;

            uo_out[4:3] <= confidence[7:6];

            uo_out[5] <= |clause_debug;

            uo_out[6] <= infer_start;

            uo_out[7] <= (bit_count == 32);
        end
    end

    assign uio_out = clause_debug;

    assign uio_oe = 8'b11111111;

endmodule
