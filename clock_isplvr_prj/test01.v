module test01(clk, in_clk, out_clk,
	      led_gnd1, led_gnd2,  //LED grounds
	      led6, led7, led8, led9, led10, led12, led13, led15, led16, led17, led18, led19, led20, led21,
              led_second_tick,
	      btn_HH, btn_MM, btn_SS, btn_SAFE
             );
input wire clk, in_clk;
output wire out_clk;
output wire led_gnd1, led_gnd2;
output wire led6, led7, led8, led9, led10, led12, led13, led15, led16, led17, led18, led19, led20, led21;
output wire led_second_tick;
input wire btn_HH, btn_MM, btn_SS, btn_SAFE;

wire SAFE_MODE = ~btn_SAFE;

assign out_clk = ~in_clk;

//clk - general clock 32768
reg [13:0] clk_div; initial clk_div <= 14'd0; //?? may be not implement
always @(posedge clk) clk_div <= clk_div + 1'b1;

wire led_line1 =  (clk_div[7])&&(SAFE_MODE==0);
wire led_line2 =  (~led_gnd1) &&(SAFE_MODE==0);

assign led_gnd1 =  led_line1||(SAFE_MODE==1);
assign led_gnd2 =  led_line2;

reg [6:0] sec;// 0..119 - 7bit
reg [3:0] m  ;// 0..9   - 4bit
reg [2:0] mm ;// 0..5   - 3bit
reg [3:0] h  ;// 0..9   - 4bit
reg [1:0] hh ;// 0..2   - 2bit

wire       sec_cy    = (sec  == 7'd119);
wire [6:0] next_sec  = (sec_cy) ? 7'd0 : (sec + 1'b1);

wire       m_cy    = (m  == 4'd9);// && sec_cy;
wire [3:0] next_m  = (m_cy) ? 4'd0 : (m + 1'b1);//(m_cy) ? 4'd0 : (m + ss_cy);

wire       mm_cy   = ((mm == 3'd5) &&(m  == 4'd9));
wire [2:0] next_mm =  (mm_cy) ? 3'd0 : (mm + 1'b1);

wire       h_cy    = (h  == 4'd9)||((hh == 4'd2) && (h  == 4'd3));
wire [3:0] next_h  = (h_cy) ? 4'd0 : (h + 1'b1);

wire       hh_cy   = ((hh == 2'd2) && (h  == 4'd3));
wire [1:0] next_hh = (hh_cy) ? 2'd0 : (hh + 1'b1);

wire timer_clk = clk_div[13]; 
always @(posedge timer_clk) begin
    sec <=                             (btn_SS)       ? 7'd0    : next_sec; //reset seconds
    m   <= (                  sec_cy)||(btn_MM)       ? next_m  : m;
    mm  <= (            m_cy&&sec_cy)||(btn_MM&&m_cy) ? next_mm : mm;
    h   <= (     mm_cy&&m_cy&&sec_cy)||(btn_HH)       ? next_h  : h;
    hh  <= (h_cy&mm_cy&&m_cy&&sec_cy)||(btn_HH&&h_cy) ? next_hh : hh;
end

wire [6:0] s_m;
wire [6:0] s_mm;
wire [6:0] s_h;
wire [6:0] s_hh;

bcd2seg0_9 sseg_m( .sin(m),  .sout(s_m));
bcd2seg0_5 sseg_mm(.sin(mm), .sout(s_mm));
bcd2seg0_9 sseg_h( .sin(h),  .sout(s_h));
bcd2seg0_2 sseg_hh(.sin(hh), .sout(s_hh));

wire a1,b1,c1,d1,e1,f1,g1;
wire a2,b2,c2,d2,e2,f2,g2;
wire a3,b3,c3,d3,e3,f3,g3;
wire a4,b4,c4,d4,e4,f4,g4;

assign {g4, f4, e4, d4, c4, b4, a4} = s_m; 
assign {g3, f3, e3, d3, c3, b3, a3} = s_mm; 
assign {g2, f2, e2, d2, c2, b2, a2} = s_h; 
assign {g1, f1, e1, d1, c1, b1, a1} = s_hh; 

//hide hour zero
wire h_show = !(hh==0);

assign led6 = (led_line1&&(b1&&h_show)) || (led_line2&&(b1&&h_show));  //  b1
assign led7 = (led_line1&&(a1&&h_show)) || (led_line2&&(g1&&h_show)); // a1/g1
assign led8 = (led_line1&&(d1&&h_show)) || (led_line2&&(e1&&h_show)); // d1/e1

assign led9  = (led_line1&&e2) || (led_line2&&(c1&&h_show)); // e2/c1 
assign led10 = (led_line1&&g2) || (led_line2&&b2); // g2/b2
assign led12 = (led_line1&&d2) || (led_line2&&c2); // d2/c2
assign led13 = (led_line1&&f2) || (led_line2&&a2); // f2/a2

assign led15 = (led_line1&&a3) || (led_line2&&f3); // a3/f3 
assign led16 = (led_line1&&b3) || (led_line2&&g3); // b3/g3
assign led17 = (led_line1&&c3) || (led_line2&&d3); // c3/d3

assign led18 = (led_line1&&e4) || ((led_line2)&&e3); // e3/e4 !!
assign led19 = (led_line1&&g4) || ((led_line2)&&b4); // g4/b4
assign led20 = (led_line1&&d4) || ((led_line2)&&c4); // d4/c4
assign led21 = (led_line1&&f4) || ((led_line2)&&a4); // f4/a4


//one second tick indicator
assign led_second_tick = (sec[0]&&(!SAFE_MODE))||(sec[0]&&(clk_div[13:6]==10'd0)&&(SAFE_MODE)); //!!

endmodule


