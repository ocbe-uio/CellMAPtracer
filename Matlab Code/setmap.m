function setmap(colormapPopupmenu,~)
%% setmap - changes current color map on figure
% INPUT:
% Colormap_Popupmenu - UIControl (parula, jet, hsv, hot, cool,....)

val = colormapPopupmenu.Value;
maps = colormapPopupmenu.String;
% For R2014a and earlier:
% val = get(source,'Value');
% maps = get(source,'String');
newmap = maps{val};
colormap(newmap);
end