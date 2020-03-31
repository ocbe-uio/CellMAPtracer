function addcolormappopupmenu(figureHandle, PopUpPosition)
%% ADDCOLORMAPOPUPMENU - adds colormap popup menu to current figure 

if nargin < 2
  PopUpPosition = [.01 0.01 .1 .02];
end

h_colormap = uicontrol('Parent', figureHandle,...
 'Style', 'popup','String', {'parula','jet','hsv','hot','cool',...
 'spring','summer','autumn','winter','gray','bone','copper','pink'},...
 'Units', 'Normalized', 'Position', PopUpPosition, 'Value',1); 

text_pos = PopUpPosition;
text_pos(2) = PopUpPosition(2) + PopUpPosition(4);

uicontrol('Parent', figureHandle,...
 'Style', 'text','String', {'Change colormap:'},'HorizontalAlignment', 'left',...
 'Units', 'Normalized', 'Position', text_pos); 

% Note: setmap is callback saved in separate mfile
set(h_colormap,  'Callback', @setmap)
end