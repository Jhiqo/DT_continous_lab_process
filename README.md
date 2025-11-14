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

## 🛠️ Repository Contents

* **`DT_online.slx`**
    * The online Simulink model implementing the dynamics of the tank cascade process.

* **`DT.slx`**
    * The offline Simulink model implementing the dynamics of the tank cascade process.

* **`DT_app.mlapp`**
    * A MATLAB App Designer application that serves as the HMI (Human-Machine Interface) for visualization and control. It allows for real-time interaction with the Digital Twin.

* **`macierze_do_modelu.mat`**
    * A `.mat` data file containing matrices (likely state-space matrices or other pre-defined parameters) required to correctly run the `DT.slx` simulation.

* **`identyfikacjaParametrow.m`**
    * A MATLAB script that performs the parameter identification process. It implements the minimization of a cost function (described in the thesis as equation 2.2) to fit the model parameters to measurement data.

## ⚙️ Requirements

The following software is required to run this project:
* **Matlab 2025b** (or newer) - for an online version
* **Matlab 2024a** (or newer) - for an offline version
* **Simulink**
* **Simulink Desktop Real-Time**
* **Simulink Industrial Communication**

## 🚀 Getting Started

1.  Clone the repository to your local machine.
2.  Open MATLAB 2024a (or newer).
3.  Ensure all required Toolboxes from the `Requirements` section are installed.
4.  Make sure the project folder (including the `.mat` file) is added to the MATLAB path.
5.  To launch the user interface, open and run the **`DT_app.mlapp`** application.
6.  To analyze the identification process, open and run the **`identyfikacjaParametrow.m`** script.

## 🎓 Academic Context

This project serves as the practical implementation of the models and concepts being developed for an upcoming B.Sc. engineering thesis *"Digital twin of the continuous laboratory process"* at **AGH University of Krakow**. The model and its identification methods are being verified and validated using measurement data collected from a real-world laboratory rig.
