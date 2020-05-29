function [cellTable, isCellValid] = track_inspect(AllImg, Cell_XYpos,CellTrackName)
%% TRACK_INSPECT - inspect single track, user can manually correct calculations
% It is simplified version of track_accroosallimages.m function
% INPUTS:
%  AllImg - matrix with all images (width x height x number of images),
%  load by loadmultitiff.m
%  firstCellPos - initial position for tracking. 
%  CellName [OPTIONAL] - string with cell name, default 'CellA'
% OUTPUTS:
% cellTrack - table with fields:
%   
% LOGIC:
% #1 Plot first position
% #2 NEXT -> use previous and current image to find track between images
% #3 BACK -> load already calculated
% #4 CORRECT -> correct in current image
% #5 PLAY_AUT -> Next by next..

[tiffWidth, tiffHeight,nImages] = size(AllImg);
RECTANGLE_SIZE_PXL = max([50, round(0.1* tiffWidth, -1)]); % round to 10, minimum value 50
ImageCount         = find(~isnan(Cell_XYpos(:,1)), 1,'First');
isCellValid = true;
Cell_XYpos_SaveCopy = Cell_XYpos;

if isempty(ImageCount)
  % Note: all positions in Cell_XYpos are nans -> there is any valid
  % position for this cell. Show info and return
  warndlg('There is any valid position for this', getVer, 'modal')
  cellTable = createCellTable();
  isCellValid = false;
  return
end
LastValidRow = find(~isnan(Cell_XYpos(:,1)), 1,'Last');
isTrackingFinished = false; 
AllCellsPos        = struct; 
AllCellsText       = struct;

%% Adjust gui to inspect cell:
gui_h = track_acrossallimages_GUI();
% Show only current frame, do not show options about dividing cells

delete(gui_h.s)
delete(gui_h.showCalculations)
set(gui_h.CellDivisionPanel, 'Visible', 'off')
set(gui_h.preprocessingpanel, 'Visible', 'off')

gui_h.s = axes;
% Make XY listbox wider:
gui_h.xy_listbox.Position(3) = gui_h.xy_listbox.Position(3)*1.5;
gui_h.xy_listbox_descriptionText.Position(3) = gui_h.xy_listbox.Position(3);
gui_h.const_togglebutton.String = 'Auto';

%% Setup Gui:
set(gui_h.figure1, 'CloseRequestFcn', @closeprogram)
set(gui_h.figure1, 'Position', [512 192 915 628])
set(gui_h.figure1, 'KeyPressFcn',     @keycallback)
set(gui_h.progress_slider,  'Max', nImages)
set(gui_h.CenterView_pushbutton, 'Callback', @upateRectangleBox)
set(gui_h.SaveAndClose,          'Callback', @closeprogram)
set(gui_h.ShowRaw,               'Callback', @ChooseWhatToShow)
set(gui_h.ShowProcessed,         'Callback', @ChooseWhatToShow)
set(gui_h.colormap,              'Callback', @setmap)
set(gui_h.ResetCalculations,     'Callback', @resetcalculations)
set(gui_h.xy_listbox,            'Callback', @click_xy_listbox)
set(gui_h.Cancel,                'Callback', @cancel)

smallerAxis = min([tiffWidth,tiffHeight]);
minRect = ceil(smallerAxis*0.05/10)*10;
if minRect>RECTANGLE_SIZE_PXL, RECTANGLE_SIZE_PXL = minRect; end
maxRect = floor(smallerAxis*0.8/10)*10;
set(gui_h.rectangle_size_slider, 'Min', minRect)
set(gui_h.rectangle_size_slider, 'Max', maxRect)
set(gui_h.rectangle_size_slider, 'SliderStep', [1/((maxRect - minRect)/10), 0.1])
set(gui_h.rectangle_size_slider, 'Value', RECTANGLE_SIZE_PXL)

addlistener(gui_h.rectangle_size_slider,  'Value','PostSet', @rectanglesizecallback);
addlistener(gui_h.progress_slider,        'Value','PostSet', @progresslidercallback);
addlistener(gui_h.previous_pushbutton,    'Value','PostSet', @previousplease);
addlistener(gui_h.next_pushbutton,        'Value','PostSet', @nextplease);
addlistener(gui_h.const_togglebutton,     'Value','PostSet', @const_play);

%% Show first image:
rectangleBox = getrectangle(getCurrImg, getCurrPos,RECTANGLE_SIZE_PXL);
[RectXdata, RectYdata] = rectangle2xydata(rectangleBox);
AxesHandle = showfirstimage();  
updGuiAccordToImageCounter()
plotplease()

%% Return result:
while ~isTrackingFinished,  pause(0.1), end
cellTable = createCellTable();
delete(gui_h.figure1)

%% LOCAL FUNCTIONS
  function cTable = createCellTable(),  cTable = Cell_XYpos;   end

