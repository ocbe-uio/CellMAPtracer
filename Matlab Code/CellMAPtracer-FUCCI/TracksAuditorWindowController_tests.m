% Takes one minute
close all
clear all
clc 

%% RGB TEST:
% Load Multitiff and AllTracks
addpath('saveastiff_4_5/')
Multitiff = loadtiff('ExampleData/RGB-PIP-FUCCI.tif');
load('ExampleData/PIP-FUCCI.tif_Tracks.mat', 'AllTracks');
S = TracksAuditorWindowController(Multitiff, AllTracks.Tracks);
S.setChannelTitles({'Burak', 'kon', 'czołg'})
% ET = S.ExportTableWithColorForEachCellPosition();
S.RunGUI();% Takes one minute
close all
clear all
clc 

%% RGB TEST:
% Load Multitiff and AllTracks
addpath('saveastiff_4_5/')
Multitiff = loadtiff('ExampleData/RGB-PIP-FUCCI.tif');
load('ExampleData/PIP-FUCCI.tif_Tracks.mat', 'AllTracks');
S = TracksAuditorWindowController(Multitiff, AllTracks.Tracks);
% ET = S.ExportTableWithColorForEachCellPosition();
S.RunGUI();
S.TEST_ALL()

%% Single channel tests:
Multitiff= loadtiff('ExampleData/July7 con A1_2-1.tif');
A = load('ExampleData/Experiment Name July7 con A1_2-1.tif_Tracks.mat');
S = TracksAuditorWindowController(Multitiff, A.AllTracks.Tracks);
S.RunGUI();
S.TEST_ALL()
%% 

S.setChannelTitles({'Burak', 'kon', 'czołg'})
S.MovingRectangles(1).DistanceFromCentrePxl = 40;
S.MovingRectangles(1).DistanceFromCentrePxl = 20;
rgbColor10 = S.getMeanColorForEachPositionOfRectangle();
ET = S.ExportTableWithColorForEachCellPosition();
S.RunGUI();
S.DEBUG_printAllRectangleSize()