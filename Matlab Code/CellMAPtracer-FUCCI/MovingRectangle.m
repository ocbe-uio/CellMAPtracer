classdef MovingRectangle < handle
  %% MOVINGRECTANGLE class
  % Moing rectangle is define as moving object with centre position and
  % distance from center position. 
  %  <-----DistanceFromCentrePxl 
  %  ___________________________
  % |                           |
  % |                           |
  % |           (X,Y)           |
  % |                           |
  % |                           |
  %  ___________________________
  %  DistanceFromCentrePxl----->
  properties
    Color 
    DistanceFromCentrePxl   % Distance from centre of ractangle to the border of rectangle
    CenterRectanglePosition % Center of rectangle
    BackgroundImageSize     % Size of background image (important to check if
                            % position is not out of image borders)
    RectangleHandle         % Handle from plotting 
    Name                    % Can be store object name, example: Cell_2.1
  end
  
  methods
    function obj = MovingRectangle()
    % Only default constructor:
    obj.Color = 'w';
    obj.DistanceFromCentrePxl = 20;
    obj.CenterRectanglePosition = [10 10];
    obj.BackgroundImageSize = [100 100];
    obj.RectangleHandle = [];
    obj.Name = [];
    end
    
    function RectangleSize = getRectangleSizeInPixels(obj)
       RectangleSize = 2*obj.DistanceFromCentrePxl +1;
    end
    
    function show(obj, WhereToPlot)
      if nargin < 2, WhereToPlot = gca; end
       rectangleBox = getrectanglebox(obj);
       obj.RectangleHandle  = rectangle(WhereToPlot, ...
         'Position', rectangleBox,...
         'EdgeColor', obj.Color);
    end
    
    function hide(obj)
      delete(obj.RectangleHandle)
      obj.RectangleHandle = [];
    end
    
    % Setters:
    function setPosition(obj, XYPos)
      obj.CenterRectanglePosition = XYPos;
      rectangleBox = getrectanglebox(obj);
      set(obj.RectangleHandle, 'Position', rectangleBox)
    end
    
 
    function setColor(obj, Color)
      obj.Color = Color; 
      obj.updRectangleColor();   
    end
    
    function updRectangleColor(obj)
      if ~isempty(obj.RectangleHandle)
        set(obj.RectangleHandle, 'EdgeColor', obj.Color)
      end
    end
    
    function rectanglebox = getrectanglebox(obj)
      %% GETRECTANGLE - returns rectangle part of image cut off from original
      % INPUTS:
      %   img  - inputimage (one frame from multitiff)
      %   centre - [xy] position of centre of rectangle
      %   DistanceFromCentrePxl - half of size of rectangle
      % OUTPUTS:
      %   rec - [x,y, width length] - rectangle
      
      MaxY = obj.BackgroundImageSize(1);
      MaxX = obj.BackgroundImageSize(2);
      
      centreX = obj.CenterRectanglePosition(1);
      centreY = obj.CenterRectanglePosition(2);
      
      % Do not pass top and left side:
      rectangle_xmin = max(1, centreX - obj.DistanceFromCentrePxl);
      rectangle_ymin = max(1, centreY - obj.DistanceFromCentrePxl);
      
      % Do not pass right and down side:
      rectangle_xmin = min(rectangle_xmin, MaxX - 2*obj.DistanceFromCentrePxl);
      rectangle_ymin = min(rectangle_ymin, MaxY - 2*obj.DistanceFromCentrePxl);
      
      % Size of rectangle: limit to image edges
      rectangle_width  = min(2*obj.DistanceFromCentrePxl, MaxX - rectangle_xmin);
      rectangle_height = min(2*obj.DistanceFromCentrePxl, MaxY - rectangle_ymin);
      
      rectanglebox = [rectangle_xmin, rectangle_ymin, rectangle_width, rectangle_height];
    end
  end
end

