function updateguicolors(gui_h)

% % Choose pallete:
% c1 = [0.8196    0.9490    0.9216];
% c2 = [0.9098    0.9725    0.9608];
% c3 = [0.9961    0.9765    0.9059];
% c4 = [0.6471    0.8392    0.6549];
% Gray tone from:
%http://www.creativecolorschemes.com/resources/free-color-schemes/gray-tone-color-scheme.shtml
ColorPallete = [
200 134 154; %1 
173 133 186; %2 
149 161 195; %3 
116 161 142; %4 
129 173 181; %5  
178 200 145; %6 
185 156 107; %7 
228 153 105; %8 
201 194 127; %9 
148 148 148; %10 
178 178 178; %11 
214 214 214; %12 
145 134 126; %13 
178 170 164; %14 
217 213 210; %15 
] / 255; 


MainWindowBackgroundColor   = ColorPallete(13,:);
ExperimentNameBackground    = ColorPallete(12,:);
CellTrackingPanelColor      = ColorPallete(12,:);
CellTrackAnalysis           = ColorPallete(12,:);
TrackSingleCol              = ColorPallete(8,:);
PlotOnNewFigPushbuttonCol   = ColorPallete(9,:);
InspectTrackCol             = ColorPallete(9,:);
DeleteTrackCol              = ColorPallete(1,:);
ListboxBackgroundCol        = ColorPallete(15,:);

%% Main panel
set(gui_h.Cell_Tracer_MainFigure, 'Color',MainWindowBackgroundColor)

%% Experiment name
set(gui_h.exp_name_edit, 'BackgroundColor', ExperimentNameBackground)

%% Calculated Tracks listbox + pushbuttons around
set(gui_h.CalculatedTracks_listbox,     'BackgroundColor', ListboxBackgroundCol)
set(gui_h.track_single_cell_pushbutton, 'BackgroundColor', TrackSingleCol)
set(gui_h.delete_track_pushbutton,      'BackgroundColor', DeleteTrackCol)
set(gui_h.plot_all_pushbutton,          'BackgroundColor', PlotOnNewFigPushbuttonCol)
set(gui_h.inspect_track_pushbutton,     'BackgroundColor', InspectTrackCol);

%% Cell Tracking panel 
set(gui_h.ax,       'Color',            CellTrackingPanelColor)
set(gui_h.uipanel2, 'BackgroundColor',  CellTrackingPanelColor)
set(gui_h.text4,    'BackgroundColor',  CellTrackingPanelColor)
set(gui_h.text7,    'BackgroundColor',  CellTrackingPanelColor)

%% Cell track analysis
set(gui_h.uipanel1, 'BackgroundColor',                      CellTrackAnalysis)
set(gui_h.text5,    'BackgroundColor',                      CellTrackAnalysis) % 1pixel
set(gui_h.text6,    'BackgroundColor',                      CellTrackAnalysis)
set(gui_h.result_table_description_text, 'BackgroundColor', CellTrackAnalysis)
set(gui_h.right_click_explanation_text,  'BackgroundColor', CellTrackAnalysis)

% Remove xticks
set(gui_h.ax, 'Xtick', [])
set(gui_h.ax, 'ytick', [])