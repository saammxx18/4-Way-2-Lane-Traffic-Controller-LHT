# 4-Way-2-Lane-Traffic-Controller-LHT
A safe, collision-free, 4-way 2-lane traffic light controller designed in Verilog. Implements a 12-state Finite State Machine (FSM) optimized for Left-Hand Traffic (India/UK) rules with deadlock protection.

Hi there! This is a Verilog project where I designed a traffic light controller specifically for **Left-Hand Traffic (LHT)** regions like India and the UK.
My main goal with this design was to solve a real-world safety issue: preventing collisions during opposing "Right Turns" at busy intersections.

## Why I built this
Standard traffic controllers often let opposing traffic turn right simultaneously. In countries where we drive on the left, this can lead to a dangerous "locking turn" scenario where vehicle paths cross in the middle of the intersection.
To fix this, I designed a **12-state Finite State Machine (FSM)** that strictly separates these conflicting turns. It trades a bit of speed for significantly higher safety, ensuring that when one side is turning right, the oncoming traffic is completely stopped.

## Key Features
Here is what makes this controller safe and reliable:

* **Safety First Logic:** The system guarantees that North-South and East-West lanes never get green signals at the same time.
* **LHT Optimized:** It gives dedicated time slots for Right Turns, preventing head-on collisions.
* **No "Instant Red":** I added specific intermediate Yellow states (S5 and S11) to act as safety buffers when transitioning from a turn back to straight traffic.
* **Self-Correcting:** If the system gets stuck or reset, the FSM automatically returns to a safe starting state (S0).
* **FPGA Ready:** The Verilog code is synthesizable and ready to be loaded onto hardware like an Artix-7 FPGA.

## How the Logic Works

The controller cycles through 12 states to manage the flow. I split the "Right Turn" phases so they happen one at a time.

|  State  |          What's happening?        | Duration (Cycles) |
|  :----  |          :----------------        | :---------------- |
|  **S0** | NS go straight & turn left                | 9 |
|  **S1** | South prepares to stop (Yellow)           | 1 |
|  **S2** | **North turns right** (South is held Red) | 4 |
|  **S3** | North prepares to stop (Yellow)           | 1 |
|  **S4** | **South turns right** (North is held Red) | 4 |
|  **S5** | South safety buffer (Yellow)              | 1 |
|  **S6** | EW go straight & turn left                | 9 |
|  **S7** | West prepares to stop (Yellow)            | 1 |
|  **S8** | **East turns right** (West is held Red)   | 4 |
|  **S9** | East prepares to stop (Yellow)            | 1 |
| **S10** | **West turns right** (East is held Red)   | 4 |
| **S11** | West safety buffer (Yellow)               | 1 |

## Verification
I wrote a self-checking testbench to make sure the logic holds up.

### The Problem solved
This hand-drawn diagram shows the exact "locking" collision scenario I wanted to prevent with this logic. By separating the blue paths, we avoid the red X's.
![Intersection Diagram showing locking turns]

(intersection_diagram.jpg)

### Simulation Results
The simulation waveform confirms that the safety logic works. You can see the transitions are smooth and conflicting green lights never overlap.
![GTKWave Simulation Output]

(waveform_simulation.png)

## Running the Project
If you want to try this out on your local machine using Icarus Verilog:

1.  **Clone the repo:**
    ```bash
    git clone [https://github.com/saammxx18/4way-2lane-traffic-lht.git](https://github.com/saammxx18/4way-2lane-traffic-lht.git)
    ```
2.  **Compile:**
    ```bash
    iverilog -o traffic_sim traffic_light_4way.v traffic_light_4way_tb.v
    ```
3.  **Run:**
    ```bash
    vvp traffic_sim
    ```

---
*Project created by **Sambhram Tailang (saammxx18)**. Feel free to connect or open an issue if you have feedback!*
