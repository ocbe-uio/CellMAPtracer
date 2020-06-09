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

%% Background color
backgroundColor = [1 1 1];
%% Main panel
set(gui_h.Cell_Tracer_MainFigure, 'Color',backgroundColor)
% %% Cell Tracking panel 
set(gui_h.ax,       'Color',            backgroundColor)
set(gui_h.uipanel2, 'BackgroundColor',  backgroundColor)
set(gui_h.text4,    'BackgroundColor',  backgroundColor)
set(gui_h.text7,    'BackgroundColor',  backgroundColor)
% %% Cell track analysis
set(gui_h.uipanel1, 'BackgroundColor',                      backgroundColor)
set(gui_h.text5,    'BackgroundColor',                      backgroundColor) % 1pixel
set(gui_h.text6,    'BackgroundColor',                      backgroundColor)
% set(gui_h.result_table_description_text, 'BackgroundColor', backgroundColor)
set(gui_h.table_description_pushbutton, 'BackgroundColor', lightGreen)
set(gui_h.Calculations_explanation_pushbutton,'BackgroundColor', lightGreen)
% set(gui_h.right_click_explanation_text, 'BackgroundColor', backgroundColor)

%% Figure name
set(gui_h.Cell_Tracer_MainFigure, 'Name', getVer)
% %% Experiment name
% set(gui_h.exp_name_edit, 'BackgroundColor', ExperimentNameBackground)
% 
% %% Pixel size and time interval:
% set(gui_h.pixel_size_edit, 'BackgroundColor', lightGreen)
% set(gui_h.dt_edit, 'BackgroundColor', lightGreen)
% 
% %% Calculated Tracks listbox + pushbuttons around
% set(gui_h.CalculatedTracks_listbox,     'BackgroundColor', ListboxBackgroundCol)
% set(gui_h.track_single_cell_pushbutton, 'BackgroundColor', TrackSingleCol)
% set(gui_h.delete_track_pushbutton,      'BackgroundColor', DeleteTrackCol)
% set(gui_h.plot_all_pushbutton,          'BackgroundColor', PlotOnNewFigPushbuttonCol)
% set(gui_h.inspect_track_pushbutton,     'BackgroundColor', InspectTrackCol);
% 
% %% Cell Tracking panel 
% set(gui_h.ax,       'Color',            CellTrackingPanelColor)
% set(gui_h.uipanel2, 'BackgroundColor',  CellTrackingPanelColor)
% set(gui_h.text4,    'BackgroundColor',  CellTrackingPanelColor)
% set(gui_h.text7,    'BackgroundColor',  CellTrackingPanelColor)
% 
% %% Cell track analysis
% set(gui_h.uipanel1, 'BackgroundColor',                      CellTrackAnalysisPanel)
% set(gui_h.text5,    'BackgroundColor',                      CellTrackAnalysisPanel) % 1pixel
% set(gui_h.text6,    'BackgroundColor',                      CellTrackAnalysisPanel)
% set(gui_h.result_table_description_text, 'BackgroundColor', CellTrackAnalysisPanel)
% set(gui_h.right_click_explanation_text,  'BackgroundColor', CellTrackAnalysisPanel)

% Remove xticks
set(gui_h.ax, 'Xtick', [])
set(gui_h.ax, 'ytick', [])

% Remove xticks
set(gui_h.ax, 'Xtick', [])
set(gui_h.ax, 'ytick', [])