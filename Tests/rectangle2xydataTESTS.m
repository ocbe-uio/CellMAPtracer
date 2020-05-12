function tests = rectangle2xydataTESTS
%% TEST function for rectangle2xydata
% Example:
% results = runtests('rectangle2xydataTESTS.m')
tests = functiontests(localfunctions);
end

function testWholeRectangleWithinImage(testCase)
  load('img1.mat')
  RECTANGLE_SIDE = 100;
  rec = getrectangle(img1,[390, 490],RECTANGLE_SIDE);
  [xdata, ydata] = rectangle2xydata(rec);
  xDataExpSolution = 290:490; 
  yDataExpSolution = 390:590;
  verifyEqual(testCase,xdata,xDataExpSolution)
  verifyEqual(testCase,ydata,yDataExpSolution)
end

