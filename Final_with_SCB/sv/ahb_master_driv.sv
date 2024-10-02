class ahb_mdriver extends uvm_driver#(ahb_trans);
    `uvm_component_utils(ahb_mdriver)
    virtual ahb_intf vif;

    bit address_phase_check;
    function new(string name="ahb_mdriver",uvm_component parent);
        super.new(name,parent);
        `uvm_info("DRIVER_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction //new()

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info(this.get_full_name(), "ahb_mdriver", UVM_HIGH)
        
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        if (!ahb_vif_config::get(this,"","vif", vif))
            `uvm_error("NOVIF","vif not set")
            
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("DRIVER_CLASS","Run Phase!",UVM_LOW)
        // wait(~vif.HRESETn)
        // `uvm_info("DRIVER_CLASS","Reset Deteced!",UVM_LOW)
        // wait(vif.HRESETn)
        // `uvm_info("DRIVER_CLASS","Reset Dropped!",UVM_LOW)
        @(posedge vif.HCLK);
        forever begin
            if(vif.HRESP & ~vif.HREADY) begin 
                @(posedge vif.HCLK); vif.HTRANS = 0;
            end else begin 
                seq_item_port.get_next_item(req);
                trans_display(req);
                fork
                begin : driver
                    address_phase(req);
                    seq_item_port.item_done(req);
                    data_phase(req);
                end
                begin 
                    wait(address_phase_check);
                    wait(~address_phase_check);
                end
                join_any
                // `uvm_info("DRIVER MSG","Fork Join Complete",UVM_LOW)

            end
        end

    endtask //run_phase

    task trans_display(input ahb_trans item);
        `uvm_info("DRIVER TRANS",$sformatf("Packet is \n%s", item.sprint()),UVM_LOW)
    endtask //trans_display

    task address_phase(input ahb_trans item);
        static int i;
        i++;
        // `uvm_info("DRIVER MSG",$sformatf("Address Phase %d Started", i),UVM_LOW)
        address_phase_check = 1;
        vif.send_to_dut(item);
        do begin
            @(posedge vif.HCLK);
        end while (!vif.HREADY);
        address_phase_check = 0;
        // `uvm_info("DRIVER MSG",$sformatf("Address Phase %d Complete", i),UVM_LOW)
    endtask

    task data_phase(input ahb_trans item);
        // @(posedge vif.HCLK);
        if(item.read_write == WRITE)
            vif.HWDATA = item.write_data;
        else
            item.read_data = vif.HRDATA;

        do begin
            @(posedge vif.HCLK);
        end while (!vif.HREADY);

    endtask  


endclass //ahb_mdriver extends uvm_driver