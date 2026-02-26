module traffic_light_4way (
    input wire clk,
    input wire reset,
    
    // North signals
    output reg [2:0] north_light,   
    output reg       north_left_arrow,
    output reg       north_right_arrow,
    
    // South signals
    output reg [2:0] south_light,
    output reg       south_left_arrow,
    output reg       south_right_arrow,
    
    // East signals
    output reg [2:0] east_light,
    output reg       east_left_arrow,
    output reg       east_right_arrow,
    
    // West signals
    output reg [2:0] west_light,
    output reg       west_left_arrow,
    output reg       west_right_arrow
);

    reg [3:0] state, next_state;
    reg [3:0] counter;

    // Lighting parameters
    parameter red    = 3'b100;
    parameter yellow = 3'b010;
    parameter green  = 3'b001;
    
    // Arrow states
    parameter arrow_off = 1'b0;
    parameter arrow_on  = 1'b1;
   
    // State Parameters
    parameter s0  = 4'b0000;
    parameter s1  = 4'b0001;
    parameter s2  = 4'b0010;
    parameter s3  = 4'b0011;
    parameter s4  = 4'b0100;
    parameter s5  = 4'b0101;
    parameter s6  = 4'b0110; 
    parameter s7  = 4'b0111; 
    parameter s8  = 4'b1000; 
    parameter s9  = 4'b1001; 
    parameter s10 = 4'b1010; 
    parameter s11 = 4'b1011; 
   
    // State timing parameters
    parameter time_s0  = 9;
    parameter time_s1  = 1;
    parameter time_s2  = 4;
    parameter time_s3  = 1;
    parameter time_s4  = 4;
    parameter time_s5  = 1; 
    parameter time_s6  = 9;
    parameter time_s7  = 1;
    parameter time_s8  = 4;
    parameter time_s9  = 1;
    parameter time_s10 = 4;
    parameter time_s11 = 1; 
   
    // Current State Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state   <= s0;
            counter <= 4'b0000;
        end
        else begin 
            if ((state == s0  && counter == time_s0) ||
                (state == s1  && counter == time_s1) ||
                (state == s2  && counter == time_s2) ||
                (state == s3  && counter == time_s3) ||
                (state == s4  && counter == time_s4) ||
                (state == s5  && counter == time_s5) ||
                (state == s6  && counter == time_s6) ||
                (state == s7  && counter == time_s7) ||
                (state == s8  && counter == time_s8) ||
                (state == s9  && counter == time_s9) ||
                (state == s10 && counter == time_s10)||
                (state == s11 && counter == time_s11)) begin
               
                state <= next_state;
                counter <= 4'b0000;
            end
            else begin
                counter <= counter + 1; 
            end
        end
    end
   
    // Next state logic
    always @(*) begin
        case (state) 
            s0 : next_state = s1;
            s1 : next_state = s2;
            s2 : next_state = s3;
            s3 : next_state = s4;
            s4 : next_state = s5;  
            s5 : next_state = s6; 
            s6 : next_state = s7;
            s7 : next_state = s8;
            s8 : next_state = s9;
            s9 : next_state = s10;
            s10: next_state = s11; 
            s11: next_state = s0;  
            
            default : next_state = s0;
        endcase
    end
   
    // Output logic
    always @(*) begin
       
        // Default safe state
        north_light = red;
        south_light = red;
        east_light = red;
        west_light = red;
        
        north_left_arrow = arrow_off;
        north_right_arrow = arrow_off;
        south_left_arrow = arrow_off;
        south_right_arrow = arrow_off;
        east_left_arrow = arrow_off;
        east_right_arrow = arrow_off;
        west_left_arrow = arrow_off;
        west_right_arrow = arrow_off;
        
        case (state)
          
            s0 : begin 
                north_light = green;
                north_left_arrow = arrow_on;
                south_light = green;
                south_left_arrow = arrow_on;
            end

            s1 : begin
                north_light = green;
                north_left_arrow = arrow_on;
                south_light = yellow;
                south_left_arrow = arrow_off; 
            end
           
            s2 : begin
                north_light = green;
                north_left_arrow = arrow_on;
                north_right_arrow = arrow_on;
            end
           
            s3 : begin
                north_light = yellow;
            end
           
            s4 : begin
                south_light = green;
                south_right_arrow = arrow_on;
                south_left_arrow = arrow_on;
            end
           
            s5 : begin
                south_light = yellow;
            end

            s6 : begin 
                east_light = green;
                east_left_arrow = arrow_on;
                west_light = green;
                west_left_arrow = arrow_on;
            end
           
            s7 : begin
                east_light = green;
                east_left_arrow = arrow_on;
                west_light = yellow;
            end
           
            s8 : begin
                east_light = green;
                east_left_arrow = arrow_on;
                east_right_arrow = arrow_on;
            end
           
            s9 : begin
                east_light = yellow;
            end
           
            s10 : begin
                west_light = green;
                west_right_arrow = arrow_on;
                west_left_arrow = arrow_on;
            end
            
            s11 : begin
                west_light = yellow;
            end
           
            default : begin
                north_light = red;
                south_light = red;
                east_light = red;
                west_light = red;
            end
        endcase
    end
   
endmodule