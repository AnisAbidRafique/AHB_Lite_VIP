class ahb_magent extends uvm_agent;

    // `uvm_component_utils(ahb_magent)

     `uvm_component_utils_begin(ahb_magent)
    `uvm_field_enum(uvm_active_passive_enum,is_active,UVM_ALL_ON)
    `uvm_component_utils_end   

    ahb_mdriver mdriver_h;
    ahb_monitor monitor_h;
    ahb_mseqr mseqr_h;

    // uvm_analysis_port#(ahb_mtrans) agent_ap;


    uvm_active_passive_enum is_active = UVM_ACTIVE;

    //Constructor
    function new(string name = "ahb_magent", uvm_component parent);
        super.new(name, parent);
        // agent_ap = new("agent_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active))
        begin
                `uvm_fatal(get_full_name(), "Cannot get AGENT-CONFIG from configuration database!")
        end

        super.build_phase(phase);

        monitor_h = ahb_monitor::type_id::create("monitor_h", this);
        if(is_active == UVM_ACTIVE)
        begin
                mdriver_h = ahb_mdriver::type_id::create("mdriver_h", this);
                mseqr_h = ahb_mseqr::type_id::create("mseqr_h", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        // monitor_h.item_collected_port.connect(agent_ap);

        if(is_active == UVM_ACTIVE)
        begin
                mdriver_h.seq_item_port.connect(mseqr_h.seq_item_export);
        end
    endfunction

endclass: ahb_magent
