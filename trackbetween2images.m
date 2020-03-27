function nextGoodPos = trackbetween2images(CurrIMG, lastGoodPos, crop_rect_size)
%% TRACKBETWEEN2IMAGES - track cell between 2 images
% Function extracts part of image, and finds best match between previous
% cell and current cells. All calculations are showed. 
% Clicking in the best match allows to correct calculations. 
% INPUTS: 
% CurrIMG - current image
% LastCell_info - last position of cell, example:
% 
%     Area        Centroid        BoundingBox     MajorAxisLength    MinorAxisLength    Orientation    PixelIdxList       PixelList      radii
%     ____    ________________    ____________    _______________    _______________    ___________    _____________    _____________    _____
% 
%     47      375.21    290.34    [1x4 double]    10.011             6.1716             81.59          [47×1 double]    [47×2 double]    4    
% OUTPUTS:
% nextCell - table row with all information about next cell

% #1 Create rectangle around last position:
rect = getrectangle(CurrIMG, lastGoodPos,crop_rect_size);
% 
% #2 Imcrop rectangle from previous and current image:
curr_crop = imcrop(CurrIMG,rect);

% #3 Preprocess image:
PreProcessedImage = preprocessimage(curr_crop);

% #4 Find cells:
Canditates = regionprops('table',PreProcessedImage,curr_crop,'Centroid',...
  'WeightedCentroid','MajorAxisLength','MinorAxisLength', 'Area');

if isempty(Canditates)
  nextGoodPos = [nan nan];
  return
end

diameters = mean([Canditates.MajorAxisLength Canditates.MinorAxisLength],2);
radii = round(diameters/2);
Canditates.radii = radii;
Canditates(Canditates.Area==0,:) = []; % Area > 0
maxCellSize = (size(PreProcessedImage,1)^2)/4; % MaxCellSize < 1/4 of image
Canditates(Canditates.Area> maxCellSize,:) = []; 

if isempty(Canditates)
  nextGoodPos = [nan nan];
  return
end

% #5 Correct position by rectangle position
Canditates.Centroid(:,1) = Canditates.Centroid(:,1) + rect(1);
Canditates.Centroid(:,2) = Canditates.Centroid(:,2) + rect(2);

% #6 Find the closest cell:
CanditatesPositions      = [Canditates.Centroid(:,1),Canditates.Centroid(:,2)];
distance_fromLastGoodOne = squareform(pdist([lastGoodPos; CanditatesPositions]));
distance_fromLastGoodOne = distance_fromLastGoodOne(1,2:end);
[~,mostProb] = sort(distance_fromLastGoodOne);
nextGoodCell = Canditates(mostProb(1), :);

% #7 Correct calculations using inensity information (WeightedCentroid
nextGoodPos  = round([nextGoodCell.WeightedCentroid(1), nextGoodCell.WeightedCentroid(2)]);

% #8 Add rectification (rectangle) values:
nextGoodPos(1) = nextGoodPos(1) + rect(1);
nextGoodPos(2) = nextGoodPos(2) + rect(2);


