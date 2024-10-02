typedef enum bit[1:0] {IDLE, BUSY, NONSEQ, SEQ} transfer_t;
typedef enum bit {READ, WRITE} rw_t;
typedef enum bit [2:0] {SINGLE, INCR, WRAP4, INCR4, WRAP8, INCR8, WRAP16, INCR16} burst_t;
typedef enum bit [2:0] {BYTE, HALFWORD, WORD, WORDx2, WORDx4, WORDx8, WORDx16, WORDx32} size_t;
typedef enum bit  {OKAY, ERROR} resp_t;
typedef enum bit  {UNLOCK, LOCK} lock_t;

class ahb_trans extends uvm_sequence_item;     

    rand bit reset;
    //Transfer Type
    rand transfer_t trans_type;

    //Address and Controls
    rand bit [31:0] address;
    rand size_t trans_size;
    rand burst_t burst_mode;
    rand rw_t read_write;
    rand bit [3:0] HPROT;
    rand lock_t lockmode;
    rand bit [31:0] write_data;

    //outputs
    rand bit ready;
    rand resp_t response;
    rand bit [31:0] read_data;

    // rand bit busy[];

  `uvm_object_utils_begin(ahb_trans)
        `uvm_field_int(reset, UVM_ALL_ON)
        `uvm_field_enum(transfer_t, trans_type, UVM_ALL_ON)
        `uvm_field_enum(lock_t, lockmode, UVM_ALL_ON)
        `uvm_field_int(address, UVM_ALL_ON)
        `uvm_field_enum(size_t, trans_size, UVM_ALL_ON)
        `uvm_field_enum(burst_t, burst_mode, UVM_ALL_ON)
        `uvm_field_int(HPROT, UVM_ALL_ON)
        `uvm_field_enum(rw_t, read_write, UVM_ALL_ON)
        `uvm_field_int(write_data, UVM_ALL_ON)
        `uvm_field_int(ready, UVM_ALL_ON)
        `uvm_field_enum(resp_t, response, UVM_ALL_ON)
        `uvm_field_int(read_data, UVM_ALL_ON)
    `uvm_object_utils_end



  constraint addr_size {
                                address < 1024;
                        }

  constraint h_size {
                                  trans_size < WORDx2;
                          }

  constraint nonseq_idle {
                                  if(burst_mode == SINGLE){
                                          trans_type inside {IDLE, NONSEQ};
                                  }
                          }

  // constraint h_pro_t {
  //                                 HPROT[0] == 1'b1;
  //                         }

  // constraint burst_single {
  //                                 burst_mode == SINGLE;
  //                         }

  function new (string name = "ahb_trans");
    super.new(name);
  endfunction : new
  
endclass : ahb_trans



