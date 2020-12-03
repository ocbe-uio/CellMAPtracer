function MovingRectangle_MouseCallback(Multitiff)
%% MovingRectangle_MouseCallback

V = vMAT(Multitiff);

fig = figure('Position', [400 386 811 592]);
set(fig, 'WindowButtonMotionFcn', @ButtonMotionCallback)
set(fig, 'WindowKeyPressFcn', @updCroppedImage)

[BackgroundImageHandle, slider] = V.showWithSlider();
CLim = get(BackgroundImageHandle.Parent, 'CLim');
M = MovingRectangle();
M.BackgroundImageSize = size(V.getSingleFrame(1));
M.DistanceFromCentrePxl = 40;
M.show()


figure('Position', [398 78 338 227], 'MenuBar', 'none');
[xdata, ydata] = rectangle2xydata(M.getrectanglebox);
ImH = imagesc(imcrop(V.getSingleFrame(round(slider.Value)),M.getrectanglebox),...
      'XData', xdata, 'YData', ydata,CLim);
figure(fig)

  function ButtonMotionCallback(varargin)
    [~, MousePosOnTheImage] = pointer2d(gcf,gca);
    MousePosOnTheImage = round(MousePosOnTheImage);
    x = max(MousePosOnTheImage(1), 1);
    y = max(MousePosOnTheImage(2), 1);
    M.setPosition([x,y])
    updCroppedImage()
  end

  function updCroppedImage(varargin)  
    set(ImH, 'CData', imcrop(V.getSingleFrame(round(slider.Value)), M.getrectanglebox))
  end
end