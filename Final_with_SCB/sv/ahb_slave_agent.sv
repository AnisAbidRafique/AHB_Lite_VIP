class ahb_sagent extends uvm_agent;

    // `uvm_component_utils(ahb_sagent)

     `uvm_component_utils_begin(ahb_sagent)
    `uvm_field_enum(uvm_active_passive_enum,is_active,UVM_ALL_ON)
    `uvm_component_utils_end   


    ahb_sdriver my_driver_h;
    // ahb_monitor my_monitor_h;
    ahb_sseqr my_seqr_h;

    // uvm_analysis_port#(ahb_strans) agent_ap;


    uvm_active_passive_enum is_active = UVM_ACTIVE;

    //Constructor
    function new(string name = "ahb_sagent", uvm_component parent);
        super.new(name, parent);
        // agent_ap = new("agent_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active))
        begin
                `uvm_fatal(get_full_name(), "Cannot get AGENT-CONFIG from configuration database!")
        end

        super.build_phase(phase);

        // my_monitor_h = ahb_monitor::type_id::create("my_monitor_h", this);
        if(is_active == UVM_ACTIVE)
        begin
                my_driver_h = ahb_sdriver::type_id::create("my_driver_h", this);
                my_seqr_h   = ahb_sseqr::type_id::create("my_seqr_h", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        // my_monitor_h.item_collected_port.connect(agent_ap);

        if(is_active == UVM_ACTIVE)
        begin
                my_driver_h.seq_item_port.connect(my_seqr_h.seq_item_export);
        end
    endfunction

endclass: ahb_sagent
