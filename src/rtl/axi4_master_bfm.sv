// QUESTION: Does awid need to increment for every write operation? No, I don't think so.
module axi4_master_bfm #(parameter BFM_NAME="test") (conn);
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
   typedef mailbox		    #(axi4_aw_beat_t) axi4_aw_inbox_t;
   typedef mailbox		    #(axi4_w_beat_t)  axi4_w_inbox_t;
   typedef mailbox		    #(axi4_b_beat_t)  axi4_b_inbox_t;
   typedef mailbox		    #(axi4_ar_beat_t) axi4_ar_inbox_t;
   typedef mailbox		    #(axi4_r_beat_t)  axi4_r_inbox_t;

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
      input logic [num_awaddr_bits-1:0]      awaddr; // 32-bits by spec
      input logic [num_awsize_bits-1:0]      awsize;
      input logic [num_awcache_bits-1:0]     awcache;
      input logic [num_awprot_bits-1:0]      awprot;
      input logic			     awlock;
      input logic [num_awregion_bits-1:0]    awregion;
      input logic [num_awburst_bits-1:0]     awburst;
      input logic [num_awid_bits-1:0]	     awid;
      input logic [num_awlen_bits-1:0]	     awlen;
      input logic [num_awqos_bits-1:0]	     awqos;
      input logic [num_awuser_bits-1:0]      awuser;

      logic [aw_conn.DATA_BITS-1:0]	     temp_aw;

      begin
	 temp_aw[awaddr_offset   +: num_awaddr_bits  ] = awaddr  ;
	 temp_aw[awsize_offset   +: num_awsize_bits  ] = awsize  ;
	 temp_aw[awcache_offset  +: num_awcache_bits ] = awcache ;
	 temp_aw[awprot_offset   +: num_awprot_bits  ] = awprot  ;
	 temp_aw[awlock_offset   +: num_awlock_bits  ] = awlock  ;
	 temp_aw[awregion_offset +: num_awregion_bits] = awregion;
	 temp_aw[awburst_offset  +: num_awburst_bits ] = awburst ;
	 temp_aw[awid_offset     +: num_awid_bits    ] = awid    ;
	 temp_aw[awlen_offset    +: num_awlen_bits   ] = awlen   ;
	 temp_aw[awqos_offset    +: num_awqos_bits   ] = awqos   ;
	 temp_aw[awuser_offset   +: num_awuser_bits  ] = awuser  ;

	 // Write the data to the bus
	 write_addr.put_simple_beat(temp_aw);
      end
   endtask // put_aw_beat


   /**************************************************************************
    * Write a burst mode beat.
    **************************************************************************/
   task put_burst_aw_beat;
      input logic [num_awaddr_bits-1:0]   awaddr;  // 32-bits by spec
      input logic [num_awlen_bits-1:0]	  awlen;   // number of burst beats - 1
      input logic [num_awburst_bits-1:0]  awburst; // type of burst [see interface definition]

      input logic [num_awid_bits-1:0]	  awid   = '0;
      input logic [num_awuser_bits-1:0]   awuser = '0;


      begin
	 put_aw_beat(.awvalid('1),
		     .awaddr(awaddr),
		     .awsize(num_wdata_bits/8),
		     .awcache('0),
		     .awprot('0),
		     .awlock('0),
		     .awregion('0),
		     .awburst(awburst),
		     .awid(awid),
		     .awlen(awlen),
		     .awqos('0),
		     .awuser(awuser));
      end
   endtask // put_burst_aw_beat


   /**************************************************************************
    * Add a simple write address beat to the queue of AXI4 Write Address beats
    * to be written.
    **************************************************************************/
   task put_simple_aw_beat;
      input logic [num_awaddr_bits-1:0]   awaddr; // 32-bits by spec
      input logic [num_awlen_bits-1:0]	  awlen;

      begin
	 put_aw_beat(.awvalid('1),
		     .awaddr(awaddr),
		     .awsize(num_wdata_bits/8),
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
      input logic [num_wdata_bits-1:0]      wdata;
      input logic [num_wstrb_bits-1:0]      wstrb;
      input logic [num_wuser_bits-1:0]      wuser;

      // axi4_w_beat_t temp;
      logic [w_conn.DATA_BITS-1:0]  temp;

      begin
	 temp[wlast_offset +: num_wlast_bits] = wlast;
	 temp[wdata_offset +: num_wdata_bits] = wdata;
	 temp[wstrb_offset +: num_wstrb_bits] = wstrb;
	 temp[wuser_offset +: num_wuser_bits] = wuser;

	 // Write the data to the bus
	 write_data.put_simple_beat(temp);
      end
   endtask // put_w_beat


   /**************************************************************************
    * Add a simple write data beat with a user value to the queue of AXI4
    * write data beats to be written.
    **************************************************************************/
   task put_user_w_beat;
      input logic [num_wdata_bits-1:0] wdata;
      input logic		       wlast;
      input logic [num_wuser_bits-1:0] wuser;

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
      input logic [num_wdata_bits-1:0] wdata;
      input logic                      wlast;

      begin
	 put_user_w_beat(.wdata(wdata),
			 .wlast(wlast),
			 .wuser('0));
      end
   endtask // put_simple_w_beat


   /**************************************************************************
    * Add a simple write data beat to the queue of AXI4 write data beats to be
    * written. A simple beat only requires data and last to be specified.
    **************************************************************************/
   task write_burst;
      // Required ports
      input logic [num_awaddr_bits-1:0]   awaddr;  // 32-bits by spec
      input logic [num_awburst_bits-1:0]  awburst; // type of burst [see interface definition]

      input logic [num_wdata_bits-1:0]	  wdata_arr[];

      // Optional ports
      input logic [num_awid_bits-1:0]	  awid   = '0;
      input logic [num_awuser_bits-1:0]   awuser = '0;

      input logic [num_awuser_bits-1:0]   wuser = '0;

      // Task specific signals
      logic				  wlast = '0;

      begin
	 // Add write address beat to the queue
	 put_burst_aw_beat(.awaddr(awaddr),
			   .awlen(wdata_arr.size()-1),
			   .awburst(awburst),
			   .awid(awid),
			   .awuser(awuser));


	 // Add write beats to the queue
	 for(int i=0; i<wdata_arr.size(); i++) begin
	    if(i == wdata_arr.size()-1)
	      wlast = '1;

	    put_w_beat(.wvalid('1),
		       .wlast(wlast),
		       .wdata(wdata_arr[i]),
		       .wstrb('1),
		       .wuser(wuser));
	 end
      end
   endtask // burst_write


   ////////////////////////////////////////////////////////////////////////////
   // Read Address Functions
   ////////////////////////////////////////////////////////////////////////////
   /**************************************************************************
    * Add a beat to the queue of AXI4 Read Address beats to be written.
    **************************************************************************/
   task put_ar_beat;
      input logic [num_araddr_bits-1:0]   araddr;
      input logic [num_arcache_bits-1:0]  arcache;
      input logic [num_arprot_bits-1:0]   arprot;
      input logic			  arlock;
      input logic [num_arregion_bits-1:0] arregion;
      input logic [num_arsize_bits-1:0]   arsize;
      input logic [num_arburst_bits-1:0]  arburst;
      input logic [num_arid_bits-1:0]     arid;
      input logic [num_arlen_bits-1:0]    arlen;
      input logic [num_arqos_bits-1:0]    arqos;
      input logic [num_aruser_bits-1:0]   aruser;

      logic [ar_conn.DATA_BITS-1:0]	  temp;

      begin
	 temp[araddr_offset   +: num_araddr_bits]   = araddr  ;
	 temp[arcache_offset  +: num_arcache_bits]  = arcache ;
	 temp[arprot_offset   +: num_arprot_bits]   = arprot  ;
	 temp[arlock_offset   +: num_arlock_bits]   = arlock  ;
	 temp[arregion_offset +: num_arregion_bits] = arregion;
	 temp[arsize_offset   +: num_arsize_bits]   = arsize  ;
	 temp[arburst_offset  +: num_arburst_bits]  = arburst ;
	 temp[arid_offset     +: num_arid_bits]     = arid    ;
	 temp[arlen_offset    +: num_arlen_bits]    = arlen   ;
	 temp[arqos_offset    +: num_arqos_bits]    = arqos   ;
	 temp[aruser_offset   +: num_aruser_bits]   = aruser  ;

	 // Write the data to the bus
	 read_address.put_simple_beat(temp);
      end
   endtask // put_ar_beat


   /**************************************************************************
    * Add a simple beat to the queue of AXI4 Read Address beats to be written.
    **************************************************************************/
   task put_simple_ar_beat;
      input logic [num_araddr_bits-1:0]   araddr;
      input logic [num_arlen_bits-1:0]    arlen;

      logic [ar_conn.DATA_BITS-1:0]	  temp;

      begin
	 // Write the data to the bus
	 put_ar_beat(
		     .araddr(araddr),
		     .arcache(0),
		     .arprot(0),
		     .arlock(0),
		     .arregion(0),
		     .arsize(conn.NUM_DATA_BITS/8),
		     .arburst(0),
		     .arid(0),
		     .arlen(arlen),
		     .arqos(0),
		     .aruser(0)
		     );
      end
   endtask // put_simple_ar_beat


   /**************************************************************************
    * Write a burst mode beat.
    **************************************************************************/
   task put_burst_ar_beat;
      input logic [num_araddr_bits-1:0]   araddr;  // 32-bits by spec
      input logic [num_arlen_bits-1:0]	  arlen;   // number of burst beats - 1
      input logic [num_arburst_bits-1:0]  arburst; // type of burst [see interface definition]

      input logic [num_arid_bits-1:0]	  arid   = '0;
      input logic [num_aruser_bits-1:0]   aruser = '0;

      begin
	 put_ar_beat(.araddr(araddr),
		     .arsize(num_wdata_bits/8),
		     .arcache('0),
		     .arprot('0),
		     .arlock('0),
		     .arregion('0),
		     .arburst(arburst),
		     .arid(arid),
		     .arlen(arlen),
		     .arqos('0),
		     .aruser(aruser));
      end
   endtask // put_burst_ar_beat


   /**************************************************************************
    * Perform a burst read
    *
    * TODO: Add read data return value
    **************************************************************************/
   task read_burst;
      input logic [num_araddr_bits-1:0]   araddr;  // 32-bits by spec
      input logic [num_arlen_bits-1:0]	  arlen;   // number of burst beats - 1
      input logic [num_arburst_bits-1:0]  arburst; // type of burst [see interface definition]

      input logic [num_arid_bits-1:0]	  arid   = '0;
      input logic [num_aruser_bits-1:0]   aruser = '0;

      // output logic [num_rdata_bits-1:0]   tmp_rdata[];

      begin
	 // tmp_rdata = new[arlen];

	 // Put the address read burst beat
	 put_burst_ar_beat(.araddr(araddr),
			   .arlen(arlen),
			   .arburst(arburst),
			   .arid(arid),
			   .aruser(aruser));

	 // for(int x=0; x<arlen; x++) begin
	 //    tmp_rdata[x] =
	 // end
      end
   endtask // read_burst


   ////////////////////////////////////////////////////////////////////////////
   // Interface connections
   ////////////////////////////////////////////////////////////////////////////
   // Write a single beat to the AXI4 full bus
   task write_beat;
      input logic [num_awaddr_bits-1:0] awaddr;
      input logic [num_wdata_bits-1:0] wdata;

      begin
	 // Write address beat
	 put_simple_aw_beat(.awaddr(awaddr),
			    .awlen(0));

	 // Write data beat
	 put_simple_w_beat(.wdata(wdata),
			   .wlast('1));

	 // Wait for write response
      end
   endtask // write_beat


   // Read a single beat using the AXI4 full bus
   task read_beat;
      input logic [num_araddr_bits-1:0] araddr;

      begin
	 // Write address beat
	 put_simple_ar_beat(.araddr(araddr),
			    .arlen(0));

	 // Wait for read response
      end
   endtask // read_beat


   ////////////////////////////////////////////////////////////////////////////
   // Interface connections
   ////////////////////////////////////////////////////////////////////////////
   /***************************************************************************
    * Write address channel
    ***************************************************************************/
   handshake_if #(.DATA_BITS($bits(axi4_aw_beat_t)-2)) aw_conn(.clk(conn.aclk), .arstn(conn.aresetn));
   handshake_master #(.IFACE_NAME($sformatf("m_axi4_%s_aw", BFM_NAME))) write_addr(aw_conn);

   assign conn.awvalid     = aw_conn.valid;
   assign aw_conn.ready    = conn.awready;

   assign conn.awaddr   = aw_conn.data[awaddr_offset   +: num_awaddr_bits  ];
   assign conn.awsize   = aw_conn.data[awsize_offset   +: num_awsize_bits  ];
   assign conn.awcache  = aw_conn.data[awcache_offset  +: num_awcache_bits ];
   assign conn.awprot   = aw_conn.data[awprot_offset   +: num_awprot_bits  ];
   assign conn.awlock   = aw_conn.data[awlock_offset                       ];
   assign conn.awregion = aw_conn.data[awregion_offset +: num_awregion_bits];
   assign conn.awburst  = aw_conn.data[awburst_offset  +: num_awburst_bits ];
   assign conn.awid     = aw_conn.data[awid_offset     +: num_awid_bits    ];
   assign conn.awlen    = aw_conn.data[awlen_offset    +: num_awlen_bits   ];
   assign conn.awqos    = aw_conn.data[awqos_offset    +: num_awqos_bits   ];
   assign conn.awuser   = aw_conn.data[awuser_offset   +: num_awuser_bits  ];

   /***************************************************************************
    * Write data channel
    ***************************************************************************/
   handshake_if #(.DATA_BITS($bits(axi4_w_beat_t)-2)) w_conn(.clk(conn.aclk), .arstn(conn.aresetn));
   handshake_master #(.IFACE_NAME($sformatf("m_axi4_%s_w", BFM_NAME))) write_data(w_conn);

   assign conn.wvalid   = w_conn.valid;
   assign w_conn.ready  = conn.wready;

   assign conn.wlast  = w_conn.data[wlast_offset                  ];
   assign conn.wdata  = w_conn.data[wdata_offset +: num_wdata_bits];
   assign conn.wstrb  = w_conn.data[wstrb_offset +: num_wstrb_bits];
   assign conn.wuser  = w_conn.data[wuser_offset +: num_wuser_bits];

   /***************************************************************************
    * Write response channel
    ***************************************************************************/
   handshake_if #(.DATA_BITS($bits(axi4_b_beat_t)-2)) b_conn(.clk(conn.aclk), .arstn(conn.aresetn));
   handshake_slave #(.IFACE_NAME($sformatf("m_axi4_%s_b", BFM_NAME))) bresp(b_conn);

   assign b_conn.valid = conn.bvalid;
   assign conn.bready = b_conn.ready;

   assign b_conn.data[bresp_offset +: num_bresp_bits] = conn.bresp;
   assign b_conn.data[bid_offset   +: num_bid_bits] = conn.bid;
   assign b_conn.data[buser_offset +: num_buser_bits] = conn.buser;

   /***************************************************************************
    * Read address channel
    ***************************************************************************/
   handshake_if #(.DATA_BITS($bits(axi4_ar_beat_t)-2)) ar_conn(.clk(conn.aclk), .arstn(conn.aresetn));
   handshake_master #(.IFACE_NAME($sformatf("m_axi4_%s_ar", BFM_NAME))) read_address(ar_conn);

   assign conn.arvalid   = ar_conn.valid;
   assign ar_conn.ready  = conn.arready;

   assign conn.araddr    = ar_conn.data[araddr_offset   +: num_araddr_bits];
   assign conn.arcache   = ar_conn.data[arcache_offset  +: num_arcache_bits];
   assign conn.arprot    = ar_conn.data[arprot_offset   +: num_arprot_bits];
   assign conn.arlock    = ar_conn.data[arlock_offset   +: num_arlock_bits];
   assign conn.arregion  = ar_conn.data[arregion_offset +: num_arregion_bits];
   assign conn.arsize    = ar_conn.data[arsize_offset   +: num_arsize_bits];
   assign conn.arburst   = ar_conn.data[arburst_offset  +: num_arburst_bits];
   assign conn.arid      = ar_conn.data[arid_offset     +: num_arid_bits];
   assign conn.arlen     = ar_conn.data[arlen_offset    +: num_arlen_bits];
   assign conn.arqos     = ar_conn.data[arqos_offset    +: num_arqos_bits];
   assign conn.aruser    = ar_conn.data[aruser_offset   +: num_aruser_bits];


   /***************************************************************************
    * Read data channel
    ***************************************************************************/
   handshake_if #(.DATA_BITS($bits(axi4_r_beat_t)-2)) r_conn(.clk(conn.aclk), .arstn(conn.aresetn));
   handshake_slave #(.IFACE_NAME($sformatf("m_axi4_%s_r", BFM_NAME))) read_data(r_conn);

   assign r_conn.valid = conn.rvalid;
   assign conn.rready  = r_conn.ready;

   assign r_conn.data[rlast_offset +: num_rlast_bits]  = conn.rlast;
   assign r_conn.data[rdata_offset +: num_rdata_bits]  = conn.rdata;
   assign r_conn.data[rresp_offset +: num_rresp_bits]  = conn.rresp;
   assign r_conn.data[rid_offset   +: num_rid_bits]    = conn.rid;
   assign r_conn.data[ruser_offset +: num_ruser_bits]  = conn.ruser;

endmodule // axi4_master_bfm
