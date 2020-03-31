function hTrack = plotcelltracks(cellTrack)
%% PLOTCELL - Plot cell track
% Function to plot on current axis cell xy position
% It is separate function because plotting single cell position need to
% fulfill requeriements:
% -> plot whole xy position
% -> mark cell division
% -> plot cells after division with different color

uniqueNames = unique(cellTrack.CellName);
nCells = numel(uniqueNames);

% Split cellTrack into each generation
NamesLength = cellfun(@numel, uniqueNames);

% Ech generation has the same color 
% ceil allows to have proper generation for old (1_CellA) and new names (Cell 1)
% generation   = ceil((NamesLength-ShortestName)/2);
 % Cell 1 -> Generation 0
 % Cell 1.2 -> Generation 1
 % Cell 1.2.1 -> Generation 2
 % etc..
CellGeneration = cellfun(@numel, strfind(uniqueNames, '.')); % 0,1,2...

% Color order for each generation
col_order = [0.85 0.3250 .0980;
  0.898 0.898 0.1098;
  0.3010 0.7450 0.9330;
  0.9290 0.6940 0.1250;
  1 0.9804 1];
  
% If there is more generations, repeat the same color order:
while numel(CellGeneration) > size(col_order,1)
  col_order = repmat(col_order,2,1); 
end

col = col_order(CellGeneration+1,:); % Cell generation starts from 0,1,2
CellMatrix = table(uniqueNames, NamesLength, CellGeneration,col);

% #1 plot cells
for i = 1:nCells
%   disp(CellMatrix.col(i,:))
  qq = find(strcmp(cellTrack.CellName,CellMatrix.uniqueNames{i}));
  hTrack(i) = plot(cellTrack.Cell_xy_pos(qq,1), cellTrack.Cell_xy_pos(qq,2),...
    '-', 'Color',CellMatrix.col(i,:), 'LineWidth' ,1); %#ok<*AGROW> % if color has 4 numbers, last number is opasity
end


 [~,UniqueCellGen] = unique(CellGeneration);
 numberOfUniqueGeneration = numel(UniqueCellGen);
 if numberOfUniqueGeneration > 1
   cellGen = num2str(CellGeneration(UniqueCellGen));
   LegendText = strcat('Cells Generation ',cellGen) ;
   legend(hTrack(UniqueCellGen), LegendText, 'Location', 'southoutside') ;
   legend('boxoff')
 end
if nargout <1, clear hTrack, end
