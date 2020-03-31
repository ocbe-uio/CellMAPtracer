function JsonFileName = saveWindowSizeToJsonFile(win_size)
%% saveWindowSizeToJsonFile - saves window size in json file
isWinSizeFourDigits = isequal(numel(win_size),4);
JsonFileName = 'win_size.json';

if isWinSizeFourDigits
  w.win_size = win_size;
  w.computername = getenv('computername');
  
  % Code into json:
  jsonStr = jsonencode(w);
  
  fid = fopen(JsonFileName, 'w');
  if fid == -1, error('Cannot create win_size JSON file'); end
  fwrite(fid, jsonStr, 'char');
  fclose(fid);
else
  fprintf(2, '\n saveWindowSizeToJsonFile  >> Incorrect win_size \n')
  JsonFileName = [];
end