%% ...Always come back to the same row when user click on the xy listbox:
% So listbox is not active even if it looks that it is
  function click_xy_listbox(src,~), src.Value = ImageCount; end

%% resetcalculations
  function resetcalculations(~,~)
    % Delete all calculations (set to NAN) from current ImageCount to the
    % end of experiment. NOTE: ImageCount must be decreased
    txt = sprintf('This option resets all calculations between current image (%i) and last image (%i) \nAre you sure?',...
      ImageCount, nImages);
    answer = questdlg(txt, getVer(),  'Yes', 'No', 'Cancel', 'Cancel');
    
    switch answer
      case 'Yes' 
        Cell_XYpos(ImageCount:end,:) = nan;
      otherwise
        return
    end
    ImageCount = max(1,ImageCount -1); % make sure that it is not below 1
    plotplease()
  end

%% ...showfirstimage
  function sH = showfirstimage() 
    DOT_SIZE = 20;
    FirstPos = Cell_XYpos(ImageCount,:);

    axes(gui_h.s)
    sH.IMGHandle = imagesc(imcrop(getCurrImg,rectangleBox),...
      'Xdata', RectXdata, 'Ydata', RectYdata); hold on
    sH.CurrCircleHandle = plot(FirstPos(1),FirstPos(2), 'r.',...
      'MarkerSize', DOT_SIZE,'LineWidth',2);
    set(sH.CurrCircleHandle, 'PickableParts', 'none')
    sH.TitleHandle = title(getS3Title); axis tight ,axis equal
    box off
    set(sH.IMGHandle, 'ButtonDownFcn', @correctplease)
  end

%% ..rectanglesizecallback
  function rectanglesizecallback(~,~)
    RECTANGLE_SIZE_PXL = round(gui_h.rectangle_size_slider.Value/10)*10;
    upateRectangleBox([],[])
  end

%% ..slidercallback
  function progresslidercallback(~, event)
    % You can move slider from first position of cell and up to image 
    % which is already processed
    LastProcessedImageNumber  = find(~isnan(Cell_XYpos(:,1))==1, 1,'Last');
    FirstProcessedImageNumber = find(~isnan(Cell_XYpos(:,1))==1, 1,'First');
    
    if event.AffectedObject.Value>LastProcessedImageNumber
      ImageCount = LastProcessedImageNumber;
      gui_h.progress_slider.Value = LastProcessedImageNumber;
    elseif event.AffectedObject.Value<FirstProcessedImageNumber
      ImageCount = FirstProcessedImageNumber;
      gui_h.progress_slider.Value = FirstProcessedImageNumber;
    else
      ImageCount = round(event.AffectedObject.Value); 
      plotplease()
    end
    updGuiAccordToImageCounter()
  end

%% ..nextplease
  function nextplease(~, ~)   
    % Increment count &  calculate new position:
    ImageCount = min([nImages, ImageCount + 1]); % Max is number of images    
    plotplease()
    if ImageCount < nImages, updGuiAccordToImageCounter(), end
  end

%% ..previousplease:
  function previousplease(~, ~)
    % Decrease ImageCount & plot
    ImageCount = max([1, ImageCount - 1]);
    plotplease() 
    updGuiAccordToImageCounter()
  end

%% ..updGuiAccordToImageCounter
  function updGuiAccordToImageCounter()
    
    if ImageCount == 1 % First image
      set(gui_h.previous_pushbutton, 'Enable', 'Off')
      set(gui_h.const_togglebutton,  'Value', 0)
    elseif ImageCount == nImages  || ImageCount == LastValidRow % Last image or last image with not nan values
      set(gui_h.next_pushbutton, 'Enable', 'Off')
      set(gui_h.const_togglebutton, 'Value', 0)
    elseif ImageCount == nImages-1 % Before Last
      set(gui_h.next_pushbutton, 'Enable', 'On')
    elseif ImageCount == 2 % Second
      set(gui_h.previous_pushbutton, 'Enable', 'On')
    end
    set(gui_h.progress_txt,'String',sprintf('Done: %i/%i',ImageCount,nImages))
    set(gui_h.xy_listbox, 'Value', ImageCount)
  end

%% ..plotplease
  function plotplease(varargin)
    % This plot should show position of cell of current image. Position is
    % for CURRENT image:
    PrevPOS = getPrevPos();
    PrevIMG = getPrevImg();
    CurrPOS = getCurrPos();
    CurrIMG = getCurrImg();
    
    % Is current position is within red rectangle box? If not update box
    if isPositionOutsideRectangle(CurrPOS)
      if ~all(isnan(PrevPOS))
        rectangleBox =  getrectangle(PrevIMG, PrevPOS,RECTANGLE_SIZE_PXL);
      end
    end
    [RectXdata, RectYdata] = rectangle2xydata(rectangleBox);
    
    CUR_IMG = imcrop(CurrIMG,rectangleBox);
