# Digital Twin of a Continuous Laboratory Process (Tank Cascade)

## 📖 Overview
This repository contains the MATLAB/Simulink implementation of a Digital Twin (DT) for a laboratory-scale continuous process (a tank cascade model). This project was developed as part of an engineering thesis and is intended to serve as an **advanced educational tool** for process control classes.

The Digital Twin addresses several key laboratory challenges:
* **safety:** it allows students to freely test control algorithms (e.g., PID controllers, model predictive control) without the risk of damaging real-world actuators (pumps, valves)
* **visualization:** it provides insight into unmeasured variables, enabling the estimation and visualization of the process's internal dynamics, thereby deepening the understanding of the phenomena involved
* **diagnostics:** it serves as a platform for implementing and testing advanced safety interlocks and diagnostic tools.

A key research aspect of this project, included in the repository, is the **model parameter identification process**. The project provides scripts (`identyfikacjaParametrow.m`) for implementing and comparing different methodologies:
1.  **A *black-box* model** (based purely on measurement data)
2.  **A hybrid *grey-box* model** (which integrates a fundamental mathematical description of the process).

This allows for the analysis of the trade-off between model-fit accuracy and its generalizability and physical interpretability, which is crucial for educational applications.

## 📂 Repository Structure

The project is organized into the following modules:

### `01_PLC_control`
Contains the source code for the industrial controller (IDEC FC6A) managing the physical rig and communication.
* **`identyfikacja.pjw`**: the original ladder logic project file implementing basic logic, scaling, and Modbus TCP/IP communication server.
* **`Modbus_Register_Map.pdf`**: Documentation of the memory map used for data exchange between the physical PLC and the Digital Twin.

### `02_Matlab_Simulink`
The core simulation models.
* **`DT.slx`**: real-time Digital Twin model with Modbus TCP/IP blocks for bi-directional synchronization with the physical plant.
* **`DT_offline.slx`**: standalone simulation model for offline testing and algorithm development.
* **`macierze_do_modelu.mat`**: data file containing initialization parameters, state-space matrices, and physical constants required for the simulations.
* **`main_pid_optimizer.m`**: PID tuning function using Nelder-Mead algorithm.

### `03_analysis_scripts`
MATLAB scripts demonstrating the mathematical rigor of the project (Identification & Validation).
* **`synchronize_sigmnal.m`**: script synchronizing signals - both rising and falling edge ignoring earlier measurements.

### `04_HMI_visualization`
* **`DT_app.mlapp`**: a MATLAB App Designer application serving as the Human-Machine Interface. It provides real-time visualization of the process state and allows for control mode switching (Monitor/Control).
* **`DT_app_offline.mlapp`**: HMI for the offline model. 

## ⚙️ Requirements

The following software is required to run this project:
* **Matlab 2025b** (or newer) - for the online version
* **Matlab 2024a** (or newer) - for the offline version
* **Simulink**
* **Simulink Desktop Real-Time**
* **Simulink Industrial Communication** - for the online version.

## 🚀 Getting Started

1.  Clone the repository to your local machine.
2.  Open MATLAB 2024a (or newer).
3.  Ensure all required Toolboxes from the `Requirements` section are installed.
4.  Make sure the project folder (including the `.mat` file) is added to the MATLAB path.
5.  To launch the user interface, open and run the **`DT_app.mlapp`** application.

## 🎓 Academic Context

This project serves as the practical implementation of the models and concepts being developed for an upcoming B.Sc. engineering thesis *"Digital twin of the continuous laboratory process"* at **AGH University of Krakow**. The model and its identification methods are being verified and validated using measurement data collected from a real-world laboratory rig.
