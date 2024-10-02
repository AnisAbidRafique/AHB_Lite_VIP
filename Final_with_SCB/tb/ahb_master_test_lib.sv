class base_test extends uvm_test;
    `uvm_component_utils(base_test)
    ahb_tb tb;

    function new(string name="base_test",uvm_component parent);
        super.new(name,parent);

    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("base_test_CLASS","Build Phase!",UVM_HIGH)

        tb=ahb_tb::type_id::create("tb",this);

        uvm_config_wrapper::set(this, "tb.env.magent.mseqr_h.run_phase",
                                "default_sequence",
                                check_INCRX_RW_B1_seq::get_type());


        uvm_config_int::set( this, "*", "recording_detail", 1);

    endfunction

    function void check_phase(uvm_phase phase);
        check_config_usage();
        
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
        
    endfunction

    task run_phase(uvm_phase phase);
        uvm_objection obj = phase.get_objection();
        obj.set_drain_time(this, 10ns);
    endtask

endclass : base_test

class WR_LOCK_TEST extends base_test;
`uvm_component_utils(WR_LOCK_TEST)

    function new(string name="WR_LOCK_TEST",uvm_component parent);
        super.new(name,parent);

    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "tb.env.magent.mseqr_h.run_phase",
                                "default_sequence",
                                wr_lock_seq::get_type());
        `uvm_info("WR_LOCK_TEST","Build Phase!",UVM_HIGH)
    endfunction

endclass : WR_LOCK_TEST

class CLEAR_MEM_TEST extends base_test;
`uvm_component_utils(CLEAR_MEM_TEST)

    function new(string name="CLEAR_MEM_TEST",uvm_component parent);
        super.new(name,parent);

    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "tb.env.magent.mseqr_h.run_phase",
                                "default_sequence",
                                Clear_mem_seq::get_type());
        `uvm_info("CLEAR_MEM_TEST","Build Phase!",UVM_HIGH)
    endfunction

endclass : CLEAR_MEM_TEST

class WRITE_READ_TEST extends base_test;
`uvm_component_utils(WRITE_READ_TEST)

    function new(string name="WRITE_READ_TEST",uvm_component parent);
        super.new(name,parent);

    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "tb.env.magent.mseqr_h.run_phase",
                                "default_sequence",
                                read_write_seq::get_type());
        `uvm_info("WRITE_READ_TEST","Build Phase!",UVM_HIGH)
    endfunction

endclass : WRITE_READ_TEST

class SINGLE_BURST_TEST extends base_test;
`uvm_component_utils(SINGLE_BURST_TEST)

    function new(string name="SINGLE_BURST_TEST",uvm_component parent);
        super.new(name,parent);

    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "tb.env.magent.mseqr_h.run_phase",
                                "default_sequence",
                                single_burst_seq::get_type());
        `uvm_info("SINGLE_BURST_TEST","Build Phase!",UVM_HIGH)
    endfunction

endclass : SINGLE_BURST_TEST

class RANDOM_NOBURST_TEST extends base_test;
`uvm_component_utils(RANDOM_NOBURST_TEST)

    function new(string name="RANDOM_NOBURST_TEST",uvm_component parent);
        super.new(name,parent);

    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "tb.env.magent.mseqr_h.run_phase",
                                "default_sequence",
                                check_random::get_type());
        `uvm_info("RANDOM_NOBURST_TEST","Build Phase!",UVM_HIGH)
    endfunction

endclass : RANDOM_NOBURST_TEST

class WR_ALL_LOCATIONS_TEST extends base_test;
`uvm_component_utils(WR_ALL_LOCATIONS_TEST)

    function new(string name="WR_ALL_LOCATIONS_TEST",uvm_component parent);
        super.new(name,parent);

    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "tb.env.magent.mseqr_h.run_phase",
                                "default_sequence",
                                wr_all_loctaions_seq::get_type());
        `uvm_info("WR_ALL_LOCATIONS_TEST","Build Phase!",UVM_HIGH)
    endfunction

endclass : WR_ALL_LOCATIONS_TEST

class WRAP4_RANDOM_TEST extends base_test;
`uvm_component_utils(WRAP4_RANDOM_TEST)

    function new(string name="WRAP4_RANDOM_TEST",uvm_component parent);
        super.new(name,parent);

    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "tb.env.magent.mseqr_h.run_phase",
                                "default_sequence",
                                check_wrap4_seq::get_type());
        `uvm_info("WRAP4_RANDOM_TEST","Build Phase!",UVM_HIGH)
    endfunction

endclass : WRAP4_RANDOM_TEST

class WRAP8_RANDOM_TEST extends base_test;
`uvm_component_utils(WRAP8_RANDOM_TEST)

    function new(string name="WRAP8_RANDOM_TEST",uvm_component parent);
        super.new(name,parent);

    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "tb.env.magent.mseqr_h.run_phase",
                                "default_sequence",
                                check_wrap8_seq::get_type());
        `uvm_info("WRAP8_RANDOM_TEST","Build Phase!",UVM_HIGH)
    endfunction

endclass : WRAP8_RANDOM_TEST

class WRAP16_RANDOM_TEST extends base_test;
`uvm_component_utils(WRAP16_RANDOM_TEST)

    function new(string name="WRAP16_RANDOM_TEST",uvm_component parent);
        super.new(name,parent);

    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "tb.env.magent.mseqr_h.run_phase",
                                "default_sequence",
                                check_wrap16_seq::get_type());
        `uvm_info("WRAP16_RANDOM_TEST","Build Phase!",UVM_HIGH)
    endfunction

endclass : WRAP16_RANDOM_TEST

class INC4_RANDOM_TEST extends base_test;
`uvm_component_utils(INC4_RANDOM_TEST)

    function new(string name="INC4_RANDOM_TEST",uvm_component parent);
        super.new(name,parent);

    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "tb.env.magent.mseqr_h.run_phase",
                                "default_sequence",
                                check_inc4_seq::get_type());
        `uvm_info("INC4_RANDOM_TEST","Build Phase!",UVM_HIGH)
    endfunction

endclass : INC4_RANDOM_TEST

class INC8_RANDOM_TEST extends base_test;
`uvm_component_utils(INC8_RANDOM_TEST)

    function new(string name="INC8_RANDOM_TEST",uvm_component parent);
        super.new(name,parent);

    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "tb.env.magent.mseqr_h.run_phase",
                                "default_sequence",
                                check_inc8_seq::get_type());
        `uvm_info("INC8_RANDOM_TEST","Build Phase!",UVM_HIGH)
    endfunction

endclass : INC8_RANDOM_TEST

class INC16_RANDOM_TEST extends base_test;
`uvm_component_utils(INC16_RANDOM_TEST)

    function new(string name="INC16_RANDOM_TEST",uvm_component parent);
        super.new(name,parent);

    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "tb.env.magent.mseqr_h.run_phase",
                                "default_sequence",
                                check_inc16_seq::get_type());
        `uvm_info("INC16_RANDOM_TEST","Build Phase!",UVM_HIGH)
    endfunction

endclass : INC16_RANDOM_TEST

class INCRX_RANDOM_TEST extends base_test;
`uvm_component_utils(INCRX_RANDOM_TEST)

    function new(string name="INCRX_RANDOM_TEST",uvm_component parent);
        super.new(name,parent);

    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "tb.env.magent.mseqr_h.run_phase",
                                "default_sequence",
                                check_INCRX_RW_B1_seq::get_type());
        `uvm_info("INCRX_RANDOM_TEST","Build Phase!",UVM_HIGH)
    endfunction

endclass : INCRX_RANDOM_TEST

class UN_LEN_INCR_RANDOM_TEST extends base_test;
`uvm_component_utils(UN_LEN_INCR_RANDOM_TEST)

    function new(string name="UN_LEN_INCR_RANDOM_TEST",uvm_component parent);
        super.new(name,parent);

    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "tb.env.magent.mseqr_h.run_phase",
                                "default_sequence",
                                check_INCR_RW_B1_seq::get_type());
        `uvm_info("UN_LEN_INCR_RANDOM_TEST","Build Phase!",UVM_HIGH)
    endfunction

endclass : UN_LEN_INCR_RANDOM_TEST

class ALL_BURST_TEST extends base_test;
`uvm_component_utils(ALL_BURST_TEST)

    function new(string name="ALL_BURST_TEST",uvm_component parent);
        super.new(name,parent);

    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "tb.env.magent.mseqr_h.run_phase",
                                "default_sequence",
                                check_INCRX_all_RW_B1_seq::get_type());
        `uvm_info("ALL_BURST_TEST","Build Phase!",UVM_HIGH)
    endfunction

endclass : ALL_BURST_TEST

class REGRESSION_TEST extends base_test;
`uvm_component_utils(REGRESSION_TEST)

    function new(string name="REGRESSION_TEST",uvm_component parent);
        super.new(name,parent);

    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "tb.env.magent.mseqr_h.run_phase",
                                "default_sequence",
                                check_all_seqs::get_type());
        `uvm_info("REGRESSION_TEST","Build Phase!",UVM_HIGH)
    endfunction

endclass : REGRESSION_TEST

class SLAVE_ERROR_RESP_TEST extends base_test;
`uvm_component_utils(SLAVE_ERROR_RESP_TEST)

    function new(string name="SLAVE_ERROR_RESP_TEST",uvm_component parent);
        super.new(name,parent);

    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        uvm_config_wrapper::set(this, "*my_seqr_h.run_phase",
                                "default_sequence",
                                ahb_error_resp_check::get_type());

        `uvm_info("SLAVE_ERROR_RESP_TEST","Build Phase!",UVM_HIGH)
    endfunction

endclass : SLAVE_ERROR_RESP_TEST

class SLAVE_READY_TRANS_TEST extends base_test;
`uvm_component_utils(SLAVE_READY_TRANS_TEST)

    function new(string name="SLAVE_READY_TRANS_TEST",uvm_component parent);
        super.new(name,parent);

    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        uvm_config_wrapper::set(this, "*my_seqr_h.run_phase",
                                "default_sequence",
                                ahb_ready_trans::get_type());

        `uvm_info("SLAVE_READY_TRANS_TEST","Build Phase!",UVM_HIGH)
    endfunction

endclass : SLAVE_READY_TRANS_TEST

class SLAVE_RANDOM_TRANS_TEST extends base_test;
`uvm_component_utils(SLAVE_RANDOM_TRANS_TEST)

    function new(string name="SLAVE_RANDOM_TRANS_TEST",uvm_component parent);
        super.new(name,parent);

    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        uvm_config_wrapper::set(this, "*my_seqr_h.run_phase",
                                "default_sequence",
                                ahb_s_5_trans::get_type());

        `uvm_info("SLAVE_RANDOM_TRANS_TEST","Build Phase!",UVM_HIGH)
    endfunction

endclass : SLAVE_RANDOM_TRANS_TEST