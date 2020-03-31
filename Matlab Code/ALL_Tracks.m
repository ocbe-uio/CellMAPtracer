classdef ALL_Tracks < handle
  %% ALL_Tracks keeps information about already calculated tracks.
  %
  % ALL_Tracks Properties:
  %    NumTracks - number of tracks
  %    Tracks - table with 4 rows: [CellID     CellName      ImageID    Cell_xy_pos]
  %    Metadata - TiffMetadata object
  %    ExperimentName - string with experiment name
  % ALL_Tracks Methods:
  %    ALL_Tracks - ALL_Tracks(gui_h) or ALL_Tracks(gui_h,TiffFullPath,TiffFileName,AllImages)
  %    incrementLastTrackNumber - increments last track number
  %    getLastTrackNumber - return last track number
  %    getTiffFileName - returns till file name
  %    getFullTiffPath - returns full tiff file path
  %    getListOfCells - return list of cells (string)
  %    isThereAnyCellTracked - if true there are some cells tracked
  %    loadCalculatedTracks2Object -  When user load calculated tracks , init object:
  %    getCellRows - returns rows of Tracks for given cell name
  %    getInitialPositionOfCalcCells - returns initial position of cells
  %    resetIDorder - resets ID order
  %    addNewTrackedCell - adds new calculated cells
  %    deleteTrack - deletes calculated track
  %    SaveAsMat - save to .mat file
  
  properties
    NumTracks  % Number of calculated tracks
    Tracks     % Tracks - tablewith 4 rows: [CellID     CellName      ImageID    Cell_xy_pos]
    Metadata   % TiffMetada object
    ExperimentName % Experiment Name
  end
  properties(Access = private)
    % Last number of calculated track. Can be change only by object
    LastTrackNumber
  end
  
  properties (Constant)
    CellTrackNameConstant = 'C' % This name is on the beggining of each cell track name
  end
  
  methods
    % Create Empty object (used when there is no tiff file)
    function obj = ALL_Tracks(ExpName,TiffFullPath,TiffFileName,AllImages)
      % Constructors:
      % ALL_Tracks(gui_h)
      % ALL_Tracks(gui_h,TiffFullPath,TiffFileName,AllImages)
      if nargin == 1
        obj.Metadata = [];
      else
        % Constructor when user load new tiff file
        obj.Metadata = TiffMetadata(TiffFullPath,TiffFileName,AllImages);
      end
      obj.NumTracks = 0;
      obj.Tracks = [];
      obj.LastTrackNumber = 0;
      obj.ExperimentName = ExpName;
    end
    
    %% LastTrackNumber methods:
    % incrementLastTrackNumber
    function incrementLastTrackNumber(obj)
      obj.LastTrackNumber = obj.LastTrackNumber+1;
    end
    
    % getLastTrackNumber
    function LastTrackNumber = getLastTrackNumber(obj)
      LastTrackNumber = obj.LastTrackNumber;
    end
    
    %% Tiff file methods
    function TiffFileName = getTiffFileName(obj)
      % Return tiff file name:
      TiffFileName = obj.Metadata.TiffFileName;
    end
    
    function FullTiffPath = getFullTiffPath(obj)
      % Return tiff file path:
      FullTiffPath = obj.Metadata.getFullTiffPath;
    end
    
    %% List of cells (tracks) methods:
    function ListOfCells = getListOfCells(obj)
      % Returns list of cells
      ListOfCells = [];
      if obj.isThereAnyCellTracked()
        ListOfCells = obj.Tracks.CellName(obj.Tracks.ImageID == 1);
      end
    end
    
    function out = isThereAnyCellTracked(obj)
      % false if there is no calculated tracks
      % if there is no calculated tracks -
      out = false;
      if obj.NumTracks > 0, out = true; end
    end
    
    function [obj, Parameters] = loadCalculatedTracks2Object(obj, inStruct)
      % When user load calculated tracks , init object:
      obj.NumTracks = inStruct.NumTracks;
      obj.Tracks    = inStruct.Tracks;
      obj.LastTrackNumber = inStruct.LastTrackNumber;
      obj.Metadata = TiffMetadata(inStruct.Metadata);
      obj.ExperimentName  = inStruct.ExperimentName;
      Parameters = ExperimentParameters(inStruct.Parameters);
    end
    
    function CellRows = getCellRows(obj, CellName)
      % Returns CellID (number) base on CellName
      if size(CellName,1) > 1 % Many cells (example Cell 2, Cell 2.1, Cell 2.2)
        CellRows = [];
        for i = 1:size(CellName,1)
          CellRows = [CellRows; find(strcmp(obj.Tracks.CellName, CellName{i}))]; %#ok<*AGROW>
        end
      else % Only one cell name (example Cell 2)
        CellRows = find(strcmp(obj.Tracks.CellName, CellName));
      end
    end
    
    function InitialPosOfCalcCells = getInitialPositionOfCalcCells(obj)
      % Return initial position of cells:
      if obj.NumTracks == 0, InitialPosOfCalcCells = [];  return, end
      InitialPosOfCalcCells = obj.Tracks{obj.Tracks.ImageID==1, 'Cell_xy_pos'};
    end
    
    function resetIDorder(obj)
      % Reset ID order - after deleting, user can update counting cells:
      if ~obj.isThereAnyCellTracked,  return, end % Do nothing if there is no tracked cells
      % Get ID for each position of calculated cells: 
      [~, ~, ic] = unique(obj.Tracks.CellID);
      
      obj.Tracks.CellID = ic;
      if numel(ic) > 100
        showwaitbar = true; 
        h = waitbar(0, 'Reseting Cells Track Order');
      end
       
      for i = 1:height(obj.Tracks)
        if showwaitbar
          waitbar(i/height(obj.Tracks), h)
        end
        % Exampel: old name Cell 3, new name Cell 2
        % Cell 3.1, new name Cell 1.1
        DotInName= strfind(obj.Tracks.CellName{i}, '.');
        if isempty(DotInName) % no dot in name
          obj.Tracks.CellName{i} = sprintf('%s%i', obj.CellTrackNameConstant,ic(i));
          % Cell 11:99
        else
          obj.Tracks.CellName{i} = sprintf('%s%i%s', obj.CellTrackNameConstant,ic(i),...
            obj.Tracks.CellName{i}(DotInName(1):end));
        end
      end
      delete(h)
      obj.updNumOfTracks()
    end
    
    %% Add new calculated cell track:
    function obj = addNewTrackedCell(obj, NewCellTrack)
      % Function add new calculated tracks to ALL_track object:
      % #1 Find New Track ID:
      NewTrackID = obj.LastTrackNumber;
      Cell1ID = table(repmat(NewTrackID, height(NewCellTrack),1),...
        'VariableNames', {'CellID'});
      
      % #2 Get ImageID:
      ImageID = NewCellTrack(:,1);
      NewCellTrack(:,1) = []; % Leave only cell positions in the table
      
      % Find unique cell names
      uniqueCellNames = unique(NewCellTrack.Properties.VariableNames);
      CellNameInAllTracks = uniqueCellNames;
      
      for i = 1:numel(CellNameInAllTracks)
        CellNameInAllTracks{i} = strrep(CellNameInAllTracks{i}, '_', '.');
      end
      
      %
      cellTracksConverted = [];
      for i = 1:numel(uniqueCellNames)
        Cell1Name = table(repmat({CellNameInAllTracks{i}},...
          height(NewCellTrack),1),'VariableNames', {'CellName'});
        cc = [Cell1ID Cell1Name ImageID...
          table(NewCellTrack.(uniqueCellNames{i}), 'VariableNames', {'Cell_xy_pos'})];
        cellTracksConverted = [cellTracksConverted;cc] ;
      end
      
      % Add to AllTracks:
      obj.Tracks = [obj.Tracks;cellTracksConverted];
      obj = updNumOfTracks(obj);
    end
    
    %% Delete track
    function NewListOfCells = deleteTrack(obj, CellTrackName)
      % Delete track from Tracks table
      CellRows = getCellRows(obj, CellTrackName);
      obj.Tracks(CellRows,:) = [];
      obj.updNumOfTracks();
      if nargout
        NewListOfCells = obj.getListOfCells;
      end
    end
    
    %% Saving and exporting:
    function h = SaveAsMat(obj,Parameters, FullSavingPath)
      % Export
      if nargin < 3
        [matFileName, path] = uiputfile([obj.ExperimentName ' '...
          obj.Metadata.TiffFileName '_Tracks.mat']);
        FullSavingPath = [path matFileName];
      end
      
      if ischar(FullSavingPath)
        AllTracks.NumTracks       = obj.NumTracks;
        AllTracks.Tracks          = obj.Tracks;
        AllTracks.LastTrackNumber = obj.LastTrackNumber;
        AllTracks.Metadata        = obj.Metadata.ExportAsStruct;
        AllTracks.ExperimentName  = obj.ExperimentName;
        AllTracks.Parameters      = Parameters; %#ok<STRNU>
        save(FullSavingPath, 'AllTracks')
        h = msgbox(sprintf('Saved as %s', FullSavingPath), 'Success');
      end  
    end
    
    function outTable = prapareForExportToExcell(obj, CellNames2Export)
      % This function reorganize Tracks in the way that there is the same
      % number of rows (equal to number of frames) and each column is XY pos
      % of cell
      if nargin < 2
        Tracks2Export = obj.Tracks;
      else
        qq = obj.getCellRows(CellNames2Export);
        Tracks2Export = obj.Tracks(qq,:);
      end
      X = Tracks2Export.Cell_xy_pos(:,1);
      Y = Tracks2Export.Cell_xy_pos(:,2);
      assert(size(X,2) == 1, 'There are two columns in X instead of 1');
      
      CellName = Tracks2Export.CellName;
      ImageNum = Tracks2Export.ImageID;
      TiffFileName = repmat(obj.Metadata.TiffFileName, numel(X),1);
      outTable = table(TiffFileName,CellName,ImageNum,X,Y);
    end
  
  end % end methods
  
  methods (Access = private)
    function obj = updNumOfTracks(obj)
      % Updade number of tracked tracks
      % After adding or deleting cell tracks
      obj.NumTracks = numel(unique(obj.Tracks.CellID));
      obj.LastTrackNumber = max(obj.Tracks.CellID);
      if isempty(obj.LastTrackNumber), obj.LastTrackNumber = 0; end
    end
  end % end of private methods
end

