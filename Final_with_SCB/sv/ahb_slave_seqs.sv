class ahb_slave_base_seq extends uvm_sequence #(ahb_trans);

  // Required macro for sequences automation
  `uvm_object_utils(ahb_slave_base_seq)

  // Constructor
  function new(string name="ahb_slave_base_seq");
    super.new(name);
  endfunction

  task pre_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body

  task post_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body

endclass : ahb_slave_base_seq

class ahb_s_5_trans extends ahb_slave_base_seq;
  
  // Required macro for sequences automation
  `uvm_object_utils(ahb_s_5_trans)

  // Constructor
  function new(string name="ahb_s_5_trans");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(), "Executing ahb_s_5_trans sequence", UVM_LOW)
     repeat(5)
      `uvm_do(req)
  endtask
endclass : ahb_s_5_trans

class ahb_ready_trans extends ahb_slave_base_seq;
  
  // Required macro for sequences automation
  `uvm_object_utils(ahb_ready_trans)

  // Constructor
  function new(string name="ahb_ready_trans");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(), "Executing ahb_ready_trans sequence", UVM_LOW)
     repeat(7)
      `uvm_do_with(req,
      {
        ready    == 0;
        response == 0;
      })
      `uvm_do_with(req,
      {
        ready    == 1;
        response == 0;
      })
  endtask
endclass : ahb_ready_trans

class ahb_error_resp_check extends ahb_slave_base_seq;
  
  // Required macro for sequences automation
  `uvm_object_utils(ahb_error_resp_check)

  // Constructor
  function new(string name="ahb_error_resp_check");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(), "Executing ahb_error_resp_check sequence", UVM_LOW)
      `uvm_do_with(req,
      {
        ready    == 0;
        response == 1; //ERROR
      })
      `uvm_do_with(req,
      {
        ready    == 1;
        response == 1; //ERROR
      })
      `uvm_do_with(req,
      {
        ready    == 1;
        response == 0; //OKAY
      })
  endtask
endclass : ahb_error_resp_check