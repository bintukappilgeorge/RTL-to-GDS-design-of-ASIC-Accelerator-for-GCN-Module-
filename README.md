# RTL-to-GDS-design-of-ASIC-Accelerator-for-GCN-Module-

## 📌 Table of Contents
- [Introduction](#introduction)
- [Design Overview](#design-overview)
- [Pipeline Stages](#pipeline-stages)
- [Testbench and Verification](#testbench-and-verification)
- [Performance and Results](#performance-and-results)
- [Future Work](#future-work)
- [How to Run](#how-to-run)
- [Conclusion](#conclusion)

---

## 🔍 Introduction
Graph Convolutional Networks (GCNs) have become a powerful tool for processing graph-structured data, enabling applications in social networks, bioinformatics, and recommendation systems. This project focuses on designing and implementing an **ASIC-accelerated GCN module** optimized for node classification.

The objective is to:
- Develop a **low-power** GCN module.
- Ensure an **end-to-end latency of <8ns**.
- Implement **hardware-efficient sparse multipliers and adders**.
- Perform **ASIC synthesis, APR, and power analysis**.

---

## 🏗️ Design Overview
![Screenshot 2025-02-13 080619](https://github.com/user-attachments/assets/01e06828-ed8c-4d09-8492-a6777d653471)

The GCN module consists of the following main operations:
1. **Feature Aggregation** – Matrix-vector multiplication between an adjacency matrix and feature matrix.
2. **Feature Transformation** – Multiplication of aggregated features with a weight matrix.
3. **Classification using Argmax** – Determines the highest probability class.

### ✅ Key Design Considerations:
- Implemented **COO (Coordinate) format** for sparse matrix representation to optimize memory usage.
- Used **parallel processing techniques** to enhance throughput.
- Designed a **hardware-efficient multiplier and adder** for fast weighted sum computations.
- **Pipelined the operations** to balance latency and power consumption.

---

## 🔄 Pipeline Stages
The design is **fully pipelined**, ensuring all operations are scheduled efficiently. Below is the breakdown of each stage:

| Clock Cycle | COO Decode | Transformation | Aggregation | Argmax |
|------------|-----------|---------------|------------|--------|
| 1-7        | Decode   | Matrix Mult.  | Vector Add | Compare|

![Screenshot 2025-02-13 081953](https://github.com/user-attachments/assets/38f76e75-cdd4-40dd-922c-3d212ed46a46)


**Optimization Approach:**
- The **entire design operates within a single clock cycle**.
- **Cycle counters** enable sequential activation of different modules.
- **Separate address generators** prevent address conflicts.

---

## 🧪 Testbench and Verification
### 📝 Testbench Functionality
#### The testbench (tb_gcn.sv) validates:
- Correctness of feature aggregation and transformation.
- Functional verification of argmax classification.
- Post-synthesis and post-APR simulations.

### ✅ Verification Steps
- Behavioral Simulation – Ensures the RTL design functions correctly.
- Post-Synthesis Simulation – Verifies the synthesized Verilog netlist.
- Post-APR Simulation – Runs the testbench on the placed-and-routed netlist.

### 📌 Golden Output Comparison
A golden.txt file contains expected results. The testbench compares:

---

## 📊 Performance and Results
### 🔹 Performance Metrics
| Parameter | Value |  
|------------|-----------| 
| Total Latency | 2.5 ns @ 1000 MHz |
| Total Power | 789.618 mW |  
| Area | 0.1777 mm² (Standard + Filler cells) |  
| Gate Count | 253,903 Gates |  
| Cell Count | 121,526 Cells |  
| Innovus Density | 55.56% |  

### 📌 Power and Area Optimization
- Implemented clock gating to minimize dynamic power consumption.
- Optimized data flow to reduce redundant memory accesses.

---

## 🚀 Future Work
- Further reduce power consumption using advanced clock gating techniques.
- Scale the design for larger graph datasets.
- Extend to support multi-layer GCN architectures.

---

## 🛠️ How to Run
### Step 1: Simulate RTL
```sh
vcs -full64 tb_gcn.sv -o simv
./simv
```

### Step 2: Run Synthesis
```sh
dc_shell -f synth_script.tcl
```

### Step 3: Perform Place & Route
```sh
innovus -init apr_script.tcl
```

### Step 4: Run DRC & LVS in Virtuoso
- Import GDS file into Virtuoso
- Run DRC & LVS checks.

---

## 📌 Output

- Simulation
![Screenshot 2025-02-13 082021](https://github.com/user-attachments/assets/6bbded39-f8a7-4f46-8908-f6cd6885ccce)

- Power Analysis
![Screenshot 2025-02-13 082031](https://github.com/user-attachments/assets/7dbbe1b8-1cd1-408f-b5ff-756e746ce2b0)

- Floorplanning
![Screenshot 2025-02-13 082037](https://github.com/user-attachments/assets/5081e7fe-6b45-4c23-af89-41f1660b39ac)

- LVS (error)
![Screenshot 2025-02-13 082102](https://github.com/user-attachments/assets/2034b403-b4b8-40ba-adda-637305567167)

---

## 🎯 Conclusion
This project successfully implements an ASIC-accelerated Graph Convolutional Network (GCN) optimized for low latency and power efficiency. Key takeaways:
- Optimized design using a sparse COO format.
- Achieved 2.5 ns latency while maintaining functionality.
- Significant power optimizations using efficient memory management and hardware-accelerated operations.

---

