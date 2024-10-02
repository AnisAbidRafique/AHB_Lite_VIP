class ahb_master_base_seq extends uvm_sequence #(ahb_trans);

  // Required macro for sequences automation
  `uvm_object_utils(ahb_master_base_seq)

  // Constructor
  function new(string name="ahb_master_base_seq");
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

endclass : ahb_master_base_seq

class write_seq extends ahb_master_base_seq;
  // Required macro for sequences automation
  `uvm_object_utils(write_seq)

  // Constructor
  function new(string name="write_seq");
    super.new(name);
  endfunction

  rand transfer_t my_trans_type;
  rand [31:0]addr;
  rand size_t size;
  rand burst_t burst_m;
  rand bit [31:0]data;
  rand bit [3:0]pro_t;
  rand lock_t lock_m;

  constraint addr_size {
                                addr < 1024;
                        }

  constraint h_size {
                                  size < WORDx2;
                          }
  //only Data access 
  constraint h_pro_t {
                                  pro_t[0] == 1'b1;
                          }

  virtual task body();
    `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)
    `uvm_do_with(req, 
        { req.trans_type == my_trans_type;
          req.address == addr;
          req.trans_size == size;
          req.burst_mode == burst_m; 
          req.read_write == 1;
          req.HPROT == pro_t;
          req.lockmode == lock_m;
          req.write_data == data;})
    `uvm_info(get_type_name(), $sformatf("WRITE ADDRESS:%0d  DATA:%h", addr, data), UVM_MEDIUM)
  endtask : body

endclass : write_seq 

class random_seq extends ahb_master_base_seq;
  // Required macro for sequences automation
  `uvm_object_utils(random_seq)
  // Constructor
  function new(string name="random_seq");
    super.new(name);
  endfunction

  rand rw_t rw;
  rand transfer_t my_trans_type;
  rand [31:0]addr;
  rand size_t size;
  rand burst_t burst_m;
  rand bit [31:0]data;
  rand bit [3:0]pro_t;
  rand lock_t lock_m;
  

  constraint addr_size {
                                addr < 1024;
                        }

  constraint h_size {
                                  size < WORDx2;
                          }

  constraint addr_boun {
                                  if(size == WORD){
                                    addr[1:0] == 2'b00;
                                  }
                                  if(size == HALFWORD){
                                    addr[0] == 1'b0;
                                  }
                          }

  //only Data access 
  constraint h_pro_t {
                                  pro_t[0] == 1'b1;
                          }


  constraint burst_single {
                                  burst_m == SINGLE;
                          }

  constraint nonseq_idle {
                                  if(burst_m == SINGLE){
                                          my_trans_type inside {IDLE, NONSEQ};
                                  }
                          }

  virtual task body();
    `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)

    `uvm_do_with(req, 
      { req.trans_type == my_trans_type;
        req.address == addr;
        req.trans_size == size;
        req.burst_mode == burst_m; 
        req.read_write == rw;
        req.HPROT == pro_t;
        req.lockmode == lock_m;
        req.write_data == data;})

      // `uvm_info("SEQ TRANS",$sformatf("Packet is \n%s", req.sprint()),UVM_LOW)
    
    endtask : body

endclass : random_seq 

class check_random extends ahb_master_base_seq;
  `uvm_object_utils(check_random)
  random_seq ran_seq;

  // Constructor
  function new(string name="check_random");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)
    repeat(2000) begin
    `uvm_do(ran_seq);
  end
  endtask
  

endclass : check_random


class read_seq extends ahb_master_base_seq;
  // Required macro for sequences automation
  `uvm_object_utils(read_seq)

  // Constructor
  function new(string name="read_seq");
    super.new(name);
  endfunction

  rand transfer_t my_trans_type;
  rand [31:0] addr;
  rand size_t size;
  rand burst_t burst_m;
  rand bit [3:0]pro_t;
  rand lock_t lock_m;

  bit [31:0]data;

  constraint addr_size {
                                addr < 1024;
                        }

  constraint h_size {
                                  size < WORDx2;
                          }
  //only Data access 
  constraint h_pro_t {
                                  pro_t[0] == 1'b1;
                          }

  virtual task body();
    `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)
    `uvm_do_with(req, 
        { req.trans_type == my_trans_type;
          req.address == addr;
          req.trans_size == size;
          req.burst_mode == burst_m; 
          req.read_write == 0;
          req.HPROT == pro_t;
          req.lockmode == lock_m;
          req.write_data == 0;})
    data = req.read_data;
    `uvm_info(get_type_name(), $sformatf("READ ADDRESS:%0d  DATA:%h", addr, data), UVM_MEDIUM)
  endtask : body

endclass : read_seq 

//write and read with lock
class wr_lock_seq extends ahb_master_base_seq;
  // Required macro for sequences automation
  `uvm_object_utils(wr_lock_seq)

  // Constructor
  function new(string name="wr_lock_seq");
    super.new(name);
  endfunction

  write_seq w_seq;
  read_seq r_seq;

  virtual task body();
    `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)
    `uvm_do_with(w_seq, 
        { my_trans_type == NONSEQ;
          lock_m == LOCK;
          addr == 'h34;
          size == WORD;
          data == 'h34;
          burst_m == SINGLE;})

    //  `uvm_info(get_type_name(), $sformatf("WRITE ADDRESS:%0d  DATA:%h", addr, data), UVM_MEDIUM)

    `uvm_do_with(r_seq, 
        { my_trans_type == NONSEQ;
          addr == 'h34;
          lock_m == LOCK;
          size == WORD;
          burst_m == SINGLE;})

    `uvm_do_with(w_seq, 
        { my_trans_type == IDLE;
          lock_m == UNLOCK;
          addr == 'h34;
          size == WORD;
          data == 'h34;
          burst_m == SINGLE;})

  endtask : body

endclass : wr_lock_seq 

