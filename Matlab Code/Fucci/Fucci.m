classdef Fucci < handle
  %% Class used to estimate phase (G1, S, G2) base on color input
  
  properties
    DataTable
    PlotCalculations = false;
    PredictingMethod = 'Geminin-PCNA - PIP';
    Parameters = [];
  end
  properties (Access = private)
      
  end
  
  methods
      function obj = Fucci(TableWithColors)
          % TableIn : table contains position and color for each position of Cell
          %          CellID    CellName    ImageID    Cell_xy_pos             RGBColor
          %     ______    ________    _______    ___________    __________________________
          %
          %       1        {'C1'}        1       550    128     196.97    199.75    198.11
          %       1        {'C1'}        2       547    129     194.11    197.99    195.36
          %       1        {'C1'}        3       548    130     198.91    203.04    200.53
          %       1        {'C1'}        4       547    130     194.97     201.4    196.75
          %       1        {'C1'}        5       546    131     200.36    205.89    201.82
          %       1        {'C1'}        6       546    129     204.08     208.5    205.65
          %       1        {'C1'}        7       546    128      208.7    213.12    210.17
          %       1        {'C1'}        8       546    129     204.72    208.61    206.45
          %       1        {'C1'}        9       547    130     201.51    201.75    203.01
          obj.DataTable = TableWithColors;
      end
      function setParameters(obj, Parameters)
        obj.Parameters = Parameters;
      end
      
      function CyclePhaseAllCells = AnalyseAllCells(obj)
          obj.PlotCalculations = false;
          AllCells = obj.getAllTracksNames();
          CyclePhaseNum = cellfun(@obj.detectCellPhase, AllCells, 'UniformOutput', false);
          CyclePhaseString = cellfun(@obj.cyclePhaseString, CyclePhaseNum,'UniformOutput', false);
          CyclePhaseString = [CyclePhaseString{:}];
          CyclePhaseAllCells = CyclePhaseString(:);
          assert(isequal(height(obj.DataTable), numel(CyclePhaseAllCells)))
      end
    
    function cyclePhase = detectCellPhase(obj, varargin)
      switch nargin
        case 2
          % Direct call
          CellName = varargin{1};
        case 3
          src   = varargin{1};
          CellName = src.String{src.Value};
      end
      rgb = obj.getsinglecellcolors(CellName);
      rgb_normalized = normalize_rgb_vectors(rgb);
      cyclePhase = obj.getphasefromrgb(rgb_normalized, CellName);

      if obj.PlotCalculations
        t = 1:numel(obj.getsinglecellrows(CellName));
        plot( t, rgb_normalized(:,1), 'R',...
              t, rgb_normalized(:,2), 'G',...
              t, rgb_normalized(:,3), 'B'),
        hold on
        LegendString = obj.plotCyclePhaseAsPatchObject(cyclePhase);
        legend(['Red', 'Green', 'Blue', LegendString])
        xlim([t(1) t(end)]), ylim([0 1])
        title('Normalized Colors values')
        hold off
      end
    end
    function obj = setPredictingMethod(obj, PredictingMethodName)
        obj.PredictingMethod = PredictingMethodName;
    end
    
    function  cyclePhase = getphasefromrgb(obj, NormalizedRGB, CellName)
      %% getphasefromrgb
      FirstTrackFrame = obj.getFirstTrackFrame(CellName);
      LastTrackFrame  = obj.getLastTrackFrame(CellName);
      parameters = obj.Parameters;
      switch obj.PredictingMethod
          case 'Geminin-PCNA - PIP'
              cyclePhase = GemininPCNA_PIP(NormalizedRGB,...
                  FirstTrackFrame, LastTrackFrame,parameters);
          case 'Geminin_Cdt1'
              cyclePhase = Geminin_Cdt1(NormalizedRGB,...
                  FirstTrackFrame, LastTrackFrame,parameters);
        otherwise
          error('Incorrect Predicting Method')
      end
      
    end

    function FirstTrackFrame = getFirstTrackFrame(obj, CellName)
      FirstTrackFrame = Tracks(obj.DataTable).getFirstTrackFrame(CellName);
    end
    
    function LastTrackFrame = getLastTrackFrame(obj,CellName)
      LastTrackFrame = Tracks(obj.DataTable).getLastTrackFrame(CellName);
    end
    
    function rgbSingleCell = getsinglecellcolors(obj,CellName)
      sc = obj.getsinglecell(CellName);
      rgbSingleCell = sc.RGBColor;
    end
    
    function CellRowsInDataTable = getsinglecellrows(obj, CellName)
      CellRowsInDataTable = find(strcmp(obj.DataTable.CellName, CellName));
    end
    
    function SingleCellTable = getsinglecell(obj,CellName)
      SingleCellTable = obj.DataTable(obj.getsinglecellrows(CellName),:);
    end
    
    function AllTracksNames = getAllTracksNames(obj)
      AllTracksNames = obj.DataTable.CellName(obj.DataTable.ImageID == 1);
    end
  end
  
    methods(Static)
      function cyclePhaseString = cyclePhaseString(cyclePhase)
        cyclePhaseString = cell(numel(cyclePhase),1);
        cyclePhaseString(find(cyclePhase==1)) = {'G1'}; %#ok<*FNDSB>
        cyclePhaseString(find(cyclePhase==2)) = {'S'};
        cyclePhaseString(find(cyclePhase==3)) = {'G2'};
      end
      
      function LegendString = plotCyclePhaseAsPatchObject(cyclePhase, WhereToPlot)
        if nargin < 2, WhereToPlot = gca; end
        LegendString = {};
        f = [1 2 3 4];
        YL = WhereToPlot.YLim;
        % Plot G1
        G1 = find(cyclePhase==1);
        if ~isempty(G1)
          v = [G1(1) YL(1); G1(end)+1 YL(1); G1(end)+1  YL(2); G1(1) YL(2)];
          patch(WhereToPlot, 'Faces',f,'Vertices',v,...
            'FaceColor','red', 'FaceAlpha', .1)
          LegendString = [LegendString 'G1'];
        end
        
        % Plot S
        S = find(cyclePhase==2);
        if ~isempty(S)
          v = [S(1) YL(1); S(end)+1 YL(1); S(end)+1  YL(2); S(1) YL(2)];
          patch(WhereToPlot, 'Faces',f,'Vertices',v,...
            'FaceColor','green', 'FaceAlpha', .1)
          LegendString = [LegendString 'S'];
        end
        
        % Plot G2
        G2 = find(cyclePhase==3);
        
        if ~isempty(G2)
          v = [G2(1) YL(1); G2(end) YL(1); G2(end)  YL(2); G2(1) YL(2)];
          patch(WhereToPlot, 'Faces',f,'Vertices',v,...
            'FaceColor','blue', 'FaceAlpha', .1);
          LegendString = [LegendString 'G2'];
        end
      end
    
    function rgb_filtered = filtercolorvector(rgb), rgb_filtered = movmean(rgb,15); end
  end
end

