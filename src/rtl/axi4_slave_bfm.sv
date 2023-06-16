// QUESTION: Does awid need to increment for every write operation? No, I don't think so.
module axi4_slave_bfm(conn);
   axi4_if conn;

   // Write address channel
   typedef struct {
      logic                            awvalid;
      logic			       awready;
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
      logic			       wready;
      logic			       wlast;
      logic [$bits(conn.wdata)-1:0]    wdata;
      logic [$bits(conn.wstrb)-1:0]    wstrb;
      logic [$bits(conn.wuser)-1:0]    wuser;
   } axi4_w_beat_t;

   // Write response channel
   typedef struct		       {
      logic			       bwvalid;
      logic			       bwready;
      logic [$bits(conn.bresp)-1:0]    bresp;
      logic [$bits(conn.bid)-1:0]      bid;
      logic [$bits(conn.buser)-1:0]    buser;
   } axi4_b_beat_t;

   // Read address channel
   typedef struct		       {
      logic			       arvalid;
      logic			       aready;
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
      logic			       rvalid;
      logic			       rready;
      logic			       rlast;
      logic [$bits(conn.rdata)-1:0]    rdata;
      logic [$bits(conn.rresp)-1:0]    rresp;
      logic [$bits(conn.rid)-1:0]      rid;
      logic [$bits(conn.ruser)-1:0]    ruser;
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


   // Write address
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

   // Write data
   localparam wlast_offset    = 0;
   localparam wdata_offset    = $bits(conn.wlast) + wlast_offset;
   localparam wstrb_offset    = $bits(conn.wdata) + wdata_offset;
   localparam wuser_offset    = $bits(conn.wstrb) + wstrb_offset;

   // Write response
   localparam bresp_offset    = 0;
   localparam bid_offset      = $bits(conn.bresp) + bresp_offset;
   localparam buser_offset    = $bits(conn.bid)   + bid_offset;

   // Read address
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

   // Read data
   localparam rlast_offset    = 0;
   localparam rdata_offset    = $bits(conn.rlast) + rlast_offset;
   localparam rresp_offset    = $bits(conn.rdata) + rdata_offset;
   localparam rid_offset      = $bits(conn.rresp) + rresp_offset;
   localparam ruser_offset    = $bits(conn.rid)   + rid_offset;


   ////////////////////////////////////////////////////////////////////////////
   // Write Response Functions
   ////////////////////////////////////////////////////////////////////////////
   /**************************************************************************
    * Add a beat to the queue of AXI4 Write Response beats to be written.
    **************************************************************************/
   task put_b_beat;
      input logic [$bits(conn.bresp)-1:0]    bresp;
      input logic [$bits(conn.bid)-1:0]      bid;
      input logic [$bits(conn.buser)-1:0]    buser;

      // axi4_w_beat_t temp;
      logic [$bits(b_conn.data)-1:0]  temp;

      begin
	 temp[bresp_offset +: $bits(conn.bresp) ] = bresp;
	 temp[bid_offset   +: $bits(conn.bid  ) ] = bid  ;
	 temp[buser_offset +: $bits(conn.buser) ] = buser;

	 // Write the response data to the bus
	 bresp.put_simple_beat(temp);
      end
   endtask // put_b_beat


   /**************************************************************************
    * Add a beat to the queue of AXI4 Write Response beats to be written.
    **************************************************************************/
   task put_simple_b_beat;
      input logic [$bits(conn.bresp)-1:0] bresp;

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
    * Add a beat to the queue of AXI4 Read Data beats to be written.
    **************************************************************************/
   task put_r_beat;
      input logic                         rlast;
      input logic [$bits(conn.rdata)-1:0] rdata;
      input logic [$bits(conn.rresp)-1:0] rresp;
      input logic [$bits(conn.rid)-1:0]   rid;
      input logic [$bits(conn.ruser)-1:0] ruser;

      logic [$bits(r_conn.data)-1:0]   temp;

      begin
	 temp[rlast_offset +: $bits(conn.rlast)] = rlast;
	 temp[rdata_offset +: $bits(conn.rdata)] = rdata;
	 temp[rresp_offset +: $bits(conn.rresp)] = rresp;
	 temp[rid_offset   +: $bits(conn.rid  )] = rid;
	 temp[ruser_offset +: $bits(conn.ruser)] = ruser;

	 // Write the data to the bus
	 read_data.put_simple_beat(temp);
      end
   endtask // put_r_beat


   /**************************************************************************
    * Add a beat to the queue of AXI4 Read Data beats to be written.
    **************************************************************************/
   task put_user_r_beat;
      input logic                         rlast;
      input logic [$bits(conn.rdata)-1:0] rdata;
      input logic [$bits(conn.rresp)-1:0] rresp;
      input logic [$bits(conn.ruser)-1:0] ruser;

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
      input logic                         rlast;
      input logic [$bits(conn.rdata)-1:0] rdata;

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
   handshake_if #(.DATA_BITS($bits(axi4_aw_beat_t)-2)) aw_conn(.clk(conn.aclk), .rst(conn.aresetn));
   handshake_slave #(.ALWAYS_READY(0)) write_addr(aw_conn);

   assign aw_conn.valid = conn.awvalid ;
   assign conn.awready  = aw_conn.ready;

   assign aw_conn.data[awaddr_offset   +: $bits(conn.awaddr)  ] = conn.awaddr  ;
   assign aw_conn.data[awsize_offset   +: $bits(conn.awsize)  ] = conn.awsize  ;
   assign aw_conn.data[awcache_offset  +: $bits(conn.awcache) ] = conn.awcache ;
   assign aw_conn.data[awprot_offset   +: $bits(conn.awprot)  ] = conn.awprot  ;
   assign aw_conn.data[awlock_offset                          ] = conn.awlock  ;
   assign aw_conn.data[awregion_offset +: $bits(conn.awregion)] = conn.awregion;
   assign aw_conn.data[awburst_offset  +: $bits(conn.awburst) ] = conn.awburst ;
   assign aw_conn.data[awid_offset     +: $bits(conn.awid)    ] = conn.awid    ;
   assign aw_conn.data[awlen_offset    +: $bits(conn.awlen)   ] = conn.awlen   ;
   assign aw_conn.data[awqos_offset    +: $bits(conn.awqos)   ] = conn.awqos   ;
   assign aw_conn.data[awuser_offset   +: $bits(conn.awuser)  ] = conn.awuser  ;

   /***************************************************************************
    * Write data channel
    ***************************************************************************/
   handshake_if #(.DATA_BITS($bits(axi4_w_beat_t)-2)) w_conn(.clk(conn.aclk), .rst(conn.aresetn));
   handshake_slave #(.ALWAYS_READY(0)) write_data(w_conn);

   assign w_conn.valid = conn.wvalid ;
   assign conn.wready  = w_conn.ready;

   assign w_conn.data[wlast_offset                     ] = conn.wlast;
   assign w_conn.data[wdata_offset +: $bits(conn.wdata)] = conn.wdata;
   assign w_conn.data[wstrb_offset +: $bits(conn.wstrb)] = conn.wstrb;
   assign w_conn.data[wuser_offset +: $bits(conn.wuser)] = conn.wuser;

   /***************************************************************************
    * Write response channel
    ***************************************************************************/
   handshake_if #(.DATA_BITS($bits(axi4_b_beat_t)-2)) b_conn(.clk(conn.aclk), .rst(conn.aresetn));
   handshake_master bresp(b_conn);

   assign conn.bwvalid = b_conn.valid;
   assign b_conn.ready = conn.bwready;

   assign conn.bresp = b_conn.data[bresp_offset +: $bits(conn.bresp)];
   assign conn.bid   = b_conn.data[bid_offset   +: $bits(conn.bid)  ];
   assign conn.buser = b_conn.data[buser_offset +: $bits(conn.buser)];

   /***************************************************************************
    * Read address channel
    ***************************************************************************/
   handshake_if #(.DATA_BITS($bits(axi4_ar_beat_t)-2)) ar_conn(.clk(conn.aclk), .rst(conn.aresetn));
   handshake_slave #(.ALWAYS_READY(0)) read_addr(ar_conn);

   assign ar_conn.valid = conn.arvalid ;
   assign conn.aready   = ar_conn.ready;

   assign ar_conn.data[araddr_offset   +: $bits(conn.araddr  )] = conn.araddr  ;
   assign ar_conn.data[arcache_offset  +: $bits(conn.arcache )] = conn.arcache ;
   assign ar_conn.data[arprot_offset   +: $bits(conn.arprot  )] = conn.arprot  ;
   assign ar_conn.data[arlock_offset   +: $bits(conn.arlock  )] = conn.arlock  ;
   assign ar_conn.data[arregion_offset +: $bits(conn.arregion)] = conn.arregion;
   assign ar_conn.data[arsize_offset   +: $bits(conn.arsize  )] = conn.arsize  ;
   assign ar_conn.data[arburst_offset  +: $bits(conn.arburst )] = conn.arburst ;
   assign ar_conn.data[arid_offset     +: $bits(conn.arid    )] = conn.arid    ;
   assign ar_conn.data[arlen_offset    +: $bits(conn.arlen   )] = conn.arlen   ;
   assign ar_conn.data[arqos_offset    +: $bits(conn.arqos   )] = conn.arqos   ;
   assign ar_conn.data[aruser_offset   +: $bits(conn.aruser  )] = conn.aruser  ;


   /***************************************************************************
    * Read data channel
    ***************************************************************************/
   handshake_if #(.DATA_BITS($bits(axi4_r_beat_t)-2)) r_conn(.clk(conn.aclk), .rst(conn.aresetn));
   handshake_master read_data(r_conn);

   assign conn.rvalid  = r_conn.valid;
   assign r_conn.ready = conn.rready ;

   assign conn.rlast = r_conn.data[rlast_offset +: $bits(conn.rlast)];
   assign conn.rdata = r_conn.data[rdata_offset +: $bits(conn.rdata)];
   assign conn.rresp = r_conn.data[rresp_offset +: $bits(conn.rresp)];
   assign conn.rid   = r_conn.data[rid_offset   +: $bits(conn.rid  )];
   assign conn.ruser = r_conn.data[ruser_offset +: $bits(conn.ruser)];



   ////////////////////////////////////////////////////////////////////////////
   // Write channel
   ////////////////////////////////////////////////////////////////////////////
   logic [$bits(w_conn)-1:0] tmp_w_beat;

   initial
   begin

      forever begin
	 write_data.get_beat(.data(tmp_w_beat));

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
   logic [$bits(ar_conn)-1:0] tmp_ar_beat;

   initial
   begin

      forever begin
	 read_addr.get_beat(.data(tmp_ar_beat));

	 // Submit read reponse
	 put_simple_r_beat(
			   .rlast('1),
			   .rdata('1)
			   );
      end
   end




endmodule // axi4_slave_bfm
