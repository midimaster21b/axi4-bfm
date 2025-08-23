// QUESTION: Does awid need to increment for every write operation? No, I don't think so.
module axi4_slave_bfm #(parameter BFM_NAME="test") (conn);
   axi4_if conn;

   ////////////////////////////////////////////////////////////////////////////
   // Bit widths
   ////////////////////////////////////////////////////////////////////////////
   // Write address channel
   localparam num_awaddr_bits   = conn.NUM_ADDR_BITS; // 32-bits by spec
   localparam num_awsize_bits   = conn.NUM_SIZE_BITS;
   localparam num_awcache_bits  = conn.NUM_CACHE_BITS;
   localparam num_awprot_bits   = conn.NUM_PROT_BITS;
   localparam num_awlock_bits   = conn.NUM_LOCK_BITS;
   localparam num_awregion_bits = conn.NUM_REGION_BITS;
   localparam num_awburst_bits  = conn.NUM_BURST_BITS;
   localparam num_awid_bits     = conn.NUM_ID_BITS;
   localparam num_awlen_bits    = conn.NUM_LEN_BITS;
   localparam num_awqos_bits    = conn.NUM_QOS_BITS;
   localparam num_awuser_bits   = conn.NUM_USER_BITS;

   // Write data channel
   localparam num_wlast_bits    = conn.NUM_LAST_BITS;
   localparam num_wdata_bits    = conn.NUM_DATA_BITS;
   localparam num_wstrb_bits    = conn.NUM_STRB_BITS;
   localparam num_wuser_bits    = conn.NUM_USER_BITS;

   // Write response channel
   localparam num_bresp_bits    = conn.NUM_RESP_BITS;
   localparam num_bid_bits      = conn.NUM_ID_BITS;
   localparam num_buser_bits    = conn.NUM_USER_BITS;

   // Read address channel
   localparam num_araddr_bits   = conn.NUM_ADDR_BITS; // 32-bits by spec
   localparam num_arcache_bits  = conn.NUM_CACHE_BITS;
   localparam num_arprot_bits   = conn.NUM_PROT_BITS;
   localparam num_arlock_bits   = conn.NUM_LOCK_BITS;
   localparam num_arregion_bits = conn.NUM_REGION_BITS;
   localparam num_arsize_bits   = conn.NUM_SIZE_BITS;
   localparam num_arburst_bits  = conn.NUM_BURST_BITS;
   localparam num_arid_bits     = conn.NUM_ID_BITS;
   localparam num_arlen_bits    = conn.NUM_LEN_BITS;
   localparam num_arqos_bits    = conn.NUM_QOS_BITS;
   localparam num_aruser_bits   = conn.NUM_USER_BITS;

   // Read data channel
   localparam num_rlast_bits    = conn.NUM_LAST_BITS;
   localparam num_rdata_bits    = conn.NUM_DATA_BITS;
   localparam num_rresp_bits    = conn.NUM_RESP_BITS;
   localparam num_rid_bits      = conn.NUM_ID_BITS;
   localparam num_ruser_bits    = conn.NUM_USER_BITS;


   ////////////////////////////////////////////////////////////////////////////
   // Offsets
   ////////////////////////////////////////////////////////////////////////////
   // Write address
   localparam awaddr_offset   = 0;
   localparam awsize_offset   = num_awaddr_bits   + awaddr_offset;
   localparam awcache_offset  = num_awsize_bits   + awsize_offset;
   localparam awprot_offset   = num_awcache_bits  + awcache_offset;
   localparam awlock_offset   = num_awprot_bits   + awprot_offset;
   localparam awregion_offset = num_awlock_bits   + awlock_offset;
   localparam awburst_offset  = num_awregion_bits + awregion_offset;
   localparam awid_offset     = num_awburst_bits  + awburst_offset;
   localparam awlen_offset    = num_awid_bits     + awid_offset;
   localparam awqos_offset    = num_awlen_bits    + awlen_offset;
   localparam awuser_offset   = num_awqos_bits    + awqos_offset;

   // Write data
   localparam wlast_offset    = 0;
   localparam wdata_offset    = num_wlast_bits + wlast_offset;
   localparam wstrb_offset    = num_wdata_bits + wdata_offset;
   localparam wuser_offset    = num_wstrb_bits + wstrb_offset;

   // Write response
   localparam bresp_offset    = 0;
   localparam bid_offset      = num_bresp_bits + bresp_offset;
   localparam buser_offset    = num_bid_bits   + bid_offset;

   // Read address
   localparam araddr_offset   = 0;
   localparam arcache_offset  = num_araddr_bits   + araddr_offset;
   localparam arprot_offset   = num_arcache_bits  + arcache_offset;
   localparam arlock_offset   = num_arprot_bits   + arprot_offset;
   localparam arregion_offset = num_arlock_bits   + arlock_offset;
   localparam arsize_offset   = num_arregion_bits + arregion_offset;
   localparam arburst_offset  = num_arsize_bits   + arsize_offset;
   localparam arid_offset     = num_arburst_bits  + arburst_offset;
   localparam arlen_offset    = num_arid_bits     + arid_offset;
   localparam arqos_offset    = num_arlen_bits    + arlen_offset;
   localparam aruser_offset   = num_arqos_bits    + arqos_offset;

   // Read data
   localparam rlast_offset    = 0;
   localparam rdata_offset    = num_rlast_bits + rlast_offset;
   localparam rresp_offset    = num_rdata_bits + rdata_offset;
   localparam rid_offset      = num_rresp_bits + rresp_offset;
   localparam ruser_offset    = num_rid_bits   + rid_offset;


   ////////////////////////////////////////////////////////////////////////////
   // Channel Structs
   ////////////////////////////////////////////////////////////////////////////
   // Write address channel
   typedef struct {
      logic                         awvalid;
      logic			    awready;
      logic [num_awaddr_bits-1:0]   awaddr; // 32-bits by spec
      logic [num_awsize_bits-1:0]   awsize;
      logic [num_awcache_bits-1:0]  awcache;
      logic [num_awprot_bits-1:0]   awprot;
      logic			    awlock;
      logic [num_awregion_bits-1:0] awregion;
      logic [num_awburst_bits-1:0]  awburst;
      logic [num_awid_bits-1:0]     awid;
      logic [num_awlen_bits-1:0]    awlen;
      logic [num_awqos_bits-1:0]    awqos;
      logic [num_awuser_bits-1:0]   awuser;
   } axi4_aw_beat_t;

   // Write data channel
   typedef struct		    {
      logic			    wvalid;
      logic			    wready;
      logic			    wlast;
      logic [num_wdata_bits-1:0]    wdata;
      logic [num_wstrb_bits-1:0]    wstrb;
      logic [num_wuser_bits-1:0]    wuser;
   } axi4_w_beat_t;

   // Write response channel
   typedef struct		       {
      logic			    bvalid;
      logic			    bready;
      logic [num_bresp_bits-1:0]    bresp;
      logic [num_bid_bits-1:0]      bid;
      logic [num_buser_bits-1:0]    buser;
   } axi4_b_beat_t;

   // Read address channel
   typedef struct		    {
      logic			    arvalid;
      logic			    arready;
      logic [num_araddr_bits-1:0]   araddr; // 32-bits by spec
      logic [num_arcache_bits-1:0]  arcache;
      logic [num_arprot_bits-1:0]   arprot;
      logic			    arlock;
      logic [num_arregion_bits-1:0] arregion;
      logic [num_arsize_bits-1:0]   arsize;
      logic [num_arburst_bits-1:0]  arburst;
      logic [num_arid_bits-1:0]     arid;
      logic [num_arlen_bits-1:0]    arlen;
      logic [num_arqos_bits-1:0]    arqos;
      logic [num_aruser_bits-1:0]   aruser;
   } axi4_ar_beat_t;

   // Read data channel
   typedef struct		    {
      logic			    rvalid;
      logic			    rready;
      logic			    rlast;
      logic [num_rdata_bits-1:0]    rdata;
      logic [num_rresp_bits-1:0]    rresp;
      logic [num_rid_bits-1:0]      rid;
      logic [num_ruser_bits-1:0]    ruser;
   } axi4_r_beat_t;


   // Define the mailbox types for each channel
   typedef mailbox		       #(axi4_aw_beat_t) axi4_aw_inbox_t;
   typedef mailbox		       #(axi4_w_beat_t)  axi4_w_inbox_t;
   typedef mailbox		       #(axi4_b_beat_t)  axi4_b_inbox_t;
   typedef mailbox		       #(axi4_ar_beat_t) axi4_ar_inbox_t;
   typedef mailbox		       #(axi4_r_beat_t)  axi4_r_inbox_t;

   // Create mailboxes for tx/rx beats
   axi4_aw_inbox_t axi4_aw_inbox  = new();
   axi4_w_inbox_t  axi4_w_inbox   = new();
   axi4_b_inbox_t  axi4_b_inbox   = new();
   axi4_ar_inbox_t axi4_ar_inbox  = new();
   axi4_r_inbox_t  axi4_r_inbox   = new();

   // Create mailboxes for expected beats
   axi4_aw_inbox_t axi4_aw_expect = new();
   axi4_w_inbox_t  axi4_w_expect  = new();
   axi4_b_inbox_t  axi4_b_expect  = new();
   axi4_ar_inbox_t axi4_ar_expect = new();
   axi4_r_inbox_t  axi4_r_expect  = new();

   // Empty beats
   axi4_aw_beat_t empty_aw_beat = '{default: '0};
   axi4_w_beat_t  empty_w_beat  = '{default: '0};
   axi4_b_beat_t  empty_b_beat  = '{default: '0};
   axi4_ar_beat_t empty_ar_beat = '{default: '0};
   axi4_r_beat_t  empty_r_beat  = '{default: '0};

   // Temporary usable beats
   axi4_aw_beat_t temp_aw_beat;
   axi4_w_beat_t  temp_w_beat;
   axi4_b_beat_t  temp_b_beat;
   axi4_ar_beat_t temp_ar_beat;
   axi4_r_beat_t  temp_r_beat;


   ////////////////////////////////////////////////////////////////////////////
   // Write Response Functions
   ////////////////////////////////////////////////////////////////////////////
   /**************************************************************************
    * Add a beat to the queue of AXI4 Write Response beats to be written.
    **************************************************************************/
   task put_b_beat;
      input logic [num_bresp_bits-1:0]    bresp;
      input logic [num_bid_bits-1:0]      bid;
      input logic [num_buser_bits-1:0]    buser;

      // axi4_w_beat_t temp;
      logic [b_conn.DATA_BITS-1:0]  temp;

      begin
	 temp[bresp_offset +: num_bresp_bits ] = bresp;
	 temp[bid_offset   +: num_bid_bits   ] = bid  ;
	 temp[buser_offset +: num_buser_bits ] = buser;

	 // Write the response data to the bus
	 write_resp_ch.put_simple_beat(temp);
      end
   endtask // put_b_beat


   /**************************************************************************
    * Add a beat to the queue of AXI4 Write Response beats to be written.
    **************************************************************************/
   task put_simple_b_beat;
      input logic [num_bresp_bits-1:0] bresp;

      begin
	 // Write the response data to the bus
	 put_b_beat(
		    .bresp(bresp),
		    .bid(0),
		    .buser(0)
		    );
      end
   endtask // put_simple_b_beat


   ////////////////////////////////////////////////////////////////////////////
   // Read Data Functions
   ////////////////////////////////////////////////////////////////////////////
   /**************************************************************************
    * Get the number of beats associated with a burst read
    **************************************************************************/
   function int num_ar_burst_beats;
      input logic [ar_conn.DATA_BITS-1:0] handshake_tmp_data;
      begin
	 num_ar_burst_beats = handshake_tmp_data[arlen_offset+num_arlen_bits-1:arlen_offset];
      end
   endfunction // num_ar_burst_beats


   /**************************************************************************
    * Add a beat to the queue of AXI4 Read Data beats to be written.
    **************************************************************************/
   task put_r_beat;
      input logic                      rlast;
      input logic [num_rdata_bits-1:0] rdata;
      input logic [num_rresp_bits-1:0] rresp;
      input logic [num_rid_bits-1:0]   rid;
      input logic [num_ruser_bits-1:0] ruser;

      logic [r_conn.DATA_BITS-1:0]   temp;

      begin
	 temp[rlast_offset +: num_rlast_bits] = rlast;
	 temp[rdata_offset +: num_rdata_bits] = rdata;
	 temp[rresp_offset +: num_rresp_bits] = rresp;
	 temp[rid_offset   +: num_rid_bits]   = rid;
	 temp[ruser_offset +: num_ruser_bits] = ruser;

	 // Write the data to the bus
	 read_data_ch.put_simple_beat(temp);
      end
   endtask // put_r_beat


   /**************************************************************************
    * Add a beat to the queue of AXI4 Read Data beats to be written.
    **************************************************************************/
   task put_user_r_beat;
      input logic                      rlast;
      input logic [num_rdata_bits-1:0] rdata;
      input logic [num_rresp_bits-1:0] rresp;
      input logic [num_ruser_bits-1:0] ruser;

      begin
	 // Write the data to the bus
	 put_r_beat(
		    .rlast(rlast),
		    .rdata(rdata),
		    .rresp(rresp),
		    .rid(0),
		    .ruser(ruser)
		    );
      end
   endtask // put_user_r_beat


   /**************************************************************************
    * Add a simple beat to the queue of AXI4 Read Data beats to be written.
    **************************************************************************/
   task put_simple_r_beat;
      input logic                      rlast;
      input logic [num_rdata_bits-1:0] rdata;

      begin
	 // Write the data to the bus
	 put_r_beat(
		    .rlast(rlast),
		    .rdata(rdata),
		    .rresp(0),
		    .rid(0),
		    .ruser(0)
		    );
      end
   endtask // put_simple_r_beat


   ////////////////////////////////////////////////////////////////////////////
   ////////////////////////////////////////////////////////////////////////////
   // Interface connections
   ////////////////////////////////////////////////////////////////////////////
   ////////////////////////////////////////////////////////////////////////////
   /***************************************************************************
    * Write address channel
    ***************************************************************************/
   handshake_if #(.DATA_BITS($bits(axi4_aw_beat_t)-2)) aw_conn(.clk(conn.aclk), .arstn(conn.aresetn));
   handshake_slave #(.ALWAYS_READY(0), .IFACE_NAME($sformatf("s_axi4_%s_aw", BFM_NAME))) write_addr_ch(aw_conn);

   assign aw_conn.valid = conn.awvalid ;
   assign conn.awready  = aw_conn.ready;

   assign aw_conn.data[awaddr_offset   +: num_awaddr_bits  ] = conn.awaddr  ;
   assign aw_conn.data[awsize_offset   +: num_awsize_bits  ] = conn.awsize  ;
   assign aw_conn.data[awcache_offset  +: num_awcache_bits ] = conn.awcache ;
   assign aw_conn.data[awprot_offset   +: num_awprot_bits  ] = conn.awprot  ;
   assign aw_conn.data[awlock_offset                       ] = conn.awlock  ;
   assign aw_conn.data[awregion_offset +: num_awregion_bits] = conn.awregion;
   assign aw_conn.data[awburst_offset  +: num_awburst_bits ] = conn.awburst ;
   assign aw_conn.data[awid_offset     +: num_awid_bits    ] = conn.awid    ;
   assign aw_conn.data[awlen_offset    +: num_awlen_bits   ] = conn.awlen   ;
   assign aw_conn.data[awqos_offset    +: num_awqos_bits   ] = conn.awqos   ;
   assign aw_conn.data[awuser_offset   +: num_awuser_bits  ] = conn.awuser  ;

   /***************************************************************************
    * Write data channel
    ***************************************************************************/
   handshake_if #(.DATA_BITS($bits(axi4_w_beat_t)-2)) w_conn(.clk(conn.aclk), .arstn(conn.aresetn));
   handshake_slave #(.ALWAYS_READY(1), .IFACE_NAME($sformatf("s_axi4_%s_w", BFM_NAME))) write_data_ch(w_conn);

   assign w_conn.valid = conn.wvalid ;
   assign conn.wready  = w_conn.ready;

   assign w_conn.data[wlast_offset                  ] = conn.wlast;
   assign w_conn.data[wdata_offset +: num_wdata_bits] = conn.wdata;
   assign w_conn.data[wstrb_offset +: num_wstrb_bits] = conn.wstrb;
   assign w_conn.data[wuser_offset +: num_wuser_bits] = conn.wuser;

   /***************************************************************************
    * Write response channel
    ***************************************************************************/
   handshake_if #(.DATA_BITS($bits(axi4_b_beat_t)-2)) b_conn(.clk(conn.aclk), .arstn(conn.aresetn));
   handshake_master #(.IFACE_NAME($sformatf("s_axi4_%s_b", BFM_NAME))) write_resp_ch(b_conn);

   assign conn.bvalid = b_conn.valid;
   assign b_conn.ready = conn.bready;

   assign conn.bresp = b_conn.data[bresp_offset +: num_bresp_bits];
   assign conn.bid   = b_conn.data[bid_offset   +: num_bid_bits  ];
   assign conn.buser = b_conn.data[buser_offset +: num_buser_bits];

   /***************************************************************************
    * Read address channel
    ***************************************************************************/
   handshake_if #(.DATA_BITS($bits(axi4_ar_beat_t)-2)) ar_conn(.clk(conn.aclk), .arstn(conn.aresetn));
   handshake_slave #(.ALWAYS_READY(0), .IFACE_NAME($sformatf("s_axi4_%s_ar", BFM_NAME))) read_addr_ch(ar_conn);

   assign ar_conn.valid = conn.arvalid ;
   assign conn.arready   = ar_conn.ready;

   assign ar_conn.data[araddr_offset   +: num_araddr_bits  ] = conn.araddr  ;
   assign ar_conn.data[arcache_offset  +: num_arcache_bits ] = conn.arcache ;
   assign ar_conn.data[arprot_offset   +: num_arprot_bits  ] = conn.arprot  ;
   assign ar_conn.data[arlock_offset   +: num_arlock_bits  ] = conn.arlock  ;
   assign ar_conn.data[arregion_offset +: num_arregion_bits] = conn.arregion;
   assign ar_conn.data[arsize_offset   +: num_arsize_bits  ] = conn.arsize  ;
   assign ar_conn.data[arburst_offset  +: num_arburst_bits ] = conn.arburst ;
   assign ar_conn.data[arid_offset     +: num_arid_bits    ] = conn.arid    ;
   assign ar_conn.data[arlen_offset    +: num_arlen_bits   ] = conn.arlen   ;
   assign ar_conn.data[arqos_offset    +: num_arqos_bits   ] = conn.arqos   ;
   assign ar_conn.data[aruser_offset   +: num_aruser_bits  ] = conn.aruser  ;


   /***************************************************************************
    * Read data channel
    ***************************************************************************/
   handshake_if #(.DATA_BITS($bits(axi4_r_beat_t)-2)) r_conn(.clk(conn.aclk), .arstn(conn.aresetn));
   handshake_master #(.IFACE_NAME($sformatf("s_axi4_%s_r", BFM_NAME))) read_data_ch(r_conn);

   assign conn.rvalid  = r_conn.valid;
   assign r_conn.ready = conn.rready ;

   assign conn.rlast = r_conn.data[rlast_offset +: num_rlast_bits];
   assign conn.rdata = r_conn.data[rdata_offset +: num_rdata_bits];
   assign conn.rresp = r_conn.data[rresp_offset +: num_rresp_bits];
   assign conn.rid   = r_conn.data[rid_offset   +: num_rid_bits  ];
   assign conn.ruser = r_conn.data[ruser_offset +: num_ruser_bits];



   ////////////////////////////////////////////////////////////////////////////
   // Write channel
   ////////////////////////////////////////////////////////////////////////////
   logic [w_conn.DATA_BITS-1:0] tmp_w_beat;

   initial
   begin
      forever begin
	 write_data_ch.get_beat(.data(tmp_w_beat));

	 // If this is the last beat of data
	 if(tmp_w_beat[wlast_offset] == '1) begin
	    // Submit write reponse
	    put_simple_b_beat(.bresp(0));
	 end
      end
   end


   ////////////////////////////////////////////////////////////////////////////
   // Read channel
   ////////////////////////////////////////////////////////////////////////////
   // logic [$bits(ar_conn)-1:0] tmp_ar_beat;

   logic [ar_conn.DATA_BITS-1:0] tmp_ar_beat;
   int			      num_burst_beats = 0;
   logic		      tmp_rlast = 0;

   initial
   begin
      forever begin
	 read_addr_ch.get_beat(.data(tmp_ar_beat));
	 num_burst_beats = num_ar_burst_beats(tmp_ar_beat);

	 for(int x=0; x<num_burst_beats+1; x++) begin
	    if(x == num_burst_beats) begin
	       tmp_rlast = 1;
	    end

	    // Submit read reponse
	    put_simple_r_beat(.rlast(tmp_rlast),
			      .rdata(x));
	 end

	 tmp_rlast = 0;
      end
   end

endmodule // axi4_slave_bfm
