%% vMAT TEST
Vector   = rand(100,1);
Matrix2D = rand(100,100);
% Is it single frame with 3 colours or single channels with 3 frames?
Matrix3D = rand(100,100,3, 10); % 3 color, 10 frames

% Test constructor:
no_input_returns_error()
vectorInput_returns_error(Vector)
Matrix2DInput_returns_error(Matrix2D)
% Single_channel_tiff_Input_returns_object(SingleChannelMultitiff)
% RGB_tiff_Input_returns_object(RGBMultitiff)
StringInput_returns_error('MyMatrix')

%Test methods
return_number_of_frames(Matrix3D,10)
return_single_frame(Matrix3D)
return_number_of_channels(Matrix3D)

% Test bahaviour with real data
addpath('saveastiff_4_5/')
Multitiff= loadtiff('ExampleData/July7 con A1_2-1.tif');
imagesc(vMAT(Multitiff).getSingleFrame(149));
close all
return_number_of_channels_single_channel_rec(Multitiff)


fig = figure;
vMAT(Multitiff).showWithSlider();
close(fig)

fig = figure;
cAxes = subplot(2,2,3);
vMAT(Multitiff).showWithSlider(cAxes);

cprintf('_green', '\n vMat_tests >> All tests passed! \n') ; 

%%
function return_number_of_channels_single_channel_rec(SingleChannelMultitiff)
assert(isequal(vMAT(SingleChannelMultitiff).getNumberOfChannels(),1))
end
function return_number_of_channels(X)
 assert(isequal(vMAT(X).getNumberOfChannels(),3))
end

function return_single_frame(X)
TestFrame = 1;
singleFrame = vMAT(X).getSingleFrame(TestFrame);
assert(isequal(singleFrame, X(:,:,:,TestFrame)))

TestFrame = 3;
singleFrame = vMAT(X).getSingleFrame(TestFrame);
assert(isequal(singleFrame, X(:,:,:,TestFrame)))
try 
  singleFrame = vMAT(X).getSingleFrame(-1); %#ok<*NASGU>
catch me
  assert(isequal(me.message, 'Frame Number must be intiger value between [1 NumberOfFrames]'))
end

try 
  singleFrame = vMAT(X).getSingleFrame(1000);
catch me
   assert(isequal(me.message, 'Frame Number must be intiger value between [1 NumberOfFrames]'))
end

displaypassedtest(dbstack)

end
function return_number_of_frames(X,correctNumberOfFrames)
returnedNumberOfFrames = vMAT(X).getNumberOfFrames;
assert(isequal(correctNumberOfFrames,returnedNumberOfFrames))
displaypassedtest(dbstack)
end

function StringInput_returns_error(stringIn)
try
  V = vMAT(stringIn);
catch me
  assert(isequal(me.message,'Matrix must be numeric'))
end
displaypassedtest(dbstack)
end

function Single_channel_tiff_Input_returns_object(X)
V = vMAT(X);
assert(isa(V, 'vMAT'))
displaypassedtest(dbstack)
end

function RGB_tiff_Input_returns_object(X)
V = vMAT(X);
assert(isa(V, 'vMAT'))
displaypassedtest(dbstack)
end

function Matrix2DInput_returns_error(Matrix2D)
try
  V = vMAT(Matrix2D);
catch me
  assert(isequal(me.message,'Matrix must have 3 dimensions'))
end
displaypassedtest(dbstack)
end

function vectorInput_returns_error(Vector)
try
  V = vMAT(Vector);
catch me
  assert(isequal(me.message,'Matrix must have 3 dimensions'))
end
displaypassedtest(dbstack)
end
%
function no_input_returns_error()
try
  V = vMAT();
catch me
  assert(isequal(me.message,'Not enough input arguments.'))
end
displaypassedtest(dbstack)
end


function displaypassedtest(dbstack)
st = dbstack;
testname = st(1).name;
disp([testname ' Passed'])
end