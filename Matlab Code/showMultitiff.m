function fig = showMultitiff(AllImages)
%% showMultitiff - plots all Images from tiff with slider
%  INPUTS:
%  AllImages - matrix with all imagesc (width x height x number of images),
%  load by loadmultitiff.m
scrnSize = get(0,'screensize');
fig = figure('Name', 'Version 2.0', 'Position', [scrnSize(1:2)+100 scrnSize(3:4)/2],...
  'Toolbar', 'figure','KeyPressFcn', @keycallback);

h = imagesc(AllImages(:,:,1)); 
nImages = size(AllImages,3);

% Create Slider:
ftext = uicontrol('Parent', fig, 'Style', 'text', 'Units', 'Normalized',...
  'HorizontalAlignment', 'left', 'FontWeight','bold', 'FontSize', 8,...
  'String', 'Frame:  ', 'Position',[.1 .03 .1 .03]);

slider = uicontrol('Parent', fig, 'Style', 'slider', 'Units', 'Normalized',...
  'Min',1, 'Max', nImages, 'SliderStep', [1/nImages 0.1],...
  'Value', 1, 'Position', [.2 0.03 .5 .03]);


addlistener(slider, 'Value','PostSet',@nextplease);

% Start Program:
nextplease()

  function nextplease(varargin)
    iFrame = round(slider.Value);
    h.CData = AllImages(:,:,iFrame);
    ftext.String = sprintf('Frame: %i', iFrame);
    title(sprintf('Image %i, (%i)', iFrame, nImages))
  end

  function keycallback(~,event )
    switch event.Key
      case 'rightarrow', slider.Value = min(nImages, slider.Value+1);
      case 'leftarrow',  slider.Value = max(1, slider.Value-1);
    end
  end
end
