function updateguicolors(gui_h)
%% updateguicolors - function adds colors to main gui figure
% Colors used from https://htmlcolorcodes.com/color-chart/
intenseGreen =  [156, 204, 101]/255;
intenseRed = [255, 112, 67]/255;
lightGreen = [ 197, 225, 165 ]/255;

set(gui_h.track_single_cell_pushbutton, 'BackgroundColor', intenseGreen)
set(gui_h.delete_track_pushbutton,      'BackgroundColor', intenseRed)
set(gui_h.plot_all_pushbutton,          'BackgroundColor', lightGreen)
set(gui_h.inspect_track_pushbutton,     'BackgroundColor', lightGreen);

% Remove xticks
set(gui_h.ax, 'Xtick', [])
set(gui_h.ax, 'ytick', [])