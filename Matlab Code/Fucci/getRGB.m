  function [R,G,B] = getRGB(img)
      if ndims(img) == 2 %#ok<ISMAT>
        R = img;
        G = img;
        B = img;
      else
        R = img(:,:,1);
        G = img(:,:,2);
        B = img(:,:,3);
      end
  end