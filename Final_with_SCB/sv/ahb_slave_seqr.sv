class ahb_sseqr extends uvm_sequencer#(ahb_trans);

    `uvm_component_utils(ahb_sseqr)

    function new(string name = "ahb_sseqr", uvm_component parent);
        super.new(name, parent);
    endfunction

endclass: ahb_sseqr
