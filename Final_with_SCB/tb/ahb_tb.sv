class ahb_tb extends uvm_env;
`uvm_component_utils(ahb_tb)
ahb_env env;
ahb_scoreboard scb;

    function new(string name="ahb_tb",uvm_component parent);
        super.new(name,parent);

    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("ahb_tb_CLASS","Build Phase!",UVM_HIGH)
        env=ahb_env::type_id::create("env",this);
        scb = ahb_scoreboard::type_id::create("scb",this);

    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info(this.get_full_name(), "testbench", UVM_HIGH)
        
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("ENV_CLASS","Connect Phase!",UVM_HIGH)
        env.magent.monitor_h.item_collected_port.connect(scb.item_collected.analysis_export);
  
    endfunction: connect_phase


endclass 