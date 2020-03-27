function [MultiTiffMatrix, tiffinfo] = loadmultitif(FullFileName)
%% LOADMULTITIF - loads multitiff image.
% INPUTS:
% FullFileName [string] - full path to *tif file
% OUTPUTS:
%  MultiTiffMatrix - 3D matrix with all images loaded from multitiff, [hight x width x nPages]
%  tiffinfo - Struct with metadata of each image from multitiff,example:
%   80×1 struct array with fields:
%     Filename
%     FileModDate
%     FileSize
%     Format
%     FormatVersion
%     Width ...
% EXAMPLE:
% [A, tiffinfo] = loadmultitif('Map-C6.tif')
% HISTORY:
% 2016-10-11 Kamil Antos base on:
% https://blogs.mathworks.com/steve/2009/04/02/matlab-r2009a-imread-and-multipage-tiffs/

tiffinfo = imfinfo(FullFileName);
num_images = numel(tiffinfo);
width = unique(cat(1, tiffinfo.Width));
hight = unique(cat(1, tiffinfo.Height));

% It is good to initialize big matrixes, but for some computers Matlab
% crushes here even if there is enough memory:
try
switch  tiffinfo(1).BitDepth
  case 8, MultiTiffMatrix  = uint8(zeros(hight,width, num_images));
  case 16,MultiTiffMatrix  = uint16(zeros(hight,width, num_images));
  otherwise
    MultiTiffMatrix = zeros(hight,width, num_images);
end
catch me
  fprintf('%s >> %s', mfilename, me.identifier);
end

% Load multitiff
[~, tiffFileName , ~] = fileparts(FullFileName);
tiffFileName = strrep(tiffFileName, '_', ' ');
f = waitbar(0, ['Loading Tiff Image: ', tiffFileName], 'Name',getVer());

try
  for k = 1:num_images
    if rem(k, 10) == 0
     waitbar(k/num_images,f, ['Loading Tiff Image: ', tiffFileName]);
    end
    MultiTiffMatrix(:,:,k) = imread(FullFileName, k);
  end
catch me
  error_handle = errordlg(sprintf('Problem with loading tiff file \n %s', me.identifier));
end
delete(f)

% Close warnings, errors and waitbars:
if exist('error_handle', 'var')
  if isvalid(error_handle), delete(error_handle), end
end

