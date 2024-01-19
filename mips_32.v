`timescale 1ns / 1ps


module mips_32(
    input clk, reset,  
    output[31:0] result
    );
    
    wire reg_dst, reg_write, alu_src, mem_read, mem_write, mem_to_reg;
    wire [3:0] ALU_Control;
    wire [5:0] inst_31_26, inst_5_0;
    wire [1:0] alu_op;
    wire jump, branch_taken;
    wire en;
    wire [9:0] pc_plus4,jump_address,branch_address,ID_pc_plus4;
    wire [31:0] instrIF,if_id_instr;
    wire IF_Flush;
    wire [4:0] destination_reg;
    wire [31:0] reg1, reg2, imm_value;
    wire mem_wb_reg_write;
    wire [4:0] mem_wb_write_reg_addr;
    wire [31:0] mem_wb_write_back_data;
    wire Data_Hazard, Control_Hazard;  

    // ID/EX registers
    wire [31:0] id_ex_instr;
    wire [31:0] id_ex_reg1;
    wire [31:0] id_ex_reg2;
    wire [31:0] id_ex_imm_value;
    wire [4:0] id_ex_destination_reg;
    wire id_ex_mem_to_reg;
    wire [1:0] id_ex_alu_op;
    wire id_ex_mem_read;
    wire id_ex_mem_write;
    wire id_ex_alu_src;
    wire id_ex_reg_write;
    
    // EX/MEM registers
    wire [31:0] ex_mem_instr;
    wire [31:0] ex_mem_alu_result;
    wire [31:0] ex_mem_write_back_result;
    wire [4:0] ex_mem_destination_reg;
    wire ex_mem_mem_to_reg;
    wire ex_mem_mem_read;
    wire ex_mem_mem_write;
    wire ex_mem_reg_write;
    wire ex_mem_reg_dst;
    wire ex_mem_branch_taken;
    wire ex_mem_jump;
    // Memory
    wire [31:0] mem_wb_read_data;
    // Forwarding unit
    wire [1:0] Forward_A;
    wire [1:0] Forward_B;
    // Execution
    wire [31:0] alu_in2_out, ex_mem_alu_in2_out;
    wire [31:0] alu_result, ex_mem_alu_result;
   
   //MEM/WB
   wire [31:0] mem_read_data, mem_wb_mem_read_data, write_back_data;
   wire [31:0] mem_wb_alu_result;
   wire mem_wb_mem_to_reg;
   wire [4:0] mem_wb_destination_reg;
// Build the pipeline as indicated in the lab manual
    // Initialize all reg-type variables to 0
///////////////////////////// Instruction Fetch    
    IF_pipe_stage IF_pipe_stage_inst( .clk(clk), .reset(reset), .en(Data_Hazard), 
				 .branch_address(branch_address), 
				 .jump_address(jump_address), 
				 .branch_taken(branch_taken),
				 .jump(jump),
				 .pc_plus4(pc_plus4),
				 .instr(instrIF) );
        
///////////////////////////// IF/ID registers
    pipe_reg_en #(.WIDTH(10)) pc_plus4_reg(
                             .clk(clk), .reset(reset), .en(Data_Hazard), .flush(IF_Flush),
			     .d(pc_plus4), .q(ID_pc_plus4) );  
    pipe_reg_en #(.WIDTH(32)) instr_reg(
                             .clk(clk), .reset(reset), .en(Data_Hazard), .flush(IF_Flush),
			     .d(instrIF), .q(if_id_instr) );  //instrID
///////////////////////////// Instruction Decode 
 // Instantiate ID_pipe_stage module
    ID_pipe_stage ID_pipe_stage_inst (
        .clk(clk),
        .reset(reset),
        .pc_plus4(ID_pc_plus4),
        .instr(if_id_instr),
        .mem_wb_reg_write(mem_wb_reg_write),
        .mem_wb_write_reg_addr(mem_wb_destination_reg),
        .mem_wb_write_back_data(write_back_data),
        .Data_Hazard(Data_Hazard),
        .Control_Hazard(IF_Flush),
        .reg1(reg1),
        .reg2(reg2),
        .imm_value(imm_value),
        .branch_address(branch_address),
        .jump_address(jump_address),
        .branch_taken(branch_taken),
        .destination_reg(destination_reg),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .jump(jump)
    );      
///////////////////////////// ID/EX registers 
    pipe_reg #(.WIDTH(32)) id_ex_instr_reg ( .clk(clk), .reset(reset), .d(if_id_instr),
               .q(id_ex_instr) );
    pipe_reg #(.WIDTH(32)) id_ex_reg1_reg ( .clk(clk), .reset(reset), .d(reg1),
               .q(id_ex_reg1) );
    pipe_reg #(.WIDTH(32)) id_ex_reg2_reg ( .clk(clk), .reset(reset), .d(reg2),
               .q(id_ex_reg2) );
    pipe_reg #(.WIDTH(32)) id_ex_imm_reg ( .clk(clk), .reset(reset), .d(imm_value),
               .q(id_ex_imm_value) );    
    pipe_reg #(.WIDTH(5)) id_ex_reg_dst_reg ( .clk(clk), .reset(reset), .d(destination_reg),
               .q(id_ex_destination_reg) );
    pipe_reg #(.WIDTH(1)) id_ex_mem2r_reg ( .clk(clk), .reset(reset), .d(mem_to_reg),
               .q(id_ex_mem_to_reg) );
    pipe_reg #(.WIDTH(2)) id_ex_aluOP_reg ( .clk(clk), .reset(reset), .d(alu_op),
               .q(id_ex_alu_op) );
    pipe_reg #(.WIDTH(1)) id_ex_mem_read_reg ( .clk(clk), .reset(reset), .d(mem_read),
               .q(id_ex_mem_read) );         
    pipe_reg #(.WIDTH(1)) id_ex_mem_write_reg ( .clk(clk), .reset(reset), .d(mem_write),
               .q(id_ex_mem_write) );   
    pipe_reg #(.WIDTH(1)) id_ex_alu_src_reg ( .clk(clk), .reset(reset), .d(alu_src),
               .q(id_ex_alu_src) );   
    pipe_reg #(.WIDTH(1)) id_ex_reg_write_reg ( .clk(clk), .reset(reset), .d(reg_write),
               .q(id_ex_reg_write) );   
                        
///////////////////////////// Hazard_detection unit
  
    Hazard_detection Hazard_detection_inst( .id_ex_mem_read(id_ex_mem_read),
                                            .id_ex_destination_reg(id_ex_destination_reg),
                                            .if_id_rs(if_id_instr[25:21]), 
                                            .if_id_rt(if_id_instr[20:16]) ,
                                            .branch_taken(branch_taken),
                                            .jump(jump),
                                            .Data_Hazard(Data_Hazard),
                                            .IF_Flush(IF_Flush) );
///////////////////////////// Execution    
	EX_pipe_stage EX_pipe_stage_inst( .id_ex_instr(id_ex_instr), .reg1(id_ex_reg1),
	                                  .reg2(id_ex_reg2), .id_ex_imm_value(id_ex_imm_value),
	                                  .ex_mem_alu_result(ex_mem_alu_result),
	                                  .mem_wb_write_back_result(write_back_data),
	                                  .id_ex_alu_src(id_ex_alu_src),
	                                  .id_ex_alu_op(id_ex_alu_op),
	                                  .Forward_A(Forward_A), .Forward_B(Forward_B),
	                                  .alu_in2_out(alu_in2_out),
	                                  .alu_result(alu_result) );
///////////////////////////// Forwarding unit
    EX_Forwarding_unit EX_Forwarding_unit_inst( .ex_mem_reg_write(ex_mem_reg_write), 
                                                .ex_mem_write_reg_addr(ex_mem_destination_reg),
                                                .id_ex_instr_rs(id_ex_instr[25:21]),
                                                .id_ex_instr_rt(id_ex_instr[20:16]),
                                                .mem_wb_reg_write(mem_wb_reg_write),
                                                .mem_wb_write_reg_addr(mem_wb_destination_reg),
                                                //the above param should be mem_wb_destination_reg
                                                .Forward_A(Forward_A),
                                                .Forward_B(Forward_B) );
///////////////////////////// EX/MEM registers
    pipe_reg #(.WIDTH(32)) ex_mem_instr_reg ( .clk(clk), .reset(reset), .d(id_ex_instr),
                .q(ex_mem_instr) );   
    pipe_reg #(.WIDTH(5)) ex_mem_reg_dst_reg ( .clk(clk), .reset(reset), .d(id_ex_destination_reg),
                .q(ex_mem_destination_reg) );
    pipe_reg #(.WIDTH(32)) ex_mem_alu_result_reg ( .clk(clk), .reset(reset), .d(alu_result),
                .q(ex_mem_alu_result) );     
    pipe_reg #(.WIDTH(32)) ex_mem_alu_in2_out_reg ( .clk(clk), .reset(reset), .d(alu_in2_out),
                .q(ex_mem_alu_in2_out) );  
    pipe_reg #(.WIDTH(1)) ex_mem_mem2r_reg ( .clk(clk), .reset(reset), .d(id_ex_mem_to_reg),
                .q(ex_mem_mem_to_reg) );
    pipe_reg #(.WIDTH(1)) ex_mem_mem_read_reg ( .clk(clk), .reset(reset), .d(id_ex_mem_read),
                .q(ex_mem_mem_read) );         
    pipe_reg #(.WIDTH(1)) ex_mem_mem_write_reg ( .clk(clk), .reset(reset), .d(id_ex_mem_write),
                .q(ex_mem_mem_write) );     
    pipe_reg #(.WIDTH(1)) ex_mem_reg_write_reg ( .clk(clk), .reset(reset), .d(id_ex_reg_write),
                .q(ex_mem_reg_write) );
///////////////////////////// memory    
     data_memory data_mem(.clk(clk), 
                          .mem_write_en(ex_mem_mem_write),
                          .mem_read_en(ex_mem_mem_read),
                          .mem_write_data(ex_mem_alu_in2_out),
                          .mem_access_addr(ex_mem_alu_result),
                          .mem_read_data(mem_read_data) );
///////////////////////////// MEM/WB registers  
    pipe_reg #(.WIDTH(32)) mem_wb_alu_result_reg ( .clk(clk), .reset(reset), .d(ex_mem_alu_result),
               .q(mem_wb_alu_result) );     
    pipe_reg #(.WIDTH(32)) mem_wb_mem_read_data_reg ( .clk(clk), .reset(reset), .d(mem_read_data),
               .q(mem_wb_mem_read_data) );
    pipe_reg #(.WIDTH(1)) mem_wb_mem2r_reg ( .clk(clk), .reset(reset), .d(ex_mem_mem_to_reg),
               .q(mem_wb_mem_to_reg) );    
    pipe_reg #(.WIDTH(1)) mem_wb_reg_write_reg ( .clk(clk), .reset(reset), .d(ex_mem_reg_write),
               .q(mem_wb_reg_write) );    
    pipe_reg #(.WIDTH(5)) mem_wb_destination_reg_reg ( .clk(clk), .reset(reset), .d(ex_mem_destination_reg),
               .q(mem_wb_destination_reg) );
///////////////////////////// writeback    
     mux2 #(.mux_width(32)) writeback_mux 
    (   .a(mem_wb_alu_result),
        .b(mem_wb_mem_read_data),
        .sel(mem_wb_mem_to_reg),
        .y(write_back_data));  
    assign result = write_back_data;
endmodule
