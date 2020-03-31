function PreProcessedImage = preprocessimage(img, varargin)
%% PREPROCESSIMAGE - image preprocessing before localize cells
% preprocessimage(img, 'PRE_PROCESSING_METHOD', 'ImageNum', 'SHOW_CALC')
% There are 2 ways of preprocessing:
% Thresholding
% watershed

expected_PRE_PROCESSING_METHODS = {'thresholding','watershed'};
default_PRE_PROCESSING_METHOD = 'thresholding';
default_SHOW_CALC = false;
default_ImageNum = 1;

%% PARSE INPUTS:
   p = inputParser;
   validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
   addRequired(p,'img');
   addOptional(p,'PRE_PROCESSING_METHOD',default_PRE_PROCESSING_METHOD,...
     @(x) any(validatestring(x,expected_PRE_PROCESSING_METHODS)));
   addOptional(p,'ImageNum',default_ImageNum, validScalarPosNum);
   addOptional(p,'SHOW_CALC',default_SHOW_CALC);
   parse(p,img,varargin{:});
   
   PRE_PROCESSING_METHOD = p.Results.PRE_PROCESSING_METHOD;
   SHOW_CALC = p.Results.SHOW_CALC;
   ImageNum = p.Results.ImageNum;
   
% #1. contrast-limited adaptive histogram equalization and threshold:
I_eq = adapthisteq(img);
bw = im2bw(I_eq, graythresh(I_eq)); %#ok<IM2BW>

switch PRE_PROCESSING_METHOD
  case 'thresholding' % Simple thresholding
    PreProcessedImage = bw;
      % SHOW CALCULATIONS:
    if SHOW_CALC
      ScreenSize = get(0,'ScreenSize');
      figure('Position', [0 0 ScreenSize(3)/3  ScreenSize(4)/2]);
      subplot(1,2,1), imagesc(img), title(sprintf('Original (%i)', ImageNum))
      subplot(1,2,2), imagesc(bw), title('Contrast-limited adaptive histogram equalization')
      for i = 1:2, subplot(1,2,i), axis tight ,axis equal,  end
    end
  case 'watershed' % watershed  
    % source: 
    % https://se.mathworks.com/company/newsletters/articles/the-watershed-transform-strategies-for-image-segmentation.html
    D = -bwdist(~bw);
    D(~bw) = -inf;
    D2 = imclose(D, ones(2,2));
    PreProcessedImage = watershed(D2);
    
    % SHOW CALCULATIONS:
    if SHOW_CALC
      ScreenSize = get(0,'ScreenSize');
      figure('Position', [0 0 ScreenSize(3)/2  ScreenSize(4)]);
      subplot(2,2,1), imagesc(img), title(sprintf('Original (%i)', ImageNum))
      subplot(2,2,2), imagesc(bw), title('Contrast-limited adaptive histogram equalization')
      subplot(2,2,3), imagesc(D2), title('Morphologically open image for watershed transform')
      subplot(2,2,4), imagesc(PreProcessedImage), title('Watershed transform')
      for i = 1:4 
        subplot(2,2,i), axis tight,  axis equal,    
        xticklabels([]), yticklabels([])
      end
    end
end


if nargout < 1, clear PreProcessedImage ,end
