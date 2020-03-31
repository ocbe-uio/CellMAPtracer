function win_size = getWindowSizeFromJsonFile()
%% getWindowSizeFromJsonFile - loads json file with tracking window size (figure position)

% Try to load already saved windows size:
try
  JsonText = fileread('win_size.json');
catch me
  % No file in direcotry
 if strcmp(me.identifier, 'MATLAB:fileread:cannotOpenFile')
  win_size = getdefaultwinsize();
  JsonFileName = saveWindowSizeToJsonFile(win_size);
  JsonText = fileread(JsonFileName);
 end
end

% Load win size from json file:
WinSizeStruct = jsondecode(JsonText);
thiscomputername = getenv('computername');
% If program is open on the same computer
if strcmp(thiscomputername, WinSizeStruct.computername)
  win_size = WinSizeStruct.win_size;
else
  win_size = getdefaultwinsize();
  saveWindowSizeToJsonFile(win_size)
end

%% ..getdefaultwinsize
function win_size = getdefaultwinsize()
screenSize = get(0,'screensize');
win_size = [screenSize(1:2)+100 screenSize(3)/2 screenSize(4)/4];

