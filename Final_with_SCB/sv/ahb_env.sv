class ahb_env extends uvm_env;
    `uvm_component_utils(ahb_env)
    ahb_magent magent;
    ahb_sagent sagent;
    // ahb_scoreboard scb;

    function new(string name = "ahb_env",uvm_component parent);
        super.new(name, parent);
        `uvm_info("ENV_CLASS","Inside Constructor!",UVM_HIGH)
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("ENV_CLASS","Build Phase!",UVM_HIGH)
    
        magent = ahb_magent::type_id::create("magent",this);
        sagent = ahb_sagent::type_id::create("sagent",this);
        //scb = ahb_scoreboard::type_id::create("scb",this);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "*magent*", "is_active", UVM_ACTIVE);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "*sagent*", "is_active", UVM_PASSIVE);
        
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info(this.get_full_name(), "ahb_env", UVM_HIGH)
        
    endfunction

    function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("ENV_CLASS","Connect Phase!",UVM_HIGH)
    //magent.monitor_h.item_collected_port.connect(scb.item_collected.analysis_export);
  
  endfunction: connect_phase
endclass 