`timescale 1ns / 1ps

module axi_lite_slave #(
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ADDRESS_WIDTH = 4
)
(
    // Global Signals
    input  wire S_AXI_ACLK,
    input  wire S_AXI_ARESETN,

    // -- Write Address Channel --
    input  wire [AXI_ADDRESS_WIDTH-1:0] S_AXI_AWADDR,
    input  wire                          S_AXI_AWVALID,
    output wire                          S_AXI_AWREADY,

    // -- Write Data Channel --
    input  wire [AXI_DATA_WIDTH-1:0]   S_AXI_WDATA,
    input  wire [AXI_DATA_WIDTH/8-1:0] S_AXI_WSTRB,
    input  wire                          S_AXI_WVALID,
    output wire                          S_AXI_WREADY,

    // -- Write Response Channel --
    output wire [1:0]                    S_AXI_BRESP,
    output wire                          S_AXI_BVALID,
    input  wire                          S_AXI_BREADY,

    // -- Read Address Channel --
    input  wire [AXI_ADDRESS_WIDTH-1:0] S_AXI_ARADDR,
    input  wire                          S_AXI_ARVALID,
    output wire                          S_AXI_ARREADY,

    // -- Read Data Channel --
    output wire [AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
    output wire [1:0]                    S_AXI_RRESP,
    output wire                          S_AXI_RVALID,
    input  wire                          S_AXI_RREADY
);

    // -- Internal Logic --
    reg                          axi_awready;
    reg [AXI_ADDRESS_WIDTH-1:0] axi_awaddr;
    reg                          axi_wready;
    reg [1:0]                    axi_bresp;
    reg                          axi_bvalid;

    reg [AXI_ADDRESS_WIDTH-1:0] axi_araddr;
    reg                          axi_arready;
    reg [AXI_DATA_WIDTH-1:0]     axi_rdata;
    reg [1:0]                    axi_rresp;
    reg                          axi_rvalid;

    reg [AXI_DATA_WIDTH-1:0] slv_reg0;
    reg [AXI_DATA_WIDTH-1:0] slv_reg1;
    reg [AXI_DATA_WIDTH-1:0] slv_reg2;
    reg [AXI_DATA_WIDTH-1:0] slv_reg3;

    assign S_AXI_AWREADY = axi_awready;
    assign S_AXI_WREADY  = axi_wready;
    assign S_AXI_BRESP   = axi_bresp;
    assign S_AXI_BVALID  = axi_bvalid;

    assign S_AXI_ARREADY = axi_arready;
    assign S_AXI_RDATA   = axi_rdata;
    assign S_AXI_RRESP   = axi_rresp;
    assign S_AXI_RVALID  = axi_rvalid;

    // -- Write FSM --
    localparam IDLE    = 2'b00;
    localparam WR_RESP = 2'b01;

    reg [1:0] wstate;

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            wstate <= IDLE;
        end
        else begin
            case (wstate)
                IDLE: begin
                    if (S_AXI_WVALID && S_AXI_WREADY && S_AXI_AWVALID && S_AXI_AWREADY) begin
                        wstate <= WR_RESP;
                    end
                end
                WR_RESP: begin
                    if (S_AXI_BREADY) begin
                        wstate <= IDLE;
                    end
                end
                default: begin
                    wstate <= IDLE;
                end
            endcase
        end
    end

endmodule