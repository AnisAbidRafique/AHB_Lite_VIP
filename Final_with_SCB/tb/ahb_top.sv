

`timescale 1ns/1ns

module ahb_top;

  // UVM class library compiled in a package
  import uvm_pkg::*;

  // Bring in the rest of the library (macros and template classes)
  `include "uvm_macros.svh"

  import ahb_pkg::*;
  // `include "amba_ahb_defines.v"
  // `include "design.sv"
  `include "ahb_tb.sv"
  `include "ahb_master_test_lib.sv"
  
  bit reset;
  bit clock;
  bit err;

  ahb_intf hif(clock,reset);

  amba_ahb_slave #(
  // bus paramaters
  .AW(),    // address bus width
  .DW(),    // data bus width
  .DE(),    // endianess
  .RW(),    // response width
  .MS(),  // memory size (in Bytes)
  .AM(),  // address mask
  .LW_NS(),  // write latency for nonsequential transfers
  .LW_S(),  // write latency for sequential transfers
  .LR_NS(),  // read latency for nonsequential transfers
  .LR_S()   // read latency for sequential transfers
)
  dut(
  // AMBA AHB system signals
  .hclk(clock),     // Bus clock
  .hresetn(reset),  // Reset (active low)
  // AMBA AHB decoder signal
  .hsel(1'b1),     // Slave select
  // AMBA AHB master signals
  .haddr(hif.HADDR),    // Address bus
  .htrans(hif.HTRANS),   // Transfer type
  .hwrite(hif.HWRITE),   // Transfer direction
  .hsize(hif.HSIZE),    // Transfer size
  .hburst(hif.HBURST),   // Burst type
  .hprot(hif.HPORT),    // Protection control
  .hwdata(hif.HWDATA),   // Write data bus
  // AMBA AHB slave signals
  .hrdata(hif.HRDATA),   // Read data bus
  .hready(hif.HREADY),   // Transfer done
  .hresp(hif.HRESP),    // Transfer response
  // slave control signal
  .error(err)     // request an error response
);
  
  initial begin
    ahb_vif_config::set(null,"*","vif", hif);
    run_test();
  end

  initial begin
    reset <= 1'b1;
    clock <= 1'b1;
    #1 reset <= 1'b0;
    #2 reset = 1'b1;
  end

  //Generate Clock
  always
    #5 clock = ~clock;

endmodule
