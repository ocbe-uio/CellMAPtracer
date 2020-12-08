function gui_h = updatetrackingwindowcolors(gui_h)
%% updatetrackingwindowcolors - function adds colors to main gui figure
% Colors used from https://htmlcolorcodes.com/color-chart/
intenseGreen =  [156, 204, 101]/255;
% intenseRed = [255, 112, 67]/255;
intenseRed = [255, 0, 0]/255;
lightGreen = [ 197, 225, 165 ]/255;
backgroundColor = [1 1 1];

set(gui_h.figure1, 'Color',backgroundColor)
set(gui_h.preprocessingpanel,   'BackgroundColor', backgroundColor)
set(gui_h.whattoshowpanel,      'BackgroundColor', backgroundColor)
set(gui_h.backroundcolorpanel,  'BackgroundColor', backgroundColor)
set(gui_h.celltrackpositionpanel, 'BackgroundColor', backgroundColor);
set(gui_h.trackingpanel,          'BackgroundColor', backgroundColor)
set(gui_h.CellDivisionPanel,      'BackgroundColor', backgroundColor);
set(gui_h.rectanglesizepanel,     'BackgroundColor', backgroundColor);
set(gui_h.method_watershed,       'BackgroundColor', backgroundColor);
set(gui_h.method_thresholding ,   'BackgroundColor', backgroundColor);
set(gui_h.ShowRaw ,               'BackgroundColor', backgroundColor);
set(gui_h.ShowProcessed,          'BackgroundColor', backgroundColor);
set(gui_h.progress_txt,           'BackgroundColor', backgroundColor);
set(gui_h.progress_slider,        'BackgroundColor', backgroundColor);
set(gui_h.use_centre_of_mass_checkbox , 'BackgroundColor',  backgroundColor);
set(gui_h.rectangle_size_slider,  'BackgroundColor', backgroundColor);
set(gui_h.CurrentTrackCellColorIndicatorText, 'BackgroundColor',backgroundColor)

%% Pushbuttons
set(gui_h.showCalculations,   'BackgroundColor', lightGreen);
set(gui_h.ResetCalculations,  'BackgroundColor', lightGreen);
set(gui_h.CurrentTrackCellColorIndicator , 'BackgroundColor', intenseRed);

set(gui_h.next_pushbutton, 'FontSize', 12, 'FontWeight', 'bold')
set(gui_h.previous_pushbutton, 'FontSize', 12, 'FontWeight', 'bold')
set(gui_h.const_togglebutton, 'FontSize', 10, 'FontWeight', 'bold','BackgroundColor', intenseGreen)
set(gui_h.SaveAndClose, 'FontSize', 10, 'FontWeight', 'bold',  'BackgroundColor', intenseGreen);
set(gui_h.CenterView_pushbutton , 'FontSize', 10,  'BackgroundColor', lightGreen);
set(gui_h.CellDivision_pushbutton , 'FontSize', 10, 'FontWeight', ...
  'bold', 'BackgroundColor', intenseGreen);
set(gui_h.Undo_CellDivision_pushbutton , 'FontSize', 10, 'BackgroundColor', lightGreen);


%% Background color
% backgroundColor = [1 1 1];
%% Main panel
% set(gui_h.Cell_Tracer_MainFigure, 'Color',backgroundColor)
% % %% Cell Tracking panel 
% set(gui_h.ax,       'Color',            backgroundColor)
% set(gui_h.uipanel2, 'BackgroundColor',  backgroundColor)
% set(gui_h.text4,    'BackgroundColor',  backgroundColor)
% set(gui_h.text7,    'BackgroundColor',  backgroundColor)
% % %% Cell track analysis
% set(gui_h.uipanel1, 'BackgroundColor',                      backgroundColor)
% set(gui_h.text5,    'BackgroundColor',                      backgroundColor) % 1pixel
% set(gui_h.text6,    'BackgroundColor',                      backgroundColor)
% % set(gui_h.result_table_description_text, 'BackgroundColor', backgroundColor)
% set(gui_h.table_description_pushbutton, 'BackgroundColor', lightGreen)
% set(gui_h.right_click_explanation_text, 'BackgroundColor', backgroundColor)
