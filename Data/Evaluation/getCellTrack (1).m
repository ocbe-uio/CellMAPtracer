function T = getCellTrack(ID, mantrack, dataSetFolder, outFolder)
%% getCellTrack - function reaturns real position of cell

fStart = mantrack.startFrame(mantrack.Label == ID);
fEnd = mantrack.endFrame(mantrack.Label == ID);
nFrames = fEnd-fStart+1;

% Init variables:
CellID = ones(nFrames,1)*ID;
Frame = [fStart:fEnd]';
X = nan(nFrames,1);
Y = nan(nFrames,1);

ii = 1;
for iFrame = fStart:fEnd
  % Import tiff file:
  tiffName = sprintf('man_track%03i.tif', iFrame);
  tiff = importdata([dataSetFolder filesep tiffName]);
  
  % Find Correct position of cell:
  bw=tiff==ID;
  stats=regionprops(bw,'CENTROID');

  % Get Center point of this region:
  X(ii) = round(stats.Centroid(1));
  Y(ii) = round(stats.Centroid(2));
  
  % Plot and save first frame:
  if ii  == 1
    fig = figure;
    imagesc(bw); hold on
    title(sprintf('ID %01i frame %i (%i, %i)', ID, iFrame,X(ii), Y(ii)));
    plot(stats.Centroid(1), stats.Centroid(2), 'ro')
    saveas(fig, sprintf('%s%simg_%i.png',outFolder, filesep, ID), 'png')
    close(fig)
  end
  ii = ii+1;
end

T = table(CellID, Frame, X, Y);