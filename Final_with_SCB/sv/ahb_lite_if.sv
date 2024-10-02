interface ahb_intf(input logic HCLK, input logic HRESETn);
    import uvm_pkg::*;

    `include "uvm_macros.svh"
    import ahb_pkg::*;

    //Master inputs
    logic HREADY;
    logic HRESP;
    logic [31:0] HRDATA;

    //Master outputs
    logic [31:0] HADDR;
    logic HWRITE;
    logic [2:0] HSIZE;
    logic [2:0] HBURST;
    logic [3:0]HPORT;
    logic [1:0]HTRANS;
    logic HMASTLOCK;
    logic [31:0] HWDATA;


    // status signals
    bit monstart;


    task reset_check();
        if(!HRESETn) `uvm_info("RESET","Reset Detected!!!",UVM_LOW)

    endtask 

    task automatic send_to_dut(input ahb_trans item);
        if(!HRESETn) begin
            `uvm_info("INTERFACE","Reset Dected!",UVM_LOW)
            HADDR <= 0;
            HWRITE <= 0;
            HSIZE <= 0;
            HBURST <= 0;
            HPORT <= 0;
            HTRANS <= 0;
            HMASTLOCK <= 0;
            HWDATA <= 0;
        //     wait(HRESETn);
        end
        else begin
            // @(posedge HCLK);
            // wait(HREADY);

            HADDR <= item.address; 
            HWRITE <= item.read_write;
            HSIZE <=  item.trans_size;
            HBURST <= item.burst_mode;
            HPORT <= item.HPROT;
            HTRANS <= item.trans_type;
            HMASTLOCK <= item.lockmode;
            item.reset = HRESETn;
            // @(posedge HCLK);
            item.read_data = HRDATA; 
            item.ready = HREADY;
            item.response = HRESP;
            // wait(HREADY);
            // HWDATA <= item.write_data;

        end
    endtask : send_to_dut

    task automatic monitor_collect(output logic [31:0] address, 
                                rw_t read_write, 
                                size_t trans_size, 
                                burst_t burst_mode, 
                                transfer_t trans_type,
                                logic [3:0] HPROT, 
                                logic [31:0] write_data, 
                                bit ready, 
                                resp_t response, 
                                logic [31:0] read_data,
                                bit reset,
                                lock_t lmode
                                );
        // wait(!HRESETn);
        reset = HRESETn;
        monstart = 1;
        @(negedge HCLK);
        
        address  = HADDR; 
        read_write =HWRITE;
        trans_size = HSIZE;
        burst_mode = HBURST;
        trans_type = HTRANS;
        HPROT = HPORT;
        lmode = HMASTLOCK;
        monstart = 0;
        @(negedge HCLK);
        //wait(HREADY);
        write_data = HWDATA;
        // `uvm_info("DRIVER MSG",$sformatf(" INSIDE IF BLOCK %t: Interface HWDATA is %h, ITEM HWDATA is %h", $time,HWDATA,write_data),UVM_LOW)
        read_data = HRDATA; 
        // `uvm_info("DRIVER MSG",$sformatf(" %t: Interface HWDATA is %h, ITEM HWDATA is %h", $time,HWDATA,write_data),UVM_LOW)
        //@(posedge HCLK);
        ready = HREADY;
        response = HRESP;
        

    endtask : monitor_collect



    // task automatic monitor_collect(
    //                                 input ahb_trans item_collected
    //                             );

        
    //     // wait(!HRESETn);
    //     item_collected.reset = HRESETn;
    //     monstart = 1;
    //     @(negedge HCLK);
        
    //     item_collected.address  = HADDR; 
    //     item_collected.read_write =HWRITE;
    //     item_collected.trans_size = HSIZE;
    //     item_collected.burst_mode = HBURST;
    //     item_collected.trans_type = HTRANS;
    //     item_collected.HPROT = HPORT;
    //     item_collected.lockmode = HMASTLOCK;
    //     monstart = 0;
    //     @(negedge HCLK);
    //     //wait(HREADY);
    //     `uvm_info("DRIVER MSG",$sformatf(" %t: HWDATA is %d", $time,HWDATA),UVM_LOW)
    //     if(item_collected.trans_type == WRITE)
    //         item_collected.write_data = HWDATA;
    //     else
    //         item_collected.read_data = HRDATA; 
    //     //@(posedge HCLK);
    //     item_collected.ready = HREADY;
    //     item_collected.response = HRESP;
        

    // endtask : monitor_collect

    //Error Response followed by Idle Trans
    property idle_on_err_p;
            @(posedge HCLK) disable iff(!HRESETn)
                    (HRESP == 1) ##1 (HRESP == 1) |-> (HTRANS == 0);
    endproperty

    IDLE_on_ERROR: 
        assert property(idle_on_err_p)
            else
        $info("non-IDLE transaction detected on 2nd cycle of error response");

    // Assert that address is within the 1KB boundary
    property addr_limit;
            @(posedge HCLK) disable iff(!HRESETn)
                        HADDR < 1024 ;
                        // HADDR[10] != 1'b1;
    endproperty

    addr_check:
        assert property (addr_limit) 
        else 
        $info("Address exceeds 1KB limit: %0b", HADDR);

    // Address Boundry Aligned for Halfword
    property size1_addr_p;
            @(posedge HCLK) disable iff(!HRESETn)
                    HSIZE == 1 |-> HADDR[0] == 0;
    endproperty

        SIZE1_ADDR_BOUD: assert property(size1_addr_p)
        else
        $info("Address Boundry Aligned for Halfword: %0h", HADDR);

    // Address Boundry Aligned for Word
    property size2_addr_p;
            @(posedge HCLK) disable iff(!HRESETn)
                    HSIZE == 2 |-> HADDR[1:0] == 0;
    endproperty

        SIZE2_ADDR_BOUD: assert property(size2_addr_p)
        else
        $info("Address Boundry Aligned for Word: %0h", HADDR);

    // // Address Boundry Aligned for Wordx2
    // property size3_addr_p;
    //         @(posedge HCLK) disable iff(!HRESETn)
    //                 HSIZE == 3 |-> HADDR[2:0] == 0;
    // endproperty

    //     SIZE3_ADDR_BOUD: assert property(size3_addr_p)
    //     else
    //     $info("Address Boundry Aligned for Wordx2: %0h", HADDR);

    // // Address Boundry Aligned for Wordx4
    // property size4_addr_p;
    //         @(posedge HCLK) disable iff(!HRESETn)
    //                 HSIZE == 4 |-> HADDR[3:0] == 0;
    // endproperty

    //     SIZE4_ADDR_BOUD: assert property(size4_addr_p)
    //     else
    //     $info("Address Boundry Aligned for Wordx4: %0h", HADDR);

    // // Address Boundry Aligned for Wordx8
    // property size5_addr_p;
    //         @(posedge HCLK) disable iff(!HRESETn)
    //                 HSIZE == 5 |-> HADDR[4:0] == 0;
    // endproperty

    //     SIZE5_ADDR_BOUD: assert property(size5_addr_p)
    //     else
    //     $info("Address Boundry Aligned for Wordx8: %0h", HADDR);

    // // Address Boundry Aligned for Wordx16
    // property size6_addr_p;
    //         @(posedge HCLK) disable iff(!HRESETn)
    //                 HSIZE == 6 |-> HADDR[5:0] == 0;
    // endproperty

    //     SIZE6_ADDR_BOUD: assert property(size6_addr_p)
    //     else
    //     $info("Address Boundry Aligned for Wordx16: %0h", HADDR);

    // // Address Boundry Aligned for Wordx32
    // property size7_addr_p;
    //         @(posedge HCLK) disable iff(!HRESETn)
    //                 HSIZE == 7 |-> HADDR[6:0] == 0;
    // endproperty

    //     SIZE7_ADDR_BOUD: assert property(size7_addr_p)
    //     else
    //     $info("Address Boundry Aligned for Wordx32: %0h", HADDR);

        //Okay Resp for Idle Trans
    property idle_okay_p;
    @(posedge HCLK) disable iff(!HRESETn)
            (HTRANS == 0) |=> (HRESP == 0);
    endproperty

    IDLE_OK: assert property(idle_okay_p)
    else
    $info("Okay Resp for Idle Trans Failed");

    //Okay Resp for BUSY Trans
    property busy_okay_p;
    @(posedge HCLK) disable iff(!HRESETn)
            (HTRANS == 1) |=> (HRESP == 0);
    endproperty

    BUSY_OK: assert property(busy_okay_p)
    else
    $info("Okay Resp for BUSY Trans Failed");

    property single_burst_followed_by_idle_or_nonseq;
    @(posedge HCLK) disable iff (!HRESETn)
    // Followed by IDLE or NONSEQ 
    (HBURST == 0) |-> (HTRANS == 0 || HTRANS == 2);
    endproperty

    assert_single_burst_followed_by_idle_or_nonseq : assert property(single_burst_followed_by_idle_or_nonseq)
    else
    `uvm_error("SINGLE_BURST_RULE", "SINGLE burst was not followed by IDLE or NONSEQ");

        //Address Check for INCR/INCRx
    property incr_addr_p;
            @(posedge HCLK) disable iff(!HRESETn)
                    (HTRANS == 3) && ((HBURST == 1)||(HBURST == 3)||(HBURST == 5)||(HBURST == 7)) &&
            ($past(HTRANS, 1) != 1) && ($past(HREADY, 1)) |-> (HADDR == ($past(HADDR, 1) + 2**HSIZE));
    endproperty

    incr_address : assert property(incr_addr_p)
    else
    `uvm_error("INCR ADDR", $sformatf("INCRX BURST address aligment error address %0h present address %0h",$past(HADDR,1),HADDR));

    //Address Check for WRAP4 Byte
    property wrap4_size_byte_addr_p;
            @(posedge HCLK) disable iff(!HRESETn)
                    (HTRANS == 3) && (HBURST == 2) && (HSIZE == 0) && ($past(HTRANS, 1) != 1) && ($past(HTRANS, 1) != 0) && ($past(HREADY, 1)) |->
            ((HADDR[1:0] == ($past(HADDR[1:0], 1) + 1'b1)) && (HADDR[31:2] == $past(HADDR[31:2], 1)));
    endproperty

    wrap4_byte_address : assert property(wrap4_size_byte_addr_p)
    else
    `uvm_error("WRAP4 BYTE ADDR", $sformatf("WRAP4 BYTE SIZE BURST address aligment error address %0h present address %0h",$past(HADDR,1),HADDR));

    //Address Check for WRAP4 Halfword      
    property wrap4_size_halfword_addr_p;
            @(posedge HCLK) disable iff(!HRESETn)
                    (HTRANS == 3) && (HBURST == 2) && (HSIZE == 1) && ($past(HTRANS, 1) != 1)  && ($past(HTRANS, 1) != 0) && ($past(HREADY, 1)) |->
            ((HADDR[2:1] == ($past(HADDR[2:1], 1) + 1'b1)) && (HADDR[31:3] == $past(HADDR[31:3], 1)));
    endproperty

    wrap4_halfword_address : assert property(wrap4_size_halfword_addr_p)
    else
    `uvm_error("WRAP4 HALFWORD ADDR", $sformatf("WRAP4 HALFWORD SIZE BURST address aligment error address %0h present address %0h",$past(HADDR,1),HADDR));

    //Address Check for WRAP4 Word  
    property wrap4_size_word_addr_p;
            @(posedge HCLK) disable iff(!HRESETn)
                    (HTRANS == 3) && (HBURST == 2) && (HSIZE == 2) && ($past(HTRANS, 1) != 1)  && ($past(HTRANS, 1) != 0) && ($past(HREADY, 1)) |->
            ((HADDR[3:2] == ($past(HADDR[3:2], 1) + 1'b1)) && (HADDR[31:4] == $past(HADDR[31:4], 1)));
    endproperty

    wrap4_word_address : assert property(wrap4_size_word_addr_p)
    else
    `uvm_error("WRAP4 WORD ADDR", $sformatf("WRAP4 WORD SIZE BURST address aligment error address %0h present address %0h",$past(HADDR,1),HADDR));

    //Address Check for WRAP8 Byte  
    property wrap8_size_byte_addr_p;
            @(posedge HCLK) disable iff(!HRESETn)
                    (HTRANS == 3) && (HBURST == 4) && (HSIZE == 0) && ($past(HTRANS, 1) != 1)  && ($past(HTRANS, 1) != 0) && ($past(HREADY, 1)) |->
            ((HADDR[2:0] == ($past(HADDR[2:0], 1) + 1'b1)) && (HADDR[31:3] == $past(HADDR[31:3], 1)));
    endproperty

    wrap8_byte_address : assert property(wrap8_size_byte_addr_p)
    else
    `uvm_error("WRAP8 BYTE ADDR", $sformatf("WRAP8 BYTE SIZE BURST address aligment error address %0h present address %0h",$past(HADDR,1),HADDR));

    //Address Check for WRAP8 Halfword      
    property wrap8_size_halfword_addr_p;
            @(posedge HCLK) disable iff(!HRESETn)
                    (HTRANS == 3) && (HBURST == 4) && (HSIZE == 1) && ($past(HTRANS, 1) != 1)  && ($past(HTRANS, 1) != 0) && ($past(HREADY, 1)) |->
            ((HADDR[3:1] == ($past(HADDR[3:1], 1) + 1'b1)) && (HADDR[31:4] == $past(HADDR[31:4], 1)));
    endproperty

    wrap8_halfword_address : assert property(wrap8_size_halfword_addr_p)
    else
    `uvm_error("WRAP8 HALFWORD ADDR", $sformatf("WRAP8 HALFWORD SIZE BURST address aligment error address %0h present address %0h",$past(HADDR,1),HADDR));

    //Address Check for WRAP8 Word  
    property wrap8_size_word_addr_p;
            @(posedge HCLK) disable iff(!HRESETn)
                    (HTRANS == 3) && (HBURST == 4) && (HSIZE == 2) && ($past(HTRANS, 1) != 1)  && ($past(HTRANS, 1) != 0) && ($past(HREADY, 1)) |->
            ((HADDR[4:2] == ($past(HADDR[4:2], 1) + 1'b1)) && (HADDR[31:5] == $past(HADDR[31:5], 1)));
    endproperty

     wrap8_word_address : assert property(wrap8_size_word_addr_p)
    else
    `uvm_error("WRAP8 WORD ADDR", $sformatf("WRAP8 WORD SIZE BURST address aligment error address %0h present address %0h",$past(HADDR,1),HADDR));

    //Address Check for WRAP16 Byte 
    property wrap16_size_byte_addr_p;
            @(posedge HCLK) disable iff(!HRESETn)
                    (HTRANS == 3) && (HBURST == 6) && (HSIZE == 0) && ($past(HTRANS, 1) != 1)  && ($past(HTRANS, 1) != 0) && ($past(HREADY, 1)) |->
            ((HADDR[3:0] == ($past(HADDR[3:0], 1) + 1'b1)) && (HADDR[31:4] == $past(HADDR[31:4], 1)));
    endproperty

    wrap16_byte_address : assert property(wrap16_size_byte_addr_p)
    else
    `uvm_error("WRAP16 BYTE ADDR", $sformatf("WRAP16 BYTE SIZE BURST address aligment error address %0h present address %0h",$past(HADDR,1),HADDR));

    //Address Check for WRAP16 Halfword     
    property wrap16_size_halfword_addr_p;
            @(posedge HCLK) disable iff(!HRESETn)
                    (HTRANS == 3) && (HBURST == 6) && (HSIZE == 1) && ($past(HTRANS, 1) != 1)  && ($past(HTRANS, 1) != 0) && ($past(HREADY, 1)) |->
            ((HADDR[4:1] == ($past(HADDR[4:1], 1) + 1'b1)) && (HADDR[31:5] == $past(HADDR[31:5], 1)));
    endproperty

    wrap16_halfword_address : assert property(wrap16_size_halfword_addr_p)
    else
    `uvm_error("WRAP16 HALFWORD ADDR", $sformatf("WRAP16 HALFWORD SIZE BURST address aligment error address %0h present address %0h",$past(HADDR,1),HADDR));

    //Address Check for WRAP16 Word 
    property wrap16_size_word_addr_p;
            @(posedge HCLK) disable iff(!HRESETn)
                    (HTRANS == 3) && (HBURST == 6) && (HSIZE == 2) && ($past(HTRANS, 1) != 1)  && ($past(HTRANS, 1) != 0) && ($past(HREADY, 1)) |->
            ((HADDR[5:2] == ($past(HADDR[5:2], 1) + 1'b1)) && (HADDR[31:6] == $past(HADDR[31:6], 1)));
    endproperty
    wrap16_word_address : assert property(wrap16_size_word_addr_p)
    else
    `uvm_error("WRAP16 WORD ADDR", $sformatf("WRAP16 WORD SIZE BURST address aligment error address %0h present address %0h",$past(HADDR,1),HADDR));

        
endinterface

