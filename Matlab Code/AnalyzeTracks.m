function CalculationsTable = AnalyzeTracks(AllTracks, Parameters)
%% ANALYZETRACKS - function analyze each track saved in ALLTracks object
% INPUTS:
%   AllTracks - ALL_Tracks class object
%   Parameters - ExperimentParameters object
% OUTPUTS:
%   CalculationResults - struct, with fields:
%     {'ExperimentName'}
%     {'TiffFileName'  }
%     {'CellName'      }
%     {'isDivided'     }
%     {'isDaughter'    }
%     {'nImages'       }
%     {'Distance'      }
%     {'Displacement'  }
%     {'TrajectoryTime'}
%     {'Directionality'}
%     {'AverageSpeed'  }
% Example:
% CalculationsStruct =
% 
% 
%     ExperimentName         TiffFileName         CellName    isDivided    isDaughter    nImages    Distance    Displacement    TrajectoryTime    Directionality    AverageSpeed
%     ______________    ______________________    ________    _________    __________    _______    ________    ____________    ______________    ______________    ____________
% 
%        'Exp'          'July7 Con F1_2-1.tif'      'C2'        false        false         25        

%% Perform all calculations
CellName = AllTracks.getListOfCells();
nCells = numel(CellName); % Number of tracks

% Analyze each track:
for i = 1:nCells
  CellRows = AllTracks.getCellRows(CellName(i));
  track_xy_pos   = AllTracks.Tracks.Cell_xy_pos(CellRows,:);
  validPos = find(~isnan(track_xy_pos(:,1)));
  % Remove nans:
  track_xy_pos(isnan(track_xy_pos(:,1)),:) = [];
  
  % Perform calculations for single track:
  R(i) = analyzeSingleTrack(track_xy_pos, Parameters);
  nImages(i,1) = numel(validPos);
  isDivided(i,1)  = isCellDivided(CellName{i},CellName);
end

isDaughter = isCellDaughter(CellName);
ExperimentName = repmat({AllTracks.ExperimentName}, nCells,1);
TiffFileName   = repmat({AllTracks.Metadata.TiffFileName},nCells,1);
CalculationsTable = table(ExperimentName, TiffFileName, CellName,...
  isDivided,isDaughter,nImages);
CalculationsTable = [CalculationsTable, struct2table(R)];
% Create description:
distUnit = Parameters.PixelSize_Unit;
timeUnit = Parameters.TimeInterval_Unit;
CalculationsTable.Properties.VariableDescriptions ={...
  'Experiment Name',...
  'Tiff File Name',...
  'Cell Name',...
  'isDivided - True if cell divided during measurement  ',...
  'isDaughter - True if cell is result of division during experiment ',...
  'nImages - Number of analyzed images  ',...
  ['Distance - Total distance traveled by cell [' distUnit ']  '],...
  ['Displacement - Distance between first and last position of the cell [' distUnit ']  '] ,...
  ['TrajectoryTime - Total trajectory time [' timeUnit ']  '] ,...
  'Directionality - ratio: Displacement/Distance  ',....
  ['AverageSpeed - Average speed of cell [' distUnit '/' timeUnit ']  '],...
  };


function isDivided = isCellDivided(cellname,AllCellNames)
% To check if cell is divided current cell name is compared with
% all cell names:
isParent = false(numel(AllCellNames),1);
for i = 1:numel(AllCellNames)
  % For each name check if there is the same name with '1' or '2' in the
  % end. If it is, it means that cell divided:
  % Note: it is possible that user clicked division and then remove
  % one of divided cell. In that case there will be C1 and C1.1
  % Even if after division is only one cell, it is still count as
  % parent: (2020-03-03)
  if any(strcmp(AllCellNames, [cellname '.1'])) ||...
      any(strcmp(AllCellNames, [cellname '.2']))
    isParent(i) = true;
  end
end
isDivided = any(isParent);

function isDaughter = isCellDaughter(CellNames)
% Cells which contains '.' in name are doughter cells
IndexC = strfind(CellNames,'.');
isDaughter = not(cellfun('isempty',IndexC)); 

function R = analyzeSingleTrack(xy, par)
% Analyze single track
% Inputs:
% XY - vector (nImages,2) with XY position of cell
% par - ExperimentParameters
% Outputs:
% R struct with fields: (example)
%           Distance: 351.4000
%       Displacement: 91.5000
%     TrajectoryTime: 1200
%     Directionality: 0.2600
%       AverageSpeed: 0.2930
%
nImages = size(xy,1);
% It is possible that xy is empty, when user remove all calculations
if nImages <= 1
  R.Distance        = 0;
  R.Displacement    = 0;
  R.TrajectoryTime  = 0;
  R.Directionality  = nan;
  R.AverageSpeed = 0;
  return
end

%% Analyze single track:
nImages = size(xy,1);
dt = par.TimeInterval;
% Convert from pixels to um:
pixel_size = par.PixelSize;
xy = xy * pixel_size;

% Calculate distance between each point of track:
for i = 2:size(xy,1)
  % n = norm(v) returns the Euclidean norm of vector v.
  % This norm is also called the 2-norm, vector magnitude, or Euclidean length.
  distance(i,1) = norm(xy(i,:)-xy(i-1,:)); %#ok<*AGROW,*SAGROW>
end

% Total distance traveled
distanceTot = sum(distance);

% Net distance traveled
displacement    = norm(xy(end,:)-xy(1,:)); % EndPoint - StartPoint
directionality  = displacement/distanceTot; % directionality ratio:

% Total trajectory time:
Ttot = (nImages-1)*dt;

% Speed:
% Vinst = distance/dt; % Instantaneous speed
% Avarage speed is sum of all speeds divided by number of images-1:
% AverageSpeed = sum(Vinst)/(nImages-1); 
AverageSpeed = sum(distance)/Ttot;

%% Pack to table:
R.Distance        = round(distanceTot,1);
R.Displacement    = round(displacement,1);
R.TrajectoryTime  = round(Ttot,1);
R.Directionality  = round(directionality,3);
R.AverageSpeed    = round(AverageSpeed,3);
