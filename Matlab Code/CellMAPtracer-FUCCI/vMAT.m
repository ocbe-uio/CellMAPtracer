classdef vMAT
  % vMAT is class to work with 3D matrix, typical multitiff files. 
  % It allows to manage each frame, present and extract data from 3D matrix
  
  properties
      % Note: I assume that 3D matrix, for example X = rand(100,100,3)
      % is single channel recording with 3 frames. So information about
      % channel is on the 3 dimension of matrix, examples:
      % X = rand(100,100,3) % Single channel with recording, 3 frames
      % X = rand(100,100,3,149) % RGB recording, 149 frames
      % V(widht, height, nFrames)
      % V(widht, height,nChannels, nFrames)
      V
  end
  
  properties (GetAccess = private) 
    nFrames 
  end

  methods
    function obj = vMAT(V)
      %VMAT initialize with 3D numeric matrix
      assert(isnumeric(V), 'Matrix must be numeric')
      assert(~ismatrix(V), 'Matrix must have 3 dimensions')
      obj.V = V;
      obj.nFrames = size(V,ndims(V));
    end
    
    function SingleFrame = getSingleFrame(obj, FrameNum)
      InfoText = 'Frame Number must be intiger value between [1 NumberOfFrames]';
      assert(FrameNum > 0, InfoText)
      assert(FrameNum <= obj.nFrames, InfoText)
      if ndims(obj.V) == 3
        SingleFrame = obj.V(:,:,FrameNum);
      elseif ndims(obj.V) == 4
        SingleFrame = obj.V(:,:,:, FrameNum);
      end
    end
    
    function ManyFrames = getManyFrames(obj, FrameNumVector)
        if ndims(obj.V) == 3
            ManyFrames = obj.V(:,:,FrameNumVector);
        elseif ndims(obj.V) == 4
            ManyFrames = obj.V(:,:,:, FrameNumVector);
        end
    end
    
    function nChannels = getNumberOfChannels(obj)
        % Return size of 3rd dimension of first frame
        nChannels = size(obj.getSingleFrame(1),3); 
    end
    function nFrames = getNumberOfFrames(obj), nFrames = obj.nFrames; end
    
    % Visualisation:
    function [ImageHandle, slider] = showWithSlider(obj,currentAxes)
      if nargin < 2, currentAxes = gca; end
      slider = uicontrol('Parent', currentAxes.Parent, 'Style', 'slider',...
        'Units', 'Normalized', 'Position', [0 0 .5 .05]);
      set(slider, 'Min',1)
      set(slider, 'Max', obj.getNumberOfFrames)
      set(slider, 'SliderStep', [1/obj.getNumberOfFrames 0.1])
      set(slider,  'Value', 1)
      
      ImageHandle = imagesc(obj.getSingleFrame(slider.Value));
      TitleHandle = title(sprintf('Frame %i', slider.Value));
      addlistener(slider,'Value','PostSet',@updplot);
      
      % Nested function for updating plot:
      function updplot(~,event)
        SliderValue = round(event.AffectedObject.Value);
        set(ImageHandle, 'CData', obj.getSingleFrame(SliderValue))
        set(TitleHandle, 'String', sprintf('Frame %i',SliderValue))
      end    
    end
    
  end
end

