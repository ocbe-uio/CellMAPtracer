classdef TracksAuditorWindowController < handle
  %% TracksAuditor - class to visualise tracks on RGB background.
  % To run, constructor needs Multitff and Tracks inputs.
  properties
    VMATobject            % vMat object
    TracksObj             % Tracks object
    MovingRectangles      % MovingRectangle object
    fig                   % Main figure handle
    RectSizeControl       % Moving Rectangle object
    guih                  % Graphic handles
  end
  
  properties  (GetAccess = private)
    ImageHandles         % handles from all subplots
    SliderAcrossFrames  
    CellNameListbox
    ExportOptionsPopupmenu
    ChannelTitles
    NormalizeCheckobox
    FucciPhasePredictidMethod
  end
  
  methods (Access = public)
    function obj = TracksAuditorWindowController(Multitiff, AllTracks)
      % Auditor - constructor
      % Load Multitff
      obj.VMATobject = vMAT(Multitiff);
      
      % Load Tracks
      obj.TracksObj = Tracks(AllTracks);
      
      % Moving rectangle
      obj.MovingRectangles = createMovingRectangleList(obj);
      
      % Create Default Channel Titles
      obj.ChannelTitles = CreateDefaultChannelTitles(obj);
      
      % Default setting of Phase Prediction method
      obj.FucciPhasePredictidMethod = 'Geminin-PCNA - PIP';
    end
    
    function setFucciPhasePredictidMethod(obj, PredictingMethodName)
      ValidNames =  {'Geminin-PCNA - PIP', 'Geminin_Cdt1'};
      assert(ismember(PredictingMethodName,ValidNames),...
        sprintf('Not validf Predicting Method [%s] \nValid Methods names: \n %s \n %s',...
        PredictingMethodName,ValidNames{1},ValidNames{2} ));
      obj.FucciPhasePredictidMethod = PredictingMethodName;
    end
    
    function MovingRectangleList = createMovingRectangleList(obj)
      AllTracksNames = obj.TracksObj.getAllTracksNames;
      for iRectangle = 1:numel(AllTracksNames)
        MovingRectangleList(iRectangle) = MovingRectangle();
        MovingRectangleList(iRectangle).BackgroundImageSize = size(obj.VMATobject.getSingleFrame(1));
        MovingRectangleList(iRectangle).DistanceFromCentrePxl = 11; %#ok<*AGROW>
        MovingRectangleList(iRectangle).Name = AllTracksNames{iRectangle};
      end
    end
    
    function RunGUI(obj)
      obj.guih = TracksAuditorWindow;
      obj.SliderAcrossFrames      = obj.SetupSliderAcrossFrames;
      obj.CellNameListbox         = obj.SetupListboxWithCellNames;
      obj.RectSizeControl         = obj.SetupRectSizeControl();
      obj.ExportOptionsPopupmenu  = obj.SetupExportOptionsPopupmenu();
      obj.NormalizeCheckobox      = obj.CreateNormalizeCheckbox();
      set(obj.guih.UIFigure,      'KeyPressFcn', @obj.keypushcallback)
      set(obj.guih.PhaseDropDown, 'ValueChangedFcn', @obj.updStartEndFucci)
      set(obj.guih.CorrectButton, 'ButtonPushedFcn', @obj.correctPushbuttonCallback)
      set(obj.guih.ClearCorrectionButton, 'ButtonPushedFcn', @obj.removecorrectedphases)
      set(obj.guih.RemoveCellButton, 'ButtonPushedFcn', @obj.removeCellFromList)
      if obj.VMATobject.getNumberOfChannels == 1
        set(obj.guih.EnlargedCell_Red_axis, 'Visible','off')
        set(obj.guih.EnlargedCell_Green_axis, 'Visible','off')
        set(obj.guih.EnlargedCell_Blue_axis, 'Visible','off')
      end
      obj.setSettingsPanelTitle()
      obj.ShowTrack
      disp('TracksAuditor >> GUI initialized')
      % 'Click' on normalization button:
      obj.NormalizeCheckobox.Value = 1;
      obj.showNewCellTrack
    end
    
    function setSettingsPanelTitle(obj)
      defaultTitle = obj.guih.SettingsPanel.Title;
      obj.guih.SettingsPanel.Title =...
        sprintf('%s [%s]', defaultTitle, obj.FucciPhasePredictidMethod);
      
      obj.setDefaultValuesInEditFiels();
      
      % Hide all
      set(obj.guih.MaximumGreenBlueRatioinG1EditField, 'Visible', 'off')
      set(obj.guih.MaximumGreenBlueRatioinG1Label, 'Visible', 'off')
      
      set(obj.guih.MinimumGreenBlueRatioinG2EditField, 'Visible', 'off')
      set(obj.guih.MinimumGreenBlueRatioinG2Label, 'Visible', 'off')
      
      set(obj.guih.MinimumBlueSignalinG2EditField, 'Visible', 'off')
      set(obj.guih.MinimumBlueSignalinG2Label, 'Visible', 'off')
      
      set(obj.guih.MinimumGreenSignalinSphaseEditField, 'Visible', 'off')
      set(obj.guih.MinimumGreenSignalinSphaseEditFieldLabel, 'Visible', 'off')
      set(obj.guih.MinimumRedSignalinSphaseEditField, 'Visible', 'off')
      set(obj.guih.MinimumRedSignalinSphaseEditFieldLabel, 'Visible', 'off')
      set(obj.guih.MinimumSignalEditField, 'Visible', 'off')
      set(obj.guih.MinimumSignalEditFieldLabel, 'Visible', 'off')
      
      % Depent on title show only parameters for current method
      switch obj.FucciPhasePredictidMethod
        case 'Geminin-PCNA - PIP'
          set(obj.guih.MaximumGreenBlueRatioinG1EditField, 'Visible', 'on')
          set(obj.guih.MaximumGreenBlueRatioinG1Label, 'Visible', 'on')
          
          set(obj.guih.MinimumGreenBlueRatioinG2EditField, 'Visible', 'on')
          set(obj.guih.MinimumGreenBlueRatioinG2Label, 'Visible', 'on')
          
          set(obj.guih.MinimumBlueSignalinG2EditField, 'Visible', 'on')
          set(obj.guih.MinimumBlueSignalinG2Label, 'Visible', 'on')
          
        case 'Geminin_Cdt1'
          
          set(obj.guih.MinimumGreenSignalinSphaseEditField, 'Visible', 'on')
          set(obj.guih.MinimumGreenSignalinSphaseEditFieldLabel, 'Visible', 'on')
          
          set(obj.guih.MinimumRedSignalinSphaseEditField,    'Visible', 'on')
          set(obj.guih.MinimumRedSignalinSphaseEditFieldLabel, 'Visible', 'on')
          
          set(obj.guih.MinimumSignalEditField, 'Visible', 'on')
          set(obj.guih.MinimumSignalEditFieldLabel, 'Visible', 'on')
      end
    end
    
    function setDefaultValuesInEditFiels(obj)
      set(obj.guih.MaximumGreenBlueRatioinG1EditField, 'Value', 0.5)
      set(obj.guih.MinimumGreenBlueRatioinG2EditField, 'Value', 0.7)
      set(obj.guih.MinimumBlueSignalinG2EditField,    'Value', 0.1)
      
      set(obj.guih.MinimumGreenSignalinSphaseEditField,'Value', 0.1)
      set(obj.guih.MinimumRedSignalinSphaseEditField, 'Value', 0.1)
      set(obj.guih.MinimumSignalEditField, 'Value', 0.1)
      
      set(obj.guih.MaximumGreenBlueRatioinG1EditField,  'ValueChangedFcn', @obj.showNewCellTrack)
      set(obj.guih.MinimumGreenBlueRatioinG2EditField,  'ValueChangedFcn', @obj.showNewCellTrack)
      set(obj.guih.MinimumBlueSignalinG2EditField,      'ValueChangedFcn', @obj.showNewCellTrack)
      set(obj.guih.MinimumGreenSignalinSphaseEditField, 'ValueChangedFcn', @obj.showNewCellTrack)
      set(obj.guih.MinimumRedSignalinSphaseEditField,   'ValueChangedFcn', @obj.showNewCellTrack)
      set(obj.guih.MinimumSignalEditField,              'ValueChangedFcn', @obj.showNewCellTrack)
    end
    
    function ExportTable = ExportTableWithColorForEachCellPosition(obj,ExportTable)
      ExportTable.RGBColor = obj.getMeanColorForEachPositionOfRectangle(ExportTable);
      F = setUpFucciObject(obj,ExportTable);
      ExportTable.CyclePhase = F.AnalyseAllCells;
      % Copy manually corrected phases
      if isCorrectedPhasesSaved(obj)
        SavedPhases = obj.guih.CorrectButton.UserData;
        AllFields = fields(SavedPhases);
        for i = 1:numel(AllFields)
          qq = strcmp(ExportTable.CellName, strrep(AllFields{i}, '_', '.'));
          if sum(qq) % it is possible that the non divided cell is corrected but not exported
            ExportTable.CyclePhase(qq) = Fucci.cyclePhaseString(SavedPhases.(AllFields{i}));
          end
        end
      end
      % Remove empty rows:
      ExportTable(isnan(ExportTable.Cell_xy_pos(:,1)),:) = [];
    end
    
    function setChannelTitles(obj, CellWith3Titles)
      if iscell(CellWith3Titles) && numel(CellWith3Titles) == 3
        obj.ChannelTitles.Red    = CellWith3Titles{1};
        obj.ChannelTitles.Green  = CellWith3Titles{2};
        obj.ChannelTitles.Blue   = CellWith3Titles{3};
      end
    end
    
    function setDefaultRectangleSize(obj, RectSize)
      for iRec = 1:numel(obj.MovingRectangles)
        obj.MovingRectangles(iRec).DistanceFromCentrePxl = floor(RectSize/2);
      end
    end
    
    function rgbColor = getMeanColorForEachPositionOfRectangle(obj, TracksTable)
      % Alghorithm: for each cell, set moving rectangle for cell position
      % and return mean value of RGB colors.
      
      AllCellNames =  TracksTable.CellName(TracksTable.ImageID == 1);
      nCells = numel(AllCellNames);
      nRowsInTracksTable = size(TracksTable, 1);
      rgbColor = nan(nRowsInTracksTable,3);
      h = waitbar(0, 'please wait', 'Name', 'Export color for each position...');
      for i = 1:nCells
        CellName = AllCellNames{i};
        waitbar(i/nCells,h,CellName)
        [MeanR, MeanG, MeanB] = getMeanRGBForEachPositionOfCell(obj,CellName);
        TrackRows = strcmp(TracksTable.CellName,CellName);
        rgbColor(TrackRows,:) = [MeanR, MeanG, MeanB];
      end
      close(h)
    end
    
    function DEBUG_printAllRectangleSize(obj)
      AllTracksNames = obj.TracksObj.getAllTracksNames;
      for i = 1:numel(AllTracksNames)
        fprintf('%s --> %i \n', obj.MovingRectangles(i).Name,...
          obj.MovingRectangles(i).getRectangleSizeInPixels())
      end
    end
    
    function TEST_ALL(obj)
      obj.MoveRectangleToNewPosition();
      obj.showNewCellTrack();
      obj.correctPushbuttonCallback()
      
      s = obj.guih.RectSizeControl;
      initVal = s.Value;
      tc = matlab.uitest.TestCase.forInteractiveUse;
      tc.press(s,'up')
      tc.verifyEqual(s.Value,initVal+s.Step)
    end
  end
  
  methods (Access = private)
    function removecorrectedphases(obj,varargin)
      % removecorrectedphasess
      SavedPhases = obj.guih.CorrectButton.UserData;
      CellName = strrep(obj.getCurrentCellName, '.', '_');
      obj.guih.CorrectButton.UserData = rmfield(SavedPhases,CellName);
      showNewCellTrack(obj)
      obj.guih.ClearCorrectionButton.Visible = 'off';
    end
    
    function correctPushbuttonCallback(obj, varargin)
      % Test Logic
      CyclePhase =  obj.guih.PhaseDropDown.UserData ;
      % Make sure that this change make any sens:
      StartValue = obj.guih.FromFrameEditField.Value;
      EndValue =  obj.guih.TillFrameEditField.Value ;
      switch obj.guih.PhaseDropDown.Value
        case 'G1' %G1 -> S
          PhaseID = 1; NextPhase = 2;
        case 'S'  %S -> G2
          PhaseID = 2; NextPhase = 3;
        case 'G2' %G2 -> G1
          PhaseID = 3; NextPhase = 1;
      end
      % Problem: jesli zmieniasz value z 1:230
      % na 1:130 to nic sie nie zmieni..
      CyclePhase(StartValue:EndValue) = PhaseID;
      StartNextPhase = EndValue+1;
      EndNextPhase = find(CyclePhase == NextPhase,1,'last');
      CyclePhase(StartNextPhase:EndNextPhase) = NextPhase;
      
      % Replot Corrected phsase
      replotCorrectedPhase(obj,CyclePhase)
      
      % Save corrected phase in Correct pushbutton
      obj.saveCorrectedPhase(CyclePhase)
      obj.guih.ClearCorrectionButton.Visible = true;
    end
    
    function replotCorrectedPhase(obj,CorrectedPhase)
      CellName =  obj.getCurrentCellName;
      [MeanR, MeanG, MeanB] = obj.getMeanRGBForEachPositionOfCell(CellName);
      TrackTable = obj.TracksObj.getTrack(CellName);
      TrackTable.RGBColor = [MeanR, MeanG, MeanB];
      % Plot RGB
      LegendString1 = plotRGB(obj,TrackTable);
      % Plot CyclePhase
      LegendString2 =  Fucci.plotCyclePhaseAsPatchObject(CorrectedPhase,obj.guih.RGB_plot_axis);
      legend(obj.guih.RGB_plot_axis,...
        [LegendString1, LegendString2], 'Location', 'eastoutside')
    end
    
    function saveCorrectedPhase(obj, CorrectedPhase)
      CellName = strrep(obj.getCurrentCellName, '.', '_');
      SavedPhases = obj.guih.CorrectButton.UserData;
      SavedPhases.(CellName) = CorrectedPhase;
      obj.guih.CorrectButton.UserData = SavedPhases;
    end
    
    
    % + correct and save
    % +
    function updStartEndFucci(obj, varargin)
      CyclePhase =  obj.guih.PhaseDropDown.UserData ;
      obj.guih.FromFrameEditField.Value = -Inf;
      obj.guih.TillFrameEditField.Value = Inf;
      
      switch obj.guih.PhaseDropDown.Value
        case 'G1'
          StartValue = find(CyclePhase==1,1,'first');
          EndValue = find(CyclePhase==1,1,'last');
        case 'S'
          StartValue = find(CyclePhase==2,1,'first');
          EndValue = find(CyclePhase==2,1,'last');
        case 'G2'
          StartValue = find(CyclePhase==3,1,'first');
          EndValue = find(CyclePhase==3,1,'last');
        otherwise
          StartValue = [];   EndValue = [];
      end
      
      if ~isempty(StartValue)
        obj.guih.FromFrameEditField.Value = StartValue;
      end
      
      if ~isempty(EndValue)
        obj.guih.TillFrameEditField.Value = EndValue;
      end
      
      obj.guih.ClearCorrectionButton.Visible = obj.isCorrectedPhasesSaved();
    end
    
    function isManuallyCorrectedPhases = isCorrectedPhasesSaved(obj)
      % check if there are saved manually corrected phases for this cell
      CellName = strrep( obj.getCurrentCellName, '.', '_');
      SavedPhases = obj.guih.CorrectButton.UserData;
      isManuallyCorrectedPhases = isfield(SavedPhases, CellName);
    end
    
    function showNewCellTrack(obj,varargin)
      % Update gui when new cell track is clicked:
      FirstTrackFrame = obj.TracksObj.getFirstTrackFrame(obj.getCurrentCellName);
      set(obj.SliderAcrossFrames, 'Value',FirstTrackFrame)
      obj.plotNewRectangle();
      obj.MoveRectangleToNewPosition()
      % Get RGB
      CellName =  obj.getCurrentCellName;
      [MeanR, MeanG, MeanB] = obj.getMeanRGBForEachPositionOfCell(CellName);
      TrackTable = obj.TracksObj.getTrack(CellName);
      TrackTable.RGBColor = [MeanR, MeanG, MeanB];
      
      % Plot RGB
      LegendString1 = plotRGB(obj,TrackTable);
      
      % Plot CyclePhase
      if obj.VMATobject.getNumberOfChannels > 1
        CyclePhase = obj.getCellCyclePhase(TrackTable, CellName);
        
        LegendString2 =  Fucci.plotCyclePhaseAsPatchObject(CyclePhase,obj.guih.RGB_plot_axis);
        legend(obj.guih.RGB_plot_axis,...
          [LegendString1, LegendString2], 'Location', 'eastoutside')
        
        obj.updStartEndFucci(CyclePhase);
      end
      %
    end
    
    function F = setUpFucciObject(obj,TrackTable)
      F = Fucci(TrackTable);
      F.setPredictingMethod(obj.FucciPhasePredictidMethod);
      F.setParameters(obj.getPredictingMethodParameters);
    end
    
    function CyclePhase = getCellCyclePhase(obj,TrackTable, CellName)
      % Check if the phase already  exist:
      if obj.isCorrectedPhasesSaved
        CellName = strrep( obj.getCurrentCellName, '.', '_');
        SavedPhases = obj.guih.CorrectButton.UserData;
        CyclePhase = SavedPhases.(CellName);
      else
        F = setUpFucciObject(obj,TrackTable);
        CyclePhase = F.detectCellPhase(CellName);  % obj.NormalizeCheckobox.Value
      end
      obj.guih.PhaseDropDown.UserData = CyclePhase;
    end
    
    function parameters = getPredictingMethodParameters(obj)
      switch obj.FucciPhasePredictidMethod
        case 'Geminin-PCNA - PIP'
          parameters.MaximumGreenBlueRatioinG1EditField =obj.guih.MaximumGreenBlueRatioinG1EditField.Value;
          parameters.MinimumGreenBlueRatioinG2EditField = obj.guih.MinimumGreenBlueRatioinG2EditField.Value;
          parameters.MinimumBlueSignalinG2EditField     = obj.guih.MinimumBlueSignalinG2EditField.Value;
        case 'Geminin_Cdt1'
          parameters.Minimum_Green_Signal_in_S_phase = obj.guih.MinimumGreenSignalinSphaseEditField.Value;
          parameters.Minimum_Red_Signal_in_S_phase = obj.guih.MinimumRedSignalinSphaseEditField.Value;
          parameters.Minimal_Signal = obj.guih.MinimumSignalEditField.Value;
      end
    end
    
    function MoveRectangleToNewPosition(obj, varargin)
      FrameNumber   = obj.getCurrentFrameNumber;
      WholeTrack = obj.TracksObj.getTrackPosition(obj.getCurrentCellName);
      obj.MovingRectangles(obj.getCurrentRectangleNumber).setPosition(WholeTrack(FrameNumber,:))
      img = obj.VMATobject.getSingleFrame(FrameNumber);
      set(obj.ImageHandles.FullFrame, 'CData', img)
      updMainImageTitle(obj)
      
      set(obj.MovingRectangles(obj.getCurrentRectangleNumber).RectangleHandle, 'Visible', 'on')
      set(obj.ImageHandles.MovingBar, 'XData', [FrameNumber, FrameNumber])
      if isnan(WholeTrack(FrameNumber,:))
        set(obj.MovingRectangles(obj.getCurrentRectangleNumber).RectangleHandle, 'Visible', 'off')
        return
      end
      CellEnlarged = imcrop(img, obj.MovingRectangles(obj.getCurrentRectangleNumber).getrectanglebox);
      set(obj.ImageHandles.EnlargedCell, 'CData', CellEnlarged)
      
      
      if obj.VMATobject.getNumberOfChannels == 3
        [R,G,B] = getRGB(CellEnlarged);
        set(obj.ImageHandles.ImR, 'CData', R)
        set(obj.ImageHandles.ImG, 'CData', G)
        set(obj.ImageHandles.ImB, 'CData', B)
      end
    end
    
    function ShowTrack(obj)
      % Fill all plots:
      WholeTrack = obj.TracksObj.getTrackPosition(obj.getCurrentCellName);
      obj.MovingRectangles(obj.getCurrentRectangleNumber).setPosition(WholeTrack(obj.getCurrentFrameNumber,:))
      img = obj.VMATobject.getSingleFrame(obj.getCurrentFrameNumber);
      CellEnlarged = imcrop(img, obj.MovingRectangles(obj.getCurrentRectangleNumber).getrectanglebox);
      [R,G,B] = getRGB(CellEnlarged);
      [RedMap,GreenMap,BlueMap] = obj.getRGB_ColorMaps();
      
      axes(obj.guih.WholeImages_axis)
      obj.ImageHandles.FullFrame  = imagesc(obj.guih.WholeImages_axis,img);
      obj.plotNewRectangle()
      updMainImageTitle(obj)
      
      % Merged channels
      [xdata, ydata] = rectangle2xydata(obj.MovingRectangles(obj.getCurrentRectangleNumber).getrectanglebox);
      obj.ImageHandles.EnlargedCell =...
        imagesc(obj.guih.EnlargedCell_axis, CellEnlarged, 'XData', xdata,...
        'YData', ydata);
      xticklabels(obj.guih.EnlargedCell_axis,[]),
      yticklabels(obj.guih.EnlargedCell_axis,[]),
      title(obj.guih.EnlargedCell_axis,'Merged channels')
      
      if obj.VMATobject.getNumberOfChannels == 3
        CLim = [0 255]; % HARD CODE
        obj.ImageHandles.ImR = imagesc(obj.guih.EnlargedCell_Red_axis,...
          R, 'XData', xdata, 'YData', ydata,CLim);
        colormap(obj.guih.EnlargedCell_Red_axis,RedMap),
        xticklabels(obj.guih.EnlargedCell_Red_axis, [])
        yticklabels(obj.guih.EnlargedCell_Red_axis, []);
        obj.ImageHandles.ImR_title =...
          title(obj.guih.EnlargedCell_Red_axis,obj.ChannelTitles.Red);
        
        obj.ImageHandles.ImG = imagesc(obj.guih.EnlargedCell_Green_axis,...
          G, 'XData', xdata, 'YData', ydata,CLim);
        colormap(obj.guih.EnlargedCell_Green_axis, GreenMap),
        xticklabels(obj.guih.EnlargedCell_Green_axis, []);
        yticklabels(obj.guih.EnlargedCell_Green_axis, []);
        obj.ImageHandles.ImG_title = title(obj.guih.EnlargedCell_Green_axis,...
          obj.ChannelTitles.Green);
        
        obj.ImageHandles.ImB = imagesc(obj.guih.EnlargedCell_Blue_axis,...
          B, 'XData', xdata, 'YData', ydata,CLim);
        colormap(obj.guih.EnlargedCell_Blue_axis, BlueMap),
        xticklabels(obj.guih.EnlargedCell_Blue_axis, []),
        yticklabels(obj.guih.EnlargedCell_Blue_axis, [])
        obj.ImageHandles.ImB_title = title(obj.guih.EnlargedCell_Blue_axis,...
          obj.ChannelTitles.Blue);
      end
      
      obj.setAllAxisEqualAndTight()
      % 'Click' on first cell:'
      obj.ImageHandles.MovingBar = obj.plotmovingbar();
      obj.showNewCellTrack();
    end
    
    
    function plotNewRectangle(obj)
      % Hide last one
      LastShownRectangleNumber = obj.guih.CellNameListbox.UserData;
      if ~isempty(LastShownRectangleNumber)
        obj.MovingRectangles(LastShownRectangleNumber).hide;
      end
      % Plot new one
      WholeTrack = obj.TracksObj.getTrackPosition(obj.getCurrentCellName);
      obj.MovingRectangles(obj.getCurrentRectangleNumber).setPosition(WholeTrack(obj.getCurrentFrameNumber,:))
      obj.MovingRectangles(obj.getCurrentRectangleNumber).show(obj.guih.WholeImages_axis);
      obj.guih.CellNameListbox.UserData = obj.getCurrentRectangleNumber;
      
      % Show New Rectangle size in Gui:
      RectSize = obj.MovingRectangles(obj.getCurrentRectangleNumber).getRectangleSizeInPixels();
      set(obj.guih.RectSizeControl, 'Value', RectSize)
    end
    
    function updMainImageTitle(obj)
      title(obj.guih.WholeImages_axis, sprintf('Frame #%i', obj.getCurrentFrameNumber))
    end
    
    function [MeanR, MeanG, MeanB] = getMeanRGBForEachPositionOfCell(obj,CellName)
      % Returns mean value of channel
      TrackPosition   = obj.TracksObj.getTrackPosition(CellName);
      FirstTrackFrame = obj.TracksObj.getFirstTrackFrame(CellName);
      LastTrackFrame  = obj.TracksObj.getLastTrackFrame(CellName);
      LastPosition    = obj.MovingRectangles(obj.getCurrentRectangleNumber).CenterRectanglePosition;
      
      set(obj.MovingRectangles(obj.getCurrentRectangleNumber).RectangleHandle,...
        'Visible', 'off')
      nCHannels = obj.VMATobject.getNumberOfChannels;
      
      MovingRectangle = obj.MovingRectangles(obj.getCurrentRectangleNumber);
      MeanRGB = nan(obj.VMATobject.getNumberOfFrames,nCHannels);
      for i = FirstTrackFrame:1:LastTrackFrame
        MovingRectangle.setPosition(TrackPosition(i,:))
        CroppedImage = imcrop(obj.VMATobject.getSingleFrame(i),...
          MovingRectangle.getrectanglebox);
        MeanRGB(i,:) = squeeze(mean(CroppedImage,[1,2]));
      end
      if nCHannels == 3
        MeanR = MeanRGB(:,1);
        MeanG = MeanRGB(:,2);
        MeanB = MeanRGB(:,3);
      elseif nCHannels == 1
        MeanR = MeanRGB;
        MeanG = MeanRGB;
        MeanB = MeanRGB;
      end
      
      obj.MovingRectangles(obj.getCurrentRectangleNumber).setPosition(LastPosition)
      set(obj.MovingRectangles(obj.getCurrentRectangleNumber).RectangleHandle, 'Visible', 'on')
    end
    
    function  plotsinglechannelintensity(obj)
      MeanIntensity = obj.getMeanRGBForEachPositionOfCell(obj.CellNameListbox.Value);
      if obj.NormalizeCheckobox.Value
        MeanIntensity = normalize_rgb_vectors(MeanIntensity);
      end
      t  = 1:obj.VMATobject.getNumberOfFrames;
      plot(obj.guih.RGB_plot_axis,t, MeanIntensity, 'k');
      xlim(obj.guih.RGB_plot_axis, [0, obj.VMATobject.getNumberOfFrames])
      title(obj.guih.RGB_plot_axis, 'Mean Value of intensity'),
      xlabel(obj.guih.RGB_plot_axis,'Frame number'),
      ylabel(obj.guih.RGB_plot_axis,'Mean intensity')
    end
    
    function LegendString = plotRGB(obj, TrackTable)
      if  obj.VMATobject.getNumberOfChannels == 1
        plotsinglechannelintensity(obj);
        obj.ImageHandles.MovingBar = obj.plotmovingbar;
        LegendString = {'Mean Intensity','CurrentFrame'};
        return
      end
      Red  = TrackTable.RGBColor(:,1);
      Green= TrackTable.RGBColor(:,2);
      Blue = TrackTable.RGBColor(:,3);
      
      if obj.NormalizeCheckobox.Value
        Red = normalize_rgb_vectors(Red);
        Green = normalize_rgb_vectors(Green);
        Blue = normalize_rgb_vectors(Blue);
      end
      
      t  = 1:obj.VMATobject.getNumberOfFrames;
      plot(obj.guih.RGB_plot_axis, t, Red, 'R', t, Green, 'G', t, Blue, 'B')
      obj.ImageHandles.MovingBar = obj.plotmovingbar;
      %       LegendString = {'Red', 'Green', 'Blue','CurrentFrame'};
      LegendString = {obj.ChannelTitles.Red, ...
        obj.ChannelTitles.Green,...
        obj.ChannelTitles.Blue, 'CurrentFrame'};
      
      xlim(obj.guih.RGB_plot_axis, [0, obj.VMATobject.getNumberOfFrames])
      title(obj.guih.RGB_plot_axis, 'Mean Value of each channel')
      xlabel(obj.guih.RGB_plot_axis, 'Frame number')
      ylabel(obj.guih.RGB_plot_axis, 'Mean intensity')
    end
    
    
    function MovingBar = plotmovingbar(obj)
      hold(obj.guih.RGB_plot_axis,'on')
      MovingBar = plot(obj.guih.RGB_plot_axis,...
        [obj.getCurrentFrameNumber obj.getCurrentFrameNumber],...
        obj.guih.RGB_plot_axis.YLim, 'Color', [.8 .8 .8], 'LineWidth', 2);
      hold(obj.guih.RGB_plot_axis,'off')
    end
    
    function removeCellFromList(obj, varargin)
      % Question: are you sure you would like to remove cell?
      question = sprintf('Are you sure you would like to remove cell [%s]?',...
        obj.guih.CellNameListbox.Value);
      dlgtitle = 'Remove Cell from List';
      answer = questdlg(question, dlgtitle, 'Yes','No','Cancel','Cancel');
      
      if strcmp(answer,'No'), return, end
      if strcmp(answer, 'Cancel'), return, end
      
      % Find cell and all children
      nItems =  numel(obj.guih.CellNameListbox.Items);
      if nItems == 1 % If tehre is one item, do not remove it
        return
      end
      toRemove = find(strcmp(obj.guih.CellNameListbox.Items, obj.guih.CellNameListbox.Value));
      
      NextVal = min(toRemove+1,nItems);
      if NextVal == nItems,  NextVal = max(1, toRemove-1); end
      
      obj.guih.CellNameListbox.Value = obj.guih.CellNameListbox.Items(NextVal);
      obj.guih.CellNameListbox.Items(toRemove) = [];
      % Listbox callback:
      obj.showNewCellTrack();
    end
    %
    function handle = CreateNormalizeCheckbox(obj)
      handle = obj.guih.NormalizeRGBCheckBox;
      set(handle, 'ValueChangedFcn', @obj.showNewCellTrack);
    end
    
    function OptionMenu = SetupExportOptionsPopupmenu(obj)
      Items =  {'Export Options..',...
        'Export All Cells to .xlsx',...
        'Export All Cells to .mat',...
        'Export Divided Cells to .xlsx',...
        'Export Divided Cells to .mat',...
        'Export Divided Daughter Cells to .xlsx',...
        'Export Divided Daughter Cells to .mat',...
        'Export All Cells to .csv',...
        'Export Divided Cells to .csv',...
        'Export Divided Daughter Cells to .csv'
        };
      
      OptionMenu  = obj.guih.ExportOptionsPopupmenu;
      set(OptionMenu, 'Items', Items)
      set(OptionMenu, 'ValueChangedFcn', @obj.OptionsPopupmenucallback)
    end
    
    function RectSize = SetupRectSizeControl(obj)
      RectSize = obj.guih.RectSizeControl;
      set(RectSize, 'Value',obj.getCurrentRectangleSize);
      set(RectSize, 'Limits',    [10 Inf])
      set(RectSize, 'Step', 2)
      set(RectSize, 'ValueChangedFcn', @obj.updRectSize)
    end
    
    function updRectSize(obj, ~,event)
      LastPos = obj.MovingRectangles(obj.getCurrentRectangleNumber).CenterRectanglePosition;
      % Note: in moving rectangle only distance from centre is set. From
      % this value the size (2*distance + 1) is returned:
      obj.MovingRectangles(obj.getCurrentRectangleNumber).DistanceFromCentrePxl =...
        floor(event.Value/2);
      obj.MovingRectangles(obj.getCurrentRectangleNumber).setPosition(LastPos)
      obj.MoveRectangleToNewPosition()
      obj.showNewCellTrack()
    end
    
    function slider = SetupSliderAcrossFrames(obj)
      slider =  obj.guih.SliderAcrossFrames;
      set(slider, 'Limits',[1 obj.VMATobject.getNumberOfFrames])
      set(slider,  'Value', 1)
      set(slider,  'ValueChangingFcn', @obj.MoveRectangleToNewPosition)
      set(slider,  'ValueChangedFcn',  @obj.MoveRectangleToNewPosition)
    end
    
    function keypushcallback(obj, ~, event)
      Limits = obj.SliderAcrossFrames.Limits;
      switch event.Key
        case 'rightarrow'
          NewValue = min(obj.SliderAcrossFrames.Value +1, Limits(2));
        case 'leftarrow'
          NewValue= max(obj.SliderAcrossFrames.Value -1,  Limits(1));
        case 'uparrow'
          NewValue = min(obj.SliderAcrossFrames.Value +10, Limits(2));
        case 'downarrow'
          NewValue = max(obj.SliderAcrossFrames.Value -10,  Limits(1));
        otherwise
          return
      end
      obj.SliderAcrossFrames.Value = NewValue;
      obj.MoveRectangleToNewPosition();
    end
    
    function listbox = SetupListboxWithCellNames(obj)
      listbox = obj.guih.CellNameListbox;
      set(listbox , 'Items', obj.TracksObj.getAllTracksNames)
      set(listbox , 'Value', obj.TracksObj.getAllTracksNames{1})
      set(listbox , 'ValueChangedFcn', @obj.showNewCellTrack);
    end


    % Export ALL:
    function exportColorsAsmat(obj)
      [matFileName, path] = uiputfile('*.mat');
      if matFileName
        TracksTable = obj.TracksObj.TracksTable;
        ExportTable = obj.ExportTableWithColorForEachCellPosition(TracksTable);
        save([path, matFileName],'ExportTable')
      end
    end
    
    function exportColorsAsxls(obj)
      [excelFileName, path] = uiputfile('*.xlsx');
      if excelFileName
        TracksTable = obj.TracksObj.TracksTable;
        ExportTable = obj.ExportTableWithColorForEachCellPosition(TracksTable);
        ExportTable = obj.adjustExportTable4Excell(ExportTable);
        writetable(ExportTable, [path, excelFileName])
      end
    end
    
    function exportColorsAsCSV(obj)
      [csvFileName, path] = uiputfile('*.csv');
      if csvFileName
        TracksTable = obj.TracksObj.TracksTable;
        ExportTable = obj.ExportTableWithColorForEachCellPosition(TracksTable);
        ExportTable = obj.adjustExportTable4Excell(ExportTable);
        writetable(ExportTable, [path, csvFileName])
      end
    end
    

    % Export divided:
    function exportDividedCellsColorsAsmat(obj)
      [matFileName, path] = uiputfile('*.mat');
      if matFileName
        TracksTable = obj.getTableWithDividedCells();
        ExportTable = obj.ExportTableWithColorForEachCellPosition(TracksTable);
        save([path, matFileName],'ExportTable')
      end
    end
    
    function exportDividedCellsColorsAsxls(obj)
      [excelFileName, path] = uiputfile('*.xlsx');
      if excelFileName
        TracksTable = obj.getTableWithDividedCells();
        ExportTable = obj.ExportTableWithColorForEachCellPosition(TracksTable);
        ExportTable = obj.adjustExportTable4Excell(ExportTable);
        writetable(ExportTable, [path, excelFileName])
      end
    end
    
    function exportDividedCellsColorsAsCSV(obj)
      [csvFileName, path] = uiputfile('*.csv');
      if csvFileName
        TracksTable = obj.getTableWithDividedCells();
        ExportTable = obj.ExportTableWithColorForEachCellPosition(TracksTable);
        ExportTable = obj.adjustExportTable4Excell(ExportTable);
        writetable(ExportTable, [path, csvFileName])
      end
    end
    
    
    % Export Divided Doughter Cells:
    function exportDividedDaughterCellsColorsAsmat(obj)
      [matFileName, path] = uiputfile('*.mat');
      if matFileName
        TracksTable = obj.getTableWithDividedDaughterCells();
        ExportTable = obj.ExportTableWithColorForEachCellPosition(TracksTable);
        save([path, matFileName],'ExportTable')
      end
    end
    
    function exportDividedDaughterCellsColorsAsxls(obj)
      [excelFileName, path] = uiputfile('*.xlsx');
      if excelFileName
        TracksTable = obj.getTableWithDividedDaughterCells();
        ExportTable = obj.ExportTableWithColorForEachCellPosition(TracksTable);
        ExportTable = obj.adjustExportTable4Excell(ExportTable);
        writetable(ExportTable, [path, excelFileName])
      end
    end
    
    function exportDividedDaughterCellsColorsAsCSV(obj)
      [csvFileName, path] = uiputfile('*.csv');
      if csvFileName
        TracksTable = obj.getTableWithDividedDaughterCells();
        ExportTable = obj.ExportTableWithColorForEachCellPosition(TracksTable);
        ExportTable = obj.adjustExportTable4Excell(ExportTable);
        writetable(ExportTable, [path, csvFileName])
      end
    end
    
    function DividedDaughterCellsTable = getTableWithDividedDaughterCells(obj)
      DividedDaughterCellsTable = obj.TracksObj.TracksTable;
      DividedDaughterCells =...
        CellsList(obj.TracksObj.getAllTracksNames).getCellDividedDaughterNames();
      RowsWithNonDividedCells = ismember(DividedDaughterCellsTable.CellName, DividedDaughterCells);
      DividedDaughterCellsTable(~RowsWithNonDividedCells, :) = [];
    end
    
    function TracksTableDividedCells = getTableWithDividedCells(obj)
      TracksTableDividedCells = obj.TracksObj.TracksTable;
      NonDivdedCellNames = CellsList(obj.TracksObj.getAllTracksNames).getNoDividedCellsNames();
      RowsWithNonDividedCells = ismember(TracksTableDividedCells.CellName, NonDivdedCellNames);
      TracksTableDividedCells(RowsWithNonDividedCells, :) = [];
    end
    
    function OptionsPopupmenucallback(obj,src,event)
      switch event.Value
        case 'Export All Cells to .xlsx',obj.exportColorsAsxls();
        case 'Export All Cells to .mat', obj.exportColorsAsmat();
        case 'Export Divided Cells to .xlsx',obj.exportDividedCellsColorsAsxls();
        case 'Export Divided Cells to .mat', obj.exportDividedCellsColorsAsmat();
        case 'Export Divided Daughter Cells to .xlsx'
          obj.exportDividedDaughterCellsColorsAsxls();
        case 'Export Divided Daughter Cells to .mat'
          obj.exportDividedDaughterCellsColorsAsmat();
        case 'Export All Cells to .csv',obj.exportColorsAsCSV();
        case 'Export Divided Cells to .csv',obj.exportDividedCellsColorsAsCSV();
        case 'Export Divided Daughter Cells to .csv',  obj.exportDividedDaughterCellsColorsAsCSV();
        otherwise
          % do nothing
      end
      src.Value = src.Items{1};
    end
    
    function RectangleSize = getCurrentRectangleSize(obj)
      RectangleSize =...
        obj.MovingRectangles(obj.getCurrentRectangleNumber).getRectangleSizeInPixels;
    end
    
    function RectangleNumber = getCurrentRectangleNumber(obj)
      RectangleNumber = 1;
      if ~isempty(obj.CellNameListbox)
        RectangleNumber = find(strcmp({obj.MovingRectangles.Name},...
          obj.CellNameListbox.Value));
      end
    end
    
    function CurrentFrameNumber = getCurrentFrameNumber(obj)
      CurrentFrameNumber = round(obj.SliderAcrossFrames.Value());
    end
    
    function CellName = getCurrentCellName(obj)
      CellName = obj.CellNameListbox.Value;
    end
    
    function setAllAxisEqualAndTight(obj)
      set(obj.guih.WholeImages_axis, 'XLimSpec', 'tight')
      set(obj.guih.WholeImages_axis, 'YLimSpec', 'tight')
      set(obj.guih.WholeImages_axis, 'DataAspectRatio', [1 1 1]) % axis equal
      
      set(obj.guih.EnlargedCell_axis, 'XLimSpec', 'tight')
      set(obj.guih.EnlargedCell_axis, 'YLimSpec', 'tight')
      set(obj.guih.EnlargedCell_axis, 'DataAspectRatio', [1 1 1])
      
      set(obj.guih.EnlargedCell_Red_axis, 'XLimSpec', 'tight')
      set(obj.guih.EnlargedCell_Red_axis, 'YLimSpec', 'tight')
      set(obj.guih.EnlargedCell_Red_axis, 'DataAspectRatio', [1 1 1])
      
      set(obj.guih.EnlargedCell_Green_axis, 'XLimSpec', 'tight')
      set(obj.guih.EnlargedCell_Green_axis, 'YLimSpec', 'tight')
      set(obj.guih.EnlargedCell_Green_axis, 'DataAspectRatio', [1 1 1])
      
      set(obj.guih.EnlargedCell_Blue_axis, 'XLimSpec', 'tight')
      set(obj.guih.EnlargedCell_Blue_axis, 'YLimSpec', 'tight')
      set(obj.guih.EnlargedCell_Blue_axis, 'DataAspectRatio', [1 1 1])
    end
    
    function  DefaultChannelTitles = CreateDefaultChannelTitles(obj)
      DefaultChannelTitles.Red   = 'Red';
      DefaultChannelTitles.Green = 'Green';
      DefaultChannelTitles.Blue  = 'Blue';
    end
  end
  
  methods(Static)
    function ExportTableExcell = adjustExportTable4Excell(ExportTable)
      % Split cell_xy_pos into 2 colomns(x,y) and RGB color into 3 columns
      ExportTableExcell = ExportTable(:,{'CellID', 'CellName', 'ImageID'});
      ExportTableExcell.Xpos = ExportTable.Cell_xy_pos(:,1);
      ExportTableExcell.Ypos = ExportTable.Cell_xy_pos(:,2);
      ExportTableExcell.Red  = ExportTable.RGBColor(:,1);
      ExportTableExcell.Green = ExportTable.RGBColor(:,2);
      ExportTableExcell.Blue = ExportTable.RGBColor(:,3);
      ExportTableExcell.CyclePhase = ExportTable.CyclePhase;
    end
    
    function [RedMap,GreenMap,BlueMap] = getRGB_ColorMaps()
      ColorMap = zeros(256,3);
      RedMap   = ColorMap;    RedMap(:,1) = (1:256)/256;
      GreenMap = ColorMap;  GreenMap(:,2) = (1:256)/256;
      BlueMap  = ColorMap;   BlueMap(:,3) = (1:256)/256;
    end
  end
end

