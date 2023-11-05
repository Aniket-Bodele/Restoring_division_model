`timescale 1ns/1ps
`include"division_rest.v"
module Division_test ;
parameter N=3;
reg [N-1:0] data_in; 
reg clk,start;
wire done;
Division_restoring D (ldm,ldq,ldaq_1,ldaq_2,clra,sfta,sftq,eqz,ldent,clk,aluout_1,aluout_2,data_in,decr);
Controller C (ldm,ldq,ldaq_1,ldaq_2,clra,sfta,sftq,eqz,ldent,clk,aluout_1,aluout_2,decr,start,done);
initial
begin
    clk=1'b0;
    #3 start=1'b1;
    #600 $finish;
end
always #5 clk=~clk;  
initial
begin
    #17 data_in=7;
    #10 data_in=3;
end
initial
begin
    
    $dumpfile("division.vcd");$dumpvars(0,Division_test);
end
    
endmodule