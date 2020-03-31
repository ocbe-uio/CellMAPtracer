function [xdata, ydata] = rectangle2xydata(rectangle)
%% RECTANGLE2XYDATA - returns x and y vector from rectangle
% INPUTS:
% Rectangle - [xmin ymin width height]
% OUTPUTS:
% [xdata, ydata] - vectors with x and y 


xmin   = rectangle(1);
ymin   = rectangle(2);
width  = rectangle(3);
height = rectangle(4);

xdata = xmin : (xmin + width);
ydata = ymin : (ymin + height);