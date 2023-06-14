// QUESTION: Does awid need to increment for every write operation? No, I don't think so.
module axi4_master_bfm(conn);
   axi4_if conn;

   // Write address channel
   typedef struct {
      logic                            awvalid;
      // logic			       awready;
      logic [$bits(conn.awaddr)-1:0]   awaddr; // 32-bits by spec
      logic [$bits(conn.awsize)-1:0]   awsize;
      logic [$bits(conn.awcache)-1:0]  awcache;
      logic [$bits(conn.awprot)-1:0]   awprot;
      logic			       awlock;
      logic [$bits(conn.awregion)-1:0] awregion;
      logic [$bits(conn.awburst)-1:0]  awburst;
      logic [$bits(conn.awid)-1:0]     awid;
      logic [$bits(conn.awlen)-1:0]    awlen;
      logic [$bits(conn.awqos)-1:0]    awqos;
      logic [$bits(conn.awuser)-1:0]   awuser;
   } axi4_aw_beat_t;

   // Write data channel
   typedef struct		       {
      logic			       wvalid;
      // logic			       wready;
      logic			       wlast;
      logic [$bits(conn.wdata)-1:0]    wdata;
      logic [$bits(conn.wstrb)-1:0]    wstrb;
      logic [$bits(conn.wuser)-1:0]    wuser;
   } axi4_w_beat_t;

   // Write response channel
   typedef struct		       {
      // logic			       bwvalid;
      logic			       bwready;
      // logic [$bits(conn.bresp)-1:0]    bresp;
      // logic [$bits(conn.bid)-1:0]      bid;
      // logic [$bits(conn.buser)-1:0]    buser;
   } axi4_b_beat_t;

   // Read address channel
   typedef struct		       {
      logic			       arvalid;
      // logic			       aready;
      logic [$bits(conn.araddr)-1:0]   araddr; // 32-bits by spec
      logic [$bits(conn.arcache)-1:0]  arcache;
      logic [$bits(conn.arprot)-1:0]   arprot;
      logic			       arlock;
      logic [$bits(conn.arregion)-1:0] arregion;
      logic [$bits(conn.arsize)-1:0]   arsize;
      logic [$bits(conn.arburst)-1:0]  arburst;
      logic [$bits(conn.arid)-1:0]     arid;
      logic [$bits(conn.arlen)-1:0]    arlen;
      logic [$bits(conn.arqos)-1:0]    arqos;
      logic [$bits(conn.aruser)-1:0]   aruser;
   } axi4_ar_beat_t;

   // Read data channel
   typedef struct		       {
      // logic			       rvalid;
      logic			       rready;
      // logic			       rlast;
      // logic [$bits(conn.rdata)-1:0]    rdata;
      // logic [$bits(conn.rresp)-1:0]    rresp;
      // logic [$bits(conn.rid)-1:0]      rid;
      // logic [$bits(conn.ruser)-1:0]    ruser;
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
   // Write Address Functions
   ////////////////////////////////////////////////////////////////////////////
   /**************************************************************************
    * Add a beat to the queue of AXI4 Write Address beats to be written.
    **************************************************************************/
   task put_aw_beat;
      input logic                            awvalid;
      // input logic			     awready;
      input logic [$bits(conn.awaddr)-1:0]   awaddr; // 32-bits by spec
      input logic [$bits(conn.awsize)-1:0]   awsize;
      input logic [$bits(conn.awcache)-1:0]  awcache;
      input logic [$bits(conn.awprot)-1:0]   awprot;
      input logic			     awlock;
      input logic [$bits(conn.awregion)-1:0] awregion;
      input logic [$bits(conn.awburst)-1:0]  awburst;
      input logic [$bits(conn.awid)-1:0]     awid;
      input logic [$bits(conn.awlen)-1:0]    awlen;
      input logic [$bits(conn.awqos)-1:0]    awqos;
      input logic [$bits(conn.awuser)-1:0]   awuser;

      axi4_aw_beat_t temp;

      begin
	 temp.awvalid  = awvalid;
	 temp.awaddr   = awaddr;
	 temp.awsize   = awsize;
	 temp.awcache  = awcache;
	 temp.awprot   = awprot;
	 temp.awlock   = awlock;
	 temp.awregion = awregion;
	 temp.awburst  = awburst;
	 temp.awid     = awid;
	 temp.awlen    = awlen;
	 temp.awqos    = awqos;
	 temp.awuser   = awuser;

	 // Add output beat to mailbox
	 axi4_aw_inbox.put(temp);
	 axi4_aw_expect.put(temp);
      end
   endtask // put_aw_beat


   /**************************************************************************
    * Add a simple write address beat to the queue of AXI4 Write Address beats
    * to be written.
    **************************************************************************/
   task put_simple_aw_beat;
      input logic [$bits(conn.awaddr)-1:0]   awaddr; // 32-bits by spec
      input logic [$bits(conn.awlen)-1:0]    awlen;

      begin
	 put_aw_beat(.awvalid('1),
		     .awaddr(awaddr),
		     .awsize($bits(conn.wdata)/8),
		     .awcache('0),
		     .awprot('0),
		     .awlock('0),
		     .awregion('0),
		     .awburst('0),
		     .awid('0),
		     .awlen(awlen),
		     .awqos('0),
		     .awuser('0));
      end
   endtask // put_simple_aw_beat



   ////////////////////////////////////////////////////////////////////////////
   // Write Functions
   ////////////////////////////////////////////////////////////////////////////
   /**************************************************************************
    * Add a beat to the queue of AXI4 Write beats to be written.
    **************************************************************************/
   task put_w_beat;
      input logic			       wvalid;
      // input logic			       wready;
      input logic			       wlast;
      input logic [$bits(conn.wdata)-1:0]      wdata;
      input logic [$bits(conn.wstrb)-1:0]      wstrb;
      input logic [$bits(conn.wuser)-1:0]      wuser;

      axi4_w_beat_t temp;

      begin
	 temp.wvalid = wvalid;
	 temp.wlast  = wlast;
	 temp.wdata  = wdata;
	 temp.wstrb  = wstrb;
	 temp.wuser  = wuser;

	 // Add output beat to mailbox
	 axi4_w_inbox.put(temp);
	 axi4_w_expect.put(temp);
      end
   endtask // put_w_beat


   /**************************************************************************
    * Add a simple write data beat with a user value to the queue of AXI4
    * write data beats to be written.
    **************************************************************************/
   task put_user_w_beat;
      input logic [$bits(conn.wdata)-1:0] wdata;
      input logic			  wlast;
      input logic [$bits(conn.wuser)-1:0] wuser;

      begin
	 put_w_beat(.wvalid('1),
		    .wlast(wlast),
		    .wdata(wdata),
		    .wstrb('1),
		    .wuser(wuser));
      end
   endtask // put_user_w_beat


   /**************************************************************************
    * Add a simple write data beat to the queue of AXI4 write data beats to be
    * written. A simple beat only requires data and last to be specified.
    **************************************************************************/
   task put_simple_w_beat;
      input logic [$bits(conn.wdata)-1:0] wdata;
      input logic			  wlast;

      begin
	 put_user_w_beat(.wdata(wdata),
			 .wlast(wlast),
			 .wuser('0));
      end
   endtask // put_simple_w_beat


   ////////////////////////////////////////////////////////////////////////////
   // Read Address Functions
   ////////////////////////////////////////////////////////////////////////////
   /**************************************************************************
    * Add a beat to the queue of AXI4 Read Address beats to be written.
    **************************************************************************/
   task put_ar_beat;
      input logic                            arvalid;
      // input logic                         aready;
      input logic [$bits(conn.araddr)-1:0]   araddr;
      input logic [$bits(conn.arcache)-1:0]  arcache;
      input logic [$bits(conn.arprot)-1:0]   arprot;
      input logic			     arlock;
      input logic [$bits(conn.arregion)-1:0] arregion;
      input logic [$bits(conn.arsize)-1:0]   arsize;
      input logic [$bits(conn.arburst)-1:0]  arburst;
      input logic [$bits(conn.arid)-1:0]     arid;
      input logic [$bits(conn.arlen)-1:0]    arlen;
      input logic [$bits(conn.arqos)-1:0]    arqos;
      input logic [$bits(conn.aruser)-1:0]   aruser;

      axi4_ar_beat_t temp;

      begin
	 temp.arvalid  = arvalid;
	 temp.araddr   = araddr;
	 temp.arcache  = arcache;
	 temp.arprot   = arprot;
	 temp.arlock   = arlock;
	 temp.arregion = arregion;
	 temp.arsize   = arsize;
	 temp.arburst  = arburst;
	 temp.arid     = arid;
	 temp.arlen    = arlen;
	 temp.arqos    = arqos;
	 temp.aruser   = aruser;

	 // Add output beat to mailbox
	 axi4_ar_inbox.put(temp);
	 axi4_ar_expect.put(temp);
      end
   endtask // put_ar_beat




   ////////////////////////////////////////////////////////////////////////////
   ////////////////////////////////////////////////////////////////////////////
   // Interface connections
   ////////////////////////////////////////////////////////////////////////////
   ////////////////////////////////////////////////////////////////////////////
   /***************************************************************************
    * Write address channel
    ***************************************************************************/
   localparam awaddr_offset   = 0;
   localparam awsize_offset   = $bits(conn.awaddr)   + awaddr_offset;
   localparam awcache_offset  = $bits(conn.awsize)   + awsize_offset;
   localparam awprot_offset   = $bits(conn.awcache)  + awcache_offset;
   localparam awlock_offset   = $bits(conn.awprot)   + awprot_offset;
   localparam awregion_offset = $bits(conn.awlock)   + awlock_offset;
   localparam awburst_offset  = $bits(conn.awregion) + awregion_offset;
   localparam awid_offset     = $bits(conn.awburst)  + awburst_offset;
   localparam awlen_offset    = $bits(conn.awid)     + awid_offset;
   localparam awqos_offset    = $bits(conn.awlen)    + awlen_offset;
   localparam awuser_offset   = $bits(conn.awqos)    + awqos_offset;

   handshake_if #(.DATA_BITS($bits(axi4_aw_beat_t)-2)) aw_conn(.clk(conn.aclk), .rst(conn.aresetn));
   handshake_master write_addr(aw_conn);

   assign conn.awvalid  = aw_conn.valid;
   assign aw_conn.ready = conn.awready;

   assign conn.awaddr   = aw_conn.data[awaddr_offset   +: $bits(conn.awaddr)  ];
   assign conn.awsize   = aw_conn.data[awsize_offset   +: $bits(conn.awsize)  ];
   assign conn.awcache  = aw_conn.data[awcache_offset  +: $bits(conn.awcache) ];
   assign conn.awprot   = aw_conn.data[awprot_offset   +: $bits(conn.awprot)  ];
   assign conn.awlock   = aw_conn.data[awlock_offset   +: $bits(conn.awlock)  ];
   assign conn.awregion = aw_conn.data[awregion_offset +: $bits(conn.awregion)];
   assign conn.awburst  = aw_conn.data[awburst_offset  +: $bits(conn.awburst) ];
   assign conn.awid     = aw_conn.data[awid_offset     +: $bits(conn.awid)    ];
   assign conn.awlen    = aw_conn.data[awlen_offset    +: $bits(conn.awlen)   ];
   assign conn.awqos    = aw_conn.data[awqos_offset    +: $bits(conn.awqos)   ];
   assign conn.awuser   = aw_conn.data[awuser_offset   +: $bits(conn.awuser)  ];

   /***************************************************************************
    * Write data channel
    ***************************************************************************/
   localparam wlast_offset = 0;
   localparam wdata_offset = $bits(conn.wlast) + wlast_offset;
   localparam wstrb_offset = $bits(conn.wdata) + wdata_offset;
   localparam wuser_offset = $bits(conn.wstrb) + wstrb_offset;

   handshake_if #(.DATA_BITS($bits(axi4_w_beat_t)-2)) w_conn(.clk(conn.aclk), .rst(conn.aresetn));
   handshake_master write_data(w_conn);

   assign conn.wvalid   = w_conn.valid;
   assign w_conn.ready = conn.wready;

   assign conn.wlast    = w_conn.data[wlast_offset +: $bits(conn.wlast)];
   assign conn.wdata    = w_conn.data[wdata_offset +: $bits(conn.wdata)];
   assign conn.wstrb    = w_conn.data[wstrb_offset +: $bits(conn.wstrb)];
   assign conn.wuser    = w_conn.data[wuser_offset +: $bits(conn.wuser)];

   /***************************************************************************
    * Write response channel
    ***************************************************************************/
   localparam bresp_offset = 0;
   localparam bid_offset   = $bits(conn.bid) + bresp_offset;
   localparam buser_offset = $bits(conn.buser) + bid_offset;

   handshake_if #(.DATA_BITS($bits(axi4_b_beat_t)-2)) b_conn(.clk(conn.aclk), .rst(conn.aresetn));
   handshake_slave bresp(b_conn);

   assign b_conn.valid = conn.bwvalid;
   assign conn.bwready = b_conn.ready;

   assign b_conn.data[bresp_offset +: $bits(conn.bresp)] = conn.bresp;
   assign b_conn.data[bid_offset   +: $bits(conn.bid)]   = conn.bid;
   assign b_conn.data[buser_offset +: $bits(conn.buser)] = conn.buser;

   /***************************************************************************
    * Read address channel
    ***************************************************************************/
   localparam araddr_offset   = 0;
   localparam arcache_offset  = $bits(conn.araddr)   + araddr_offset;
   localparam arprot_offset   = $bits(conn.arcache)  + arcache_offset;
   localparam arlock_offset   = $bits(conn.arprot)   + arprot_offset;
   localparam arregion_offset = $bits(conn.arlock)   + arlock_offset;
   localparam arsize_offset   = $bits(conn.arregion) + arregion_offset;
   localparam arburst_offset  = $bits(conn.arsize)   + arsize_offset;
   localparam arid_offset     = $bits(conn.arburst)  + arburst_offset;
   localparam arlen_offset    = $bits(conn.arid)     + arid_offset;
   localparam arqos_offset    = $bits(conn.arlen)    + arlen_offset;
   localparam aruser_offset   = $bits(conn.arqos)    + arqos_offset;

   handshake_if #(.DATA_BITS($bits(axi4_ar_beat_t)-2)) ar_conn(.clk(conn.aclk), .rst(conn.aresetn));
   handshake_master read_address(ar_conn);

   assign conn.arvalid   = ar_conn.valid;
   assign ar_conn.ready  = conn.aready;

   assign conn.araddr    = ar_conn.data[araddr_offset   +: $bits(conn.araddr  )];
   assign conn.arcache   = ar_conn.data[arcache_offset  +: $bits(conn.arcache )];
   assign conn.arprot    = ar_conn.data[arprot_offset   +: $bits(conn.arprot  )];
   assign conn.arlock    = ar_conn.data[arlock_offset   +: $bits(conn.arlock  )];
   assign conn.arregion  = ar_conn.data[arregion_offset +: $bits(conn.arregion)];
   assign conn.arsize    = ar_conn.data[arsize_offset   +: $bits(conn.arsize  )];
   assign conn.arburst   = ar_conn.data[arburst_offset  +: $bits(conn.arburst )];
   assign conn.arid      = ar_conn.data[arid_offset     +: $bits(conn.arid    )];
   assign conn.arlen     = ar_conn.data[arlen_offset    +: $bits(conn.arlen   )];
   assign conn.arqos     = ar_conn.data[arqos_offset    +: $bits(conn.arqos   )];
   assign conn.aruser    = ar_conn.data[aruser_offset   +: $bits(conn.aruser  )];


   /***************************************************************************
    * Read data channel
    ***************************************************************************/
   localparam rlast_offset = 0;
   localparam rdata_offset = $bits(conn.rlast) + rlast_offset;
   localparam rresp_offset = $bits(conn.rdata) + rdata_offset;
   localparam rid_offset   = $bits(conn.rresp) + rresp_offset;
   localparam ruser_offset = $bits(conn.rid)   + rid_offset;

   handshake_if #(.DATA_BITS($bits(axi4_r_beat_t)-2)) r_conn(.clk(conn.aclk), .rst(conn.aresetn));
   handshake_slave read_data(r_conn);

   assign r_conn.valid  = conn.rvalid;
   assign conn.rready   = r_conn.ready;

   assign r_conn.data[rlast_offset +: $bits(conn.rlast)]  = conn.rlast;
   assign r_conn.data[rdata_offset +: $bits(conn.rdata)]  = conn.rdata;
   assign r_conn.data[rresp_offset +: $bits(conn.rresp)]  = conn.rresp;
   assign r_conn.data[rid_offset   +: $bits(conn.rid  )]  = conn.rid;
   assign r_conn.data[ruser_offset +: $bits(conn.ruser)]  = conn.ruser;






























   // initial begin
   //    $timeformat(-9, 2, " ns", 20);

   //    conn.tvalid = '0;
   //    conn.tdata  = '0;
   //    conn.tstrb  = '0;
   //    conn.tkeep  = '0;
   //    conn.tlast  = '0;
   //    conn.tid    = '0;
   //    conn.tdest  = '0;
   //    conn.tuser  = '0;

   //    #1;

   //    forever begin
   //	 if(axi4_inbox.try_get(temp_beat) != 0) begin
   //	    write_beat(temp_beat);

   //	    $display("%t: AXI4 Master - Write Data - '%x'", $time, temp_beat.tdata);

   //	    @(negedge conn.aclk)
   //	    if(conn.tready == '0) begin
   //	       wait(conn.tready == '1);
   //	    end

   //	    // Wait for device ready
   //	    @(posedge conn.aclk && conn.tready == '1);

   //	 end else begin
   //	    write_beat(empty_beat);

   //	    // Wait for the next clock cycle
   //	    @(posedge conn.aclk);

   //	 end
   //    end
   // end

endmodule // axi4_master_bfm
