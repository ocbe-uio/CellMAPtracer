function varargout = CellTracer_Main_GUI(varargin)
% CellTracer_Main_GUI MATLAB code for CellTracer_Main_GUI.fig
%      CellTracer_Main_GUI, by itself, creates a new CellTracer_Main_GUI or raises the existing
%      singleton*.
%
%      H = CellTracer_Main_GUI returns the handle to a new CellTracer_Main_GUI or the handle to
%      the existing singleton*.
%
%      CellTracer_Main_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CellTracer_Main_GUI.M with the given input arguments.
%
%      CellTracer_Main_GUI('Property','Value',...) creates a new CellTracer_Main_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CellTracer_Main_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CellTracer_Main_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CellTracer_Main_GUI

% Last Modified by GUIDE v2.5 25-Jan-2020 22:31:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CellTracer_Main_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @CellTracer_Main_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before CellTracer_Main_GUI is made visible.
function CellTracer_Main_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CellTracer_Main_GUI (see VARARGIN)

% Choose default command line output for CellTracer_Main_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CellTracer_Main_GUI wait for user response (see UIRESUME)
% uiwait(handles.Cell_Tracer_MainFigure);


% --- Outputs from this function are returned to the command line.
function varargout = CellTracer_Main_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in CalculatedTracks_listbox.
function CalculatedTracks_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to CalculatedTracks_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CalculatedTracks_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CalculatedTracks_listbox


% --- Executes during object creation, after setting all properties.
function CalculatedTracks_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CalculatedTracks_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in track_single_cell_pushbutton.
function track_single_cell_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to track_single_cell_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in delete_track_pushbutton.
function delete_track_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to delete_track_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in plot_all_pushbutton.
function plot_all_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plot_all_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_load_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_save_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_plot_Callback(hObject, eventdata, handles)
% hObject    handle to menu_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_plot_allnewwindow_Callback(hObject, eventdata, handles)
% hObject    handle to menu_plot_allnewwindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_save_mat_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save_mat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_save_xls_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save_xls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_loadtiff_Callback(hObject, eventdata, handles)
% hObject    handle to menu_loadtiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_loadcalculatedfile_Callback(hObject, eventdata, handles)
% hObject    handle to menu_loadcalculatedfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_cell_id_Callback(hObject, eventdata, handles)
% hObject    handle to menu_cell_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_reset_cellsID_Callback(hObject, eventdata, handles)
% hObject    handle to menu_reset_cellsID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function analyze_single_track_Callback(hObject, eventdata, handles)
% hObject    handle to analyze_single_track (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function analyze_all_tracks_Callback(hObject, eventdata, handles)
% hObject    handle to analyze_all_tracks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function define_dt_Callback(hObject, eventdata, handles)
% hObject    handle to define_dt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_cell_info_Callback(hObject, eventdata, handles)
% hObject    handle to menu_cell_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function define_cell_size_Callback(hObject, eventdata, handles)
% hObject    handle to define_cell_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function exp_name_edit_Callback(hObject, eventdata, handles)
% hObject    handle to exp_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exp_name_edit as text
%        str2double(get(hObject,'String')) returns contents of exp_name_edit as a double


% --- Executes during object creation, after setting all properties.
function exp_name_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exp_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pixel_size_edit_Callback(hObject, eventdata, handles)
% hObject    handle to pixel_size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pixel_size_edit as text
%        str2double(get(hObject,'String')) returns contents of pixel_size_edit as a double


% --- Executes during object creation, after setting all properties.
function pixel_size_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixel_size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dt_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dt_edit as text
%        str2double(get(hObject,'String')) returns contents of dt_edit as a double


% --- Executes during object creation, after setting all properties.
function dt_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pixel_size_unit_popupmenu.
function pixel_size_unit_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to pixel_size_unit_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pixel_size_unit_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pixel_size_unit_popupmenu


% --- Executes during object creation, after setting all properties.
function pixel_size_unit_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixel_size_unit_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dt_unit_popupmenu.
function dt_unit_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to dt_unit_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dt_unit_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dt_unit_popupmenu


% --- Executes during object creation, after setting all properties.
function dt_unit_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dt_unit_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in export_result_struct_popupmenu.
function export_result_struct_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to export_result_struct_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns export_result_struct_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from export_result_struct_popupmenu


% --- Executes during object creation, after setting all properties.
function export_result_struct_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to export_result_struct_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_on_new_figure_pushbutton.
function plot_on_new_figure_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plot_on_new_figure_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in export_tracks_popupmenu.
function export_tracks_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to export_tracks_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns export_tracks_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from export_tracks_popupmenu


% --------------------------------------------------------------------
function menu_track_single_cell_Callback(hObject, eventdata, handles)
% hObject    handle to menu_track_single_cell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_plot_all_on_new_figure_Callback(hObject, eventdata, handles)
% hObject    handle to menu_plot_all_on_new_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in inspect_track_pushbutton.
function inspect_track_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to inspect_track_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
