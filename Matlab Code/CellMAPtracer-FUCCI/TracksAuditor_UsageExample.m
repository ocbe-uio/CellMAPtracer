% 
close all
clear all
clc
%% Load Multitiff and AllTracks
addpath('saveastiff_4_5/')
Multitiff= loadtiff('ExampleData/RGB-TIFF.tif');
A = load('ExampleData/RGBto8bitsadj RGBto8bitsadj.tif_Tracks.mat');
S = TracksAuditorWindowController(Multitiff, A.AllTracks.Tracks);
S.RunGUI();

%%
S = TracksAuditor(Multitiff, A.AllTracks);
S.MovingRectangleObj.DistanceFromCentrePxl = 40;
tic, rgbColor40 = S.getMeanColorForEachPositionOfRectangle(); toc

S.MovingRectangleObj.DistanceFromCentrePxl = 20;
tic, rgbColor = S.getMeanColorForEachPositionOfRectangle(); toc
S.MovingRectangleObj.DistanceFromCentrePxl = 20;
ET = S.ExortTableWithColorForEachCellPosition();
S.RunGUI();

S = TracksAuditor(Multitiff, A.AllTracks);
S.setChannelTitles({'Burak', 'kon', 'czołg'})
S.RunGUI();