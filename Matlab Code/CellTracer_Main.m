function CellTracer_Main()
%% CELLTRACER_MAIN - main function contains main gui and all callbacks
% Loads CellTracer_Main_GUI figure and operates on handles from this GUI. 
% CellTracer_Main()

%% Load Graphic User Interface and set all callbacks
gui_h = guidata(CellTracer_Main_GUI);

set(gui_h.inspect_track_pushbutton,     'Callback', @inspecttrack)
% Note: exporting only XY position: (not used in current version)
set(gui_h.export_result_struct_popupmenu, 'Callback', @exportresults)
set(gui_h.exp_name_edit,                'Callback', @updexperimentname)
set(gui_h.menu_reset_cellsID,           'Callback', @reset_ID_Order) % Reset All names
set(gui_h.menu_loadtiff,                'Callback', @loadtiffandinitalltracks)
set(gui_h.menu_save_mat,                'Callback', @AllTracks_SaveAsMat)
set(gui_h.menu_loadcalculatedfile,      'Callback', @AllTracks_loadFromMat) 
set(gui_h.CalculatedTracks_listbox,     'Callback', @SingleTrack_Plot)
set(gui_h.menu_track_single_cell,       'Callback', @tracksinglecell)
set(gui_h.track_single_cell_pushbutton, 'Callback', @tracksinglecell)
set(gui_h.delete_track_pushbutton,      'Callback', @deletetrack)
set(gui_h.plot_all_pushbutton,          'Callback', @Tracks_VisualizeInExternalWindow)
set(gui_h.menu_plot_all_on_new_figure, 'Callback',  @plotallonnewfigure)
set(gui_h.ax, 'Visible', 'Off')
set(gui_h.Cell_Tracer_MainFigure, 'CloseRequestFcn', @closemain)

