//---------------Variable Params------------// 
parameter run_time = 100000; // Run time of the design
parameter clk_period = 100; //In pico seconds
parameter num_of_cols_fm = 96;  // Change to modify the number of cols in feature matrix you can take -- MAX VALUE = 96
parameter num_of_rows_wm = 3;  // Change to modify the number of cols in weight matrix you can take -- MAX_VALUE = 3
parameter num_of_rows_fm = 6;  // Change to modify the number of rows in feature matrix you can take -- MAX_VALUE = 6
parameter num_of_outs = 6;  // Change to modify the number of outputs the design can produce at a time -- MAX_VALUE = 6
parameter cycles_to_finish = 15; // Change to modify the number of cycles it takes for the design to give the final output
//-----------------------------------------//

//---------------Fixed Params--------------// !!!!!!!! NOT MEANT TO BE CHANGED !!!!!!!!!!!!
parameter BW = 5;
parameter num_of_elements_in_col = 6; // For feature matrix
parameter num_of_elements_in_row = 96; // For both features and weights again cause weights are transposed for easier access
parameter num_of_nodes = 6;
parameter bits_to_represent_nodes = $clog2(num_of_nodes);
parameter num_of_rows_in_w_mem = 3;
parameter num_of_rows_in_f_mem = 6; 
//-----------------------------------------//

module gcn(
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    input  var [num_of_cols_fm-1:0] [num_of_elements_in_col*BW-1:0] col_features,
    input  var [num_of_rows_wm-1:0] [num_of_elements_in_row*BW-1:0] row_weights,
    input  var [1:0] [17:0] COO_mat,
    output logic [num_of_rows_wm-1:0] [1:0] input_addr_wm,
    output logic [num_of_rows_fm-1:0] [2:0] input_addr_fm_row, 
    output logic [num_of_cols_fm-1:0] [6:0] input_addr_fm_col,
    output logic [num_of_outs-1:0] [2:0] output_addr,
    output logic [num_of_outs-1:0] [2:0] y,
    output logic done
);
integer i,j,val1,val2,cyc,k,c1, c2, c3,c4;
logic [14:0]trans_matrix [5:0][2:0];
logic [14:0]output_matrix[5:0][2:0];
logic [num_of_rows_in_f_mem-1:0] [num_of_rows_in_f_mem-1:0] adj_matrix;
//
//  counter	
//
always @ (negedge clk) begin
		if(rst_n == 1'b0)
			cyc <= 0;
		else if (start == 1'b1)
			cyc <= cyc + 1;
end

always@(negedge rst_n) begin
	for(c1=0;c1<3'd6;c1++)begin
		input_addr_fm_row[c1] = c1;
	end

	for(c2=0;c2<2'd3;c2++) begin
		input_addr_wm[c2] = c2;
	end

	for(c3=0;c3<7'd96;c3++) begin
		input_addr_fm_col[c3] = c3;
	end
end
//
//  COO_decode
//
always@(posedge clk) begin
	if (cyc <7'd3) begin
		for(i=0;i<num_of_rows_in_f_mem;i++) begin
			for(j=0;j<num_of_rows_in_f_mem;j++) begin
				adj_matrix[i][j]=0;
			end
		end
	end

	if (cyc > 7'd3) begin
		for(j=0;j<num_of_rows_in_f_mem;j++) begin
			val1=COO_mat[0][3*j+:3];
			val2=COO_mat[1][3*j+:3];
			adj_matrix[val1-1][val2-1]=1'b1;
        		adj_matrix[val2-1][val1-1]=1'b1;
		end
	end
end
//
// Transformation Block
//
always@(posedge clk)begin
	if(cyc<7'd3)begin
		for(i=0;i<3'd6;i++) begin
			for(j=0;j<2'd3;j++) begin
				trans_matrix[i][j]=0;
			end
	end
	end
	if (cyc > 7'd6) begin
		if (cyc < 7'd8) begin
			for(i=0;i<3'd6;i++)begin
				for(j=0;j<2'd3;j++)begin
					for(k=1'b0;k<7'd96;k++)begin
						trans_matrix[i][j]=trans_matrix[i][j]+(col_features[i][5*k+4 -: 5]*row_weights[j][5*k+4 -: 5]);
					end
				end
			end
		end
	end
end
//
// Aggregation Block
//
always@(posedge clk) begin
	if(cyc<7'd3)begin
		for(i=0;i<3'd6;i++) begin
			for(j=0;j<2'd3;j++) begin
				output_matrix[i][j]=0;
			end
		end
	end

	if (cyc > 7'd8) begin
		for(i=0;i<3'd6;i++)begin
			for(j=0;j<2'd3;j++)begin
				for(k=0;k<3'd6;k++)begin
						output_matrix[i][j]=output_matrix[i][j]+(adj_matrix[i][k]*trans_matrix[k][j]);
				end
			end
		end
	end
end
//
//  Argmax Block
//
always@(posedge clk) begin

	if(cyc<7'd5)begin
		for(i=0;i<3'd6;i++) begin
				y[i]=0;
		end
	end

	if (cyc > 7'd10) begin
		for(i=0;i<6;i++)begin
			if(output_matrix[i][0]>output_matrix[i][1] && output_matrix[i][0]>output_matrix[i][2]) begin
					y[i]=3'd0;
			end
			else if (output_matrix[i][1]>output_matrix[i][0] && output_matrix[i][1]>output_matrix[i][2]) begin
					y[i]=3'd1;
			end
			else if (output_matrix[i][2]>output_matrix[i][0] && output_matrix[i][2]>output_matrix[i][1]) begin
					y[i]=3'd2;
			end

		end
			
	end
		done= 1'b1;
		for(c4=0;c4<7'd6;c4++) begin
			output_addr[c4] = c4;
			end
end
endmodule


