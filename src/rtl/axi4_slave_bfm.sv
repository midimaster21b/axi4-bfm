// QUESTION: Does awid need to increment for every write operation? No, I don't think so.
// TODO:
// - Mailbox for address and data on a mailbox/ID basis?
// - Filter out by ID from handshake_slaves?
// - Support AW before or after w
// - Check final W length == awlen
import mem_pkg::*;


module axi4_slave_bfm #(parameter
			BFM_NAME="test",
			VERBOSITY="LOG",
			W_CHAN_FAIL_ON_MISMATCH=0,
			R_CHAN_FAIL_ON_MISMATCH=0,
			NUM_BYTES=2048
) (conn);
   axi4_if conn;

   localparam bfm_name_str    = $sformatf("s_axi4_%s", BFM_NAME);
   localparam bfm_name_aw_str = $sformatf("%s_aw", bfm_name_str);
   localparam bfm_name_w_str  = $sformatf("%s_w",  bfm_name_str);
   localparam bfm_name_b_str  = $sformatf("%s_b",  bfm_name_str);
   localparam bfm_name_ar_str = $sformatf("%s_ar", bfm_name_str);
   localparam bfm_name_r_str  = $sformatf("%s_r",  bfm_name_str);

   ////////////////////////////////////////////////////////////////////////////
   // Bit widths
   ////////////////////////////////////////////////////////////////////////////
   // Write address channel
   localparam num_awaddr_bits   = conn.NUM_ADDR_BITS;
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
   localparam num_araddr_bits   = conn.NUM_ADDR_BITS;
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

   localparam num_wid_values    = 2**num_awid_bits;
   localparam num_rid_values    = 2**num_arid_bits;

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
   typedef struct packed {
      logic [num_awuser_bits-1:0]   awuser;
      logic [num_awqos_bits-1:0]    awqos;
      logic [num_awlen_bits-1:0]    awlen;
      logic [num_awid_bits-1:0]     awid;
      logic [num_awburst_bits-1:0]  awburst;
      logic [num_awregion_bits-1:0] awregion;
      logic			    awlock;
      logic [num_awprot_bits-1:0]   awprot;
      logic [num_awcache_bits-1:0]  awcache;
      logic [num_awsize_bits-1:0]   awsize;
      logic [num_awaddr_bits-1:0]   awaddr;
   } axi4_aw_beat_t;

   // Write data channel
   typedef struct packed {
      logic [num_wuser_bits-1:0]    wuser;
      logic [num_wstrb_bits-1:0]    wstrb;
      logic [num_wdata_bits-1:0]    wdata;
      logic			    wlast;
   } axi4_w_beat_t;

   // Write response channel
   typedef struct packed {
      logic [num_buser_bits-1:0]    buser;
      logic [num_bid_bits-1:0]      bid;
      logic [num_bresp_bits-1:0]    bresp;
   } axi4_b_beat_t;

   // Read address channel
   typedef struct packed {
      logic [num_aruser_bits-1:0]   aruser;
      logic [num_arqos_bits-1:0]    arqos;
      logic [num_arlen_bits-1:0]    arlen;
      logic [num_arid_bits-1:0]     arid;
      logic [num_arburst_bits-1:0]  arburst;
      logic [num_arsize_bits-1:0]   arsize;
      logic [num_arregion_bits-1:0] arregion;
      logic			    arlock;
      logic [num_arprot_bits-1:0]   arprot;
      logic [num_arcache_bits-1:0]  arcache;
      logic [num_araddr_bits-1:0]   araddr; // 32-bits by spec
   } axi4_ar_beat_t;

   // Read data channel
   typedef struct packed {
      logic [num_ruser_bits-1:0]    ruser;
      logic [num_rid_bits-1:0]      rid;
      logic [num_rresp_bits-1:0]    rresp;
      logic [num_rdata_bits-1:0]    rdata;
      logic			    rlast;
   } axi4_r_beat_t;


   mailbox #(axi4_w_beat_t) axi4_w_inbox = new();


   ////////////////////////////////////////////////////////////////////////////
   // Burst Structs
   ////////////////////////////////////////////////////////////////////////////
   // Burst information
   typedef struct packed {
      longint base_addr;
      longint length;
      longint id;
      logic [conn.NUM_BURST_BITS-1:0] burst_type;
   } axi4_burst_t;

   // Write address burst
   typedef struct packed {
      logic valid;
      longint base_addr;
      longint length;
      longint byte_count;
      logic [num_awid_bits-1:0]	id;
      logic [num_awburst_bits-1:0] burst_type;
   } axi4_burst_tracker_t;

   axi4_burst_tracker_t disabled_burst = '{default: '0};

   typedef mailbox #(axi4_burst_t) axi4_aw_burst_inbox_t;
   typedef mailbox #(axi4_burst_t) axi4_ar_burst_inbox_t;

   // Queue for each ID (so AW addr and W data can be associated with each other)
   axi4_aw_burst_inbox_t axi4_aw_burst_inbox = new();
   axi4_ar_burst_inbox_t axi4_ar_burst_inbox[num_rid_values-1:0];

   // Current burst trackers
   axi4_burst_tracker_t curr_aw_burst = disabled_burst;
   axi4_burst_tracker_t curr_ar_burst = disabled_burst;

   // Memory model
   mem_model #(.BASE_ADDR(0), .ADDR_WIDTH(32), .LENGTH(NUM_BYTES), .FAIL_ON_MISMATCH(1)) u_mem = new();

   // // Burst mailboxes
   // typedef mailbox #(axi4_burst_t)   axi4_wburst_inbox_t;
   // typedef mailbox #(axi4_burst_t)   axi4_rburst_inbox_t;

   // axi4_wburst_inbox_t axi4_wburst_inbox[num_id_values-1:0];
   // axi4_rburst_inbox_t axi4_rburst_inbox[num_id_values-1:0];

   // longint wlast_count[num_id_values-1:0] = '{default: 0};
   // longint aw_count[num_id_values-1:0]    = '{default: 0};

   ////////////////////////////////////////////////////////////////////////////
   // Write Functions
   ////////////////////////////////////////////////////////////////////////////
   /**************************************************************************
    * Expect a specific beat of write channel data
    **************************************************************************/
   // Write data channel
   task expect_w_beat (
			logic [num_wdata_bits-1:0] data = '0,
			logic [num_wstrb_bits-1:0] strb = '1,
			logic			   last = '0,
			logic [num_wuser_bits-1:0] user = '0
		       );

      axi4_w_beat_t tmp_w_beat;
      begin
	 $timeformat(-9, 2, " ns", 20);

	 tmp_w_beat.wdata = data;
	 tmp_w_beat.wstrb = strb;
	 tmp_w_beat.wlast = last;
	 tmp_w_beat.wuser = user;

	 $display("%t: %s - Write Channel - Expecting Data: %X, Keep: %x, Last: %x, User: %x", $time, bfm_name_str, tmp_w_beat.wdata, tmp_w_beat.wstrb, tmp_w_beat.wlast, tmp_w_beat.wuser);

	 write_data_ch.expect_beat(tmp_w_beat);
      end
   endtask // expect_w_beat

   /**************************************************************************
    * Expect a specific beat of write channel data
    **************************************************************************/
   task expect_w_mem (
		      logic [num_wdata_bits-1:0] data = '0,
		      logic [num_awaddr_bits-1:0] addr = '0
		      );
      begin
	 $timeformat(-9, 2, " ns", 20);
	 $display("%t: %s - Write Channel - Expecting - Addr: %X, Data: %X", $time, bfm_name_str, addr, data);

	 for(int x=0; x<($bits(data)/8)-1; x++) begin
	    u_mem.write_expect_byte(.addr(addr+x), .data(data[x*8+:8]));
	 end
      end
   endtask // expect_w_mem





   ////////////////////////////////////////////////////////////////////////////
   // Write Response Functions
   ////////////////////////////////////////////////////////////////////////////
   /**************************************************************************
    * Add a beat to the queue of AXI4 Write Response beats to be written.
    **************************************************************************/
   task put_b_beat (
      input logic [num_bresp_bits-1:0] bresp = '0,
      input logic [num_bid_bits-1:0]   bid   = '0,
      input logic [num_buser_bits-1:0] buser = '0
   );
      axi4_b_beat_t temp;
      begin
	 temp.bresp = bresp;
	 temp.bid   = bid  ;
	 temp.buser = buser;

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
   handshake_if #(.DATA_BITS($bits(axi4_aw_beat_t))) aw_conn(.clk(conn.aclk), .arstn(conn.aresetn));
   handshake_slave #(.ALWAYS_READY(0), .IFACE_NAME(bfm_name_aw_str)) write_addr_ch(aw_conn);

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
   handshake_if #(.DATA_BITS($bits(axi4_w_beat_t))) w_conn(.clk(conn.aclk), .arstn(conn.aresetn));
   handshake_slave #(
		     .ALWAYS_READY(1),
		     .IFACE_NAME(bfm_name_w_str),
		     .FAIL_ON_MISMATCH(W_CHAN_FAIL_ON_MISMATCH),
		     .VERBOSE("FALSE")
		     ) write_data_ch(w_conn);

   assign w_conn.valid = conn.wvalid ;
   assign conn.wready  = w_conn.ready;

   assign w_conn.data[wlast_offset                  ] = conn.wlast;
   assign w_conn.data[wdata_offset +: num_wdata_bits] = conn.wdata;
   assign w_conn.data[wstrb_offset +: num_wstrb_bits] = conn.wstrb;
   assign w_conn.data[wuser_offset +: num_wuser_bits] = conn.wuser;

   /***************************************************************************
    * Write response channel
    ***************************************************************************/
   handshake_if #(.DATA_BITS($bits(axi4_b_beat_t))) b_conn(.clk(conn.aclk), .arstn(conn.aresetn));
   handshake_master #(.IFACE_NAME(bfm_name_b_str)) write_resp_ch(b_conn);

   assign conn.bvalid = b_conn.valid;
   assign b_conn.ready = conn.bready;

   assign conn.bresp = b_conn.data[bresp_offset +: num_bresp_bits];
   assign conn.bid   = b_conn.data[bid_offset   +: num_bid_bits  ];
   assign conn.buser = b_conn.data[buser_offset +: num_buser_bits];

   /***************************************************************************
    * Read address channel
    ***************************************************************************/
   handshake_if #(.DATA_BITS($bits(axi4_ar_beat_t))) ar_conn(.clk(conn.aclk), .arstn(conn.aresetn));
   handshake_slave #(.ALWAYS_READY(0), .IFACE_NAME(bfm_name_ar_str)) read_addr_ch(ar_conn);

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
   handshake_if #(.DATA_BITS($bits(axi4_r_beat_t))) r_conn(.clk(conn.aclk), .arstn(conn.aresetn));
   handshake_master #(.IFACE_NAME(bfm_name_r_str)) read_data_ch(r_conn);

   assign conn.rvalid  = r_conn.valid;
   assign r_conn.ready = conn.rready ;

   assign conn.rlast = r_conn.data[rlast_offset +: num_rlast_bits];
   assign conn.rdata = r_conn.data[rdata_offset +: num_rdata_bits];
   assign conn.rresp = r_conn.data[rresp_offset +: num_rresp_bits];
   assign conn.rid   = r_conn.data[rid_offset   +: num_rid_bits  ];
   assign conn.ruser = r_conn.data[ruser_offset +: num_ruser_bits];



   ////////////////////////////////////////////////////////////////////////////
   // Write channels
   ////////////////////////////////////////////////////////////////////////////
   // Write address channel
   axi4_aw_beat_t tmp_aw_beat;
   axi4_burst_t   tmp_aw_burst;

   // Store address write transactions
   initial
   begin
      $timeformat(-9, 2, " ns", 20);

      forever begin
	 // Retrieve Write Address
	 write_addr_ch.get_beat(.data(tmp_aw_beat));

	 // Queue Write Address and length
	 tmp_aw_burst.base_addr  = tmp_aw_beat.awaddr;
	 tmp_aw_burst.length     = tmp_aw_beat.awlen;
	 tmp_aw_burst.burst_type = tmp_aw_beat.awburst;

	 // Put the AW burst into the ID-matched mailbox
	 axi4_aw_burst_inbox.put(tmp_aw_burst);

      end // forever begin
   end // initial begin


   // Write data channel
   axi4_w_beat_t tmp_w_beat;
   longint tmp_waddr;

   initial
   begin
      $timeformat(-9, 2, " ns", 20);

      forever begin
	 write_data_ch.get_beat(.data(tmp_w_beat));

	 $display("%t: %s - Write Channel - Data: %X, Kepp: %x, Last: %x, User: %x", $time, bfm_name_str, tmp_w_beat.wdata, tmp_w_beat.wstrb, tmp_w_beat.wlast, tmp_w_beat.wuser);

	 // Put in mailbox
	 axi4_w_inbox.put(tmp_w_beat);
      end
   end


   // Write response channel
   axi4_burst_t aw_burst_peek;
   axi4_w_beat_t w_data_beat;
   logic [7:0] tmp_wdata[];

   initial
     begin
	$timeformat(-9, 2, " ns", 20);

	forever begin
	   // If data empty OR empty address and disabled current burst
	   if(axi4_w_inbox.num() == 0 || (axi4_aw_burst_inbox.num() == 0 && curr_aw_burst == disabled_burst)) begin
	      @(posedge conn.aclk);
	      continue;
	   end

	   // If this is the first data beat for the transaction
	   if(curr_aw_burst == disabled_burst) begin
	      axi4_aw_burst_inbox.peek(aw_burst_peek);

	      curr_aw_burst.valid = '1;
	      curr_aw_burst.byte_count = 0;
	      curr_aw_burst.base_addr  = aw_burst_peek.base_addr;
	      curr_aw_burst.length     = aw_burst_peek.length;
	      curr_aw_burst.id         = aw_burst_peek.id;
	      curr_aw_burst.burst_type = aw_burst_peek.burst_type;

	      u_mem.burst_write_addr(.addr(curr_aw_burst.base_addr));
	   end // if (curr_aw_burst == disabled_burst)

	   // Write all data out to memory
	   while(axi4_w_inbox.num() > 0) begin
	      // Get the next write beat
	      axi4_w_inbox.get(w_data_beat);

	      // For all bytes in the data beat, write to memory
	      for(int x=0; x<(conn.NUM_DATA_BITS/8)-1; x++) begin
		 u_mem.burst_write_byte(.data(w_data_beat.wdata[x*8+:8]));
	      end

	      // Increment the number of bytes written
	      curr_aw_burst.byte_count += (conn.NUM_DATA_BITS / 8);

	      // If last write beat in transaction
	      if(w_data_beat.wlast == '1) begin
		 // Queue a response to the ID
		 // TODO: Send back correct response
		 // Ex. if curr_aw_burst.length != curr_aw_burst.byte_count -- ERROR
		 put_b_beat(.bresp(0), .bid(curr_aw_burst.id));

		 // Pop the burst transaction
		 axi4_aw_burst_inbox.get(aw_burst_peek);

		 // Disable burst
		 curr_aw_burst = disabled_burst;
		 break;
	      end // if (w_data_beat.wlast == '1)
	   end // while (axi4_w_inbox.num() > 0)
	end // forever begin
     end // initial begin


   ////////////////////////////////////////////////////////////////////////////
   // Read channel
   ////////////////////////////////////////////////////////////////////////////
   axi4_ar_beat_t tmp_ar_beat;
   int            num_burst_beats = 0;
   logic          tmp_rlast = 0;

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