% Setting min=0 and max=10 allows to highlight more than one value on the
% listbox (then when user click one cell or doughters and mothers cell are
% highlighted and plotted:
set(gui_h.CalculatedTracks_listbox,   'Min', 0);
set(gui_h.CalculatedTracks_listbox,   'Max', 10);

% Set Calculation Parameters
set(gui_h.dt_edit,            'Callback', @changeparameters)
set(gui_h.dt_unit_popupmenu,  'Callback', @changeparameters)
set(gui_h.pixel_size_edit,    'Callback', @changeparameters)
set(gui_h.pixel_size_unit_popupmenu, 'Callback', @changeparameters)

%% Initialize Variables and objects
AllImages  = []; 
AllTracks  = ALL_Tracks(gui_h.exp_name_edit.String);
Parameters = ExperimentParameters();
CalculationResults = [];

%% LOCAL FUNCTIONS:
% ..closemain
  function closemain(~,~)
    % Before closing ask user to save tracks
    % By default .mat is saved (user can reload and export as .xls)
    if ~AllTracks.isThereAnyCellTracked()
      % close imidiately if there is nothing to save
      delete(gui_h.Cell_Tracer_MainFigure); 
    else
      answer = questdlg('Do you want save calculated tracks?',getVer(), ...
        'Yes', 'No','Cancel', 'Cancel');
      switch answer
        case 'No', delete(gui_h.Cell_Tracer_MainFigure); 
        case 'Yes'
          AllTracks_SaveAsMat([],[]) % Save as .mat
          delete(gui_h.Cell_Tracer_MainFigure);  % close program
        case 'Cancel' % Do nothing
      end
    end   
  end

% ..tracksinglecell
  function tracksinglecell(varargin)
    if isempty(AllImages), noTiffWarning(), return, end
    % Desable 'Track Single Cell' to not open many windows in the same time
    set(gui_h.track_single_cell_pushbutton, 'Enable', 'off')
    iniPosOfCells = AllTracks.getInitialPositionOfCalcCells();
    [pos, isCanceled] = choosecellfortracking(AllImages(:,:,1), iniPosOfCells);
    if isCanceled, replot(), return, end
    if isnan(pos), noCellFoundWarning(), replot(),return, end
    AllTracks.incrementLastTrackNumber;
    CellTrackName = [AllTracks.CellTrackNameConstant num2str(AllTracks.getLastTrackNumber)];
    cellTracks = track_acrossallimages(AllImages,pos,CellTrackName);
    AllTracks.addNewTrackedCell(cellTracks);
    updlistbox([],[]), replot()
  end

% ..inspecttrack
  function inspecttrack(varargin)
     if isempty(AllImages), noTiffWarning(), return, end
    if ~AllTracks.isThereAnyCellTracked(), return, end
    listbox  = gui_h.CalculatedTracks_listbox;
    if numel(listbox.Value) > 1
       warndlg('You can choose only one track to inspect', mfilename)
       return
    end
    CellRows = AllTracks.getCellRows(listbox.String(listbox.Value));
    Cell_xy_pos = AllTracks.Tracks.Cell_xy_pos(CellRows,:);
    CellTrackName = AllTracks.Tracks.CellName{CellRows(1)};
    [cellTable, isCellValid] = track_inspect(AllImages,Cell_xy_pos,CellTrackName);
    if isCellValid
      CellRows = AllTracks.getCellRows(CellTrackName);
      AllTracks.Tracks.Cell_xy_pos(CellRows,:) = cellTable;
      replot()
    end
  end

% ..updexperimentname
  function updexperimentname(src,~), AllTracks.ExperimentName = src.String; end

% ..updlistbox
  function updlistbox(varargin)
    if ~AllTracks.isThereAnyCellTracked()
      set(gui_h.CalculatedTracks_listbox, 'String', [])
    else
      set(gui_h.CalculatedTracks_listbox, 'String', AllTracks.getListOfCells())
      set(gui_h.CalculatedTracks_listbox, 'Value', AllTracks.NumTracks)
    end
  end

% ..gettiffpath
  function loadtiffandinitalltracks(varargin)
    [TiffFileName, TiffFullPath] = uigetfile(sprintf('%s.tif', '*'));
    if ischar(TiffFileName)
      [AllImages, ~] = loadmultitif([TiffFullPath, TiffFileName]);
      ExpName = gui_h.exp_name_edit.String;
      AllTracks = ALL_Tracks(ExpName,TiffFullPath,TiffFileName,AllImages);
      updadeGUI()
    end
  end

% ..updadeGUI
  function updadeGUI()
    Parameters.updParametesFields(gui_h)
    updlistbox([],[])
    
    replot()
    % If there are no cells, reset gui:
    if AllTracks.NumTracks == 0
      CalculationResults = [];
      set(gui_h.calculation_results_uitable, 'Data', [])
      % Clear row names to not keep cell names when new tiff file is loaded
      set(gui_h.calculation_results_uitable, 'RowName', []) 
      set(gui_h.export_result_struct_popupmenu, 'Visible', 'off')
    end
    if isempty(AllImages)
      axes(gui_h.ax), cla
    end
  end

% ..replot
  function replot()
    % By default shows first image from multitiff and plot initial position
    % of calculated tracks.
    axis(gui_h.ax); 
    set(gui_h.ax, 'Visible', 'on')
    if isempty(AllImages)
      cla
    else
      imagesc(AllImages(:,:,1));
    end
    set(gui_h.ax,'ytick', []); 
    set(gui_h.ax,'xtick', []);
    initialPos = AllTracks.getInitialPositionOfCalcCells();
    if ~isempty(initialPos)
      hold on, plot(initialPos(:,1), initialPos(:,2), 'or'); hold off
    end
    title(AllTracks.getTiffFileName(),'Interpreter','none');
    if AllTracks.NumTracks > 0, analyzetracks(), end
    set(gui_h.track_single_cell_pushbutton, 'Enable', 'on')
  end

% ..plotallonnwefigure
  function plotallonnewfigure(~,~)
     if ~AllTracks.isThereAnyCellTracked(), return, end 
     listbox = gui_h.CalculatedTracks_listbox;
     set(listbox, 'Value', 1:numel(listbox.String))
     Tracks_VisualizeInExternalWindow()
  end

% ..SingleTrack_Plot
  function SingleTrack_Plot(listbox,~) 
    % Because is listbox callback do not add warning about tracks (its anoying)
    if ~AllTracks.isThereAnyCellTracked(), return, end 
    replot()
    CellRows = AllTracks.getCellRows(listbox.String(listbox.Value));
    hold on, plotcelltracks(AllTracks.Tracks(CellRows, :)), hold off % plot in red
    legend('off')
  end

% ..analyzetracks
  function analyzetracks(~,~)
    if AllTracks.NumTracks == 0,  noTracksWarning(),  return, end 
    CalculationResults = AnalyzeTracks(AllTracks,Parameters);
    set(gui_h.calculation_results_uitable, 'Visible', 'on')
    set(gui_h.export_result_struct_popupmenu, 'Visible', 'on')
    % To make it more clear, round values of the table
    VarList = {'isDivided','isDaughter','nImages',...
      'Distance', 'Displacement','TrajectoryTime', 'Directionality','AverageSpeed'};
    
    Data2Table = CalculationResults(:,VarList);
    % Round values to first decimal digit (only for visualisation)
    Data2Table.Distance = round( Data2Table.Distance,1 );
    Data2Table.Displacement = round( Data2Table.Displacement,1 );
    Data2Table.TrajectoryTime = round( Data2Table.TrajectoryTime,1 );
    Data2Table.Directionality = round( Data2Table.Directionality,1 );
    Data2Table.AverageSpeed = round( Data2Table.AverageSpeed,1 );
    
    set(gui_h.calculation_results_uitable, 'Data', table2cell(Data2Table));
    set(gui_h.calculation_results_uitable, 'ButtonDownFcn', @showdisplacementexplanation)
    set(gui_h.calculation_results_uitable,'ColumnName',VarList);
    set(gui_h.calculation_results_uitable, 'RowName',...
      CalculationResults{:,'CellName'});
    
    c = CalculationResults.Properties.VariableDescriptions(VarList);
    set(gui_h.result_table_description_text, 'String',[c{:}])
    set(gui_h.right_click_explanation_text, 'Visible', 'on')
  end

% ..showdisplacementexplanation
    function showdisplacementexplanation(varargin)
        figure('MenuBar', 'none','ToolBar', 'none');
        imshow('displacement.jpeg')
    end

% ..reset_ID_Order
  function reset_ID_Order(~,~)
    % After deleting cells order is not correct. Here i reorder CellID and
    % CellNames (unfortutely in for loop)
    if AllTracks.NumTracks == 0,  noTracksWarning(),  return, end
    AllTracks.resetIDorder();
    set(gui_h.CalculatedTracks_listbox, 'Value', 1)
    updadeGUI()
  end

% ..AllTracks_VisualizeInExternalWindow()
  function Tracks_VisualizeInExternalWindow(varargin)
    % Visualise in new figure cells tracks which are highlighted in listbox 
    if isempty(AllImages), noTiffWarning(), return, end
    if AllTracks.NumTracks == 0
      % Show only multitiff
      showMultitiff(AllImages)
    else
      % Show multitiff and tracks
      listbox = gui_h.CalculatedTracks_listbox;
      CellRows = AllTracks.getCellRows(listbox.String(listbox.Value));
      visualizeResults(AllImages,  AllTracks.Tracks(CellRows,:))
    end
  end

% ..AllTracks_loadFromMat() 
  function AllTracks_loadFromMat(~,~)
    [tracksFile, path] = uigetfile('*.mat');
    if ischar(tracksFile)
       A = load([path, tracksFile], 'AllTracks');
      % In this point AllImages are already loaded
      [AllTracks, Parameters] = AllTracks.loadCalculatedTracks2Object(A.AllTracks);
      gui_h.exp_name_edit.String = AllTracks.ExperimentName;
      try
        [AllImages, ~] = loadmultitif(AllTracks.getFullTiffPath);
      catch
        % There is no tiff file in path specified in AllImages metadata.
        % User can specify where the multitiff is
        % This happens when user works on 2 different computers, because
        % file path is saved as full path. 
        answer = questdlg({sprintf('Can''t find %s',AllTracks.getTiffFileName())...
          'Would you like to specify location of this file?'}, ...
          'Yes','Yes', 'No','No');
        
        % Load tiff file from new location:
        % Note that tracks are already loaded so only the image is missing:
        if strcmp(answer, 'Yes')
          [fname, fpath] = uigetfile(sprintf('%s.tif', AllTracks.getTiffFileName()));
          
          if ischar(fname)
            % Check if the loaded file and saved file have the same name
            if ~isequal(fname, AllTracks.getTiffFileName())
              errordlg(sprintf('File Names does not match: \n Saved file: %s \n New File: %s',...
                 AllTracks.getTiffFileName(), fname))
              reset_gui()
              return
            end
            try
            [AllImages, ~] = loadmultitif([fpath, fname]);
             AllTracks.Metadata.TiffFullPath = fpath;
            catch 
              errordlg('File cannot be loaded')
              reset_gui()
              return
            end
          end
        elseif strcmp(answer, 'No')
          AllImages = [];
        end
      end
      figure(gui_h.Cell_Tracer_MainFigure)
      updadeGUI()
    end
  end

% ..AllTracks_SaveAsMat
  function AllTracks_SaveAsMat(~, ~)
    if ~AllTracks.isThereAnyCellTracked(), noTracksWarning(), return, end
    AllTracks.SaveAsMat(Parameters);
  end

% ..deletetrack()
  function deletetrack(~,~)
    if AllTracks.NumTracks == 0, noTracksWarning(), return, end
     Track2delete = get(gui_h.CalculatedTracks_listbox, 'Value');
     AllListboxStrings = get(gui_h.CalculatedTracks_listbox, 'String');
     Track2deleteName = string(AllListboxStrings(Track2delete,:));
     choice = questdlg(sprintf('Delete track %s ?',join(Track2deleteName, ',')),...
       getVer(), 'Yes', 'No', 'No'); % I am not sure if join works in my version of matlab
    if strcmp(choice, 'Yes')
      AllTracks.deleteTrack(Track2deleteName)
      set(gui_h.CalculatedTracks_listbox, 'Value', 1)
      updadeGUI()
    end
  end

% ..changeparameters
  function changeparameters(src,~)
    switch src.Tag
      case 'pixel_size_unit_popupmenu'
        Parameters.PixelSize_Unit = src.String{src.Value};
      case 'pixel_size_edit'
        if isinputvalueok(str2double(src.String)) % check if user writes someting stupid
          Parameters.PixelSize = str2double(src.String); 
        else
          src.String =  Parameters.PixelSize;
        end
      case 'dt_edit'
        if isinputvalueok(str2double(src.String))  % check if user writes someting stupid
           Parameters.TimeInterval = str2double(src.String);
        else
          src.String =  Parameters.TimeInterval;
        end
      case 'dt_unit_popupmenu'
         Parameters.TimeInterval_Unit = src.String{src.Value};
    end
    analyzetracks()
  end

% ...exportresults
  function exportresults(src,~)
    % Export results to Excell file:
    WhatToExport = src.String{src.Value}; % Divided, not divided, all cells
    switch WhatToExport
      case 'All Cells' % All cells
        result2Export = CalculationResults;
      case 'Dividing Cells' 
        % Cells which divides at least once -> 'isDivided' is true
        result2Export = CalculationResults(CalculationResults.isDivided,:);
      case 'Non-Dividing Cells'
        % Cells which did not divide -> 'isDivided' is false
        result2Export = CalculationResults(~CalculationResults.isDivided,:);
      case 'Daughter Cells'
        % Cells which did not divide -> 'isDaughter' is true
          result2Export = CalculationResults(CalculationResults.isDaughter,:);
      case 'Dividing Daughter Cells' 
        % Cells which divides twice  -> 'isDivided' is true & 'isDaughter' is true 
        isDivided =  CalculationResults.isDivided;
        isDaughter = CalculationResults.isDaughter;
        result2Export = CalculationResults(isDivided & isDaughter,:);
      otherwise % do nothing if user click meanwhile on something else
        return
    end

    if isempty(result2Export)
      warndlg(sprintf('There is no [%s] cells to export',WhatToExport), getVer())
      return
    end
    tracks2Export = AllTracks.prapareForExportToExcell(result2Export.CellName);
    
    % Save results of calculations to excell file:
    tiffName = AllTracks.getTiffFileName();
    [excelFileName, path] = uiputfile([AllTracks.ExperimentName ' ',...
      tiffName(1:end-4) ' ' WhatToExport  '_Results.xlsx']);
    h = msgbox(sprintf('Saving %s ...', excelFileName), 'Saving Excell File');
    if ischar(excelFileName)
      try
      warning('off', 'MATLAB:xlswrite:AddSheet')
      catch
      end
      writetable(result2Export, [path, excelFileName],'Sheet',1)
      writetable(tracks2Export, [path, excelFileName],'Sheet',2)
      msgbox(sprintf('Saved as %s', excelFileName), 'Success')
    end
    delete(h)
  end

% reset gui
  function reset_gui()
    % It is called when loaded tracks do not fit to loaded tiff
    AllImages  = [];
    AllTracks  = ALL_Tracks(gui_h.exp_name_edit.String);
    Parameters = ExperimentParameters();
    CalculationResults = [];
  end

  % ..isinputvalueok
  function isok = isinputvalueok(userinput)
    % Must be positive number, both for pixel size and Time Interval
    if isnumeric(userinput), isok = userinput > 0; else, isok = false; end
    if ~isok,  warndlg('Input must be positive number', mfilename); end
  end

% ..warnings::
  function noTiffWarning(),   warndlg('First Tiff Load File', mfilename), end
  function noTracksWarning(), warndlg('No tracks found', mfilename), end
  function noCellFoundWarning(), warndlg('No Cells found', mfilename), end
end

