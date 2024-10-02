
class ahb_scoreboard  extends uvm_scoreboard;

  `uvm_component_utils(ahb_scoreboard)

  ahb_trans seq;
  
  uvm_tlm_analysis_fifo#(ahb_trans) item_collected;

  int e_count=0;
  int count=0;
  byte mem[logic[0:32-1]];
  logic [31:0]data_out;
    int i=0;
  /*********************************************************************** Coverage ********************************************************************/
    // HTRANS types and HBURST coverage group
    covergroup htrans_hburst_types;
        HTRANS_SEQ: coverpoint seq.trans_type {
            bins seq = {SEQ};
        }
        HTRANS_BUSY: coverpoint seq.trans_type {
            bins busy = {BUSY};
        }
        HTRANS_IDLE: coverpoint seq.trans_type {
            bins idle = {IDLE};
        }
        HTRANS_NONSEQ: coverpoint seq.trans_type {
            bins nonseq= {NONSEQ};
        }

        //Burst types coverage points
        HBURST_SINGLE: coverpoint seq.burst_mode {
            bins single = {SINGLE};
        }
        HBURST_WRAP: coverpoint seq.burst_mode {
            bins wrap4 = {WRAP4};
            bins wrap8 = {WRAP8};
            bins wrap16 = {WRAP16};
        }
        HBURST_INCR: coverpoint seq.burst_mode {
            bins incr = {INCR};
            bins incr4 = {INCR4};
            bins incr8 = {INCR8};
            bins incr16 = {INCR16};
        }

        cross HBURST_INCR,HTRANS_BUSY {}

        cross HBURST_SINGLE,HTRANS_IDLE {}

        cross HBURST_SINGLE,HTRANS_NONSEQ {}

    endgroup

    // HSIZE types coverage group
    covergroup hsize_types;
        HSIZE_TYPES: coverpoint seq.trans_size {
            bins HSIZE_BYTE = {BYTE};
            bins HSIZE_HALFWORD = {HALFWORD};
            bins HSIZE_WORD= {WORD};
        }
    endgroup

    //1KB address coverage group 
    covergroup haddr;
        HADDR_TYPES: coverpoint seq.address {
            bins bounded_addr[] = {[0:1023]};
        }
    endgroup

    // read write coverage group
    covergroup hwrite;
        HWRITE_TYPES: coverpoint seq.read_write {
            bins read = {READ};
            bins write = {WRITE};
        }
    endgroup




    //slave responce coverage group 
    covergroup hresp;
        HRESP_TYPES: coverpoint seq.response {
            bins okay_resp = {OKAY};
            bins error_resp = {ERROR};
        }
    endgroup

    //slave ready coverage group 
    covergroup hready;
        HREADY_TYPES: coverpoint seq.ready {
            bins ready_1 = {1'b1};
        }
    endgroup 

    // trans follow by other one
    covergroup trans_follow ;
        // IDEL_TO_SEQ: coverpoint seq.trans_type{
        //     bins idel_to_seq = (IDLE => SEQ);
        // }

        // BUSY_TO_NONSEQ: coverpoint seq.trans_type{
        //     bins busy_to_nonseq = (BUSY => NONSEQ);
        // }
        IDEL_TO_NONSEQ: coverpoint seq.trans_type{
            bins idel_to_nonseq = (IDLE => NONSEQ);
        }
        BUSY_TO_SEQ: coverpoint seq.trans_type{
            bins idel_to_seq = (BUSY => SEQ);
        }
        NONSEQ_TO_SEQ: coverpoint seq.trans_type{
            bins nonseq_to_seq = (NONSEQ => SEQ);
        }
        SEQ_TO_NONESEQ: coverpoint seq.trans_type{
            bins seq_to_nonseq = (SEQ => NONSEQ);
        }
    endgroup




/*********************************************************************** End Coverage ********************************************************************/
  
  function new(string name,uvm_component parent);
    super.new(name,parent);
    `uvm_info("SCB_CLASS","Inside Constructor!",UVM_HIGH)
    htrans_hburst_types  = new();
    hsize_types  = new();
    haddr = new();
    hwrite = new();
    trans_follow = new();
    hresp = new();
    hready = new();
  endfunction:new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_collected=new("items_collected",this);
    `uvm_info("SCB_CLASS","Build Phase!",UVM_HIGH)
    
  endfunction:build_phase
  
  
  
  virtual task run_phase(uvm_phase phase);
    `uvm_info("SCB_CLASS","Run Phase!",UVM_HIGH)
    
    repeat (256) begin 
        mem[i] = i; 
        i++;
    end
    `uvm_info("SCB_CLASS","reference memory reset!!",UVM_HIGH)
    forever begin
      item_collected.get(seq);
    htrans_hburst_types.sample();
    hsize_types.sample();
    haddr.sample();
    hwrite.sample();
   
    trans_follow.sample();
    hresp.sample();
    hready.sample();
      count++;
      if ((seq.read_write == WRITE) && (seq.trans_type == NONSEQ || seq.trans_type == SEQ))  begin 
        if (seq.trans_size == WORD) begin
            mem[seq.address] = seq.write_data[7:0];
            mem[seq.address + 1] = seq.write_data[15:8];
            mem[seq.address + 2] = seq.write_data[23:16];
            mem[seq.address + 3] = seq.write_data[31:24];
        end

        else if (seq.trans_size == HALFWORD) begin
            if (!seq.address[1]) begin
                mem[seq.address] = seq.write_data[7:0];
                mem[seq.address + 1] = seq.write_data[15:8];
            end
            else begin
                mem[seq.address] = seq.write_data[23:16];
                mem[seq.address + 1] = seq.write_data[31:24];
            end 
        end

        else if (seq.trans_size == BYTE) begin
            if (seq.address[1:0] == 2'b00) 
                mem[seq.address] = seq.write_data[7:0];
            else if (seq.address[1:0] == 2'b01) 
                mem[seq.address] = seq.write_data[15:8];
            else if (seq.address[1:0] == 2'b10) 
                mem[seq.address] = seq.write_data[23:16];
            else                              
                mem[seq.address] = seq.write_data[31:24];
        end
        
     end
     else if ((seq.read_write == READ) && (seq.trans_type == NONSEQ || seq.trans_type == SEQ)) begin
        if (seq.trans_size == WORD)        
            data_out = {mem[seq.address + 3], mem[seq.address + 2], mem[seq.address + 1], mem[seq.address]};
        else if (seq.trans_size == HALFWORD) begin
            if (!seq.address[1])
                data_out = {16'b0, mem[seq.address + 1], mem[seq.address]};
            else
                data_out = {mem[seq.address + 1], mem[seq.address], 16'b0};
        end
        else if (seq.trans_size == BYTE)begin
            if (seq.address[1:0] == 2'b00)   
                data_out = {8'b0, 8'b0, 8'b0, mem[seq.address]};
            else if  (seq.address[1:0] == 2'b01)   
                data_out = {8'b0, 8'b0, mem[seq.address], 8'b0};
            else if  (seq.address[1:0] == 2'b10)   
                data_out = {8'b0, mem[seq.address], 8'b0, 8'b0};
            else                                     
                data_out = {mem[seq.address], 8'b0, 8'b0, 8'b0};
        end
        compare(seq.trans_size,seq.address,seq.read_data,data_out);
     end
    end
  endtask : run_phase

  function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        // string test_name = uvm_test_top.get_name();
        if(e_count) 
            begin
            $display("\n");
            $display("Total transactions: %d ", count);
            $display("\n");
            $display("Test Failed with %d Errors", e_count);
            $display("\n");
            $display("                              _ ._  _ , _ ._");
            $display("                            (_ ' ( `  )_  .__)");
            $display("                          ( (  (    )   `)  ) _)");
            $display("                         (__ (_   (_ . _) _) ,__)");
            $display("                             `~~`\ ' . /`~~`");
            $display("                             ,::: ;   ; :::,");
            $display("                            ':::::::::::::::'");
            $display(" ________________________________/_ __ \________________________________");
            $display("|                                                                       |");
            $display("|                               TEST FAILED                             |");
            $display("|_______________________________________________________________________|");
            $display("\n");
        end
        else begin
            $display("Total transactions: %d ", count);
            $display("\n");
            $display("                                  _\\|/_");
            $display("                                  (o o)");
            $display(" ______________________________oOO-{_}-OOo_______________________________");
            $display("|                                                                        |");
            $display("|                               TEST PASSED                              |");
            $display("|________________________________________________________________________|");
        end
        $display("\n");
        $display ("*************************************** Coverage Results **************************************");
        $display ("TRANS AND HBURST TYPES: %0.2f %%", htrans_hburst_types.get_inst_coverage());
        $display ("HSIZE TYPES: %0.2f %%", hsize_types.get_inst_coverage());
        $display ("ADDRESS ACCESS: %0.2f %%", haddr.get_inst_coverage());
        $display ("READ WRITE: %0.2f %%", hwrite.get_inst_coverage());
        $display ("TRANS FOLLOW BY OTHER: %0.2f %%", trans_follow.get_inst_coverage());
        $display ("HRESP: %0.2f %%", hresp.get_inst_coverage());
        $display ("HREADY TYPES: %0.2f %%", hready.get_inst_coverage());
        
        $display ("************************************** Coverage Results ENDS **********************************");
        $display("\n");


  	endfunction : report_phase

    task  compare(size_t t,input [31:0]addr,input [7:0] a_data,input [7:0] e_data);
        if(a_data===e_data)
        `uvm_info("PASSED",$sformatf("Pass Actual value=%h Expected value=%h",a_data,e_data),UVM_LOW)
        else begin
            `uvm_info("FAILED",$sformatf("Read type:%s Address:%0h Actual value=%h Expected value=%h",t.name(),addr,a_data,e_data),UVM_LOW)
            e_count++;
        end
    endtask 
    
endclass : ahb_scoreboard