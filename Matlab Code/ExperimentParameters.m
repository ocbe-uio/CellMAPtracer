classdef ExperimentParameters < handle
%   % ExperimentParameters - keeps parameters of experiment
%   
%   ExperimentParameters Properties:
%     TimeInterval - time interval (single number)
%     TimeInterval_Unit  - unit of time interval: {ms, sec, [min], hours}
%     PixelSize - pixel size (single number)
%     PixelSize_Unit -  Pixel size unit {nanometers, micrometers, milimeters}
%
%   ExperimentParameters Methods:
%     ExperimentParameters - constructor
%     ExportAsStruct - returns struct with experiment parameters
%     updParametesFields - update parameters fields in main GUI
%     (CellTracer_Main)
  properties
    TimeInterval 
    TimeInterval_Unit 
    PixelSize
    PixelSize_Unit
  end
  
  methods
    
    function par = ExperimentParameters(inStruct)
      % ExperimentParameters(), ExperimentParameters(inStruct)
      
      if nargin < 1 % Default Parameters
        par.TimeInterval = 30;  % default time interval between images
        par.TimeInterval_Unit = 'min'; % {ms, sec, min, hours}
        par.PixelSize = 1;  % pixel size
        par.PixelSize_Unit = 'nanometers';   % Pixel size units {nanometers, micrometers, milimeters}
      else
        par.TimeInterval      = inStruct.TimeInterval; 
        par.TimeInterval_Unit = inStruct.TimeInterval_Unit;
        par.PixelSize         = inStruct.PixelSize;
        par.PixelSize_Unit    = inStruct.PixelSize_Unit;
      end
    end
    
    function outStruct = ExportAsStruct(obj)
      % Export parameters as struct
      outStruct.TimeInterval      = obj.TimeInterval;
      outStruct.TimeInterval_Unit = obj.TimeInterval_Unit;
      outStruct.PixelSize         = obj.PixelSize;
      outStruct.PixelSize_Unit    = obj.PixelSize_Unit;
    end
    
    function updParametesFields(obj, gui_h)
      % Updated fields on main gui
      set(gui_h.dt_edit, 'String', obj.TimeInterval)
      dT_Units = gui_h.dt_unit_popupmenu.String;
      set(gui_h.dt_unit_popupmenu, 'Value',...
        find(strcmp(dT_Units, obj.TimeInterval_Unit)))
      
      set(gui_h.pixel_size_edit, 'String', obj.PixelSize)
      pixelSizeUnits = gui_h.pixel_size_unit_popupmenu.String;
      
      % Patch to adjust pixel values: (in old structs there was um and mm)
      switch obj.PixelSize_Unit
        case 'um', obj.PixelSize_Unit = 'micrometers';
        case 'mm', obj.PixelSize_Unit = 'milimeters';
        case {'nanometers', 'micrometers', 'milimeters'}
            % do  nothing. It is ok
        otherwise
        % set default PixelSize unit
        obj.PixelSize_Unit = 'nanometers';
      end
      
      set(gui_h.pixel_size_unit_popupmenu,...
        'Value',find(strcmp(pixelSizeUnits, obj.PixelSize_Unit)))
    end
      
  end
end

