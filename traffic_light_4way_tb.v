`timescale 1ns/1ps

module traffic_light_4way_tb;
  
    reg clk, reset;
  
    wire [2:0] north_light, south_light, east_light, west_light;
    wire north_left_arrow, north_right_arrow;
    wire south_left_arrow, south_right_arrow;
    wire east_left_arrow, east_right_arrow;
    wire west_left_arrow, west_right_arrow;
  
    parameter red    = 3'b100;
    parameter yellow = 3'b010;
    parameter green  = 3'b001;

    // Instantiate the DUT
    traffic_light_4way DUT (
        .clk(clk),
        .reset(reset),
        
        .north_light(north_light),
        .north_left_arrow(north_left_arrow),
        .north_right_arrow(north_right_arrow), 
        
        .south_light(south_light),
        .south_left_arrow(south_left_arrow),
        .south_right_arrow(south_right_arrow), 
        
        .east_light(east_light),
        .east_left_arrow(east_left_arrow),
        .east_right_arrow(east_right_arrow), 
        
        .west_light(west_light),
        .west_left_arrow(west_left_arrow),
        .west_right_arrow(west_right_arrow)
    );
  
    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period
    end

    // Test Stimulus
    initial begin
        $dumpfile("traffic_light_4way.vcd");
        $dumpvars(0, traffic_light_4way_tb);

        // Test 1: Power-on reset
        $display("\n=== Test 1: Power-on Reset ===");
        reset = 1;
        #20;                    // Hold reset
        reset = 0;
        $display("Reset released. FSM should start in S0.\n");
        
        // Test 2: Run for full cycle sequence
        $display("=== Test 2: Running through full sequence (S0 to S11) ===");
        #600; 
        
        // Test 3: Reset during operation
        $display("\n=== Test 3: Reset During Operation ===");
        reset = 1;
        #20;
        reset = 0;
        $display("Reset applied. Checking recovery to S0...\n");
        
        #200;
        
        $display("\n=== Simulation Complete ===");
        $finish;
    end
  
    // Display Header
    initial begin
        $display("\n==========================================================================================");
        $display(" Time  | State Name    | Cnt | North (L/R) | South (L/R) | East (L/R)  | West (L/R) ");
        $display("-------|---------------|-----|-------------|-------------|-------------|------------");
    end
  
    // Monitor: Print only when State changes or Counter wraps
    reg [3:0] prev_state;
    always @(posedge clk) begin
        if (DUT.state != prev_state || DUT.counter == 0) begin
            print_status();
            prev_state <= DUT.state;
        end
    end

    task print_status;
        begin
            $display("%5t | %-13s | %2d  |  %s   %s %s  |  %s   %s %s  |  %s   %s %s  |  %s   %s %s",
                $time,
                get_state_name(DUT.state),
                DUT.counter,
                
                decode_light(north_light), (north_left_arrow?"L":"-"), (north_right_arrow?"R":"-"),
                decode_light(south_light), (south_left_arrow?"L":"-"), (south_right_arrow?"R":"-"),
                decode_light(east_light),  (east_left_arrow?"L":"-"),  (east_right_arrow?"R":"-"),
                decode_light(west_light),  (west_left_arrow?"L":"-"),  (west_right_arrow?"R":"-")
            );
        end
    endtask
  
    // Helper Functions

    function [2*8:1] decode_light;
        input [2:0] light;
        begin
            case (light)
                3'b001:  decode_light = "G "; 
                3'b010:  decode_light = "Y "; 
                3'b100:  decode_light = "R "; 
                default: decode_light = "??"; 
            endcase
        end
    endfunction

    function [13*8:1] get_state_name;
        input [3:0] s;
        begin
            case(s)
                4'd0:  get_state_name = "NS_STRAIGHT";
                4'd1:  get_state_name = "S_STOPPING";
                4'd2:  get_state_name = "N_RIGHT_TURN";
                4'd3:  get_state_name = "N_STOPPING";
                4'd4:  get_state_name = "S_RIGHT_TURN";
                4'd5:  get_state_name = "S_YELLOW_NEW";
                4'd6:  get_state_name = "EW_STRAIGHT";
                4'd7:  get_state_name = "W_STOPPING";
                4'd8:  get_state_name = "E_RIGHT_TURN";
                4'd9:  get_state_name = "E_STOPPING";
                4'd10: get_state_name = "W_RIGHT_TURN";
                4'd11: get_state_name = "W_YELLOW_NEW";
                default: get_state_name = "UNKNOWN";
            endcase
        end
    endfunction
  
    // Safety Assertions

    // 1. Invalid Output Check
    always @(posedge clk) begin
        if (!reset) begin 
            if (north_light == 0 || south_light == 0 || east_light == 0 || west_light == 0) 
                $display("ERROR at %t: One or more lights are blacked out (000)!", $time);
        end
    end

    // 2. Strict Collision Check (Mutually Exclusive Groups)
    // If North OR South is NOT Red, then East AND West MUST be Red.
    always @(posedge clk) begin
        if (!reset) begin
            // Check NS vs EW
            if ((north_light != red || south_light != red) && 
                (east_light != red || west_light != red)) begin
                
                $display("CRITICAL FAILURE at %t: Traffic flowing on both NS and EW axes!", $time);
                $stop; // Stop simulation immediately on crash
            end
        end
    end

    // 3. State Duration Checker
    integer state_entry_time;
    integer state_duration;
    reg [3:0] last_tracked_state;
    reg first_run;
    
    initial begin
        first_run = 1;
        state_entry_time = 0;
    end
    
    always @(posedge clk) begin
        if (reset) begin
            last_tracked_state = 0;
            state_entry_time = $time;
            first_run = 1;
        end
        else if (DUT.state != last_tracked_state) begin
            state_duration = ($time - state_entry_time) / 10;
            
            if (!first_run) begin
               $display("      >> State %s completed. Duration: %0d cycles", 
                        get_state_name(last_tracked_state), state_duration);
            end
            
            last_tracked_state = DUT.state;
            state_entry_time = $time;
            first_run = 0;
        end
    end

endmodule