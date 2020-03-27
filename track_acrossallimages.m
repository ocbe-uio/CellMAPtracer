function cellTable = track_acrossallimages(AllImg, firstCellPos, CellTrackName)
%% TRACK_ACROSSALLFRAMES -track single cell across all frames
% INPUTS:
%  AllImg - matrix with all images (width x height x number of images),
%  load by loadmultitiff.m
%  firstCellPos - initial position for tracking. 
%  CellName [OPTIONAL] - string with cell name, default 'CellA'
% OUTPUTS:
%  cellTrack - table with fields
%   
% LOGIC:
% #1 Plot first position
% #2 NEXT -> use previous and current image to find track between images
% #3 BACK -> load already calculated
% #4 CORRECT -> correct in current image
% #5 PLAY_AUT -> Next by next..

%% Init variables:
[tiffWidth, tiffHeight,nImages] = size(AllImg);
RECTANGLE_SIZE_PXL =  max([50, round(0.1* tiffWidth, -1)]); % round to 10, minimum value 50
Cell_XYpos         = nan(nImages,2); % [xy position for each image]
Cell_XYpos(1,:)    = firstCellPos;
ImageCount         = 1;
isTrackingFinished = false; 
ActiveBottonName   = [];
askedAboutFinish   = false;
AllCellsPos        = struct; 
AllCellsText       = struct;

%% Create Gui
gui_h = track_acrossallimages_GUI();
delete(gui_h.Cancel) % Cancel pushbutton is used only for inspect track

%% Setup Gui:
set(gui_h.figure1, 'CloseRequestFcn', @closeprogram)
set(gui_h.figure1, 'KeyPressFcn',     @keycallback)
set(gui_h.figure1, 'SizeChangedFcn',  @savewinsize)
set(gui_h.progress_slider,  'Max', nImages)

set(gui_h.CellDivision_pushbutton ,     'Callback', @divideCell)
set(gui_h.Undo_CellDivision_pushbutton, 'Callback', @UndoDivision)
set(gui_h.CenterView_pushbutton,        'Callback', @upateRectangleBox)
set(gui_h.SaveAndClose,                 'Callback', @closeprogram)
set(gui_h.ShowRaw,                      'Callback', @ChooseWhatToShow)
set(gui_h.ShowProcessed,                'Callback', @ChooseWhatToShow)
set(gui_h.showCalculations,             'Callback', @showcalc)
set(gui_h.colormap,                     'Callback', @setmap)
set(gui_h.method_thresholding,          'Callback', @changepreprocessingmethod)
set(gui_h.method_watershed,             'Callback', @changepreprocessingmethod)
set(gui_h.xy_listbox,                   'Callback', @click_xy_listbox)
set(gui_h.ResetCalculations,            'Callback', @resetcalculations)

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
rectangleBox           = getrectangle(getPrevImg, getPrevPos,RECTANGLE_SIZE_PXL);
[RectXdata, RectYdata] = rectangle2xydata(rectangleBox);
[s1H,s2H,s3H]          = showfirstimage();  
updGuiAccordToImageCounter()

%% Create first cell toggle button:
ActiveBottonName = createToggleButton([.05 .75 .9 .2], CellTrackName);
AllCellsPos.(ActiveBottonName) = Cell_XYpos;
switchactivetogglebutton(gui_h.buttons.(ActiveBottonName));

%% Return result:
while ~isTrackingFinished,  pause(0.1), end
cellTable = createCellTable();
delete(gui_h.figure1)

