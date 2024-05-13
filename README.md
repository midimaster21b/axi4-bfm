# AXI4 BFM

A pair of simple AXI4 full BFMs. This repository is for developing a basic AXI4 master and slave BFM.

## Concept

The design approach is to build the BFMs using the handshake module in a similar manner to how I designed the AXI4-lite BFM, but for AXI4 full.


## Running FuseSoC Core

`fusesoc --cores-root . --cores-root ../handshake/ --cores-root ../amba-interfaces/ run --target sim_smoke midimaster21b:bfm:axi4`


### Running GUI

```
cd build/midimaster21b_bfm_axi4_0.1.0/sim_smoke-xsim/
make run-gui
```

## BFM Usage

1. Include the master or slave BFM in the testbench.

   ```SystemVerilog      
   axi4_master_bfm #(.BFM_NAME("dut_mst")) dut_master(connector);
   axi4_slave_bfm  #(.BFM_NAME("dut_slv")) dut_slave(connector);
   ```

1. Create the one or more interfaces necessary to connect with the BFM.

   ```SystemVerilog
   axi4_if #(.DATA_BYTES(DATA_BYTES_P),
   .ADDR_BYTES(ADDR_BYTES_P),
   .NUM_ID_BITS_P(NUM_ID_BITS_P),
   .NUM_USER_BITS_P(NUM_USER_BITS_P)
   ) connector(.aclk(aclk), .aresetn(aresetn));
   ```

1. Create transactions using the BFM's provided tasks

   Master examples:

   ```SystemVerilog
   dut_master.write_beat(.awaddr('1), .wdata('1));
   dut_master.read_beat(.araddr('1));
   ```

## BFM API

### AXI4 Master

#### write_beat(awaddr, wdata)

#### read_beat(awaddr, wdata)

### AXI4 Slave
