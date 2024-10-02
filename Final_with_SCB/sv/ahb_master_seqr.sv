class ahb_mseqr extends uvm_sequencer#(ahb_trans);

    `uvm_component_utils(ahb_mseqr)

    function new(string name = "ahb_mseqr", uvm_component parent);
        super.new(name, parent);
    endfunction

endclass: ahb_mseqr