%    
    if ~gui_h.ShowRaw.Value && gui_h.ShowProcessed.Value
    % Only watershed
      CUR_IMG = preprocessimage(CUR_IMG);
    elseif gui_h.ShowRaw.Value && gui_h.ShowProcessed.Value
      CUR_IMG = imoverlay(CUR_IMG, bwperim(preprocessimage(CUR_IMG)<1), 'w'); 
      CUR_IMG = CUR_IMG(:,:,1);
    end

    axes(gui_h.s)
    set(AxesHandle.IMGHandle,    'CData', CUR_IMG)
    set(AxesHandle.IMGHandle,    'Xdata', RectXdata)
    set(AxesHandle.IMGHandle,    'Ydata', RectYdata)
    set(AxesHandle.CurrCircleHandle, 'XData', CurrPOS(1))
    set(AxesHandle.CurrCircleHandle, 'YData', CurrPOS(2))
    set(AxesHandle.TitleHandle, 'String', getS3Title)

%     set(gui_h.RectText, 'String', sprintf('Rectangle size: %i',...
%       round(gui_h.rectangle_size_slider.Value)))
    set(gui_h.progress_slider, 'Value', ImageCount)
    
    if ~isempty(fieldnames(AllCellsText))
      AllCellsNames = fieldnames(AllCellsText);
      for i = 1:numel(AllCellsNames)
        pos = AllCellsPos.(AllCellsNames{i})(ImageCount,1:2);
        if isPositionOutsideRectangle(pos)
          set(AllCellsText.(AllCellsNames{i}), 'Visible', 'Off')
        else
          set(AllCellsText.(AllCellsNames{i}), 'Visible', 'On')
          % move 5 pixels for better visibility
          set(AllCellsText.(AllCellsNames{i}), 'Position',pos +5); 
        end
      end
    end
    
    set(gui_h.progress_txt,'String',sprintf('Done: %i/%i',ImageCount,nImages))
    set(gui_h.xy_listbox, 'String',  num2str([[1:nImages]', Cell_XYpos])) %#ok<NBRAK>
    set(gui_h.xy_listbox, 'Value', ImageCount)
    drawnow()
  end

%% upateRectangleBox
  function upateRectangleBox(~,~)
    rectangleBox = getrectangle(getPrevImg,  getCurrPos,RECTANGLE_SIZE_PXL); 
    plotplease()
  end

%%  Helper functions
  function Out = getPrevPos(), Out = Cell_XYpos(max(1,ImageCount-1),:); end
  function Out = getCurrPos(), Out = Cell_XYpos(ImageCount,:); end
  function Out = getPrevImg(), Out = AllImg(:,:,max(1,ImageCount-1)); end
  function Out = getCurrImg(), Out = AllImg(:,:,ImageCount);end

  function Out = getS3Title()
    CurrPOS = getCurrPos();
    Out = {sprintf('Current image %i, [%i, %i]',...
      ImageCount ,CurrPOS(1),CurrPOS(2)),...
      CellTrackName};
  end

%% ... isPositionWithinRectangle
  function isOut = isPositionOutsideRectangle(pos)
    isOut = RectXdata(1) > pos(1) || pos(1) > RectXdata(end) || ...
            RectYdata(1) > pos(2) || pos(2) > RectYdata(end);
  end
%% ...const_play 
  function const_play(~, ~)
    while gui_h.const_togglebutton.Value == 1
      gui_h.const_togglebutton.String = 'STOP';
      nextplease([],[])
    end
    % In inspection there is no tracking, so i changed name into Auto
    gui_h.const_togglebutton.String = 'Auto'; 
  end

%% ...correctplease
  function correctplease(~,event)
    clickedPos = [round(event.IntersectionPoint(1)),...
      round(event.IntersectionPoint(2))];    
    
%     CurrentPosition = trackbetween2images(getCurrImg, getPrevPos,RECTANGLE_SIZE_PXL); 
    if gui_h.use_centre_of_mass_checkbox.Value
      clickedPos = trackbetween2images(getCurrImg(), clickedPos, RECTANGLE_SIZE_PXL);
    end
    Cell_XYpos(ImageCount, :) = clickedPos;
    plotplease()
  end

%% ..keyboard callback
  function keycallback(~,event )
    switch event.Key
      case 'rightarrow', nextplease([], [])
      case 'leftarrow',  previousplease([], [])
    end
  end

%% ...closeprogram
  function closeprogram(varargin)
    isTrackingFinished = true; pause(0.1),  delete(gui_h.figure1); 
  end

%% ...
  function cancel(varargin)
    Cell_XYpos = Cell_XYpos_SaveCopy;
    isCellValid = false;
    closeprogram()
  end

%% ..ChooseWhatToShow
function ChooseWhatToShow(~,~)
% At least one option must be choosen:
if ~gui_h.ShowRaw.Value && ~gui_h.ShowProcessed.Value
  gui_h.ShowRaw.Value = 1;
end
plotplease()
end  
end


