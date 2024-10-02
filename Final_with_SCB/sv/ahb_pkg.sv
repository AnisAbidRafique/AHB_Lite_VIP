package ahb_pkg;

 import uvm_pkg::*;
 `include "uvm_macros.svh"

  typedef uvm_config_db#(virtual ahb_intf) ahb_vif_config;

  `include "ahb_trans.sv"
  `include "ahb_mon.sv"
  `include "ahb_master_driv.sv"
  `include "ahb_master_seqr.sv"
  `include "ahb_master_seqs.sv"
  `include "ahb_master_agent.sv" 
  `include "ahb_scb.sv"

    
  `include "ahb_slave_seqr.sv"
  `include "ahb_slave_driv.sv"
  `include "ahb_slave_agent.sv" 
  `include "ahb_slave_seqs.sv"

  `include "ahb_env.sv"

endpackage : ahb_master_pkg
