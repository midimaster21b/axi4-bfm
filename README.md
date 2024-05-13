# AXI4 BFM

A pair of simple AXI4 full BFMs. This repository is for developing a basic AXI4 master and slave BFM.

## Concept

The design approach is to build the BFMs using the handshake module in a similar manner to how I designed the AXI4-lite BFM, but for AXI4 full.


## Running

`fusesoc --cores-root . --cores-root ../handshake/ --cores-root ../amba-interfaces/ run --target sim_smoke midimaster21b:bfm:axi4`


## Running GUI

```
cd build/midimaster21b_bfm_axi4_0.1.0/sim_smoke-xsim/
make run-gui
```
