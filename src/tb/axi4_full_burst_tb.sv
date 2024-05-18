module axi4_full_burst_tb;
   localparam DATA_BYTES_P    = 4;
   localparam ADDR_BYTES_P    = 1;
   localparam NUM_USER_BITS_P = 4;
   localparam NUM_ID_BITS_P   = 4;

   logic aclk     = 0;
   logic aresetn  = 0;

   // Write address channel
   logic                        awvalid;
   logic			awready;
   logic [(ADDR_BYTES_P*8)-1:0] awaddr; // 32-bits by spec
   logic [2:0]			awsize;
   logic [3:0]			awcache;
   logic [2:0]			awprot;
   logic			awlock;
   logic [3:0]			awregion;
   logic [1:0]			awburst;
   logic [NUM_ID_BITS_P-1:0]	awid;
   logic [7:0]			awlen;
   logic [3:0]			awqos;
   logic [NUM_USER_BITS_P-1:0]	awuser;

   // Write data channel
   logic			wvalid;
   logic			wready;
   logic			wlast;
   logic [(DATA_BYTES_P*8)-1:0] wdata;
   logic [DATA_BYTES_P-1:0]	wstrb;
   logic [NUM_USER_BITS_P-1:0]	wuser;

   // Write response channel
   logic			bvalid;
   logic			bready;
   logic [1:0]			bresp;
   logic [NUM_ID_BITS_P-1:0]	bid;
   logic [NUM_USER_BITS_P-1:0]	buser;

   // Read address channel
   logic			arvalid;
   logic			arready;
   logic [(ADDR_BYTES_P*8)-1:0] araddr; // 32-bits by spec
   logic [3:0]			arcache;
   logic [2:0]			arprot;
   logic			arlock;
   logic [3:0]			arregion;
   logic [2:0]			arsize;
   logic [1:0]			arburst;
   logic [NUM_ID_BITS_P-1:0]	arid;
   logic [7:0]			arlen;
   logic [3:0]			arqos;
   logic [NUM_USER_BITS_P-1:0]	aruser;

   // Read data channel
   logic			rvalid;
   logic			rready;
   logic			rlast;
   logic [(DATA_BYTES_P*8)-1:0] rdata;
   logic [1:0]			rresp;
   logic [NUM_ID_BITS_P-1:0]	rid;
   logic [NUM_USER_BITS_P-1:0]	ruser;

   axi4_if #(.DATA_BYTES(DATA_BYTES_P),
	     .ADDR_BYTES(ADDR_BYTES_P),
	     .NUM_ID_BITS_P(NUM_ID_BITS_P),
	     .NUM_USER_BITS_P(NUM_USER_BITS_P)
	     ) connector(.aclk(aclk), .aresetn(aresetn));

   /**************************************************************************
    * Assignments
    **************************************************************************/
   // Write address
   assign awvalid        = connector.awvalid;
   assign awready	 = connector.awready;
   assign awaddr	 = connector.awaddr;
   assign awsize	 = connector.awsize;
   assign awcache	 = connector.awcache;
   assign awprot	 = connector.awprot;
   assign awlock	 = connector.awlock;
   assign awregion       = connector.awregion;
   assign awburst	 = connector.awburst;
   assign awid		 = connector.awid;
   assign awlen		 = connector.awlen;
   assign awqos		 = connector.awqos;
   assign awuser	 = connector.awuser;

   // Write data
   assign wvalid	 = connector.wvalid;
   assign wready	 = connector.wready;
   assign wlast		 = connector.wlast;
   assign wdata		 = connector.wdata;
   assign wstrb		 = connector.wstrb;
   assign wuser		 = connector.wuser;

   // Write response
   assign bvalid	 = connector.bvalid;
   assign bready	 = connector.bready;
   assign bresp		 = connector.bresp;
   assign bid		 = connector.bid;
   assign buser		 = connector.buser;

   // Read address
   assign arvalid	 = connector.arvalid;
   assign arready	 = connector.arready;
   assign araddr	 = connector.araddr;
   assign arcache	 = connector.arcache;
   assign arprot	 = connector.arprot;
   assign arlock	 = connector.arlock;
   assign arregion       = connector.arregion;
   assign arsize	 = connector.arsize;
   assign arburst	 = connector.arburst;
   assign arid           = connector.arid;
   assign arlen          = connector.arlen;
   assign arqos          = connector.arqos;
   assign aruser         = connector.aruser;

   // Read data
   assign rvalid         = connector.rvalid;
   assign rready         = connector.rready;
   assign rlast		 = connector.rlast;
   assign rdata		 = connector.rdata;
   assign rresp		 = connector.rresp;
   assign rid		 = connector.rid;
   assign ruser		 = connector.ruser;

   ////////////////////////////////////////////
   // Master BFM
   ////////////////////////////////////////////
   // Write process
   logic [31:0] 		wdata_tmp[];
   initial begin
      wdata_tmp = new[10];

      for(int x=0; x<wdata_tmp.size(); x++) begin
	 wdata_tmp[x] = $urandom();
      end

      wait(aresetn == '1);
      @(posedge aclk);

      dut_master.write_burst(.awaddr('0),
			     .awburst(2'b01),
			     .wdata_arr(wdata_tmp),
			     .awid('0),
			     .awuser('0),
			     .wuser('0));
   end

   // Read process
   initial begin
      wait(aresetn == '1);
      @(posedge aclk);

      dut_master.read_beat(.araddr('1));
   end


   ////////////////////////////////////////////
   // Testbench basics
   ////////////////////////////////////////////
   // Clock signal control
   always #5 aclk = ~aclk;

   // Deassert reset signal
   initial #100 aresetn = 1'b1;

   // Testbench timeout
   initial begin
      #1ms;

      $display("============================");
      $display("======= TEST TIMEOUT =======");
      $display("============================");
      $finish;
   end


   axi4_master_bfm #(.BFM_NAME("dut_mst")) dut_master(connector);
   axi4_slave_bfm  #(.BFM_NAME("dut_slv")) dut_slave(connector);
endmodule // axi4_full_burst_tb
