function MovingRectangle_MouseCallbackRGB(Multitiff)
%% MovingRectangle_MouseCallbackRGB
V = vMAT(Multitiff);

fig = figure('Position', [400 386 811 592]);
set(fig, 'WindowButtonMotionFcn', @ButtonMotionCallback)
set(fig, 'WindowKeyPressFcn', @updCroppedImage)

[~, slider] = V.showWithSlider();
% CLim = get(BackgroundImageHandle.Parent, 'CLim');
CLim = [0 255];
ColorMap = zeros(256,3);
RedMap   = ColorMap;    RedMap(:,1) = (1:256)/256;
GreenMap = ColorMap;  GreenMap(:,2) = (1:256)/256;
BlueMap  = ColorMap;   BlueMap(:,3) = (1:256)/256;

M = MovingRectangle();
M.BackgroundImageSize = size(V.getSingleFrame(1));
M.DistanceFromCentrePxl = 40;
M.show()
[xdata, ydata] = rectangle2xydata(M.getrectanglebox);
[R,G,B] = getRGB(V.getSingleFrame(round(slider.Value)));

figure('Position',  [400 110 1087 236], 'MenuBar', 'none');

subplot 131, 
ImR = imagesc(imcrop(R, M.getrectanglebox), 'XData', xdata, 'YData', ydata,CLim);
colormap(gca,RedMap)
subplot 132, 
ImG = imagesc(imcrop(G, M.getrectanglebox), 'XData', xdata, 'YData', ydata,CLim);
colormap(gca, GreenMap)

subplot 133
ImB = imagesc(imcrop(B ,M.getrectanglebox), 'XData', xdata, 'YData', ydata,CLim);
colormap(gca, BlueMap)

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
    [R, G,B] = getRGB(V.getSingleFrame(round(slider.Value)));
    [xdata, ydata] = rectangle2xydata(M.getrectanglebox);
    set(ImR, 'CData', imcrop(R, M.getrectanglebox))    
    set(ImG, 'CData', imcrop(G, M.getrectanglebox)) 
    set(ImB, 'CData', imcrop(B, M.getrectanglebox))
  end
end