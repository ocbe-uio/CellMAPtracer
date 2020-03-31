function visualizeResults(AllImages, Tracks)
%% VISUALIZERESUTLS - function plots all Images from tiff file and
% calculated position of cells.
%  INPUTS:
%  AllImg - matrix with all imagesc (width x height x number of images),
%  load by loadmultitiff.m
%  AllTracks - initial position for tracking.
%   struct with fields:
%           NumTracks: 3
%              Tracks: [60×4 table]
%     LastTrackNumber: 3
%            Metadata: [1×1 struct]

scrnSize = get(0,'screensize');
fig = figure('Name', getVer(), 'Position', [scrnSize(1:2)+100 scrnSize(3:4)/2],...
  'Toolbar', 'figure','KeyPressFcn', @keycallback);

h = imagesc(AllImages(:,:,1)); 
nImages = size(AllImages,3);

hold on
hTrack   = plotcelltracks(Tracks);
CellPos  = Tracks{Tracks.ImageID==1, 'Cell_xy_pos'};
CellName = Tracks{Tracks.ImageID==1, 'CellName'};
p  = plot(CellPos(:,1),CellPos(:,2), 'mo') ;
tx = text(CellPos(:,1), CellPos(:,2), CellName,'Color', 'black',...
  'Interpreter', 'None','FontWeight','bold' );
addcolormappopupmenu(fig, [0 0.1 0.1 0.02])

% Create Slider:
ftext = uicontrol('Parent', fig, 'Style', 'text', 'Units', 'Normalized',...
  'HorizontalAlignment', 'left', 'FontWeight','bold', 'FontSize', 8,...
  'String', 'Frame:  ', 'Position',[.1 .03 .1 .03]);

uicontrol('Parent', fig, 'Style', 'text', 'Units', 'Normalized',...
  'HorizontalAlignment', 'left', 'FontWeight','bold', 'FontSize', 8,...
  'String', 'Opacity', 'Position',  [.1 .0 .1 .03]);

slider = uicontrol('Parent', fig, 'Style', 'slider', 'Units', 'Normalized',...
  'Min',1, 'Max', nImages, 'SliderStep', [1/nImages 0.1],...
  'Value', 1, 'Position', [.2 0.03 .5 .03]);

OPslider = uicontrol('Parent', fig, 'Style', 'slider', 'Units', 'Normalized',...
  'Min',0, 'Max', 1, 'SliderStep', [0.1 0.1],...
  'Value', 1, 'Position', [.2 0 .2 .03]);

addlistener(slider, 'Value','PostSet',@nextplease);
addlistener(OPslider,'Value','PostSet',@updopacity);

% Start Program:
nextplease([],[])

% Show next frame
  function nextplease(~, ~)
    iFrame = round(slider.Value);
    h.CData = AllImages(:,:,iFrame);
    ftext.String = sprintf('Frame: %i', iFrame);
    if ~isempty(Tracks)
      CellPos  = Tracks{Tracks.ImageID==iFrame, 'Cell_xy_pos'};
      CellName = Tracks{Tracks.ImageID==iFrame, 'CellName'};
      UniqueCellNames = unique(string(Tracks.CellName));
      set(p, 'XData', CellPos(:,1))
      set(p, 'YData', CellPos(:,2))
      for iCell = 1:numel(UniqueCellNames)
        tx(iCell).Position(1:2) = CellPos(iCell,:);
      end
    end
    title(sprintf('Image %i, (%i)', iFrame, nImages))
  end

% Change opacity of tracks:
  function updopacity(~,~)
    for iC = 1:numel(hTrack), hTrack(iC).Color(4)  = OPslider.Value; end
  end

  function keycallback(~,event )
    switch event.Key
      case 'rightarrow', slider.Value = min(nImages, slider.Value+1);
      case 'leftarrow',  slider.Value = max(1, slider.Value-1);
    end
  end
end
