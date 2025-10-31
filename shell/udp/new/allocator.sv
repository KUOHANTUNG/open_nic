`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/26 20:16:23
// Design Name: 
// Module Name: allocator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/*
class0 (64B): base_addr 0x0000 - 0x3FFF
class1 (128B): base_addr 0x4000 - 0x7FFF
class2 (256B): base_addr 0x8000 - 0xBFFF
class3 (512B): base_addr 0xC000 - 0xFFFF
*/

module allocator#(
    parameter cache_depth = 16,
    parameter MEMORY_WIDTH = 512,
    parameter CLASS_COUNT = 4,
    parameter BLOCKSIZE = 64 //B
)(
    input                       clk,
    input                       rst_n,
    
    input                       req_valid,
    input       [15:0]          req_data,
    output reg                  req_ready,
    
    output reg  [15:0]          alloc_pointer,
	output reg 	                alloc_valid,
	input  	                    alloc_ready,
	
    input      [15:0]           free_pointer,
	input  	                    free_valid,
	output reg 		            free_ready
    );
    
    
    localparam integer
        CLASS1 = 1,
        CLASS2 = 2,
        CLASS3 = 4,
        CLASS4 = 8;  
    localparam [3:0]	
        ST_ALLOC_IDLE   = 0,
        ST_ALLOC_BEGIN  = 1,
        ST_ALLOC_DECIDE  = 2;
    reg [3:0] alloc_state;  
            
     
     
    localparam [3:0]
       ST_FREE_BEGIN = 0,
       ST_FREE_DECIDE_QUEUE = 1,
       ST_FREE_EXE = 2;
    reg [3:0] free_state;
    

    reg[3:0]    in_class;
    reg[3:0]    chosen_class; 
    
    reg [3:0]   free_class;
    
    
 //distributor
 reg [11:0]  cache_pointer_alloc  [CLASS_COUNT-1:0][cache_depth-1:0];  
 reg [4:0]   cache_counter_alloc  [CLASS_COUNT-1:0];
 reg         cache_pointer_alloc_ready[CLASS_COUNT-1:0];
 
 reg        alloc_cache_front_ready[CLASS_COUNT-1:0];
 reg        alloc_cache_back_ready[CLASS_COUNT-1:0];
 
 
 reg [11:0]  cache_pointer_free  [CLASS_COUNT-1:0][cache_depth-1:0];  
 reg [4:0]   cache_pointer_free_cons_ptr  [CLASS_COUNT-1:0];
 reg [4:0]   cache_pointer_free_prod_ptr  [CLASS_COUNT-1:0];
 
 reg [15:0]  free_pointer_buf ;
 
 reg [11:0]  recycle_cache_pointer_free  [CLASS_COUNT-1:0][cache_depth-1:0]; 
 reg [4:0]   recycle_cache_pointer_free_con_ptr [CLASS_COUNT-1:0];
 reg [4:0]   recycle_cache_pointer_free_pro_ptr [CLASS_COUNT-1:0];
 
 reg        has_recycled[CLASS_COUNT-1:0];
 
 localparam logic [15:0] CLASS_BASE [CLASS_COUNT] = '{16'h0000, 16'h4000, 16'h8000, 16'hC000};

 reg [15:0] neededsize;
 localparam logic [3:0] NEEDEDSIZE_FREE [CLASS_COUNT] = '{4'd0, 4'd1, 4'd2, 4'd3};
 
 // allocate process
  always @(posedge clk) begin
    if(!rst_n)begin
        foreach (cache_counter_alloc[i])           cache_counter_alloc[i]           <= '0;
        foreach (cache_pointer_alloc[i,j])         cache_pointer_alloc[i][j]         <= '0;
        alloc_state <= 0; 
        alloc_valid <= 0;
        req_ready <= 1; 
        alloc_pointer <= 0;
    end else begin
        case (alloc_state)
            ST_ALLOC_IDLE: begin
                if(cache_pointer_alloc_ready[0] && 
                    cache_pointer_alloc_ready[1] && 
                    cache_pointer_alloc_ready[2] &&
                    cache_pointer_alloc_ready[3] 
                )begin
                    req_ready <= 1;
                    alloc_state <= ST_ALLOC_BEGIN;
                end
            end
            ST_ALLOC_BEGIN: begin
                if(alloc_valid && alloc_ready)begin
                    alloc_valid <= 0;
                    alloc_pointer <=0;
                end  
                if (req_valid==1 && req_ready==1) begin
                    in_class <= (req_data <= CLASS1*BLOCKSIZE) ? 0 : (req_data<=CLASS2*BLOCKSIZE) ? 1 : (req_data<=CLASS3*BLOCKSIZE) ? 2 : (req_data<=CLASS4*BLOCKSIZE) ? 3 : 3; 
                    neededsize <= (req_data <= CLASS1*BLOCKSIZE) ? CLASS1 : (req_data<=CLASS2*BLOCKSIZE) ? CLASS2 : (req_data<=CLASS3*BLOCKSIZE) ? CLASS3 : (req_data<=CLASS4*BLOCKSIZE) ? CLASS4 : CLASS4;
                    req_ready <= 0;   
                    alloc_state <= ST_ALLOC_DECIDE;     
                end                         
            end
            ST_ALLOC_DECIDE:begin
                if(alloc_ready) begin            
                    if((cache_pointer_free_cons_ptr[in_class]&(cache_depth-1) )!= (cache_pointer_free_prod_ptr[in_class]&(cache_depth-1)))begin
                        //
                        cache_pointer_free_cons_ptr[in_class] <= cache_pointer_free_cons_ptr[in_class] + 1'b1;              
                        alloc_valid <= 1;
                        req_ready <= 1;
                        alloc_state <= ST_ALLOC_BEGIN;
                        alloc_pointer <=  neededsize*(cache_pointer_free[in_class][cache_pointer_free_cons_ptr[in_class]&(cache_depth-1)]) + CLASS_BASE[in_class];
                    end
                    else begin     
                        if((alloc_cache_front_ready[in_class] && ((cache_counter_alloc[in_class]&(cache_depth-1))<cache_depth/2))||(alloc_cache_back_ready[in_class] &&(cache_counter_alloc[in_class]&(cache_depth-1))>=cache_depth/2))begin
                            cache_counter_alloc[in_class] <= cache_counter_alloc[in_class] + 1;
                            has_recycled[in_class] <= '0;
                            alloc_valid <= 1;
                            req_ready <= 1;  
                            alloc_pointer <=  neededsize*(cache_pointer_alloc[in_class][cache_counter_alloc[in_class]&(cache_depth-1)]) + CLASS_BASE[in_class];
                            alloc_state <= ST_ALLOC_BEGIN;
                        end
                        else begin
                            alloc_valid <= 0;
                            req_ready <= 0;
                        end                             
                    end
                end 
            end
        endcase 
    end 
  end
      // free the pointer
  always @(posedge clk) begin
     if(!rst_n)begin
     
        foreach (cache_pointer_free_cons_ptr[i])           cache_pointer_free_cons_ptr[i]           <= '0;
        foreach (cache_pointer_free_prod_ptr[i])           cache_pointer_free_prod_ptr[i]           <= '0;  
              
        foreach (cache_pointer_free[i,j])         cache_pointer_free[i][j]         <= '0;
        foreach (recycle_cache_pointer_free[i,j])         recycle_cache_pointer_free[i][j]         <= '0;
        foreach (recycle_cache_pointer_free_con_ptr[i])         recycle_cache_pointer_free_con_ptr[i]         <= '0;
        foreach (recycle_cache_pointer_free_pro_ptr[i])         recycle_cache_pointer_free_pro_ptr[i]         <= '0;
        free_ready <= 1;
        free_pointer_buf <= 0;
        free_state <= 0;
     end
     else begin
        case(free_state)
           ST_FREE_BEGIN: begin
             if (free_valid==1 && free_ready==1) begin
                free_ready <= 0;
                free_pointer_buf <= free_pointer;
                free_class <= free_pointer[15:14];
                free_state <= ST_FREE_DECIDE_QUEUE;           
             end
           end 
           ST_FREE_DECIDE_QUEUE: begin
                if((cache_pointer_free_cons_ptr[free_class]&(cache_depth-1)) != ((cache_pointer_free_prod_ptr[free_class]+1)&(cache_depth-1)))begin
                    cache_pointer_free_prod_ptr[free_class] <= cache_pointer_free_prod_ptr[free_class] + 1;
                    cache_pointer_free[free_class][cache_pointer_free_prod_ptr[free_class]&(cache_depth-1)] <= (free_pointer_buf -  CLASS_BASE[free_class])>>NEEDEDSIZE_FREE[free_class];
                    free_state <= ST_FREE_BEGIN;
                    free_ready <= 1;
                end
                else begin
                    if((recycle_cache_pointer_free_con_ptr[free_class]&(cache_depth-1)) != ((recycle_cache_pointer_free_pro_ptr[free_class] + 1)&(cache_depth-1)))begin
                        recycle_cache_pointer_free_pro_ptr[free_class] <= recycle_cache_pointer_free_pro_ptr[free_class] + 1;
                        recycle_cache_pointer_free[free_class][recycle_cache_pointer_free_pro_ptr[free_class]&(cache_depth-1)] <= (free_pointer_buf -  CLASS_BASE[free_class])>>NEEDEDSIZE_FREE[free_class];
                        free_state <= ST_FREE_BEGIN;
                        free_ready <= 1;               
                    end
                end
           end
        endcase
     end
  end
 // alloc recyclor
    localparam [3:0]
        ST_CLEAR_BIT_MAP = 0,
        ST_ALLOC_RECYCLE_IDLE = 1,
        ST_ALLOC_RECYCLE_BEGIN = 2,
        ST_ALLOC_RECYCLE_EXE_READ = 3,
        ST_ALLOC_RECYCLE_EXE_READ_GET = 4,
        ST_ALLOC_RECYCLE_EXE = 5,
        ST_ALLOC_RECYCLE_EXE_WRITE_BACK = 6;
    reg [3:0]   alloc_recycle_state[CLASS_COUNT-1:0]; 
    
    reg [3:0] bram_clear_counter[CLASS_COUNT-1:0];
    reg [3:0] bram_addr_counter[CLASS_COUNT-1:0];
    reg       alloc_front_back[CLASS_COUNT-1:0];
    reg [3:0] alloc_get_pointer_number[CLASS_COUNT-1:0]; 
    reg       alloc_exe_not_first[CLASS_COUNT-1:0];
    reg [10:0] alloc_exe_ptr[CLASS_COUNT-1:0];

    localparam [3:0]
        ST_FREE_RECYCLE_BEGIN = 0,
        ST_FREE_RECYCLE_DECIDE_READ = 1,  
        ST_FREE_RECYCLE_WRITE_BUF = 2,
        ST_FREE_RECYCLE_WRITE_BACK = 3;
    reg [3:0]   free_recycle_state[CLASS_COUNT-1:0];  
  
  reg [4:0]         alloc_addra  [CLASS_COUNT-1:0];
  reg [MEMORY_WIDTH-1:0]       alloc_dina   [CLASS_COUNT-1:0];
  reg [MEMORY_WIDTH-1:0]       alloc_douta  [CLASS_COUNT-1:0];
  reg [MEMORY_WIDTH-1:0]       alloc_douta_buf  [CLASS_COUNT-1:0];
  reg               alloc_wea    [CLASS_COUNT-1:0];
  reg               alloc_ena    [CLASS_COUNT-1:0];
  
  
  reg [4:0]         free_addrb   [CLASS_COUNT-1:0];
  reg [MEMORY_WIDTH-1:0]       free_dinb    [CLASS_COUNT-1:0];
  reg [MEMORY_WIDTH-1:0]       free_doutb   [CLASS_COUNT-1:0];
  reg               free_web     [CLASS_COUNT-1:0];
  reg               free_enb    [CLASS_COUNT-1:0];
  
  reg [11:0]         free_exe_pointer_buf [CLASS_COUNT-1:0] ;
  reg [MEMORY_WIDTH-1:0]       recycle_bram_free_exe_buffer[CLASS_COUNT-1:0] ;
  localparam int unsigned BRAM_DEPTH [CLASS_COUNT] = '{8, 4, 2, 1};



  bram_class1_ip bram_class1_ip_inst(
    .addra(alloc_addra[0]),
    .clka(clk),
    .dina(alloc_dina[0]),
    .douta(alloc_douta[0]),
    .ena(alloc_ena[0]),
    .wea(alloc_wea[0]),
    
    .addrb(free_addrb[0]),
    .clkb(clk),
    .dinb(free_dinb[0]),
    .doutb(free_doutb[0]),
    .enb(free_enb[0]),
    .web(free_web[0])
  );
   bram_class2_ip bram_class2_ip_inst(
    .addra(alloc_addra[1]),
    .clka(clk),
    .dina(alloc_dina[1]),
    .douta(alloc_douta[1]),
    .ena(alloc_ena[1]),
    .wea(alloc_wea[1]),
    
    .addrb(free_addrb[1]),
    .clkb(clk),
    .dinb(free_dinb[1]),
    .doutb(free_doutb[1]),
    .enb(free_enb[1]),
    .web(free_web[1])
  ); 
   bram_class3_ip bram_class3_ip_inst(
    .addra(alloc_addra[2]),
    .clka(clk),
    .dina(alloc_dina[2]),
    .douta(alloc_douta[2]),
    .ena(alloc_ena[2]),
    .wea(alloc_wea[2]),
    
    .addrb(free_addrb[2]),
    .clkb(clk),
    .dinb(free_dinb[2]),
    .doutb(free_doutb[2]),
    .enb(free_enb[2]),
    .web(free_web[2])
  ); 
  bram_class4_ip bram_class4_ip_inst(
    .addra(alloc_addra[3]),
    .clka(clk),
    .dina(alloc_dina[3]),
    .douta(alloc_douta[3]),
    .ena(alloc_ena[3]),
    .wea(alloc_wea[3]),
    
    .addrb(free_addrb[3]),
    .clkb(clk),
    .dinb(free_dinb[3]),
    .doutb(free_doutb[3]),
    .enb(free_enb[3]),
    .web(free_web[3])
  ); 
   wire [15:0]     m_in[CLASS_COUNT-1:0];
   wire [7:0][3:0] idx[CLASS_COUNT-1:0]; 
   wire [3:0]      cnt[CLASS_COUNT-1:0];  
  generate for (genvar gv=0; gv<CLASS_COUNT; gv=gv+1) begin: recyclors_alloc
    assign m_in[gv] = ((alloc_exe_ptr[gv] & (MEMORY_WIDTH-1)) == 504 ) ? {8'b1111_1111,alloc_douta_buf[gv][511:504]} : alloc_douta_buf[gv][(alloc_exe_ptr[gv] & (MEMORY_WIDTH-1)) +: 16] ;
      pick8_indices16 pick8_indices16_inst(
        .m_in(m_in[gv]),
        .idx(idx[gv]), 
        .cnt(cnt[gv])  
      );
     //alloc
      always @(posedge clk) begin
        if(!rst_n)begin
            alloc_addra[gv] <= '0;
            alloc_dina [gv] <= '0;
            alloc_douta[gv] <= '0;
            alloc_wea  [gv] <= '0; 
            alloc_ena  [gv] <= '0;
            alloc_recycle_state [gv] <= '0;
            cache_pointer_alloc_ready[gv] <= '0;
            bram_addr_counter[gv] <= '0;
            alloc_front_back[gv]  <= '0;
            alloc_exe_ptr[gv] <= '0;
            alloc_get_pointer_number[gv] <= '0;
            alloc_exe_not_first[gv] <= '0;
            bram_clear_counter[gv] <= '0; 
            alloc_douta_buf[gv] <= '0;
            alloc_cache_front_ready[gv] <= '0; 
            alloc_cache_back_ready[gv] <= '0; 
            has_recycled[gv] <='0;
        end
        else begin
            case (alloc_recycle_state [gv])
                ST_CLEAR_BIT_MAP: begin
                    if(bram_clear_counter[gv] < BRAM_DEPTH[gv])begin
                        alloc_ena  [gv] <= 1;
                        bram_clear_counter[gv] <= bram_clear_counter[gv] + 1'b1;
                        alloc_addra[gv] <= bram_clear_counter[gv];
                        alloc_dina [gv] <= '0;                 
                        alloc_wea  [gv] <= 1'b1;
                    end
                    else begin
                        bram_clear_counter[gv] <= '0; 
                        alloc_wea  [gv] <= 1'b0;
                        alloc_recycle_state[gv] <= ST_ALLOC_RECYCLE_IDLE; 
                    end
                end
                ST_ALLOC_RECYCLE_IDLE: begin                      
                    for(int i  = 0; i < cache_depth; i++)begin
                        cache_pointer_alloc[gv][i] <= i;
                        alloc_douta_buf[gv][i] <= 1'b1;
                    end 
                    alloc_cache_front_ready[gv] <= '1; 
                    alloc_cache_back_ready[gv] <= '1;           
                    alloc_exe_ptr[gv] <= alloc_exe_ptr[gv] + cache_depth/2;
                    cache_pointer_alloc_ready[gv] <= 1;
                    alloc_recycle_state[gv] <= ST_ALLOC_RECYCLE_BEGIN;
                end
                ST_ALLOC_RECYCLE_BEGIN: begin
                    alloc_wea[gv] <= 1'b0;
                    if(((cache_counter_alloc[gv]&(cache_depth-1)) == cache_depth/2) && !has_recycled[gv])begin
                        alloc_front_back[gv] <= 0; 
                        alloc_cache_front_ready[gv]<= 0;
                        if((alloc_exe_ptr[gv]& (MEMORY_WIDTH-1)) == 0)begin
                            alloc_recycle_state[gv] <= ST_ALLOC_RECYCLE_EXE_READ;
                        end
                        else begin
                            alloc_recycle_state[gv] <= ST_ALLOC_RECYCLE_EXE;
                        end               
                    end
                    if(((cache_counter_alloc[gv]&(cache_depth-1)) == cache_depth - 1) && !has_recycled[gv])begin
                        alloc_front_back[gv] <= 1;
                        alloc_cache_back_ready[gv]<= 0;
                        if((alloc_exe_ptr[gv]& (MEMORY_WIDTH-1)) == 0)begin
                            alloc_recycle_state[gv] <= ST_ALLOC_RECYCLE_EXE_READ;
                        end
                        else begin
                            alloc_recycle_state[gv] <= ST_ALLOC_RECYCLE_EXE;
                        end                         
                    end
                end
                ST_ALLOC_RECYCLE_EXE_READ: begin 
                   alloc_wea[gv] <= 1'b0;               
     
                   bram_addr_counter[gv] <= bram_addr_counter[gv] + 1;
                   alloc_addra[gv] <= bram_addr_counter[gv]&(BRAM_DEPTH[gv]-1);
                  
                    alloc_recycle_state[gv] <= ST_ALLOC_RECYCLE_EXE_READ_GET;
                end
                ST_ALLOC_RECYCLE_EXE_READ_GET: begin
                    alloc_douta_buf[gv] <= alloc_douta[gv];
                    alloc_recycle_state[gv] <= ST_ALLOC_RECYCLE_EXE;
                end
                ST_ALLOC_RECYCLE_EXE: begin
                    if((cache_counter_alloc[gv]&(cache_depth-1)) != cache_depth - 1)begin
                        if(alloc_get_pointer_number[gv] < 8)begin
                            if(((alloc_exe_ptr[gv] & (MEMORY_WIDTH-1)) == '0 )&& alloc_exe_not_first[gv] ) begin
                                alloc_recycle_state[gv] <= ST_ALLOC_RECYCLE_EXE_WRITE_BACK;
                            end
                            else begin
                                alloc_exe_not_first[gv] <= 1'b1;
                                for(int i = 0; i < ((cnt[gv] + alloc_get_pointer_number[gv] > 8)
                                    ? (8 - alloc_get_pointer_number[gv])
                                    :  cnt[gv]); i++)begin
                                    if(alloc_front_back[gv])begin
                                        cache_pointer_alloc[gv][i+8] <= ((alloc_exe_ptr[gv]  & (MEMORY_WIDTH-1))+ idx[gv][i]) + (bram_addr_counter[gv]&(BRAM_DEPTH[gv]-1)) * MEMORY_WIDTH ;
                                        
                                    end                       
                                    else begin
                                        cache_pointer_alloc[gv][i] <= ((alloc_exe_ptr[gv]  & (MEMORY_WIDTH-1))+ idx[gv][i]) + (bram_addr_counter[gv]&(BRAM_DEPTH[gv]-1)) * MEMORY_WIDTH;
                                    end  
                                    alloc_douta_buf[gv][((alloc_exe_ptr[gv] + idx[gv][i]) & (MEMORY_WIDTH-1)) ] <= 1'b1;                  
                                end
                                if(alloc_get_pointer_number[gv] +  cnt[gv] >= 8)begin
                                    alloc_exe_ptr[gv] <= alloc_exe_ptr[gv];
                                end
                                else begin
                                    alloc_exe_ptr[gv] <= alloc_exe_ptr[gv] + 8;
                                end
                                alloc_get_pointer_number[gv] <= alloc_get_pointer_number[gv] +  cnt[gv];
                            end
                        end
                        else begin
                            if(alloc_front_back[gv])begin
                                alloc_cache_back_ready[gv] <= 1'b1;
                            end
                            else begin
                                alloc_cache_front_ready[gv] <= 1'b1;
                            end
                            has_recycled[gv] <= 1'b1;
                            alloc_get_pointer_number[gv] <= 0; 
                            alloc_recycle_state[gv] <= ST_ALLOC_RECYCLE_BEGIN;                    
                        end
                    end
                end
                ST_ALLOC_RECYCLE_EXE_WRITE_BACK: begin
                    alloc_wea[gv] <= 1'b1;
                    alloc_addra[gv] <= bram_addr_counter[gv]&(BRAM_DEPTH[gv]-1);
                    alloc_dina [gv]  <= alloc_douta_buf[gv];
                    alloc_recycle_state[gv] <= ST_ALLOC_RECYCLE_EXE_READ; 
                end
            endcase
        end
      end
      //free
      always @(posedge clk) begin
        if(!rst_n)begin
           free_recycle_state[gv] <= '0;
           free_addrb [gv]  <= '0;
           free_dinb  [gv]  <= '0;
           free_web   [gv]  <= '0;
           free_enb   [gv]  <= '0;  
           free_exe_pointer_buf[gv] <= '0; 
           recycle_bram_free_exe_buffer[gv] <=  '0;             
        end
        else begin
            case(free_recycle_state[gv])
                ST_FREE_RECYCLE_BEGIN: begin
                     free_web   [gv]  <= 1'b0;
                    if((recycle_cache_pointer_free_con_ptr[gv]&(cache_depth-1)) != (recycle_cache_pointer_free_pro_ptr[gv]&(cache_depth-1)))begin
                       free_recycle_state[gv] <= ST_FREE_RECYCLE_DECIDE_READ;
                       free_exe_pointer_buf[gv] <= recycle_cache_pointer_free[gv][recycle_cache_pointer_free_con_ptr[gv]&(cache_depth-1)];
                       recycle_cache_pointer_free_con_ptr[gv] <= recycle_cache_pointer_free_con_ptr[gv] + 1; 
                       free_enb   [gv]  <= 1'b1;                                                                   
                    end
                end
                ST_FREE_RECYCLE_DECIDE_READ: begin
                    if(free_exe_pointer_buf[gv]/MEMORY_WIDTH == (bram_addr_counter[gv]&(BRAM_DEPTH[gv]-1)))begin
                        alloc_douta_buf[gv][free_exe_pointer_buf[gv]&(MEMORY_WIDTH-1)] <= 1'b0;
                        free_recycle_state[gv] <= ST_FREE_RECYCLE_BEGIN;
                    end
                    else begin
                       free_addrb [gv]  <= free_exe_pointer_buf[gv]/MEMORY_WIDTH;
                       free_recycle_state[gv] <= ST_FREE_RECYCLE_WRITE_BUF;
                    end
                end
                ST_FREE_RECYCLE_WRITE_BUF: begin
                    recycle_bram_free_exe_buffer[gv] <=  free_doutb  [gv] ;                   
                    free_recycle_state[gv] <= ST_FREE_RECYCLE_WRITE_BACK;
                end
                ST_FREE_RECYCLE_WRITE_BACK: begin
                    free_web   [gv]  <= 1'b1;
                    free_dinb  [gv]  <= recycle_bram_free_exe_buffer[gv] & ~((512'b1)<<(free_exe_pointer_buf[gv]&(MEMORY_WIDTH-1)));
                    free_recycle_state[gv] <= ST_FREE_RECYCLE_BEGIN;
                end
            endcase
        end
      end    
  end
  endgenerate 
 
endmodule
