module pu_reset(clk, res);
input wire clk;
output wire res;

reg [3:0] res_cntr;
assign res = (res_cntr!=4'b1111);
wire [3:0] next_res_cntr = (res) ? res_cntr : res_cntr + 1'b1; 

always @(posedge clk) res_cntr <= next_res_cntr;

endmodule
