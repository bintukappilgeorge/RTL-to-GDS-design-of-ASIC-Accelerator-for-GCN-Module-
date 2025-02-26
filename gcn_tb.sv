`timescale 1ps/1ps
module gcn_tb();

`include "./params.vh" // All parameters

//----------TB Port Declaration--------------//
// -> From TB.  <- To TB.
logic clk,rst_n,start; // ->
logic [num_of_rows_fm-1:0] [num_of_elements_in_row*BW-1:0] row_features; // Port for feature matrix -> // Rowise decode
logic [num_of_cols_fm-1:0] [num_of_elements_in_col*BW-1:0] col_features; // Port for feature matrix -> // Added functionality for colwise dedcode.
logic [num_of_rows_wm-1:0] [num_of_elements_in_row*BW-1:0] row_weights; // Port for weight matrix -> // Weights are transposed for easier access. Hence number of rows
logic [1:0] [17:0] COO_mat; //Port for adjacency matrix ->
logic [num_of_outs-1:0] [2:0] y; //Port for outputs <-
logic input_re; // Port for reading memory from TB <-
logic [num_of_rows_wm-1:0] [1:0] input_addr_wm; // Address for selecting 1-3 rows(transoposed cols) of weights. So max val for num_of_rows_wm = 1-3. <-
logic [num_of_rows_fm-1:0] [2:0] input_addr_fm_row; // Address for selecting 1-6 rows of features. So val for num_of_rows_fm = 1-6. <-
logic [num_of_cols_fm-1:0] [6:0] input_addr_fm_col; // Address for selecting 1-96 cols of features. So val for num_of_cols_fm. <- 1-96. <-
logic output_we; // <-
logic [num_of_outs-1:0] [2:0] output_addr; // <-
logic done; // <-
logic [num_of_outs-1:0] [9:0] Aggregated_out; // <-
logic [num_of_outs*7-1:0] Aggregated_address [1:0]; // <- First should have row address and second row should have column address for the Aggregated memory in the TB
// For Aggregated address the BW is calculated by num_of_outs * 7. (7 being the max bits to represent 96 values in the Aggregated_matrix_memory). 
// Num_of_outs are the number of outputs generated by the module. So every 7 bits there will be one output
//----------------------------------------//


////For counter////
int count = 0;
int countb = 0;
always @(negedge clk) begin // Counter for tb
  count = count + 1;
end

always @(posedge clk) begin // Counter for design
  countb = countb +1;
  end
////////////////////


//----------Module Declaration--------------//
gcn DUT (.clk(clk),
         .rst_n(rst_n),
         .start(start),
         .col_features(col_features),
         //.row_features(row_features),
         .row_weights(row_weights),
         .COO_mat(COO_mat),
         .y(y),
         //.input_re(input_re),
         .input_addr_wm(input_addr_wm),
         .input_addr_fm_row(input_addr_fm_row),
         //.output_we(output_we),
         .output_addr(output_addr),
         //.Aggregated_out(Aggregated_out),
         //.Aggregated_address(Aggregated_address),
         .done(done)
);
//-----------------------------------------//


//---------Memory Initialization------------//
logic  [BW-1:0] Feature_matrix_memory [num_of_rows_in_f_mem]  [num_of_elements_in_row]; //Each row of the memory has 96 features i.e 6x96 sized feature matrix
logic  [BW-1:0] Aggregated_matrix_memory_golden [num_of_rows_in_f_mem]  [num_of_elements_in_row]; // Has the Feature aggregation outs(If aggregation is performed first)
logic  [BW-1:0] Weight_matrix_memory [num_of_rows_in_w_mem] [num_of_elements_in_row];   // Each row has 3 classes so 96x3 sized matrix
logic  [bits_to_represent_nodes-1:0] ADJ_matrix_memory [1:0] [num_of_nodes];             // 1st row has the source nodes the 2nd row has the destination nodes
logic  [bits_to_represent_nodes-1:0] gcn_out_memory [5:0];                             // Has 5 rows each 3 bits long to store the index of the output
logic  [bits_to_represent_nodes-1:0] gcn_out_memory_golden [5:0];                      // Has 5 rows each 3 bits long to store the index of the output
logic  [BW*2-1:0] Aggregated_matrix_memory [num_of_rows_in_f_mem] [num_of_elements_in_row]; // Has the same dimensions of that of the feature matrix. 6x6 * 6x96 = 6*96 but 10 its wide

//-----------------------------------------//

//--------------File Declarations--------------//
`include "tasks_to_read_txt.sv" // All tasks to read input files
`include "./parametrized_decode_subtask.sv"// Decoders for memory access
`include "./clk_gen_reset_subtask.sv" // Generate Clock
`include "./vcd_vpd_subtasks.sv" // VCD,VPD for power and DVE waveviewer
`include "./give_outputs.sv" // For giving inputs to TB for testing
`include "./finish_subtask.sv" // Denotes the finish for TB
//--------------------------------------------//

//------------------ Tb ---------------------//
always @(negedge clk) begin
   init_inputs(); // Initializes all the inputs to 0
   reset_dut();   // Resets the design -- active high reset.
   start_valid(); // Provides the start valid signal and also stops the start signal when done singal is provided by the GCN module
   send_features_weights_COO_WB(); // Performs the memory decode to give the features weights and COO matrix and also performs the write back
   //compare_online(); // For onine students to compare the design outs with golden outs(Aggregation only) !!!!!!
   compare_F2F(); // For F2F students to compare the design outs with golden outs !!!!!!!!!!!!

end
//------------------------------------------------//

//-------------For testing purpose------------//
always @(posedge clk) begin
  //give_outputs();
  // Can use this portion to print out values from the gcn module for debugging purpose
end
//------------------------------------------------//


//-------------------------------------------------------------//
//Fetching the values from the text file and generating clock
//-------------------------------------------------------------//
initial begin
  get_features(); // Reads the txt file for feature matrix
  get_weights();  // Reads the txt file for weight matrix
  get_sparse_matrix(); // Reads the txt file for sparse matrix
  get_golden_outputs(); // Reads the golden outputs file
  //get_fa_matrix(); // FA matrix from txt file
end
//-------------------------------------------------------------//

//-------------------------------------------------------------//
initial begin
  clk_gen(); // Generates clock
end
//-------------------------------------------------------------//

//-------------------------------------------------------------//
// Dumps the VPD for DVE and VCD for power analysis
//-------------------------------------------------------------//
initial begin
  //dump_vcd();
 // dump_vpd(); // Comment it out if it throws errors or warnings
  finish();
end
endmodule
//-------------------------------------------------------------//