%% LOCAL FUNCTIONS
  function cTable = createCellTable()
    ImagesTable = table((1:nImages)', 'VariableNames',{'ImageID'});
    cTable = [ImagesTable,struct2table(AllCellsPos)];
  end

% -------------------------------------------------
  function StringIN = createToggleButton(pos, StringIN)
    gui_h.buttons.(StringIN) = uicontrol('Parent',gui_h.CellDivisionPanel,...
      'Style','togglebutton', 'String',StringIN,  'Units','Normalized',...
      'Position',pos, 'Callback', @switchactivetogglebutton);
    AllCellsText.(StringIN) = text(0,0, StringIN,...
      'PickableParts', 'none', 'Interpreter', 'none', 'Color', 'r', 'FontWeight', 'bold');
  end

  function UndoDivision(~,~)
    % delete 2 pushbuttons:
    nButtons = numel(fieldnames(gui_h.buttons));
    if nButtons == 1, return, end % there is only one button, do nothing
    
    Cell1Name = [ActiveBottonName(1:end-1), '1']; % DO NOT CHANGE TO _1 !
    Cell2Name = [ActiveBottonName(1:end-1), '2']; % DO NOT CHANGE TO _2 !
    try
    delete(gui_h.buttons.(Cell1Name))
    delete(gui_h.buttons.(Cell2Name))
    catch
      % User clicked on generation which cannot be removed
      return
    end
      
    gui_h.buttons = rmfield(gui_h.buttons, Cell1Name);
    gui_h.buttons = rmfield(gui_h.buttons, Cell2Name);
    AllCellsPos = rmfield(AllCellsPos, Cell1Name);
    AllCellsPos = rmfield(AllCellsPos, Cell2Name);
    
    delete(AllCellsText.(Cell1Name))
    delete(AllCellsText.(Cell2Name))
    AllCellsText = rmfield(AllCellsText,Cell1Name);
    AllCellsText = rmfield(AllCellsText,Cell2Name);
    
    ActiveBottonName = ActiveBottonName(1:end-2); 
    switchactivetogglebutton(gui_h.buttons.(ActiveBottonName), [])
    Cell_XYpos = AllCellsPos.(ActiveBottonName);
  end

  function switchactivetogglebutton(src,~)
    set(gui_h.previous_pushbutton,'Enable', 'On')
    set(gui_h.next_pushbutton,    'Enable', 'On')
    set(gui_h.const_togglebutton, 'Enable', 'On')
    
    % Highlight buttons:
    highlightactivetogglebutton(src)
    
    ActiveBottonName = src.String;
    Cell_XYpos = AllCellsPos.(ActiveBottonName);
    % Come back to first image with this cell:
    ImageCount = find(~isnan(Cell_XYpos(:,1))==1, 1,'First');
    % Note: if the image count is 1, program come back to the beggining of
    % tiff file. In many cases, when user switch between cells, he/she
    % would like to compare last image before cell division and first image
    % after cell division. To make it easier, if the Image count is 1, a
    % jump to last image instead of first:
    if ImageCount == 1
       ImageCount = find(~isnan(Cell_XYpos(:,1))==1, 1,'Last');
    end
    upateRectangleBox([], [])
    plotplease()
  end

  function highlightactivetogglebutton(clickedButton)
    % Disactive all:
    AllButtonNames = fieldnames(gui_h.buttons);
    for i = 1:numel(AllButtonNames)
      set(gui_h.buttons.(AllButtonNames{i}), 'Value', 0)
      set(gui_h.buttons.(AllButtonNames{i}), 'BackgroundColor', [.94 .94 .94])
    end
    set(clickedButton, 'BackgroundColor', [.6 1 .6]);
  end

  function divideCell(~,~)
    if isempty(ActiveBottonName), return, end % Any button is actvie
    % Cell cannot divides in first image, probably user clicked by mistake,
    % I do not show any warrning here. 
    if ImageCount == 1, return, end
    ActiveBotton = gui_h.buttons.(ActiveBottonName);
    LastPosBeforeDivision = getCurrPos();
    % Clear everything after division: this happen when user come back using
    % slider to place where there cell division. Calculation from this
    % point should be erased:
%     Cell_XYpos(min(ImageCount+1,nImages):end,:) = nan; %!
% When click cell division cell is already divided. So position for current
% ImageCount should be nan:
% #Frame #CellA   #CellA_1  #CellA_2
% 1     [10 10]   [nan nan] [nan nan]
% 2     [20 20]   [nan nan] [nan nan]
% 3     [nan nan] [25 25]   [35 35]
% 4     [nan nan] [28 28]   [32 32]
% 5     [nan nan] [29 29]   [33 33]

    Cell_XYpos(min(ImageCount,nImages):end,:) = nan; %!
    % Save calculation for cell before division
    AllCellsPos.(ActiveBottonName) = Cell_XYpos;
    % Create new cell positions:
    reset_cell_xy_pos();
    % Last good position is before cell division:
    % Note: next action is next, so ImageCount is incremented anyway:
    Cell_XYpos(max(1,ImageCount),: )  = LastPosBeforeDivision;
  
    % Add 2 new buttons:
    ButtonPos = ActiveBotton.Position;
    newButtonPos1 = [ButtonPos(1), ButtonPos(2)-0.1, ButtonPos(3)/2 ButtonPos(4)];
    newButtonPos2 = [ButtonPos(1)+ButtonPos(3)/2, ButtonPos(2)-0.1, ButtonPos(3)/2 ButtonPos(4)];
    createToggleButton(newButtonPos1,  [ActiveBottonName '_1']);
    createToggleButton(newButtonPos2,  [ActiveBottonName '_2']);
    
    AllCellsPos.([ActiveBottonName '_1']) = Cell_XYpos; 
    AllCellsPos.([ActiveBottonName '_2']) = Cell_XYpos;
    
    % After cell division mark active first one:
    % TODO: OPTIMIZE IT 
    highlightactivetogglebutton(gui_h.buttons.([ActiveBottonName '_1']))
    ActiveBottonName = [ActiveBottonName '_1'];
    
    Cell_XYpos = AllCellsPos.(ActiveBottonName);
    % Come back to first image with this cell:
    ImageCount = find(~isnan(Cell_XYpos(:,1))==1, 1,'First');
    plotplease()
  end

  function reset_cell_xy_pos(), Cell_XYpos =  nan(nImages,2); end
% -----------------------------------------------------

%% ...Always come back to the same row when user click on the xy listbox:
% So listbox is not active even if it looks that it is
  function click_xy_listbox(src,~), src.Value = ImageCount; end

  function resetcalculations(~,~)
    % Delete all calculations (set to NAN) from current ImageCount to the
    % end of experiment. NOTE: ImageCount must be decreased
    txt = sprintf('This option resets all calculations between current image (%i) and last image (%i) \nAre you sure?',...
    ImageCount, nImages);
    answer = questdlg(txt, getVer(),  'Yes', 'No', 'Cancel', 'Cancel');
    
    switch answer
      case 'Yes'
        Cell_XYpos(ImageCount:end,:) = nan;
        AllCellsPos.(ActiveBottonName) = Cell_XYpos;
      otherwise
        return
    end
    ImageCount = ImageCount -1;
    plotplease() 
  end
%% 
  function [s1H,s2H,s3H] = showfirstimage() 
    DOT_SIZE = 20;
    FirstPos = getPrevPos();
    subplot(gui_h.s(1));
    s1H.IMGHandle = imagesc(getPrevImg); hold on
    s1H.RecHandle = rectangle('Position', rectangleBox, 'EdgeColor', 'r');
    s1H.CircleHandle = plot(FirstPos(1),FirstPos(2),'r.','MarkerSize', DOT_SIZE);
    s1H.TitleHandle = title(getS1Title); hold off, axis equal, axis tight
    
    subplot(gui_h.s(2));
    s2H.IMGHandle = imagesc(imcrop(getPrevImg,rectangleBox),...
      'Xdata', RectXdata, 'Ydata', RectYdata); hold on
    s2H.CircleHandle = plot(FirstPos(1),FirstPos(2), 'm.',...
      'MarkerSize', DOT_SIZE, 'LineWidth',2);
    s2H.TitleHandle = title(getS2Title); 
    hold off, axis tight ,axis equal
    
    subplot(gui_h.s(3))
    s3H.IMGHandle = imagesc(imcrop(getCurrImg,rectangleBox),...
      'Xdata', RectXdata, 'Ydata', RectYdata); hold on
    s3H.PrevCircleHandle = plot(FirstPos(1),FirstPos(2), 'm.',...
      'MarkerSize', DOT_SIZE,'LineWidth',2);
    s3H.CurrCircleHandle = plot(FirstPos(1),FirstPos(2), 'r.',...
      'MarkerSize', DOT_SIZE,'LineWidth',2);
    
    set(s3H.PrevCircleHandle, 'PickableParts', 'none')
    set(s3H.CurrCircleHandle, 'PickableParts', 'none')
    s3H.TitleHandle = title(getS3Title); axis tight ,axis equal
    set(s3H.IMGHandle, 'ButtonDownFcn', @correctplease)
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
    % Note: getCurrImg applies threshold on image
    CurrentPosition = trackbetween2images(getCurrImg, getPrevPos,RECTANGLE_SIZE_PXL); 
    if all(isnan(CurrentPosition))
      set(gui_h.const_togglebutton, 'Value', 0);
      % No cell found - copy last pos:
      CurrentPosition = Cell_XYpos(max(1,ImageCount-1), 1:2);
    end
    Cell_XYpos(ImageCount, 1:2) = CurrentPosition; 
    AllCellsPos.(ActiveBottonName) = Cell_XYpos;
    plotplease()
    if ImageCount < nImages, updGuiAccordToImageCounter(), end
  end

%% ...correctplease
  function correctplease(~,event)
    clickedPos = [round(event.IntersectionPoint(1)),...
      round(event.IntersectionPoint(2))];
    if gui_h.use_centre_of_mass_checkbox.Value
      clickedPos = trackbetween2images(getCurrImg(), clickedPos, RECTANGLE_SIZE_PXL);
    end
    Cell_XYpos(ImageCount, :) = clickedPos;
    AllCellsPos.(ActiveBottonName) = Cell_XYpos;
    plotplease()
  end

%% ..previousplease:
  function previousplease(~, ~)
    % Decrease ImageCount & plot
    ImageCount = max([1, ImageCount - 1]);
    plotplease() 
    updGuiAccordToImageCounter()
  end

%% ...lastimageoption
  function lastimageoption()
    % Show options when you finish tracking
    % Come back to cell division moment and start tracking part2
    % close and finish
    if ~askedAboutFinish % ask only once
      answer = questdlg('Finished tracking for one cell',getVer(), ...
        'Save and close', 'Back to tracking', 'Back to tracking');
      % Handle response
      switch answer
        case 'Save and close',  isTrackingFinished = true;
        case 'Back to tracking'
      end
      askedAboutFinish = true;
    end
  end
%% ..updGuiAccordToImageCounter
  function updGuiAccordToImageCounter()
    if ImageCount == 1 % First image
      set(gui_h.previous_pushbutton, 'Enable', 'Off')
      set(gui_h.const_togglebutton,  'Value', 0)
    elseif ImageCount == nImages % Last image
      set(gui_h.next_pushbutton, 'Enable', 'Off')
      set(gui_h.const_togglebutton, 'Value', 0)
      AllCellsPos.(ActiveBottonName) = Cell_XYpos;
      lastimageoption()
    elseif ImageCount == nImages-1 % Before Last
      set(gui_h.next_pushbutton, 'Enable', 'On')
       isTrackingFinished = false;
    elseif ImageCount == 2 % Second
      set(gui_h.previous_pushbutton, 'Enable', 'On')
    end
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

    subplot(gui_h.s(1)), 
    set(s1H.IMGHandle,    'CData',CurrIMG)
    set(s1H.RecHandle,    'Position', rectangleBox)
    set(s1H.CircleHandle, 'XData', CurrPOS(1))
    set(s1H.CircleHandle, 'YData', CurrPOS(2))
    set(s1H.TitleHandle,  'String', getS1Title)
    

    PRE_IMG = imcrop(PrevIMG,rectangleBox);
    CUR_IMG = imcrop(CurrIMG,rectangleBox);
   
    if ~gui_h.ShowRaw.Value && gui_h.ShowProcessed.Value
    % Only watershed
      PRE_IMG = preprocessimage(PRE_IMG, 'PRE_PROCESSING_METHOD', getpreprocessingmethod());
      CUR_IMG = preprocessimage(CUR_IMG, 'PRE_PROCESSING_METHOD', getpreprocessingmethod());
    elseif gui_h.ShowRaw.Value && gui_h.ShowProcessed.Value
    % Both watershed
      PRE_IMG = imoverlay(PRE_IMG,...
        bwperim(preprocessimage(PRE_IMG, 'PRE_PROCESSING_METHOD', getpreprocessingmethod())<1), 'w'); 
      PRE_IMG = PRE_IMG(:,:,1);
      CUR_IMG = imoverlay(CUR_IMG,...
        bwperim(preprocessimage(CUR_IMG, 'PRE_PROCESSING_METHOD', getpreprocessingmethod())<1), 'w'); 
      CUR_IMG = CUR_IMG(:,:,1);
    end
    
    subplot(gui_h.s(2)), 
    set(s2H.IMGHandle,    'CData', PRE_IMG)
    set(s2H.IMGHandle,    'Xdata', RectXdata)
    set(s2H.IMGHandle,    'Ydata', RectYdata)
    set(s2H.CircleHandle, 'XData', PrevPOS(1))
    set(s2H.CircleHandle, 'YData', PrevPOS(2))
    set(s2H.TitleHandle,  'String', getS2Title)

    subplot(gui_h.s(3))
    set(s3H.IMGHandle,    'CData', CUR_IMG)
    set(s3H.IMGHandle,    'Xdata', RectXdata)
    set(s3H.IMGHandle,    'Ydata', RectYdata)
    set(s3H.PrevCircleHandle, 'XData', PrevPOS(1))
    set(s3H.PrevCircleHandle, 'YData', PrevPOS(2))
    set(s3H.CurrCircleHandle, 'XData', CurrPOS(1))
    set(s3H.CurrCircleHandle, 'YData', CurrPOS(2))
    set(s3H.TitleHandle, 'String', getS3Title)

    set(gui_h.RectText, 'String', sprintf('Rectangle size: %i',...
      round(gui_h.rectangle_size_slider.Value)))
    set(gui_h.progress_slider, 'Value', ImageCount)
    
    % Plot Name of cell on the last subplot:
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

  function Out = getS1Title(), Out = sprintf('Image %i (%i)',ImageCount,nImages); end
  function Out = getS2Title()
    PrevPOS = getPrevPos();
     Out = {sprintf('Previous image %i [%i, %i]', max([1,ImageCount-1]),...
      PrevPOS(1), PrevPOS(2)), '\color{magenta} Last Good position'};
  end 

  function Out = getS3Title()
    CurrPOS = getCurrPos();
    Out = {sprintf('Current image %i, [%i, %i]', ImageCount ,CurrPOS(1),CurrPOS(2)),...
      '\color{magenta} Last Good position \color{red} Calculated Position'};
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
    gui_h.const_togglebutton.String = 'Automated Tracking';
  end

%% ..keyboard callback
  function keycallback(~,event )
    switch event.Key
      case 'rightarrow', nextplease([], [])
      case 'leftarrow',  previousplease([], [])
    end
  end

%% ...closeprogram
  function closeprogram(~,~)
    isTrackingFinished = true; pause(0.1),  delete(gui_h.figure1); 
  end

%% ..plotcalc
  function showcalc(~,~)
    preprocessimage(imcrop(getCurrImg,rectangleBox),...
      'PRE_PROCESSING_METHOD', getpreprocessingmethod(),...
      'SHOW_CALC', true,...
      'ImageNum',ImageCount)
  end

%% .. getpreprocessing method
 function preprocessing_method = getpreprocessingmethod()
  if gui_h.method_thresholding.Value
    preprocessing_method = 'thresholding';
  else
    preprocessing_method = 'watershed';
  end
    
  end

%% ..changepreprocessingmethod
  function changepreprocessingmethod(src,~)
    switch src.Tag
      case 'method_thresholding'
        set(gui_h.method_thresholding, 'Value', 1)
        set(gui_h.method_watershed	, 'Value', 0)
      case 'method_watershed'
      set(gui_h.method_thresholding, 'Value', 0)
      set(gui_h.method_watershed	, 'Value', 1)
    end
    plotplease()
  end

%% ..savewinsize
  function savewinsize(varargin)
    JsonFileName = saveWindowSizeToJsonFile(get(gui_h.figure1, 'Position'));
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


