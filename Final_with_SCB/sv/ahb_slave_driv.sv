class ahb_sdriver extends uvm_driver#(ahb_trans);
    `uvm_component_utils(ahb_sdriver)
    virtual ahb_intf vif;
    int packet_count = 1;

    function new(string name="ahb_sdriver",uvm_component parent);
        super.new(name,parent);
        `uvm_info("DRIVER_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction //new()

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info(this.get_full_name(), "ahb_sdriver", UVM_HIGH)
        
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        if (!ahb_vif_config::get(this,"","vif", vif))
            `uvm_error("NOVIF","vif not set")
            
    endfunction

    // run_phase
    task run_phase(uvm_phase phase);
        fork
        get_and_drive();
        reset_signals();
        trans_signals();
        join
    endtask : run_phase

    task get_and_drive();
        forever
            begin
                seq_item_port.get_next_item(req);
                @(negedge vif.HCLK)
                    vif.HREADY  <= req.ready;
                    vif.HRESP   <= req.response;
                    vif.HRDATA  <= req.read_data;
                `uvm_info("DRIVER TRANS",$sformatf("Send this packet to sequence \n%s \n Driver packet no: %d\n", req.sprint(),packet_count),UVM_LOW)
                seq_item_port.item_done();
                packet_count++;
                // if(req.response == ERROR)
                //     begin
                //         @(posedge vif.clock);
                //         vif.HRESP  <= 1;
                //         vif.HREADY <= 0;
                //         @(posedge vif.clock);
                //         vif.HREADY <= 1;
                //     end
                // else
                //     begin
                    // end
            end

    endtask : get_and_drive

    task reset_signals();
        forever begin
            // vif.slave_reset();
            if(!vif.HRESETn)
                begin
                        vif.HRESP     <= 1'b0;
                        vif.HREADY    <= 1'b1;
                        vif.HRDATA    <= 'hz;
                end
        wait(vif.HRESETn);
        end
    endtask : reset_signals

    task trans_signals();
        forever begin
            // vif.trans_resp();
            wait(vif.HTRANS == 00 || vif.HTRANS == 01);
            begin
                vif.HRESP     <= 1'b0;
                vif.HREADY    <= 1'b0;
                vif.HRDATA    <= 'hz;
            end
        end
    endtask : trans_signals

endclass : ahb_sdriver