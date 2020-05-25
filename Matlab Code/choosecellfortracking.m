function [ChoosenPosition, isCanceled] = choosecellfortracking(img, initialPos)
%% CHOOSECELLFORTRACKING -  Choose first cell for tracking. 
% Function uses ginput to mark position. The position is saved and returned
% when window is closed by user
% INPUTS
%   img - image with cells
%   initialPos - [xy] initial position (used to mark already calculated
%   cells)
%   CellSizeInPixels - [INTIGER] 
% OUTPUTS
%   ChoosenPosition - xy position marked by user
%   isCanceled - [FLAG] if user close window instead of choose position

if nargin < 2, initialPos = []; end

screenSize = get(0,'screensize');
fig = figure('Name', getVer(),'Toolbar', 'none','MenuBar', 'none',...
  'Position', [screenSize(1:2) + 100, screenSize(3:4)/2],...
  'Color', [1 1 1]);
imagesc(img); hold on

if ~isempty(initialPos), plot(initialPos(:,1), initialPos(:,2), 'or'); end
ChoosenPosition = [1,1];
FirstCell = plot(ChoosenPosition(1),ChoosenPosition(2), 'rx', 'MarkerSize', 15);
title({'Mark cell for trackng', 'Close window to cancel'})

addcolormappopupmenu(fig)

isCanceled = false;
doWork     = true;
while doWork
  try
  [x,y, key] = ginput(1);
  FirstCell.XData = round(x);
  FirstCell.YData = round(y);
  if key % new click
    ChoosenPosition = [FirstCell.XData, FirstCell.YData];
  else % if key is empty, enter was clicked
    plot(ChoosenPosition(1),ChoosenPosition(2), 'rx', 'MarkerSize', 15);
    doWork = false;
    close(fig)
  end
  catch
    isCanceled = true;
    return
  end
end

% Apply preprocessing and centre of mass:
InitialRectangleSize = 20;
ChoosenPosition = trackbetween2images(img, ChoosenPosition, InitialRectangleSize);

end

