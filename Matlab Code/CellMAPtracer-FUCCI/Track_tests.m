%% Tracks tests
clear all

%% Example Data:
load(['ExampleData' filesep 'Experiment Name July7 con A1_2-1.tif_Tracks.mat'])
XYPos = AllTracks.Tracks.Cell_xy_pos(1:149,:);

%% Initialize tracks
T = Tracks(AllTracks.Tracks); 

%% Get track by number
% Return empty table if the number is incorrect:
TrackTable = T.getTrack(0);   assert(isempty(TrackTable))
TrackTable = T.getTrack(-1);  assert(isempty(TrackTable))
TrackTable = T.getTrack(200);  assert(isempty(TrackTable))

% Return table:
TrackTable = T.getTrack(1); assert(isa(TrackTable, 'table'))

trackPosition = T.getTrackPosition(1);
T.visualisetrack(1)
close all
clear T

%% Load whole table from CellTracer:
T = Tracks(AllTracks.Tracks);
         
TrackTable2 = T.getTrack(1);
assert(isequal(TrackTable2,TrackTable))

%% Test if the output is the same if user send rows instead columns:
T = Tracks(AllTracks.Tracks);
TrackTable3 = T.getTrack(1);         
assert(isequal(TrackTable2,TrackTable3))

%% Get all tracks id:
AllTracksNames = T.getAllTracksNames();
TrackTable = T.getTrack('C1');
TrackTable = T.getTrack('C3.2');

%%  Get first
assert(isequal(T.getFirstTrackFrame('C3.2'),83))
assert(isequal(T.getLastTrackFrame('C3.2'),149))
%% 
cprintf('_green', '\n Track_tests >> All tests passed! \n') ; 