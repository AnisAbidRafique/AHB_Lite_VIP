class ahb_monitor extends uvm_monitor;
    `uvm_component_utils(ahb_monitor)
    virtual ahb_intf vif;
    uvm_analysis_port #(ahb_trans) item_collected_port;
    ahb_trans seq_collected;

    function new(string name = "ahb_monitor",uvm_component parent);
        super.new(name,parent);
        item_collected_port = new("item_collected_port", this);
        seq_collected=new("seq_collected");
        `uvm_info("MONITOR_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction //new()

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info(this.get_full_name(), "ahb_monitor", UVM_HIGH)
        
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (!ahb_vif_config::get(this,"","vif", vif))
            `uvm_error("NOVIF","vif not set")
            
    endfunction

    task run_phase(uvm_phase phase);
        ahb_trans item_collected;
        `uvm_info("MONITOR_CLASS","ahb_monitor",UVM_LOW)
        // @(posedge vif.HCLK);
        @(posedge vif.HCLK);
        forever begin
            seq_collected=new("seq_collected");
            fork
            begin : mon
                vif.reset_check();
                vif.monitor_collect(seq_collected.address, 
                                seq_collected.read_write,
                                seq_collected.trans_size,
                                seq_collected.burst_mode,
                                seq_collected.trans_type,
                                seq_collected.HPROT,
                                seq_collected.write_data,
                                seq_collected.ready,
                                seq_collected.response,
                                seq_collected.read_data,
                                seq_collected.reset,
                                seq_collected.lockmode
                                );
                // vif.monitor_collect(
                //                     seq_collected
                //                 );
                trans_display(seq_collected);
                $cast(item_collected,seq_collected);
                item_collected_port.write(item_collected);
            end
            begin 
                    wait(vif.monstart);
                    wait(~vif.monstart);            
            end
            join_any
            // `uvm_info("MONITOR MSG","Fork Join Complete",UVM_LOW)
        end 
        
    endtask 

    task trans_display(input ahb_trans item);
        `uvm_info("MONITOR TRANS",$sformatf("Packet is \n%s", item.sprint()),UVM_LOW)
        
    endtask //trans_display

endclass //ahb_monitor