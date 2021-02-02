# CellMAPtracer

[![DOI](https://zenodo.org/badge/249989991.svg)](https://zenodo.org/badge/latestdoi/249989991)

![CellMAPtracer](CellMAPtracerLogo.png)

## CellMAPtracer: A user-friendly tracking tool for long-term migratory and proliferating cells.  

### Getting Started
CellMAPtracer is built using MATLAB (v 9.8) and can be freely obtained as: (A) a standalone executable program for Microsoft Windows, macOS or GNU/Linux; (B) a MATLAB App/Toolbox; and (C) the source MATLAB code. 

#### (A)  CellMAPtracer standalone executable program. 
Navigate to https://github.com/ocbe-uio/CellMAPtracer/releases/tag/v1.0. Three assets of CellMAPtracer for Windows, Linux and macOS versions can be found and downloaded. After downloading the version compatible with your Operating System, users should uncompress the file and follow the instructions in the corresponding “readme.txt”. 
#### (B) CellMAPtracer MATLAB App
To be able to run CellMAPtracer App within the MATLAB environment, users should follow three simple steps: 1) Download the “App” folder from the CellMAPtracer repository: https://github.com/ocbe-uio/CellMAPtracer. 2) In MATLAB, go to APPS tab and click 'Install App' and find ”CellMAPtracer.mlappinstall” then install it. 3) Open CellMAPtracer App from Application list in MATLAB.

#### C) CellMAPtracer from the source MATLAB code
To be able to run CellMAPtracer code, users should clone the CellMAPtracer repository from https://github.com/ocbe-uio/CellMAPtracer and then run “CellMAPtracer_Main.m” after opening a project in MATLAB.

### Tracking single cells
CellMAPtracer is capable of loading multi-TIFF stacks (8 and 16 bits) of spatio-temporal live cell images as input for tracking. The output is an interactive multi-generation trajectory plot and 5 categories of trajectory data. The 5 categories include: all cells, dividing cells, non-dividing cells, daughter cells and dividing daughter cells. Each of these contains two spreadsheets. The first sheet contains the measurements of cell migration parameters such as the total distance, displacement, directionality and speed. The second sheet contains the x-y coordinates of tracked cells in the corresponding category. 


### CellMAPtracer FUCCI plug-in
The CellMAPtracer FUCCI plug-in enables users to profile the fluorescent signals of FUCCI‐expressing cells in 2-3 channel systems. It detects the cell cycle phase at any given time point throughout the course of the tracking. The input of the FUCCI plug-in is a multi-TIFF stack in RGB format of spatio-temporal live cell images which should be associated with the outcome of the tracking outcome of CellMAPtracer for the corresponding multi-TIFF stacks (8 and 16 bits). After loading the needed files and selecting the cell cycle detection method, the FUCCI phase algorithm automatically implements an internal RGB normalization. Users can inspect the normalized and the raw signals and monitor the detection of the cell cycle phases with a possibility of correcting the detection. 


### A list of suggested online visualization tools 
https://huygens.science.uva.nl/PlotsOfData
https://goodcalculators.com/box-plot-maker
https://chart-studio.plotly.com/create/box-plot/#/
http://www.alcula.com/calculators/statistics/box-plot
