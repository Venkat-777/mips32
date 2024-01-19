`timescale 1ns / 1ps


module ALUControl(
    input [1:0] ALUOp, 
    input [5:0] Function,
    output reg[3:0] ALU_Control);  

wire [7:0] ALUControlIn;  
 assign ALUControlIn = {ALUOp,Function};  
 always @(ALUControlIn)  
 casex (ALUControlIn)  
        8'b1x_100100: ALU_Control=4'b0000;  
        8'b10_100101: ALU_Control=4'b0001;  
        8'b00_xxxxxx: ALU_Control=4'b0010; 
        8'b10_100000: ALU_Control=4'b0010;
        8'b10_100010: ALU_Control=4'b0110; 
        8'b10_011000: ALU_Control=4'b0101;
        8'b10_011010: ALU_Control=4'b1011;
        8'b10_100110: ALU_Control=4'b0100;
        8'b10_100111: ALU_Control=4'b1100;
        8'b10_101010: ALU_Control=4'b0111;
        8'b10_000000: ALU_Control=4'b1000;
        8'b10_000010: ALU_Control=4'b1001;
        8'b10_000011: ALU_Control=4'b1010;		
        8'b11_001100: ALU_Control=4'b0000;
        8'b01_xxxxxx: ALU_Control=4'b0110;
  default: ALU_Control=4'b0000;  
  endcase  
 endmodule  


