classdef TiffMetadata < handle
%   % TiffMetadata - keeps metadata of tiff file
%   
%   TiffMetadata Properties:
%     TiffFullPath - tiff full path
%     TiffFileName - tiff file name
%     Height - height of tiff (in pixels)
%     Width - width of tiff (in pixels)
%     nImages - number of images (frames) in multitiff
%
%   ExperimentParameters Methods:
%     TiffMetadata  - constructor
%     ExportAsStruct  -   returns struct with properties
%     getFullTiffPath - return full tiff path and name 
  properties
    TiffFullPath
    TiffFileName
    Height
    Width
    nImages
  end
  
  methods
    function obj = TiffMetadata(TiffFullPath,TiffFileName,AllImages)
      % Constructors:
      % TiffMetadata()
      % TiffMetadata(TiffFullPath,TiffFileName,AllImages)
      
      if nargin == 1
        inStruct = TiffFullPath;
        obj.TiffFullPath = inStruct.TiffFullPath;
        obj.TiffFileName = inStruct.TiffFileName;
        obj.Height  = inStruct.Height;
        obj.Width   = inStruct.Width;
        obj.nImages = inStruct.nImages;
      else
      obj.TiffFullPath = TiffFullPath;
      obj.TiffFileName = TiffFileName;
      [obj.Height, obj.Width, obj.nImages] = size(AllImages);
      end
    end
    
    function outStruct = ExportAsStruct(obj)
      % Export as struct
      outStruct.TiffFullPath = obj.TiffFullPath;
      outStruct.TiffFileName = obj.TiffFileName;
      outStruct.Height  = obj.Height;
      outStruct.Width   = obj.Width;
      outStruct.nImages = obj.nImages; 
    end
    
    function FullTiffPath = getFullTiffPath(obj)
      % returns [TiffPath TiffName]
      FullTiffPath = [obj.TiffFullPath obj.TiffFileName];
    end
  end
end