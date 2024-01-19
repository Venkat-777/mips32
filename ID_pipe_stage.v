`timescale 1ns / 1ps


module ID_pipe_stage(
    input  clk, reset,
    input  [9:0] pc_plus4,
    input  [31:0] instr,
    input  mem_wb_reg_write,
    input  [4:0] mem_wb_write_reg_addr,
    input  [31:0] mem_wb_write_back_data,
    input  Data_Hazard,
    input  Control_Hazard,
    output [31:0] reg1, reg2,
    output [31:0] imm_value,
    output [9:0] branch_address,
    output [9:0] jump_address,
    output branch_taken,
    output [4:0] destination_reg, 
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_read,  
    output mem_write,
    output alu_src,
    output reg_write,
    output jump
    );

    // wires
    wire reg_dst;
    wire branch;
    wire [6:0] temp_ctrl_mReg_aluO_mRd_mWr_aluS_rWr;
    wire [6:0] ctrl_out;
    wire haz_sel;
    wire eq_test_res; 


    // Remember that we test if the branch is taken or not in the decode stage.    
	control control_inst(.reset(reset), .opcode(instr[31:26]), 
			     .reg_dst(reg_dst),
			     .mem_to_reg(temp_ctrl_mReg_aluO_mRd_mWr_aluS_rWr[6]),
                             .alu_op(temp_ctrl_mReg_aluO_mRd_mWr_aluS_rWr[5:4]),
			     .mem_read(temp_ctrl_mReg_aluO_mRd_mWr_aluS_rWr[3]),
                             .mem_write(temp_ctrl_mReg_aluO_mRd_mWr_aluS_rWr[2]),
			     .alu_src(temp_ctrl_mReg_aluO_mRd_mWr_aluS_rWr[1]),
                             .reg_write(temp_ctrl_mReg_aluO_mRd_mWr_aluS_rWr[0]),
			     .branch(branch),
                             .jump(jump) );
	assign haz_sel = !Data_Hazard || Control_Hazard;
        mux2 #(.mux_width(12)) ctrl_mux 
       (   .a(temp_ctrl_mReg_aluO_mRd_mWr_aluS_rWr),
           .b(12'b000000000000),
           .sel(haz_sel),
           .y(ctrl_out) );
	assign mem_to_reg = ctrl_out[6];
	assign alu_op = ctrl_out[5:4];
	assign mem_read = ctrl_out[3]; 
	assign mem_write = ctrl_out[2];
	assign alu_src = ctrl_out[1];
	assign reg_write = ctrl_out[0];
	assign jump_address = instr[25:0] << 2;
        sign_extend sign_ex_inst (
            .sign_ex_in(instr[15:0]),
            .sign_ex_out(imm_value)); 
	assign branch_address = (imm_value << 2) + pc_plus4;
        mux2 #(.mux_width(5)) dest_reg_mux 
       (   .a(instr[20:16]),
           .b(instr[15:11]),
           .sel(reg_dst),
           .y(destination_reg) );
	register_file reg_file ( .clk(clk), .reset(reset), .reg_write_en(mem_wb_reg_write),
				 .reg_write_dest(mem_wb_write_reg_addr), 
				 .reg_write_data(mem_wb_write_back_data),
				 .reg_read_addr_1(instr[25:21]),
				 .reg_read_addr_2(instr[20:16]),
				 .reg_read_data_1(reg1),
				 .reg_read_data_2(reg2) );
	assign eq_test_res = (( reg1 ^ reg2 )==32'd0) ? 1'b1 : 1'b0;
	assign branch_taken = eq_test_res & branch;
endmodule
