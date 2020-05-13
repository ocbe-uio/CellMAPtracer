function updateguicolors(gui_h)

% Choose pallete:
c1 = [ 0.8196    0.9490    0.9216];
c2 = [0.9098    0.9725    0.9608];
c3 = [0.9961    0.9765    0.9059];
c4 = [0.6471    0.8392    0.6549];

% Remove xticks
set(gui_h.ax, 'Xtick', [])
set(gui_h.ax, 'ytick', [])

% Experiment name
set(gui_h.exp_name_edit, 'BackgroundColor', c1)

%% Calculated Tracks listbox + pushbuttons around
set(gui_h.CalculatedTracks_listbox, 'BackgroundColor', c2)
set(gui_h.track_single_cell_pushbutton, 'BackgroundColor', c4)
set(gui_h.delete_track_pushbutton, 'BackgroundColor', c1)
set(gui_h.plot_all_pushbutton, 'BackgroundColor',c4)
set(gui_h.inspect_track_pushbutton, 'BackgroundColor',c4);

%% Cell Tracking panel 
set(gui_h.ax, 'Color', c2)
set(gui_h.uipanel2, 'BackgroundColor', c2)
set(gui_h.text4, 'BackgroundColor', c2)
set(gui_h.text7, 'BackgroundColor', c2)

%% Cell track analysis
set(gui_h.uipanel1, 'BackgroundColor', c1)
set(gui_h.text5, 'BackgroundColor',c1) % 1pixel
set(gui_h.text6, 'BackgroundColor', c1)
set(gui_h.result_table_description_text, 'BackgroundColor', c1)
set(gui_h.right_click_explanation_text, 'BackgroundColor', c1)

