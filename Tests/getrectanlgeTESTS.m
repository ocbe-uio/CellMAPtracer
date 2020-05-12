function tests = getrectanlgeTESTS
% TEST script for getrectanlge function.
% Usage:
% results = runtests('getrectanlgeTESTS.m')
tests = functiontests(localfunctions);
end

function testWholeRectangleWithinImage(testCase)
  load('img1.mat')
  %
  RECTANGLE_SIDE = 100;
  actSolution1 = getrectangle(img1,[390, 490],RECTANGLE_SIDE);
  expSolution = [290 390 200 200];  
  verifyEqual(testCase,actSolution1,expSolution)

  actSolution2 = getrectangle(img1,[200, 200],RECTANGLE_SIDE);
  expSolution = [100 100 200 200];  
  verifyEqual(testCase,actSolution2,expSolution)
 
  actSolution3 = getrectangle(img1,[900, 600],RECTANGLE_SIDE);
  expSolution = [800 500 200 200];  
  verifyEqual(testCase,actSolution3,expSolution)

  %
  figure('Position', [49 143 629 371], 'Name', 'testWholeRectangleWithinImage')
  imagesc(img1), hold on, 
  rectangle('Position', actSolution1, 'EdgeColor', 'r')
  rectangle('Position', actSolution2, 'EdgeColor', 'r')
  rectangle('Position', actSolution3, 'EdgeColor', 'r')
  title('testWholeRectangleWithinImage')
end

function testRectangleOnTheRight(testCase)
  load('img1.mat')
  %
  RECTANGLE_SIDE = 100;
  actSolution1 = getrectangle(img1,[1050, 490],RECTANGLE_SIDE);
  expSolution = [950 390 151 200];  
  verifyEqual(testCase,actSolution1,expSolution)

  actSolution2 = getrectangle(img1,[1090, 200],RECTANGLE_SIDE);
  expSolution = [990 100 111 200];  
  verifyEqual(testCase,actSolution2,expSolution)
 
  actSolution3 = getrectangle(img1,[1004, 600],RECTANGLE_SIDE);
  expSolution = [904 500 197 200];  
  verifyEqual(testCase,actSolution3,expSolution)
  
  figure('Position', [49 143 629 371], 'Name', 'testRectangleOnTheRight')
  imagesc(img1), hold on,
  rectangle('Position', actSolution1, 'EdgeColor', 'r')
  rectangle('Position', actSolution2, 'EdgeColor', 'r')
  rectangle('Position', actSolution3, 'EdgeColor', 'r')
  title('testRectangleOnTheRight')
end


function testRectangleOnTheLeft(testCase)
  load('img1.mat')
  %
   RECTANGLE_SIDE = 100;
  actSolution1 = getrectangle(img1,[20, 490],RECTANGLE_SIDE);
  expSolution = [1 390 200 200];  
  verifyEqual(testCase,actSolution1,expSolution)

  actSolution2 = getrectangle(img1,[50, 200],RECTANGLE_SIDE);
  expSolution = [1 100 200 200];  
  verifyEqual(testCase,actSolution2,expSolution)
 
  actSolution3 = getrectangle(img1,[90, 600],RECTANGLE_SIDE);
  expSolution = [1 500 200 200];  
  verifyEqual(testCase,actSolution3,expSolution)
  
  figure('Position', [49 143 629 371], 'Name', 'testRectangleOnTheLeft')
  imagesc(img1), hold on,
  rectangle('Position', actSolution1, 'EdgeColor', 'r')
  rectangle('Position', actSolution2, 'EdgeColor', 'r')
  rectangle('Position', actSolution3, 'EdgeColor', 'r')
  title('testRectangleOnTheLeft')
end

function testRectangleOnTheTop(testCase)
  load('img1.mat')
  %
     RECTANGLE_SIDE = 100;
  actSolution1 = getrectangle(img1,[390, 10],RECTANGLE_SIDE);
  expSolution = [290  1  200  200];  
  verifyEqual(testCase,actSolution1,expSolution)

  actSolution2 = getrectangle(img1,[200, 50],RECTANGLE_SIDE);
  expSolution = [100  1  200  200];  
  verifyEqual(testCase,actSolution2,expSolution)
 
  actSolution3 = getrectangle(img1,[900, 90],RECTANGLE_SIDE);
  expSolution = [800 1 200 200];  
  verifyEqual(testCase,actSolution3,expSolution)
  
  figure('Position', [49 143 629 371], 'Name', 'testRectangleOnTheTop')
  imagesc(img1), hold on,
  rectangle('Position', actSolution1, 'EdgeColor', 'r')
  rectangle('Position', actSolution2, 'EdgeColor', 'r')
  rectangle('Position', actSolution3, 'EdgeColor', 'r')
  title('testRectangleOnTheTop')
end

function testRectangleOnTheBotton(testCase)
  load('img1.mat')
  %
  RECTANGLE_SIDE = 100;
  actSolution1 = getrectangle(img1,[390, 750],RECTANGLE_SIDE);
  expSolution = [290  650  200  100];  
  verifyEqual(testCase,actSolution1,expSolution)

  actSolution2 = getrectangle(img1,[750, 700],RECTANGLE_SIDE);
  expSolution = [650  600  200  150];  
  verifyEqual(testCase,actSolution2,expSolution)
 
  actSolution3 = getrectangle(img1,[690, 690],RECTANGLE_SIDE);
  expSolution = [590 590 200 160];  
  verifyEqual(testCase,actSolution3,expSolution)
  
  figure('Position', [49 143 629 371], 'Name', 'testRectangleOnTheBotton')
  imagesc(img1), hold on,
  rectangle('Position', actSolution1, 'EdgeColor', 'r')
  rectangle('Position', actSolution2, 'EdgeColor', 'r')
  rectangle('Position', actSolution3, 'EdgeColor', 'r')
  title('testRectangleOnTheBotton')
end


function testRectangleIntheCorner(testCase)
  load('img1.mat')
  %
  RECTANGLE_SIDE = 100;
  actSolution1 = getrectangle(img1,[20, 750],RECTANGLE_SIDE);
  expSolution = [ 1   650   200   100];  
  verifyEqual(testCase,actSolution1,expSolution)

  actSolution2 = getrectangle(img1,[20, 20],RECTANGLE_SIDE);
  expSolution = [1  1  200  200];  
  verifyEqual(testCase,actSolution2,expSolution)
 
  actSolution3 = getrectangle(img1,[1100, 750],RECTANGLE_SIDE);
  expSolution = [1000 650 101 100];  
  verifyEqual(testCase,actSolution3,expSolution)
  
  actSolution4 = getrectangle(img1,[1100, 20],RECTANGLE_SIDE);
  expSolution = [1000 1 101 200];  
  verifyEqual(testCase,actSolution4,expSolution)
  
  figure('Position', [49 143 629 371], 'Name', 'testRectangleIntheCorner')
  imagesc(img1), hold on,
  rectangle('Position', actSolution1, 'EdgeColor', 'r')
  rectangle('Position', actSolution2, 'EdgeColor', 'r')
  rectangle('Position', actSolution3, 'EdgeColor', 'r')
  rectangle('Position', actSolution4, 'EdgeColor', 'r')
  title('testRectangleIntheCorner')
end
