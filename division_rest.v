`timescale 1ns/1ps
module Division_restoring (ldm,ldq,ldaq_1,ldaq_2,clra,sfta,sftq,eqz,ldent,clk,aluout_1,aluout_2,data_in,decr);
input ldm,ldq,clra,sfta,sftq,clk,ldent,decr;
input ldaq_1,ldaq_2;
parameter N=3;
input [N-1:0] data_in;
output eqz;
output aluout_1,aluout_2;
wire [N-1:0] A,M,Z,Q,X;
wire [N-1:0] count;
assign eqz= ~|count;
shiftreg1 Ac (A,Z,X,sfta,clra,ldaq_1,ldaq_2,Q[N-1],clk);
shiftreg2 Qc (Q,data_in,ldq,sftq,ldaq_1,ldaq_2,clk);
PIPO Mul (M,data_in,ldm,clk);
ALU Sub (Z,A,M,aluout_1,aluout_2,X);
Counter c (count,decr,ldent,clk);
endmodule
module shiftreg1 (out,in,in2,sft,clr,ldaq_1,ldaq_2,s_in,clk);
input s_in,clk,clr,sft;
parameter N=3;
input ldaq_1,ldaq_2;
input [N-1:0] in,in2;
output reg [N-1:0] out;
always @(posedge clk)
begin
if(sft) out<={out[N-2:0],s_in};
else if(clr) out<=0;
else if(ldaq_1 && !ldaq_2) out<=in;
else if(ldaq_2 && !ldaq_1) out<=in2;
 
end
endmodule
module shiftreg2 (out,in,ld,sft,ldaq_1,ldaq_2,clk);
input ld,clk,sft;
parameter N=3;
input ldaq_1,ldaq_2;
input [N-1:0] in;
output reg [N-1:0] out;
always @(posedge clk)
begin
    if(sft) out<={out[N-2:0],1'b0};
    else if(ldaq_1) out<={out[N-1:1],1'b1};
    else if(ldaq_2) out<={out[N-1:1],1'b0};
    else if(ld) out<=in;
end
endmodule
module PIPO (out,in,ld,clk);
input ld,clk;
parameter N=3;
input [N-1:0] in;
output reg [N-1:0] out;
always @(posedge clk)
if(ld) out<=in;
endmodule
module ALU (out,in1,in2,aluout_1,aluout_2,X);
output reg aluout_1,aluout_2;
parameter N=3;
input [N-1:0] in1,in2;
output reg [N-1:0]out,X;
always @(*)
begin
    out=in1-in2;
    X=in1;
    if(in1>=in2) begin aluout_1<=1'b1;aluout_2<=1'b0;end 
    else if(in1<in2) begin aluout_2<=1'b1; aluout_1<=1'b0; end 
    
     
end

endmodule
module Counter (data_out,decr,ldent,clk);
    input decr,clk,ldent;
    parameter N=3;
    output reg [N-1:0] data_out;
    always @(posedge clk)
    begin
        if(ldent) data_out<=N;
        else if(decr) data_out<=data_out-1;
    end
endmodule
module Controller (ldm,ldq,ldaq_1,ldaq_2,clra,sfta,sftq,eqz,ldent,clk,aluout_1,aluout_2,decr,start,done);
input clk, start,eqz;
input aluout_1,aluout_2;
output reg ldm,ldq,clra,sfta,sftq,ldent,decr,done;
output reg ldaq_1,ldaq_2;
reg [2:0] state;
parameter s0=3'b000, s1=3'b001,s2=3'b010,s3=3'b011,s4=3'b100,s5= 3'b101,s6=3'b110,s7=3'b111;
always @(posedge clk)
begin
    case (state)
        s0: if(start) state<=s1;
        s1:state<=s2;
        s2:state<=s3;
        s3:if(aluout_1==1'b1 && aluout_2==1'b0) state<=s4;
           else if(aluout_2==1'b1 && aluout_1==1'b0)state<=s5;
        s4:state<=s6;
        s5:state<=s6;
        s6:#2 if(!eqz) state<=s2;
              else state<=s7;
        s7:state<=s7;

        default: state<=s0;
    endcase
end
always @(state)
begin
    case (state)
        s0: begin
            ldm=0;ldq=0;clra=0;sfta=0;sftq=0;ldent=0;decr=0;done=0;
        end
        s1:begin
            ldm=0;ldq=1;clra=1;sfta=0;sftq=0;ldent=1;decr=0;done=0;
        end
        s2:begin
            ldm=1;ldq=0;sfta=1;sftq=1;ldaq_1=1'b0;ldaq_2=1'b0;ldent=0;decr=0;done=0;clra=0;
        end
        s3:begin
            ldm=0;ldq=0;sfta=0;ldaq_1=1'b0;ldaq_2=1'b0;sftq=0;ldent=0;decr=0;done=0;clra=0;
        end
        s4:begin
            ldm=0;ldq=0;ldaq_1=1'b1;ldaq_2=1'b0;sfta=0;sftq=0;ldent=0;decr=0;done=0;clra=0;
        end
        s5:begin
            ldm=0;ldq=0;sfta=0;ldaq_1=1'b0;ldaq_2=1'b1;sftq=0;ldent=0;decr=0;done=0;clra=0;
        end
        s6: begin ldm=0;ldq=0;sfta=0;sftq=0;ldent=0;decr=1;done=0;ldaq_1=1'b0;ldaq_2=1'b0;
        end
        s7:done=1;
        default:begin
            clra=0;sfta=0;ldq=0;sftq=0;
        end  
    endcase

end
    
endmodule