class single_burst_seq extends ahb_master_base_seq;
  // Required macro for sequences automation
  `uvm_object_utils(single_burst_seq)

  // Constructor
  function new(string name="single_burst_seq");
    super.new(name);
  endfunction

  write_seq w_seq;

  virtual task body();
    `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)
    repeat(5) begin
      `uvm_do_with(w_seq, 
        { my_trans_type == NONSEQ;
          lock_m == UNLOCK;
          addr == 'h20;
          // size == WORD;
          data == 'h20;
          burst_m == SINGLE;})
    //  `uvm_info(get_type_name(), $sformatf("WRITE ADDRESS:%0d  DATA:%h", addr, data), UVM_MEDIUM)
    `uvm_do_with(w_seq, 
        { my_trans_type == IDLE;
          lock_m == UNLOCK;
          addr == 'h34;
          // size == WORD;
          data == 'h20;
          burst_m == SINGLE;})
    end
    

  endtask : body

endclass : single_burst_seq 


class WRAP4_rw_seq extends ahb_master_base_seq;

  // Required macro for sequences automation
  `uvm_object_utils(WRAP4_rw_seq)
  write_seq w_myseq;
  read_seq r_myseq;
  rand size_t wrap_sizes;
  rand rw_t rw;
  // rand bit [31:0]data_in[3:0];

  constraint wrap4_size {
                                  wrap_sizes < WORDx2;
                          }

  // Constructor
  function new(string name="WRAP4_rw_seq");
    super.new(name);
  endfunction

  bit      [31:0] myaddr;
  rand bit [31:0] initial_addr;


  virtual task body();
    // `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)
    if (rw == WRITE) 
      begin
        `uvm_do_with(w_myseq, 
          { my_trans_type == NONSEQ;
            data == initial_addr;
            addr == initial_addr;
            size == wrap_sizes;
            burst_m == WRAP4;})
            myaddr = w_myseq.addr;
      end
    // $display("transcation type  %d",w_myseq.trans_type);
    else 
      begin
        `uvm_do_with(r_myseq, 
          { my_trans_type == NONSEQ;
            addr == initial_addr;
            size == wrap_sizes;
            burst_m == WRAP4;})
            myaddr = r_myseq.addr;
      end

    repeat(3)
      begin
        case (wrap_sizes)
        BYTE     : myaddr = {myaddr[31:2],myaddr[1:0]+1'b1};      
        HALFWORD : myaddr = {myaddr[31:3],myaddr[2:1]+1'b1,1'b0}; 
        WORD     : myaddr = {myaddr[31:4],myaddr[3:2]+1'b1,2'b00};
        WORDx2   : myaddr = {myaddr[31:5],myaddr[4:3]+1'b1,3'b000};
        WORDx4   : myaddr = {myaddr[31:6],myaddr[5:4]+1'b1,4'b0000};
        WORDx8   : myaddr = {myaddr[31:7],myaddr[6:5]+1'b1,5'b00000};
        WORDx16  : myaddr = {myaddr[31:8],myaddr[7:6]+1'b1,6'b000000};
        WORDx32  : myaddr = {myaddr[31:9],myaddr[8:7]+1'b1,7'b0000000};
        default : $display("The size is not in the range !!!");
        endcase

        if(rw)
            `uvm_do_with(w_myseq, 
          { my_trans_type == SEQ;
            data == myaddr;
            addr == myaddr;
            size == wrap_sizes;
            lock_m == 1'b0;
            burst_m == WRAP4;})

        else
          `uvm_do_with(r_myseq, 
        { my_trans_type == SEQ;
          addr == myaddr;
          lock_m == 1'b0;
          size == wrap_sizes;
          burst_m == WRAP4;})
      end
   
    // `uvm_info(get_type_name(), $sformatf("WRITE ADDRESS:%0d  DATA:%h", addr, data), UVM_MEDIUM)
  endtask : body

endclass : WRAP4_rw_seq

class check_wrap4_seq extends ahb_master_base_seq;
  
  // Required macro for sequences automation
  `uvm_object_utils(check_wrap4_seq)
  WRAP4_rw_seq check_halfword;
  WRAP4_rw_seq check_halfword_1;
  // Constructor
  function new(string name="check_wrap4_seq");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(), "Executing check_wrap4_seq sequence", UVM_LOW)
    repeat(25) begin
      `uvm_do_with(check_halfword, 
        { initial_addr == 'h34;
          rw == WRITE;
          // wrap_sizes   == WORD;
          })

      `uvm_do_with(check_halfword_1, 
          { initial_addr == 'h34;
            rw == READ;
            wrap_sizes   == check_halfword.wrap_sizes;
            })
    end
    
  endtask
endclass : check_wrap4_seq

//WRAP8_rw_seq

class WRAP8_rw_seq extends ahb_master_base_seq;

  // Required macro for sequences automation
  `uvm_object_utils(WRAP8_rw_seq)
  write_seq w_myseq;
  read_seq r_myseq;
  rand size_t wrap_sizes;
  rand rw_t rw;
  // rand bit [31:0]data_in[3:0];
  constraint wrap8_size {
                                  wrap_sizes < WORDx2;
                          }
  // Constructor
  function new(string name="WRAP8_rw_seq");
    super.new(name);
  endfunction

  bit      [31:0] myaddr;
  rand bit [31:0] initial_addr;


  virtual task body();
    // `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)
    if (rw == WRITE) 
      begin
        `uvm_do_with(w_myseq, 
          { my_trans_type == NONSEQ;
            data == initial_addr;
            addr == initial_addr;
            lock_m == 1'b0;
            size == wrap_sizes;
            burst_m == WRAP8;})
            myaddr = w_myseq.addr;
      end
    // $display("transcation type  %d",w_myseq.trans_type);
    else 
      begin
        `uvm_do_with(r_myseq, 
          { my_trans_type == NONSEQ;
            addr == initial_addr;
            lock_m == 1'b0;
            size == wrap_sizes;
            burst_m == WRAP8;})
            myaddr = r_myseq.addr;
      end

    repeat(7)
      begin
        case (wrap_sizes)
        BYTE     : myaddr = {myaddr[31:3],myaddr[2:0]+1'b1};      
        HALFWORD : myaddr = {myaddr[31:4],myaddr[3:1]+1'b1,1'b0}; 
        WORD     : myaddr = {myaddr[31:5],myaddr[4:2]+1'b1,2'b00};
        WORDx2   : myaddr = {myaddr[31:6],myaddr[5:3]+1'b1,3'b000};
        WORDx4   : myaddr = {myaddr[31:7],myaddr[6:4]+1'b1,4'b0000};
        WORDx8   : myaddr = {myaddr[31:8],myaddr[7:5]+1'b1,5'b00000};
        WORDx16  : myaddr = {myaddr[31:9],myaddr[8:6]+1'b1,6'b000000};
        WORDx32  : myaddr = {myaddr[31:10],myaddr[9:7]+1'b1,7'b0000000};
        default : $display("The size is not in the range !!!");
        endcase

        if(rw)
            `uvm_do_with(w_myseq, 
          { my_trans_type == SEQ;
            data == myaddr;
            addr == myaddr;
            size == wrap_sizes;
            lock_m == 1'b0;
            burst_m == WRAP8;})

        else
          `uvm_do_with(r_myseq, 
        { my_trans_type == SEQ;
          addr == myaddr;
          lock_m == 1'b0;
          size == wrap_sizes;
          burst_m == WRAP8;})
      end
   
    // `uvm_info(get_type_name(), $sformatf("WRITE ADDRESS:%0d  DATA:%h", addr, data), UVM_MEDIUM)
  endtask : body

endclass : WRAP8_rw_seq

class check_wrap8_seq extends ahb_master_base_seq;
  
  // Required macro for sequences automation
  `uvm_object_utils(check_wrap8_seq)
  WRAP8_rw_seq check_halfword;
  WRAP8_rw_seq check_halfword_1;
  // Constructor
  function new(string name="check_wrap8_seq");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(), "Executing check_wrap8_seq sequence", UVM_LOW)
    repeat(25) begin
      `uvm_do_with(check_halfword, 
        { initial_addr == 'h34;
          rw == WRITE;
          // wrap_sizes   == WORD;
          })

      `uvm_do_with(check_halfword_1, 
          { initial_addr == 'h34;
            rw == READ;
            wrap_sizes   == check_halfword.wrap_sizes;
            })
    end
    
  endtask
endclass : check_wrap8_seq

//WRAP16_rw_seq

class WRAP16_rw_seq extends ahb_master_base_seq;

  // Required macro for sequences automation
  `uvm_object_utils(WRAP16_rw_seq)
  write_seq w_myseq;
  read_seq r_myseq;
  rand size_t wrap_sizes;
  rand rw_t rw;
  // rand bit [31:0]data_in[3:0];
  constraint wrap16_size {
                                  wrap_sizes < WORDx2;
                          }
  // Constructor
  function new(string name="WRAP16_rw_seq");
    super.new(name);
  endfunction

  bit      [31:0] myaddr;
  rand bit [31:0] initial_addr;


  virtual task body();
    // `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)
    if (rw == WRITE) 
      begin
        `uvm_do_with(w_myseq, 
          { my_trans_type == NONSEQ;
            data == initial_addr;
            addr == initial_addr;
            size == wrap_sizes;
            lock_m == 1'b0;
            burst_m == WRAP16;})
            myaddr = w_myseq.addr;
      end
    // $display("transcation type  %d",w_myseq.trans_type);
    else 
      begin
        `uvm_do_with(r_myseq, 
          { my_trans_type == NONSEQ;
            addr == initial_addr;
            size == wrap_sizes;
            lock_m == 1'b0;
            burst_m == WRAP16;})
            myaddr = r_myseq.addr;
      end

    repeat(15)
      begin
        case (wrap_sizes)
        BYTE     : myaddr = {myaddr[31:4],myaddr[3:0]+1'b1};      
        HALFWORD : myaddr = {myaddr[31:5],myaddr[4:1]+1'b1,1'b0}; 
        WORD     : myaddr = {myaddr[31:6],myaddr[5:2]+1'b1,2'b00};
        WORDx2   : myaddr = {myaddr[31:7],myaddr[6:3]+1'b1,3'b000};
        WORDx4   : myaddr = {myaddr[31:8],myaddr[7:4]+1'b1,4'b0000};
        WORDx8   : myaddr = {myaddr[31:9],myaddr[8:5]+1'b1,5'b00000};
        WORDx16  : myaddr = {myaddr[31:10],myaddr[9:6]+1'b1,6'b000000};
        WORDx32  : myaddr = {myaddr[31:11],myaddr[10:7]+1'b1,7'b0000000};
        default : $display("The size is not in the range !!!");
        endcase

        if(rw)
            `uvm_do_with(w_myseq, 
          { my_trans_type == SEQ;
            data == myaddr;
            addr == myaddr;
            size == wrap_sizes;
            lock_m == 1'b0;
            burst_m == WRAP16;})

        else
          `uvm_do_with(r_myseq, 
        { my_trans_type == SEQ;
          addr == myaddr;
          lock_m == 1'b0;
          size == wrap_sizes;
          burst_m == WRAP16;})
      end
   
    // `uvm_info(get_type_name(), $sformatf("WRITE ADDRESS:%0d  DATA:%h", addr, data), UVM_MEDIUM)
  endtask : body

endclass : WRAP16_rw_seq

class check_wrap16_seq extends ahb_master_base_seq;
  
  // Required macro for sequences automation
  `uvm_object_utils(check_wrap16_seq)
  WRAP16_rw_seq check_halfword;
  WRAP16_rw_seq check_halfword_1;
  // Constructor
  function new(string name="check_wrap16_seq");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(), "Executing check_wrap16_seq sequence", UVM_LOW)
    repeat(25) begin
      `uvm_do_with(check_halfword, 
        { initial_addr == 'h34;
          rw == WRITE;
          // wrap_sizes   == WORD;
          })

      `uvm_do_with(check_halfword_1, 
          { initial_addr == 'h34;
            rw == READ;
            wrap_sizes   == check_halfword.wrap_sizes;
            })
    end
    
  endtask
endclass : check_wrap16_seq

class ahb_m_10_trans extends ahb_master_base_seq;
  
  // Required macro for sequences automation
  `uvm_object_utils(ahb_m_10_trans)
  write_seq w;
  // Constructor
  function new(string name="ahb_m_10_trans");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(), "Executing ahb_m_10_trans sequence", UVM_LOW)
     repeat(10) begin
      `uvm_do(w)
      // `uvm_info("SEQ TRANS",$sformatf("Packet is \n%s", w.sprint()),UVM_LOW)
     end
  endtask
endclass

class INC4_rw_seq extends ahb_master_base_seq;

  // Required macro for sequences automation
  `uvm_object_utils(INC4_rw_seq)

  write_seq w_myseq;
  read_seq r_myseq;
  rand size_t wrap_sizes;
  rand rw_t rw;
  // rand bit [31:0]data_in[3:0];
  constraint inc4_size {
                                  wrap_sizes < WORDx2;
                          }

  // Constructor
  function new(string name="INC4_rw_seq");
    super.new(name);
  endfunction

  bit      [31:0] myaddr;
  rand bit [31:0] initial_addr;


  virtual task body();
    // `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)
    case (wrap_sizes)

        BYTE     : initial_addr = initial_addr;                     //byte
        HALFWORD : initial_addr = {initial_addr[31:1], 1'b0};       //half word
        WORD     : initial_addr = {initial_addr[31:2], 2'b00};      //word
        WORDx2   : initial_addr = {initial_addr[31:3], 3'b000};     //2words
        WORDx4   : initial_addr = {initial_addr[31:4], 4'b0000};    //4words
        WORDx8   : initial_addr = {initial_addr[31:5], 5'b00000};   //8words
        WORDx16  : initial_addr = {initial_addr[31:6], 6'b000000};  //16words
        WORDx32  : initial_addr = {initial_addr[31:7], 7'b0000000}; //32words
        default  : $display("The Hbus size is not in the range !!!");
        endcase

    if (rw == WRITE) 
      begin
       `uvm_do_with(w_myseq, 
        { my_trans_type == NONSEQ;
          lock_m == 1'b0;
          data == initial_addr;
          addr == initial_addr;
          size == wrap_sizes;
          burst_m == INCR4;})

      myaddr = w_myseq.addr;
      end
    // $display("transcation type  %d",w_myseq.trans_type);
    else
      begin
          `uvm_do_with(r_myseq, 
          { my_trans_type == NONSEQ;
            addr == initial_addr;
            lock_m == 1'b0;
            size == wrap_sizes;
            burst_m == INCR4;})

      myaddr = r_myseq.addr;
      end

    repeat(3)
      begin
        case (wrap_sizes)

          BYTE     : myaddr += 1;   //byte
          HALFWORD : myaddr += 2;   //half word
          WORD     : myaddr += 4;   //word
          WORDx2   : myaddr += 8;   //2words
          WORDx4   : myaddr += 16;  //4words
          WORDx8   : myaddr += 32;  //8words
          WORDx16  : myaddr += 64;  //16words
          WORDx32  : myaddr += 128; //32words
          default  : $display("The size is not in the range !!!");
        endcase
 //rw ? w_myseq : r_myseq

        if(rw) //write
              `uvm_do_with( w_myseq, 
              { my_trans_type == SEQ;
                lock_m == 1'b0;
                data == myaddr;
                addr == myaddr;
                size == wrap_sizes;
                burst_m == INCR4;})
        else  //read
              `uvm_do_with(r_myseq,
              { my_trans_type == SEQ;
                lock_m == 1'b0;
                addr == myaddr;
                size == wrap_sizes;
                burst_m == INCR4;})
      end
   
  endtask : body

endclass : INC4_rw_seq

class check_inc4_seq extends ahb_master_base_seq;
  
  // Required macro for sequences automation
  `uvm_object_utils(check_inc4_seq)
  INC4_rw_seq seq;
  INC4_rw_seq seq_1;
  // Constructor
  function new(string name="check_inc4_seq");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(), "Executing check_inc4_seq sequence", UVM_LOW)
    repeat(5) begin
      `uvm_do_with(seq, 
        { initial_addr == 'h34;
          rw == WRITE;
          // data_in == {32'h0001, 32'h0002, 32'h0003, 32'h0004};
          // wrap_sizes   == WORD;
          })
      `uvm_do_with(seq_1, 
          { initial_addr == 'h34;
            rw == READ;
            wrap_sizes   == seq.wrap_sizes;
            })
    end
    
  endtask
endclass : check_inc4_seq

//INC8_rw_seq

class INC8_rw_seq extends ahb_master_base_seq;

  // Required macro for sequences automation
  `uvm_object_utils(INC8_rw_seq)

  write_seq w_myseq;
  read_seq r_myseq;
  rand size_t wrap_sizes;
  rand rw_t rw;
  // rand bit [31:0]data_in[3:0];
  constraint inc8_size {
                                  wrap_sizes < WORDx2;
                          }
  // Constructor
  function new(string name="INC8_rw_seq");
    super.new(name);
  endfunction

  bit      [31:0] myaddr;
  rand bit [31:0] initial_addr;


  virtual task body();
    // `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)
    case (wrap_sizes)

        BYTE     : initial_addr = initial_addr;                     //byte
        HALFWORD : initial_addr = {initial_addr[31:1], 1'b0};       //half word
        WORD     : initial_addr = {initial_addr[31:2], 2'b00};      //word
        WORDx2   : initial_addr = {initial_addr[31:3], 3'b000};     //2words
        WORDx4   : initial_addr = {initial_addr[31:4], 4'b0000};    //4words
        WORDx8   : initial_addr = {initial_addr[31:5], 5'b00000};   //8words
        WORDx16  : initial_addr = {initial_addr[31:6], 6'b000000};  //16words
        WORDx32  : initial_addr = {initial_addr[31:7], 7'b0000000}; //32words
        default  : $display("The Hbus size is not in the range !!!");
        endcase

    if (rw == WRITE) 
      begin
       `uvm_do_with(w_myseq, 
        { my_trans_type == NONSEQ;
          data == initial_addr;
          addr == initial_addr;
          lock_m == 1'b0;
          size == wrap_sizes;
          burst_m == INCR8;})

      myaddr = w_myseq.addr;
      end
    // $display("transcation type  %d",w_myseq.trans_type);
    else
      begin
          `uvm_do_with(r_myseq, 
          { my_trans_type == NONSEQ;
            addr == initial_addr;
            size == wrap_sizes;
            lock_m == 1'b0;
            burst_m == INCR8;})

      myaddr = r_myseq.addr;
      end

    repeat(7)
      begin
        case (wrap_sizes)

          BYTE     : myaddr += 1;   //byte
          HALFWORD : myaddr += 2;   //half word
          WORD     : myaddr += 4;   //word
          WORDx2   : myaddr += 8;   //2words
          WORDx4   : myaddr += 16;  //4words
          WORDx8   : myaddr += 32;  //8words
          WORDx16  : myaddr += 64;  //16words
          WORDx32  : myaddr += 128; //32words
          default  : $display("The size is not in the range !!!");
        endcase
 //rw ? w_myseq : r_myseq

        if(rw) //write
              `uvm_do_with( w_myseq, 
              { my_trans_type == SEQ;
                data == myaddr;
                addr == myaddr;
                lock_m == 1'b0;
                size == wrap_sizes;
                burst_m == INCR8;})
        else  //read
              `uvm_do_with(r_myseq,
              { my_trans_type == SEQ;
                addr == myaddr;
                lock_m == 1'b0;
                size == wrap_sizes;
                burst_m == INCR8;})
      end
   
  endtask : body

endclass : INC8_rw_seq

class check_inc8_seq extends ahb_master_base_seq;
  
  // Required macro for sequences automation
  `uvm_object_utils(check_inc8_seq)
  INC8_rw_seq seq;
  INC8_rw_seq seq_1;
  // Constructor
  function new(string name="check_inc8_seq");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(), "Executing check_inc8_seq sequence", UVM_LOW)
    repeat(5) begin
      `uvm_do_with(seq, 
        { initial_addr == 'h34;
          rw == WRITE;
          //data_in == {32'h0001, 32'h0002, 32'h0003, 32'h0004};
          // wrap_sizes   == HALFWORD;
          })
      `uvm_do_with(seq_1, 
          { initial_addr == 'h34;
            rw == READ;
            wrap_sizes   == seq.wrap_sizes;
            })
    end
    
  endtask
endclass : check_inc8_seq

//INC16_rw_seq

class INC16_rw_seq extends ahb_master_base_seq;

  // Required macro for sequences automation
  `uvm_object_utils(INC16_rw_seq)

  write_seq w_myseq;
  read_seq r_myseq;
  rand size_t wrap_sizes;
  rand rw_t rw;
  // rand bit [31:0]data_in[3:0];
  constraint inc16_size {
                                  wrap_sizes < WORDx2;
                          }
  // Constructor
  function new(string name="INC16_rw_seq");
    super.new(name);
  endfunction

  bit      [31:0] myaddr;
  rand bit [31:0] initial_addr;


  virtual task body();
    // `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)
    case (wrap_sizes)

        BYTE     : initial_addr = initial_addr;                     //byte
        HALFWORD : initial_addr = {initial_addr[31:1], 1'b0};       //half word
        WORD     : initial_addr = {initial_addr[31:2], 2'b00};      //word
        WORDx2   : initial_addr = {initial_addr[31:3], 3'b000};     //2words
        WORDx4   : initial_addr = {initial_addr[31:4], 4'b0000};    //4words
        WORDx8   : initial_addr = {initial_addr[31:5], 5'b00000};   //8words
        WORDx16  : initial_addr = {initial_addr[31:6], 6'b000000};  //16words
        WORDx32  : initial_addr = {initial_addr[31:7], 7'b0000000}; //32words
        default  : $display("The Hbus size is not in the range !!!");
        endcase

    if (rw == WRITE) 
      begin
       `uvm_do_with(w_myseq, 
        { my_trans_type == NONSEQ;
          data == initial_addr;
          lock_m == 1'b0;
          addr == initial_addr;
          size == wrap_sizes;
          burst_m == INCR16;})

      myaddr = w_myseq.addr;
      end
    // $display("transcation type  %d",w_myseq.trans_type);
    else
      begin
          `uvm_do_with(r_myseq, 
          { my_trans_type == NONSEQ;
            addr == initial_addr;
            lock_m == 1'b0;
            size == wrap_sizes;
            burst_m == INCR16;})

      myaddr = r_myseq.addr;
      end

    repeat(15)
      begin
        case (wrap_sizes)

          BYTE     : myaddr += 1;   //byte
          HALFWORD : myaddr += 2;   //half word
          WORD     : myaddr += 4;   //word
          WORDx2   : myaddr += 8;   //2words
          WORDx4   : myaddr += 16;  //4words
          WORDx8   : myaddr += 32;  //8words
          WORDx16  : myaddr += 64;  //16words
          WORDx32  : myaddr += 128; //32words
          default  : $display("The size is not in the range !!!");
        endcase
 //rw ? w_myseq : r_myseq

        if(rw) //write
              `uvm_do_with( w_myseq, 
              { my_trans_type == SEQ;
                data == myaddr;
                addr == myaddr;
                lock_m == 1'b0;
                size == wrap_sizes;
                burst_m == INCR16;})
        else  //read
              `uvm_do_with(r_myseq,
              { my_trans_type == SEQ;
                addr == myaddr;
                lock_m == 1'b0;
                size == wrap_sizes;
                burst_m == INCR16;})
      end
   
  endtask : body

endclass : INC16_rw_seq

class check_inc16_seq extends ahb_master_base_seq;
  
  // Required macro for sequences automation
  `uvm_object_utils(check_inc16_seq)
  INC16_rw_seq seq;
  INC16_rw_seq seq_1;
  // Constructor
  function new(string name="check_inc16_seq");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(), "Executing check_inc16_seq sequence", UVM_LOW)
    repeat(5) begin
      `uvm_do_with(seq, 
        { initial_addr == 'h30;
          rw == WRITE;
          //data_in == {32'h0001, 32'h0002, 32'h0003, 32'h0004};
          // wrap_sizes   == HALFWORD;
          })
      `uvm_do_with(seq_1, 
          { initial_addr == 'h30;
            rw == READ;
            wrap_sizes   == seq.wrap_sizes;
            })
    end
    
  endtask
endclass : check_inc16_seq


class  INCRX_RW_B1_seq extends ahb_master_base_seq;

  // Required macro for sequences automation
  `uvm_object_utils(INCRX_RW_B1_seq)

  //arguments
  rand rw_t rw;
  rand int busy;
  rand size_t wrap_sizes;
  rand burst_t burst;
  rand bit [31:0] initial_addr;

  bit w_busy_flag,rd_busy_flag;

  constraint incrx_size {
                                  wrap_sizes < WORDx2;
                          }
  constraint incrx_burst {
                                  burst inside {INCR4,INCR8,INCR16};
                          }
  // Constructor
  function new(string name="INCRX_RW_B1_seq");
    super.new(name);
  endfunction

  //local 
  write_seq w_seq;
  read_seq r_seq;
  bit      [31:0] myaddr;
  int count;

  virtual task body();
    case(burst)
    INCR4 : count = 3;
    INCR8 : count = 7;
    INCR16 : count = 15;
    default: $display("INVALID burst type for increminting brust !!!");
    endcase

    if(rw == WRITE) 
      begin
        `uvm_do_with(w_seq, 
          { my_trans_type == NONSEQ;
            addr == initial_addr;
            lock_m == 1'b0;
            data == initial_addr;
            size == wrap_sizes;
            burst_m == burst;})

        myaddr = w_seq.addr;
      end
    else
      begin
        `uvm_do_with(r_seq, 
          { my_trans_type == NONSEQ;
            addr == initial_addr;
            lock_m == 1'b0;
            size == wrap_sizes;
            burst_m == burst;})

        myaddr = r_seq.addr;
      end

    repeat(count) 
    begin
      $display($time,"MY signals busy%0d,w_busy_flag%0d,rd_busy_flag%0d",busy,w_busy_flag,rd_busy_flag);
      if (~(w_busy_flag || rd_busy_flag) ) 
      begin
      
        case (wrap_sizes)
          BYTE     : myaddr += 1;     //byte
          HALFWORD : myaddr += 2; //half word
          WORD     : myaddr += 4;     //word
          WORDx2   : myaddr += 8;   //2words
          WORDx4   : myaddr += 16;   //4words
          WORDx8   : myaddr += 32;   //8words
          WORDx16  : myaddr += 64;   //16words
          WORDx32  : myaddr += 128;   //32words
          default  : $display("The size is not in the range !!!");
        endcase
      end
      if(busy == 0) //busy is zero
         begin
          w_busy_flag = 0;
          rd_busy_flag = 0;
         end
         
        if(rw) begin
        `uvm_do_with(w_seq, 
        { my_trans_type == SEQ;
          addr == myaddr;
          data == myaddr;
          lock_m == 1'b0;
          size == wrap_sizes;
          burst_m == burst;})

          while (busy) 
          begin
            if(!w_busy_flag)
              begin
                w_busy_flag = 1;
                case (wrap_sizes)
                  BYTE     : myaddr += 1;     //byte
                  HALFWORD : myaddr += 2; //half word
                  WORD     : myaddr += 4;     //word
                  WORDx2   : myaddr += 8;   //2words
                  WORDx4   : myaddr += 16;   //4words
                  WORDx8   : myaddr += 32;   //8words
                  WORDx16  : myaddr += 64;   //16words
                  WORDx32  : myaddr += 128;   //32words
                  default  : $display("The size is not in the range !!!");
                endcase
              end
            
              `uvm_do_with(w_seq,
              { my_trans_type == BUSY;
                addr == myaddr;
                data == myaddr;
                lock_m == 1'b0;
                size == wrap_sizes;
                burst_m == burst;})

          busy--;
          end
        end
        else 
          begin
            `uvm_do_with(r_seq, 
            { my_trans_type == SEQ;
              addr == myaddr;
              lock_m == 1'b0;
              size == wrap_sizes;
              burst_m == burst;})

            while (busy) 
            begin
              if(!rd_busy_flag)
                begin
                  rd_busy_flag = 1;
                  case (wrap_sizes)
                    BYTE     : myaddr += 1;     //byte
                    HALFWORD : myaddr += 2; //half word
                    WORD     : myaddr += 4;     //word
                    WORDx2   : myaddr += 8;   //2words
                    WORDx4   : myaddr += 16;   //4words
                    WORDx8   : myaddr += 32;   //8words
                    WORDx16  : myaddr += 64;   //16words
                    WORDx32  : myaddr += 128;   //32words
                    default  : $display("The size is not in the range !!!");
                  endcase
                end
              
                `uvm_do_with(r_seq,
                { my_trans_type == BUSY;
                  addr == myaddr;
                  lock_m == 1'b0;
                  size == wrap_sizes;
                  burst_m == burst;})

            busy--;
            end
          end
    end
  endtask : body

endclass : INCRX_RW_B1_seq

class check_INCRX_RW_B1_seq extends ahb_master_base_seq;
  
  // Required macro for sequences automation
  `uvm_object_utils(check_INCRX_RW_B1_seq)
  INCRX_RW_B1_seq check;
  INCRX_RW_B1_seq check_1;
  // Constructor
  function new(string name="check_INCRX_RW_B1_seq");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(), "Executing check_INCRX_RW_B1_seq sequence", UVM_LOW)
    repeat(5) begin
      `uvm_do_with(check, 
        { initial_addr == 'h24;
          rw == WRITE;
          busy == 8;
          // wrap_sizes   == WORD;
          // burst == INCR4;
          })

      `uvm_do_with(check_1,
          { initial_addr == 'h24;
            rw == READ;
            busy == 0;
            wrap_sizes   == check.wrap_sizes;
            burst == check.burst;
            })
    end
    
  endtask
endclass : check_INCRX_RW_B1_seq

class check_INCRX_all_RW_B1_seq extends ahb_master_base_seq;
  
  // Required macro for sequences automation
  `uvm_object_utils(check_INCRX_all_RW_B1_seq)
  INCRX_RW_B1_seq check;
  // Constructor
  function new(string name="check_INCRX_all_RW_B1_seq");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(), "Executing check_INCRX_all_RW_B1_seq sequence", UVM_LOW)
    `uvm_do_with(check, 
        { initial_addr == 'h24;
          rw == WRITE;
          busy == 2;
          wrap_sizes   == WORD;
          burst == INCR4;
          })
    `uvm_do_with(check,
        { initial_addr == 'h24;
          rw == READ;
          busy == 0;
          wrap_sizes   == WORD;
          burst == INCR4;
          })

    `uvm_do_with(check, 
        { initial_addr == 'h30;
          rw == WRITE;
          busy == 2;
          wrap_sizes   == WORD;
          burst == INCR8;
          })
    `uvm_do_with(check,
        { initial_addr == 'h30;
          rw == READ;
          busy == 0;
          wrap_sizes   == WORD;
          burst == INCR8;
          })

    `uvm_do_with(check, 
        { initial_addr == 'h34;
          rw == WRITE;
          busy == 2;
          wrap_sizes   == WORD;
          burst == INCR16;
          })
    `uvm_do_with(check,
        { initial_addr == 'h34;
          rw == READ;
          busy == 0;
          wrap_sizes   == WORD;
          burst == INCR16;
          })

  endtask
endclass : check_INCRX_all_RW_B1_seq

//incremental burst with busy and length specified
class  INCR_RW_B1_seq extends ahb_master_base_seq;

  // Required macro for sequences automation
  `uvm_object_utils(INCR_RW_B1_seq)

  //arguments
  rand rw_t rw;
  rand int busy;
  rand size_t wrap_sizes;
  rand bit [31:0] initial_addr;
  rand int unsigned length;


  bit w_busy_flag,rd_busy_flag;

  
  constraint len_range {length < 100;}
  constraint incr_un_size {
                                  wrap_sizes < WORDx2;
                          }
  // Constructor
  function new(string name="INCR_RW_B1_seq");
    super.new(name);
  endfunction

  //local 
  write_seq w_seq;
  read_seq r_seq;
  bit      [31:0] myaddr;

  virtual task body();
   $display("[INCR_RW_B1_seq]The value of length is %d",length);
    if(rw == WRITE) 
      begin
        `uvm_do_with(w_seq, 
          { my_trans_type == NONSEQ;
            addr == initial_addr;
            lock_m == 1'b0;
            data == initial_addr;
            size == wrap_sizes;
            burst_m == INCR;})

        myaddr = w_seq.addr;
      end
    else
      begin
        `uvm_do_with(r_seq, 
          { my_trans_type == NONSEQ;
            addr == initial_addr;
            lock_m == 1'b0;
            size == wrap_sizes;
            burst_m == INCR;})

        myaddr = r_seq.addr;
      end

    repeat(length - 2)
    begin
      // $display($time,"MY signals busy%0d,w_busy_flag%0d,rd_busy_flag%0d",busy,w_busy_flag,rd_busy_flag);
      if (~(w_busy_flag || rd_busy_flag) )
      begin
      
        case (wrap_sizes)
          BYTE     : myaddr += 1;     //byte
          HALFWORD : myaddr += 2; //half word
          WORD     : myaddr += 4;     //word
          WORDx2   : myaddr += 8;   //2words
          WORDx4   : myaddr += 16;   //4words
          WORDx8   : myaddr += 32;   //8words
          WORDx16  : myaddr += 64;   //16words
          WORDx32  : myaddr += 128;   //32words
          default  : $display("The size is not in the range !!!");
        endcase
      end
      if(busy == 0) //busy is zero
         begin
          w_busy_flag = 0;
          rd_busy_flag = 0;
         end
         
        if(rw)
          begin
          `uvm_do_with(w_seq, 
          { my_trans_type == SEQ;
            addr == myaddr;
            data == myaddr;
            lock_m == 1'b0;
            size == wrap_sizes;
            burst_m == INCR;})

            while (busy) 
              begin
                if(!w_busy_flag)
                  begin
                    w_busy_flag = 1;
                    case (wrap_sizes)
                      BYTE     : myaddr += 1;     //byte
                      HALFWORD : myaddr += 2; //half word
                      WORD     : myaddr += 4;     //word
                      WORDx2   : myaddr += 8;   //2words
                      WORDx4   : myaddr += 16;   //4words
                      WORDx8   : myaddr += 32;   //8words
                      WORDx16  : myaddr += 64;   //16words
                      WORDx32  : myaddr += 128;   //32words
                      default  : $display("The size is not in the range !!!");
                    endcase
                  end
                
                  `uvm_do_with(w_seq,
                  { my_trans_type == BUSY;
                    addr == myaddr;
                    data == myaddr;
                    lock_m == 1'b0;
                    size == wrap_sizes;
                    burst_m == INCR;})

                busy--;
              end
          end
        else 
          begin
            `uvm_do_with(r_seq, 
            { my_trans_type == SEQ;
              addr == myaddr;
              lock_m == 1'b0;
              size == wrap_sizes;
              burst_m == INCR;})

            while (busy) 
              begin
                if(!rd_busy_flag)
                  begin
                    rd_busy_flag = 1;
                    case (wrap_sizes)
                      BYTE     : myaddr += 1;     //byte
                      HALFWORD : myaddr += 2;     //half word
                      WORD     : myaddr += 4;     //word
                      WORDx2   : myaddr += 8;     //2words
                      WORDx4   : myaddr += 16;    //4words
                      WORDx8   : myaddr += 32;    //8words
                      WORDx16  : myaddr += 64;    //16words
                      WORDx32  : myaddr += 128;   //32words
                      default  : $display("The size is not in the range !!!");
                    endcase
                  end
                
                  `uvm_do_with(r_seq,
                  { my_trans_type == BUSY;
                    addr == myaddr;
                    lock_m == 1'b0;
                    size == wrap_sizes;
                    burst_m == INCR;})

                busy--;
              end
          end
      end

      case (wrap_sizes)
        BYTE     : myaddr += 1;     //byte
        HALFWORD : myaddr += 2; //half word
        WORD     : myaddr += 4;     //word
        WORDx2   : myaddr += 8;   //2words
        WORDx4   : myaddr += 16;   //4words
        WORDx8   : myaddr += 32;   //8words
        WORDx16  : myaddr += 64;   //16words
        WORDx32  : myaddr += 128;   //32words
        default  : $display("The size is not in the range !!!");
      endcase
      
        if(rw)
          `uvm_do_with(w_seq, 
          { my_trans_type == IDLE;
            addr == myaddr;
            data == myaddr;
            lock_m == 1'b0;
            size == wrap_sizes;
            burst_m == INCR;})
        else
          `uvm_do_with(r_seq, 
          { my_trans_type == IDLE;
            addr == myaddr;
            lock_m == 1'b0;
            size == wrap_sizes;
            burst_m == INCR;})
    
  endtask : body

endclass : INCR_RW_B1_seq

//set initial address, WR operation, with busy or not, Hwidth and specified length
class check_INCR_RW_B1_seq extends ahb_master_base_seq;
  
  // Required macro for sequences automation
  `uvm_object_utils(check_INCR_RW_B1_seq)
  INCR_RW_B1_seq check;
  INCR_RW_B1_seq check_1;
  // Constructor
  function new(string name="check_INCR_RW_B1_seq");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(), "Executing check_INCR_RW_B1_seq sequence", UVM_LOW)
    `uvm_do_with(check, 
        { initial_addr == 'h34;
          rw == WRITE;
          busy == 4;
          // wrap_sizes   == WORD;
          // length == 20;
          })

    `uvm_do_with(check_1, 
        { initial_addr == 'h34;
          rw == READ;
          busy == 0;
          wrap_sizes   == check.wrap_sizes;
          length == check.length;
          })
  endtask
endclass : check_INCR_RW_B1_seq

class Clear_mem_seq extends ahb_master_base_seq;
  // Required macro for sequences automation
  `uvm_object_utils(Clear_mem_seq)

  // Constructor
  function new(string name="Clear_mem_seq");
    super.new(name);
  endfunction

  write_seq w_seq;
  read_seq r_seq;
  int i=0;

  virtual task body();
    `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)

    repeat(1023) begin
      `uvm_do_with(w_seq, 
        { my_trans_type == NONSEQ;
          lock_m == UNLOCK;
          addr == i;
          size == BYTE;
          data == 'h0;
          burst_m == SINGLE;})
          i +=1;
    end

    i=0;
    repeat(256) begin
      `uvm_do_with(r_seq, 
        { my_trans_type == NONSEQ;
          addr == i;
          lock_m == UNLOCK;
          size == WORD;
          burst_m == SINGLE;})
          i+=4;
    end
    
  endtask : body

endclass : Clear_mem_seq

class wr_all_loctaions_seq extends ahb_master_base_seq;
  // Required macro for sequences automation
  `uvm_object_utils(wr_all_loctaions_seq)
  rand int incr;
  size_t d_size;
  int count=1024/incr;

  constraint incement {
    incr < 5; incr >0;
  }
  // Constructor
  function new(string name="wr_all_loctaions_seq");
    super.new(name);
  endfunction

  write_seq w_seq;
  read_seq r_seq;
  int i=0;

  virtual task body();
    `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)
    case (incr)
      1: d_size = BYTE;
      2: d_size = HALFWORD;
      4: d_size = WORD;
      default: d_size = WORD;
    endcase
    
    repeat(count) begin
      `uvm_do_with(w_seq, 
        { my_trans_type == NONSEQ;
          lock_m == UNLOCK;
          addr == i;
          size == d_size;
          data == i;
          burst_m == SINGLE;})
          i +=incr;
    end

    i=0;
    repeat(count) begin
      `uvm_do_with(r_seq, 
        { my_trans_type == NONSEQ;
          addr == i;
          lock_m == UNLOCK;
          size == d_size;
          burst_m == SINGLE;})
          i+=incr;
    end
    
  endtask : body

endclass : wr_all_loctaions_seq

class read_write_seq extends ahb_master_base_seq;
  // Required macro for sequences automation
  `uvm_object_utils(read_write_seq)

  // Constructor
  function new(string name="read_write_seq");
    super.new(name);
  endfunction

  write_seq w_seq;
  read_seq r_seq;
  int i=0;

  virtual task body();
    `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)

    repeat(256) begin
      `uvm_do_with(w_seq, 
        { my_trans_type == NONSEQ;
          lock_m == UNLOCK;
          addr == i;
          size == WORD;
          data == i;
          burst_m == SINGLE;})

        `uvm_do_with(r_seq, 
        { my_trans_type == NONSEQ;
          addr == i;
          lock_m == UNLOCK;
          size == WORD;
          burst_m == SINGLE;})
          
          i +=4;
    end
  endtask : body

endclass : read_write_seq 


class check_all_seqs extends ahb_master_base_seq;
  
  wr_lock_seq               myseq1;
  Clear_mem_seq             myseq2;
  read_write_seq            myseq3;
  check_random              myseq4;
  wr_all_loctaions_seq      myseq5;
  check_wrap4_seq           myseq6;
  check_wrap8_seq           myseq7;
  check_wrap16_seq          myseq8;
  check_inc4_seq            myseq9;
  check_inc8_seq            myseq10;
  check_inc16_seq           myseq11;
  check_INCRX_RW_B1_seq     myseq12;
  check_INCR_RW_B1_seq      myseq13;
  single_burst_seq          myseq14;
  check_INCRX_all_RW_B1_seq myseq15;

  // Required macro for sequences automation
  `uvm_object_utils(check_all_seqs)
  // Constructor
  function new(string name="check_all_seqs");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(), "Executing check_all_seqs sequence", UVM_LOW)
        `uvm_do(myseq1)
        `uvm_do(myseq2)
        `uvm_do(myseq3)
        `uvm_do(myseq4)
        `uvm_do_with(myseq5,{incr == 4;})  //set data size word 
        `uvm_do_with(myseq5,{incr == 2;})  //set data size halfword 
        `uvm_do_with(myseq5,{incr == 1;})  //set data size word 
        `uvm_do(myseq6)  
        `uvm_do(myseq7)  
        `uvm_do(myseq8)  
        `uvm_do(myseq9)  
        `uvm_do(myseq10)  
        `uvm_do(myseq11)  
        `uvm_do(myseq12)  
        `uvm_do(myseq13)  
        `uvm_do(myseq14)  
        `uvm_do(myseq15)  
  endtask
endclass : check_all_seqs