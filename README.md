# DT_continous_lab_process
This repository contains MATLAB implementations of the algorithms developed in 

## 📖 Overview
The design of informative input signals is crucial for accurate system identification.
Traditional Fisher-information–based approaches are inherently local and may fail under large parameter uncertainty or nonlinear dynamics.
This project implements a Bayesian input design framework based on maximizing the mutual information (MI) between model parameters and observations, using a tractable lower bound.

Key contributions implemented here:

efficient computation of the Kolchinsky–Tracey MI lower bound
a highly efficient, Kalman filter-based algorithm that makes the method feasible for long experiments by avoiding the inversion of large covariance matrices
example scripts replicating selected results from the paper.

## ⚙️ Functions
- `DT.slx` - Simulink model of the tanks cascade.
- `DT_app.mlapp` - MATLAB App Designer app containing visualization and control.
- `macierze_do_modelu.mat` - data required in the model.
- `identyfikacjaParametrow.m` - minimalization of a cost function function (2.2).

## 💻 Requirements
- Matlab 2024a
- Simulink
- Simulink Desktop Real-Time
- Simulink Industrial Communication

