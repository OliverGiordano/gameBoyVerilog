This project is a Game Boy implementation written in SystemVerilog. 

While designing the Cpu I created a diagram mapping out individual connection between components. 
In future projects I will not continue to use Google Slides for this type of diagram.

<img width="1089" height="615" alt="image" src="https://github.com/user-attachments/assets/8fb4fc8a-e1a7-4e34-9383-1de2387544dd" />


Programs are loaded into Rom and passed onto the control unit, which is a implemented as a FSM to make it possible to handle the variable length instructions that come with the x86 architecture the Game Boy uses 


Here is it launching the loading screen for Tetris
<img width="745" height="682" alt="image" src="https://github.com/user-attachments/assets/970ce9fb-7524-4e08-879d-37c74c3a8e8d" />


For display out, the Game Boy writes to a frame buffer, I use Verilator with C++ to pull that frame buffer and display on my computer.
