function rec = getrectangle(img, centre,DistanceFromCentrePxl)
%% GETRECTANGLE - returns rectangle part of image cut off from original
% INPUTS:
%   img  - inputimage (one frame from multitiff)
%   centre - [xy] position of centre of rectangle
%   DistanceFromCentrePxl - half of size of rectangle
% OUTPUTS:
%   rec - [x,y, width length] - rectangle

[MaxY,MaxX] = size(img);
centreX = centre(1);
centreY = centre(2);

if any(centre < 1) , error('Center of cell cannot be less than 1'),end
if centreX > MaxX , warning('Center of cell is outside X lim'),end
if centreY > MaxY , warning('Center of cell is outside Y lim'),end

rectangle_xmin = max(1, centreX - DistanceFromCentrePxl);
rectangle_ymin = max(1, centreY - DistanceFromCentrePxl); 

% Size of rectangle: limit to image edges
rectangle_width  = min(2*DistanceFromCentrePxl, MaxX - rectangle_xmin); 
rectangle_height = min(2*DistanceFromCentrePxl, MaxY - rectangle_ymin);

rec = [rectangle_xmin, rectangle_ymin, rectangle_width, rectangle_height];


