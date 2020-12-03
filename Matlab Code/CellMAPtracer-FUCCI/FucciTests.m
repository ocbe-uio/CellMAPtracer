%% Fucci tests
% In this section there will be three phases G1  -  S  -  G2. For every phase, the user should describe the intensity of each channel and select one of these four intensity options [High   -  Detected   -  Low    -   Absent]
% I am not sure how you gonna determine the thresholds for being high or low. I think absence is easy and anything that is less than the high threshold and higher than than the low. 
% 
%        Red Intensity    Green Intensity     Blue Intensity 
% G1      Absent            Detected        High
% S       Detected           High           Absent
% G2      Detected          Detected         High

load(['ExampleData' filesep 'rgb.mat'], 'ExportTable')

%% Parameters:
parameters.MaximumGreenBlueRatioinG1EditField = 0.5;
parameters.MinimumGreenBlueRatioinG2EditField = 0.7;
parameters.MinimumBlueSignalinG2EditField = 0.1;

F = Fucci(ExportTable);
F.setParameters(parameters)
TestCell = 'C5.1';

CellRowsInDataTable = F.getsinglecellrows(TestCell);
assert(isequal(numel(CellRowsInDataTable), 425))
assert(all(diff(CellRowsInDataTable)), 'Rows do not increase by 1')
FirstTrackFrame = F.getFirstTrackFrame(TestCell);
LastTrackFrame  = F.getLastTrackFrame(TestCell);

F.PlotCalculations = true;
CyclePhase = F.detectCellPhase(TestCell);
CyclePhaseString = F.cyclePhaseString(F.detectCellPhase(TestCell));
fig = figure;
F.plotCyclePhaseAsPatchObject(CyclePhase)
close(fig)

%% Change Predicting method
F.setPredictingMethod('Geminin_Cdt1');
F.setPredictingMethod('Geminin-PCNA - PIP');
try F.setPredictingMethod('WrongName'),catch, end

%% 
tic
F.setPredictingMethod('Geminin-PCNA - PIP');
CyclePhaseAllCells = F.AnalyseAllCells();
toc

%% 
close all
fig = figure;
subplot(2,1,1)
CellNameListbox = uicontrol('Parent',fig, 'Style', 'Listbox','units',...
  'normalized', 'Position', [.4 .2 .3 .2], 'Callback', @F.detectCellPhase);
set(CellNameListbox, 'String',F.getAllTracksNames)


cprintf('_green', '\n Fucci_tests >> All tests passed! \n') ; 


%% 
