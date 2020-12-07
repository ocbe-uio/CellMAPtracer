function rgb_normalized = normalize_rgb_vectors(rgb)
% maxRGB = max(rgb, [], 'all'); % or 255
  maxRGB = 255;
  rgb_normalized = rgb/maxRGB;
end