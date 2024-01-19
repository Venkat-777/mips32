`timescale 1ns / 1ps


module IF_pipe_stage(
    input clk, reset,
    input en,
    input [9:0] branch_address,
    input [9:0] jump_address,
    input branch_taken,
    input jump,
    output [9:0] pc_plus4,
    output [31:0] instr
    );
    
// write your code here
    reg [9:0] pc;
    
    wire [9:0] branch_mux_result;
    wire [9:0] jump_mux_result;
    wire [9:0] new_pc;
    
    always @(posedge clk or posedge reset) //MIGHT NEED TO CHANGE TO NEGEDGE
    begin
        if(reset)
            pc <= 10'b0000000000;
        else if(en)
            pc <= new_pc;
    end
    assign pc_plus4 = pc + 10'b0000000100;
    mux2 #(.mux_width(10)) branch_mux
    (   .a(pc_plus4),
        .b(branch_address),
        .sel(branch_taken),
        .y(branch_mux_result) );
    mux2 #(.mux_width(10)) jump_mux
    (   .a(branch_mux_result),
        .b(jump_address),
        .sel(jump),
        .y(jump_mux_result) ); 
    assign new_pc = jump_mux_result;
    instruction_mem inst_mem (
        .read_addr(pc),
        .data(instr));    

endmodule
