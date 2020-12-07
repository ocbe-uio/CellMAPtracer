classdef Tracks
  %%  Tracks(TracksTable) Object keeps tracks information.
% 
%     CellID    CellName    ImageID    Cell_xy_pos
%     ______    ________    _______    ___________
% 
%       1       {'C1'  }        1      708    103 
%       1       {'C1'  }        2      702    107 
%       1       {'C1'  }        3      698    110 
%       1       {'C1'  }        4      696    104 
%       1       {'C1'  }        5      687    100 
%       1       {'C1'  }        6      676    100 
%       1       {'C1'  }        7      675     96 
%       1       {'C1'  }        8      675     99 
  properties
    TracksTable 
  end
  
  methods
    function obj = Tracks(TracksTable)
      % Tracks - table keeps position of each cell for each frame. 
      assert(isa(TracksTable, 'table'), 'TracksTable must be a table')
      assert(ismember('Cell_xy_pos', TracksTable.Properties.VariableNames))
      obj.TracksTable   = TracksTable;
    end
        
    function TrackTable = getTrack(obj, TrackID)
      if isnumeric(TrackID) % '1'
        cFind = find(obj.TracksTable.CellID == TrackID);
      elseif ischar(TrackID) % 'Cell_2'
        c = strcmp(obj.TracksTable.CellName,TrackID);
        cFind = find(c);
      elseif iscell(TrackID) % {'Cell_2', 'Cell_3'}
        TrackID = TrackID{1};
        c = strcmp(obj.TracksTable.CellName,TrackID);
        cFind = find(c);
      end
      TrackTable = obj.TracksTable(cFind,:);
    end
    
    function TrackRows = getCellRows(obj, TrackName)
      TrackRows = find(strcmp(obj.TracksTable.CellName,TrackName));
    end
    
    function TrackPosition = getTrackPosition(obj,TrackID)
      TrackTable    = getTrack(obj, TrackID);
      TrackPosition = TrackTable{:, 'Cell_xy_pos'};
    end
    
    function visualisetrack(obj,TrackID)
      TrackTable = obj.getTrack(TrackID);
      plot(TrackTable.Cell_xy_pos(:,1),...
           TrackTable.Cell_xy_pos(:,2), '--.')
    end
    
    function trackNames = getAllTracksNames(obj)
        trackNames = obj.TracksTable.CellName(obj.TracksTable.ImageID == 1);
    end
    
    function FirstTrackFrame = getFirstTrackFrame(obj, TrackName)
      TrackTable = getTrack(obj, TrackName);
      FirstTrackFrame = find(~isnan(TrackTable.Cell_xy_pos(:,1)),1,'First');
    end
    
    function LastTrackFrame = getLastTrackFrame(obj,TrackName)
       TrackTable = getTrack(obj, TrackName);
       LastTrackFrame = find(~isnan(TrackTable.Cell_xy_pos(:,1)),1,'Last');
    end
    
  end
end

