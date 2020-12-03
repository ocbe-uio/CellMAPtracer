% MovingRectangle_Tests
addpath('saveastiff_4_5/')
Multitiff= loadtiff('ExampleData/July7 con A1_2-1.tif');
img = Multitiff(:,:,1);
fig = figure; imagesc(img)

%% Show and hide rectangle:
M = MovingRectangle();
M.BackgroundImageSize = size(img);
M.show()
M.hide()
M.show()

%% Set position
M.setPosition([100,100])
% Change Color of rectangle, 2 options:
M.setColor('m')
set(M.RectangleHandle, 'EdgeColor', 'g')

%% Change Distanse from centre and check rectangle size
M.DistanceFromCentrePxl = 30;
assert(isequal(M.getRectangleSizeInPixels, 61))

%% set Name
% set positions and check output:
M.DistanceFromCentrePxl = 20;
M.setPosition([1,1]);       assert(isequal(M.RectangleHandle.Position, [1 1 40 40]))
M.setPosition([-1,1]);      assert(isequal(M.RectangleHandle.Position, [1 1 40 40]))
M.setPosition([100,100]);   assert(isequal(M.RectangleHandle.Position, [80 80 40 40]))
M.setPosition([-100,100]);  assert(isequal(M.RectangleHandle.Position, [1 80 40 40]))
M.setPosition([100,-100]);  assert(isequal(M.RectangleHandle.Position, [80 1 40 40]))
M.setPosition([100,750]);   assert(isequal(M.RectangleHandle.Position, [80 710 40 40]))
M.setPosition([1101,750]);  assert(isequal(M.RectangleHandle.Position, [1061 710 40 40]))
close(fig)

%% Create list of rectangles:
for i = 1:10
  M(i) = MovingRectangle();
  M(i) = MovingRectangle();
  M(i).Name = ['Exmpl_' num2str(i)];
end
assert(any(strcmp({M.Name},'Exmpl_9')))

cprintf('_green', '\n MovingRectangle_tests >> All tests passed! \n') ; 
