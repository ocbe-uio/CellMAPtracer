function cyclePhase = GemininPCNA_PIP(RGB,...
  FirstTrackFrame, LastTrackFrame, parameters)
% Return cyclePhase Base on Normalized RGB signal
% Phase   Red       Green     Blue
% G1(1)      Absence   Presence  Presence
% S(2)       Presence  Presence  Absence
% G2(3)      Presence  Presence Presence

%       I think this parameter "G1 Maximum Green-Blue Ratio threshold  (G1-MGBRt)" is too long it is better to make it:
%           Maximum Green-Blue Ratio in G1 (MGBr-G1=0.5)
% If there is enough space for the whole name of the parameters then we dont need the abbreviations.

if nargin < 4
  MaximumGreenBlueRatioinG1 = 0.5;
  MinimumGreenBlueRatioinG2 = 0.7;
  MinimumBlueSignalinG2 = 0.1;
else
  MaximumGreenBlueRatioinG1 = parameters.MaximumGreenBlueRatioinG1EditField;
  MinimumGreenBlueRatioinG2 = parameters.MinimumGreenBlueRatioinG2EditField;
  MinimumBlueSignalinG2     = parameters.MinimumBlueSignalinG2EditField;
end

% Rapid drop is define as 1%:
RapidDropGreen = -0.01;
RapidDropBlue = -0.01;

cyclePhase = nan(size(RGB,1),1);
% Apply moving avarage as simplest filtering
FilteredRGB = movmean(RGB,3,'Endpoints','shrink');

% FilteredRGB = RGB;
Green = FilteredRGB(:,2);
Blue  = FilteredRGB(:,3);
% NaNs exist in data points before/after division
NoNansRows = ~isnan(Green);
GreenBlueRatio = Green./Blue;

% If it is lower than 0.25, continue
% Check first 5 frames:
FirstFrame = find(NoNansRows, 1, 'First');
% LastFrame = find(NoNansRows, 1, 'Last');
AvarageFirstFrames = GreenBlueRatio(FirstFrame);
if AvarageFirstFrames>0.7
  if Blue(FirstFrame) < 0.1
    SG2Border = find(Blue(FirstTrackFrame:LastTrackFrame)>MinimumBlueSignalinG2, 1,'First');
    cyclePhase(FirstTrackFrame:SG2Border) = 2;
    cyclePhase((SG2Border +FirstTrackFrame)  : LastTrackFrame) = 3;
    return
  end
end


% If whole BlueRedRatio is below 0.5, is clear G1 phase
if all(GreenBlueRatio(NoNansRows) < MaximumGreenBlueRatioinG1)
  cyclePhase(NoNansRows) = 1;
  return
end

% If whole BlueRedRatio is above 0.7, is clear G2 phase
if all(GreenBlueRatio(NoNansRows) > MinimumGreenBlueRatioinG2)
  cyclePhase(NoNansRows) = 3;
  return
end


% Find minimum Values of Blue and red:
[MinimumValueGreen,  IndexOfMinimumValueGreen]  = min([0; diff(Green)]);
[MinimumValueBlue, IndexOfMinimumValueBlue] = min([0; diff(Blue)]);

% Rapit drop in green is G2->G1 border
if MinimumValueGreen < RapidDropGreen
  G2G1Border = IndexOfMinimumValueGreen;
  cyclePhase(FirstTrackFrame:G2G1Border) = 3;
  cyclePhase(G2G1Border:LastTrackFrame) = 1;
end

% If there is blue drop -> Border between G1 and S
if MinimumValueBlue < RapidDropBlue
  G1SBorder = IndexOfMinimumValueBlue;
  cyclePhase(FirstTrackFrame:G1SBorder) = 1;
  cyclePhase(G1SBorder:LastTrackFrame) = 2;
  
  % Then check if blue is going up (phase G2)
  NextFrameAfterG1SBorder = G1SBorder + 3;
  SG2Border = find(Blue(NextFrameAfterG1SBorder:LastTrackFrame)>MinimumBlueSignalinG2, 1,'First');
  cyclePhase((SG2Border+G1SBorder) : LastTrackFrame) = 3;
end
end

