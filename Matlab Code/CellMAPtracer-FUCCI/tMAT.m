classdef tMAT
    
properties  
    X               % X(r,c), r = 'time', c = replication
    t               % time, default=1:r
end

properties (GetAccess = private) 
    IsSpikes = false;  % if signal seems to be spikes
    IsFreq   = false;  % if signal seems to be frequency plot
end

methods    
    %% PUBLIC METHODS
    %% ... 1. Creating object tMAT (and providing help info on tMAT)
    function obj = tMAT(X, t) 
    % function obj = tMAT(X, t, CIKind, mType)
    %   tMAT is an object primarily intended for illustrating means,
    % medians, population distributions and confidence intervals.
    %   The data is contained in X(r,c) with r=time bins and c=replications;
    % t represents 'time' and is default 1:r.
    %   In addition to utility function to obtain, means, median, SD, SEM, 
    % the main functions of tMAT are 
    %   1. "patch" that plots mean or median and confidence intervals of 
    %       population or central value 
    %   2. "stack" that rescales vectors useful for plotting stacked plots
    %
    % METHODS:
    % >> PLOTTING - "patch":
    % function patch(Color, Rows, Cols, mType, Kind, CI, LineWidth, Alpha)
    %   Creates a plot with a line representing a central value (mean or 
    % median) and a patch corresponding to the confidence interval of either
    % the central value or the population.
    %   The inputs are interpreted in the order shown but above if no 
    % parameter specifier is included. Parameter specificers and valid 
    % values are given below, the defaults in square brackets and options 
    % in curly brackets.
    %  o Alpha: [0.5] {0-1}
    %      Transparency property of patch (0: invisible; 1: full intensity) 
    %  o CI: [95] {0-100}
    %      Confidence interval in percent 
    %  o Color: ['b'] {standard color character or RGB triplet, e.g. [0 0 1]
    %      Patch and line color (i.e., with Alpha=1, the mean or median 
    %      line is not visible)
    %  o Cols: [1:size(X,2)] {any valid columns of X}
    %      Columns in X used for population estimates
    %  o CIKind: ['Population'] {'Population' = 'p', 'm'} 
    %      Kind of confidence interval, that is either the population (with
    %      'p') or - depending on mType - mean or median (with 'm')
    %  o LineWidth: [2] {number or 'none'}
    %      LineWidth of mean or median (depending on mType); use
    %      'none' for excluding line drawing
    %  o mType:  ['mean'] {'mean', 'median' = 'md'}
    %      The 'type' of central value, i.e., mean or median. With 'mean' 
    %      the distribution in each time bin is assumed to be normal and 
    %      confidence intervals (CI) are calculated accordingly. 
    %         With 'median' (or 'md') the population CI is calculated as 
    %      actually observed center range percentages (that is, with CI=50, 
    %      the lower and upper boundaries of the patch correspond to Q1 and 
    %      Q3). The confidence interval of the median is calculated only for 
    %      n>11 and then a normal distribution of the median is assumed.  
    %  o Rows: [1:size(X,1)] {any valid rows of X}
    %      Rows in X used for population estimates
    % 
    % Examples
    % To create a default object (120 rows and 80 cols) and then a default 
    % patch, i.e., transparent blue patch depicting the 95% CI of the 
    % population and a thick line corresponding to the mean value of each 
    % time bin, run 
    %    R = tMAT;  
    %    R.patch; 
    %
    % To create a magenta patch corresponding to the central 95% of the 
    % population and then superimpose a green patch with the CI of the
    % median in each bin:
    %    R.patch('m','mType', 'md'), 
    %    R.patch('g', 'CIKind', 'm', 'mType', 'md')
    %
    % The default matrix R.X intentionally contains NaN for all cells
    % in time bins [1:5 110:120], i.e., the beginning and end. In addition
    % replications [11:70] contains NaN in the time bins [20:30 80:90] and
    % this explains the increased variability in the mean and the increased
    % SEM in these bins. 
    %   Invalid CI results in NaN, e.g., because all cells in a time bin are 
    % NaN or there are too few valid cells which precludes estimation of 
    % the CI of the median. To see an example of this for the median, run 
    % the following code:
    %   close all
    %   clear R, R = tMAT;
    %   R.X([20:30 80:90], 4:76) = NaN;
    %   figure,
    %   subplot(3,1,1)
    %       R.patch;
    %       R.patch('g', 'mType', 'mean', 'CIKind', 'm', 'CI', 96)
    %   	title(sprintf('mean \\pm 2·SD and mean \\pm2·SEM'))
    %    subplot(3,1,2)
    %       R.patch('mType', 'md');
    %       R.patch('g', 'mType', 'median', 'CIKind', 'm')
    %   	title(sprintf('96 percent CI for median and population'))
    %    subplot(3,1,3)
    %       plot(R.t, sum(~isnan(R.X')));
    %   	title('n = Valid columns'); ylim([-5 100])
    %
    % >> PLOTTING - "stack":
    % function [M OrigCols] = stack(Rows, Cols, MinDist, Sort) 
    %   M.stack plots a stack plot.
    %   M = M.stack returns the curves to generate the stack plot but
    %  generates no plot
    %   The parameters are all optional and interpreted in the order shown 
    % above if no parameter specifier is included. Parameter specificers 
    % and valid values are given below, the defaults in square brackets and 
    % options in curly brackets.
    %  o Cols: [1:size(X,2)] {any valid columns of X}
    %      Columns in X used for population estimates
    %  o Rows: [1:size(X,1)] {any valid rows of X}
    %      Rows in X used for population estimates%  o Rows: [0.5] {0-1}
    %  o MinDist [1] {any number}
    %      The minimum distance between stacked plots, i.e., MinDist=1
    %      the curves are separated with a minimum distance of 1% of the
    %      maximum range across all columns
    %  o Sort    [false] {0/1 or false/true} 
    %      If true, the columns are sorted to reduce the total height of
    %      the stacked plot. Perfect minimization is a N!-problem (N=number 
    %      of columns). Instead, starting with column J=1, the column 
    %      closest to J among (J+1):end is put in column 2, the the closest 
    %      to J=2 is put in column 3 and soforth (the computation for 
    %      sorting is thus a N²-problem)
    %  OUTPUTS
    %  o M         - the stacked matrix ready for plotting
    %  o OrigCols  - the original column order in M (changes only with
    %                sorting)
    %
    % Example "stack":
    %   clear all
    %   % Create 3 sinusoids shifted with pi/4 and with added noise:
    %      t = (0:10:3000)/1000; ST = size(t);
    %      for J = 1:3:30, X(:,J) = sin(2*pi*t)+(0.4).*randn(ST); end
    %      for J = 2:3:30, X(:,J) = sin(pi+2*pi*t)+(0.4).*randn(ST); end
    %      for J = 3:3:30, X(:,J) = sin(pi/2+2*pi*t)+(0.4).*randn(ST); end
    %   % Create a tMAT object and load the created sinusoids
    %      T = tMAT(X, t);
    %   % Plot 2 subplots, one 'unsorted' and one 'sorted'
    %      figure
    %      ax(1) = subplot(1,3,1); 
    %      T.stack
    %        title('Default stack plot');
    %      ax(2) = subplot(1,3,2); D = T.stack('Sort', false); 
    %        plot(t,D(:,1:3:30),'b', t,D(:,2:3:30),'g', t,D(:,3:3:30),'r')
    %        title('Unsorted');
    %      ax(3) = subplot(1,3,3); [D] = T.stack('Sort', true); 
    %        plot(t, D(:,1:10),'b', t, D(:,11:20),'g', t, D(:,21:30),'r')
    %        title('Sorted');
    %      linkaxes(ax, 'xy'); xlim([0 3]);
    %
    % 
    % >> PLOTTING - "SED" (smoothed empirical distributions)
    % function [DistPar] = SED(obj, Cols, Rows, DistPar, ColorMap)
    %   M.SED plots a smoothed empirical distribution (SED) representing
    % the probability of observing a specific value in X (on ordinate) at time
    % t (on abscissa).
    %   [DistPar] = M.SED plots a SED and returns the parameter used for
    % calculating the uniform SD of the normal pdf convolved with each
    % observation
    %   The parameters are all optional and interpreted in the order shown 
    % above if no parameter specifier is included. Parameter specificers 
    % and valid values are given below, the defaults in square brackets and 
    % options in curly brackets.
    %  o Cols: [1:size(X,2)] {any valid columns of X}
    %      Columns in X used for population estimates
    %  o Rows: [1:size(X,1)] {any valid rows of X}
    %      Rows in X used for population estimates%  o Rows: [0.5] {0-1}
    %  o DistPar [2/number of columns in X] {any number >0 }
    %      DistPar is used to calculate the SD of the normal distribution 
    %      convolved with each observation: SD = DistPar * YRange where 
    %      YRange is the range of values across all columns.
    %  o ColorMap ['Hot'] {any valid colormap}
    %      The colormap used for illustrating the probability of
    %      observering a particular value at time t
    %  o TightLimits [0.005] {0-1}
    %      Constrains ylim the center (1-2*TightLimits) of the distributions 
    %      in Y 
    %  o Normp [false] {0/1/false/true}
    %      Indicate how to represent the probabilities of the values parallel
    %      with the oridinate. 
    %        true : the probablities are adjusted to that the maximal value 
    %               in each row is 1 
    %        false: the integrated probablity along rows equals 1
    %
    % >> UTILITIES:
    % MEANS (distributions and confidence intervals):
    %    function m = Get_m(obj, r,c)  
    %    function SD = Get_SD(obj, r,c)
    %    function SEM = Get_SEM(obj, r,c)
    % MEDIANS (distributions and confidence intervals):
    %    function md = Get_md(obj, r,c)
    %    function P = Get_Prctile(obj, CI, r,c)
    % PLOT STRUCTURES ('low-level' routines to access mean, medians and 
    %       limits)
    %    function [m_pSD_SD] = mpSD(obj, CI, r, c)
    %    function [m_pSEM_SEM] = mpSEM(obj, CI, r,c)
    %    function [md_pV_V] = mdpPerc(obj, CI, r,c)
    %    function [md_pV_V] = mdpCI(obj, CI, r,c)
    %
    % Examples:
    % To obain the median trajetory across all rows and columns, run:
    %    m = R.Get_m; 
  
    % HISTORY
    % 2014-04-28: First working version (BB Edin, Umeå University)
    % 2014-04-29: Manages NaN (BB Edin, Umeå University)
    % 2014-05-09: Simplified use and parsing input parameters (BB Edin, 
    %             Umeå University)
    % 2014-06-20: Added function stack (BB Edin, Umeå University)
    % 2015-01-18: Ver 3.0: Added function SED (BB Edin, Umeå University)
        
        % if no input parameters use defaults
        if ~exist('X', 'var')
            X = 1+1.1*randn(120, 80);
            X([1:5, 110:120],:) = NaN;
            X([20:30 80:90], 11:70) = NaN;  
            disp('tMAT: WARNING - created default matrix X')
        end
        if ~exist('t', 'var')
            t = 1:size(X,1);
            disp('tMAT: WARNING - created default ''time'' t=1:size(X,1)')
        end 
        obj.X = X;
        if size(t,1) == 1; t = t'; end;
        obj.t = t;
        obj.IsSpikes = max(max(X))==1 && min(min(X))==0&&numel(unique(X(:)));
        if ~obj.IsSpikes 
          dX = diff(X);
          obj.IsFreq   = sum(dX(:) == 0) > 0.90*numel(X(:));
        end
          
    end
    
    %% ... 2. Get_m - get mean
    function m = Get_m(obj, r,c)
        % by default use all rows and columns 
        if ~exist('r', 'var'), r = 1:size(obj.X, 1); end;
        if ~exist('c', 'var'), c = 1:size(obj.X, 2); end;
        m = nanmean(obj.X(r, c),2);
    end
    
    %% ... 3. Get_SD - get SD
    function SD = Get_SD(obj, r,c)
        % by default use all rows and columns
        if ~exist('r', 'var'), r = 1:size(obj.X, 1); end;
        if ~exist('c', 'var'), c = 1:size(obj.X, 2); end;
        SD = nanstd(obj.X(r, c),0,2);
    end
    
    %% ... 4. Get_SEM - get SEM
    function SEM = Get_SEM(obj, r,c)
        % by default use all rows and columns
        if ~exist('r', 'var'), r = 1:size(obj.X, 1); end;
        if ~exist('c', 'var'), c = 1:size(obj.X, 2); end;
        nc = sum(~isnan(obj.X),2);
        SEM = nanstd(obj.X(r, c),0,2)./sqrt(nc);
    end
    
    %% ... 5. Get_md - get median
    function md = Get_md(obj, r,c)
        % by default use all rows and columns
        if ~exist('r', 'var'), r = 1:size(obj.X, 1); end;
        if ~exist('c', 'var'), c = 1:size(obj.X, 2); end;
        md = nanmedian(obj.X(r, c),2);
    end
    
    %% ... 6. Get_Prctile - get percentile
    function P = Get_Prctile(obj, CI, r,c)
        % by default use all rows and columns
        if ~exist('r', 'var'), r = 1:size(obj.X, 1); end;
        if ~exist('c', 'var'), c = 1:size(obj.X, 2); end;
        % by default use default CI = 95%
        if ~exist('CI', 'var'), CI = 95; end;
        P = prctile(obj.X(r,c), CI, 2);
    end
 
    %% Routines to create structures for plotting
    %% ... 1. mpSD - population CI assuming normal distribution
    function [m_pSD_SD] = mpSD(obj, CI, r, c)
    % function [m_pSD_SD] = mpSD(obj, CI, r, c)
    %   Creates a structure for plotting:
    %     m_pSD_SD.m  - mean
    %     m_pSD_SD.pV - polygon that can be fed to Matlab's patch
    %     m_pSD_SD.V  - V(:,1) lower bound; V(:,2) upper bound 
    %   CI (confidence interval) is interpreted as multiples of SD when 
    % <5 otherwise as the central CI percent of the distribution in each 
    % time bin. 
        % by default use all rows and columns
        if ~exist('r', 'var'), r = 1:size(obj.X, 1); end;
        if ~exist('c', 'var'), c = 1:size(obj.X, 2); end;
        % by default use default CI = 1, i.e., +/-1 SD
        if ~exist('CI', 'var'), CI = 1; end;
        m = obj.Get_m(r,c);
        SD = obj.Get_SD(r,c);
        YLH = NaN*ones(numel(r), 2);
        if CI > 4 % Assume alpha in percent
            a = (100-CI)/200;
            for j = 1:numel(m)           
                YLH(j,:) = norminv([a 1-a], [m(j) m(j)], [SD(j) SD(j)]);
            end
        else
            YLH = [m+CI*SD m-CI*SD];
        end     
        T = obj.t(r);
        pV = obj.LOC_CreatePatches(YLH, T, r);
        m_pSD_SD.m = m;
        m_pSD_SD.pV = pV;
        m_pSD_SD.V =YLH; 
    end
    
    %% ... 2. mpSEM - CI of mean
    function [m_pSEM_SEM] = mpSEM(obj, CI, r,c)
    % function [m_pSEM_SEM] = mpSEM(obj, CI, r,c)
    %   Creates a structure for plotting:
    %     m_pSEM_SEM.m  - mean
    %     m_pSEM_SEM.pV - polygon that can be fed to Matlab's patch
    %     m_pSEM_SEM.V  - V(:,1) lower bound; V(:,2) upper bound 
    %   CI (confidence interval) is interpreted as multiples of SEM if <5
    % and otherwise as the central CI percent of the confidence interval of 
    % the mean in each time bin. 
        % by default use all rows and columns
        if ~exist('r', 'var'), r = 1:size(obj.X, 1); end;
        if ~exist('c', 'var'), c = 1:size(obj.X, 2); end;
        % by default use default CI = 1, i.e., +/-1 SEM
        if ~exist('CI', 'var'), CI = 1; end;
        m = obj.Get_m(r,c);
        SEM = obj.Get_SEM(r,c);
        YLH = NaN*ones(numel(m), 2);
        if CI > 4 % Assume CI in percent
            a = (100-CI)/200;
            for j = 1:numel(m)           
                YLH(j,:) = norminv([a 1-a], [m(j) m(j)], [SEM(j) SEM(j)]);
            end
        else
            YLH = [m+CI*SEM m-CI*SEM];
        end    
        T = obj.t(r);
        pV = obj.LOC_CreatePatches(YLH, T, r);
        m_pSEM_SEM.m = m;
        m_pSEM_SEM.pV = pV;
        m_pSEM_SEM.V =YLH;
    end
    
     %% ... 3. mdpPerc - population CI without assuming normal distribution
    function [md_pV_V] = mdpPerc(obj, CI, r,c)
    % function [m_pSD_SD] = mpSD(obj, CI, r, c)
    %   Creates a structure for plotting:
    %     md_pV_V.m  - median
    %     md_pV_V.pV - polygon that can be fed to Matlab's patch
    %     md_pV_V.V  - V(:,1) lower bound; V(:,2) upper bound 
        % by default use all rows and columns
      if ~exist('r', 'var'), r = 1:size(obj.X, 1); end;
      if ~exist('c', 'var'), c = 1:size(obj.X, 2); end;
      % by default use default CI = 95%
      if ~exist('CI', 'var'), CI = 95; end;
      CI = (100-CI)/2;
      YLH = obj.Get_Prctile([CI 100-CI],r,c);
      
      T = obj.t(r);
      pV = obj.LOC_CreatePatches(YLH, T, r);
      md_pV_V.m = obj.Get_md(r, c);
      md_pV_V.pV = pV;
      md_pV_V.V =YLH;
    end
    
    %% ... 4. mdpCI - CI of median
    function [md_pV_V] = mdpCI(obj, CI, r,c)
    % function [md_pV_V] = mdpCI(obj, CI, r,c)
    %   Creates a structure for plotting:
    %     md_pV_V.m  - median
    %     md_pV_V.pV - polygon that can be fed to Matlab's patch
    %     md_pV_V.V  - V(:,1) lower bound; V(:,2) upper bound
    %   CI is the central CI percent of the confidence interval of 
    % the median in each time bin. 
    % by default use all rows and columns
      if ~exist('r', 'var'), r = 1:size(obj.X, 1); end;
      if ~exist('c', 'var'), c = 1:size(obj.X, 2); end;
      % by default use default CI = 95%
      if ~exist('CI', 'var'), CI = 95; end;
      CI = (100-CI)/200;
      C = norminv([CI 1-CI], 0, 1);
      for R = 1:numel(r)
        nc = find(~isnan(obj.X(r(R), c)));
        D = sortrows(obj.X(r(R), c(nc))');
        nc = numel(nc);
        if nc < 12
          YLH(R,1:2) = NaN;
        else
          Limits = round((nc + C*sqrt(nc))/2);
          if Limits(1)>0 && Limits(2)<=nc
            YLH(R,:) = D(Limits)';
          else
            YLH(R,:) = NaN;
          end
        end
      end
      T = obj.t(r);
      pV = obj.LOC_CreatePatches(YLH, T, r);
      md_pV_V.m = obj.Get_md(r, c);
      md_pV_V.pV = pV;
      md_pV_V.V =YLH;
    end

%% MAIN METHODS:
%% ... 1. patch
    function patch(obj, varargin)
      R = obj.tPatchParser(obj.X, varargin);
      if strcmpi(R.mType, 'mean')
        if strcmpi(R.CIKind, 'm')
          D = obj.mpSEM(R.CI, R.Rows, R.Cols);
        else % p or 'Population'
          D = obj.mpSD(R.CI, R.Rows, R.Cols);
        end
      else
        if strcmpi(R.CIKind, 'm')
          D = obj.mdpCI(R.CI, R.Rows, R.Cols);
        else % p or 'Population'
          D = obj.mdpPerc(R.CI, R.Rows, R.Cols);
        end
      end
      CLR = R.Color;
      Alpha = R.Alpha;
      LineWidth = R.LineWidth;
      if isfield(D, 'pSD'), AllY = D.pSD; else AllY = D.pV; end
      for Patch = 1:numel(AllY)
        if ~isfield(AllY,'P'), continue; end
        Y = AllY(Patch).P;
        patch(Y(:,1), Y(:,2), CLR, 'FaceAlpha', Alpha, 'EdgeColor', 'none')
        hold on
      end
      if isnumeric(LineWidth)
        if obj.IsFreq
          stairs(obj.t(R.Rows), D.m, 'Color', CLR, 'LineWidth', LineWidth);
        else
          plot(obj.t(R.Rows), D.m, 'Color', CLR, 'LineWidth', LineWidth);
        end
      end
    end
 

%% ... 2. stack     
    function [OutD, UseCols] = stack(obj, varargin)
      R = obj.tStackParser(obj.X, varargin);
      OptimSort = R.Sort;
      D = obj.X(R.Rows, R.Cols);
      D = D-repmat(nanmean(D,1), size(D, 1), 1);
      if OptimSort==1 && ~obj.IsSpikes
        UseCols = obj.LOC_FindMinimumRange(D);
        D = D(:, UseCols);
      else
        if OptimSort==2 && ~obj.IsSpikes
          UseCols = obj.LOC_FindMinimumRange(D);
          if ~isempty(UseCols)  
            D = D(:, UseCols);
            Nans = ones(size(D,2),2);
            Nans(:,2) = 1:size(D,2);
            for C = 1:size(D,2)
              Nans(C,1) = sum(isnan(D(:,C)));
            end
            Nans = sortrows(Nans);
            Nans = Nans(:,2);
            D = D(:,Nans(end:-1:1));
            cCol = 1:size(D, 2); % KA
          else 
            cCol = [];
            OutD = [];
          end
        end
        UseCols = 1:size(D, 2);
      end;
      D_MaxRange = nanmax(nanmax(D,[],1) - nanmin(D,[],1));
      CheckAllNans = nanmax(D);
      D(:,isnan(CheckAllNans)) = [];
      dD = [zeros(size(D(:,1))) D(:,1:(end-1))-D(:,2:end)]-D_MaxRange*R.MinDist;
      minDiff = cumsum(nanmin(dD, [],1));
      for i = 1:size(D, 2)
        OutD(:,i) = D(:,i)+minDiff(i);
      end
      if nargout < 1
        if obj.IsSpikes
%           SpikesPlot(obj.X, obj.t, 'SpikeColors', R.Color)
          SpikesPlot(obj.X, obj.t, R.Color)
%           SpikesPlot(obj.X, obj.t, 'Middle', 'Color')
          set(gca, 'YTick', []);
        else
          if obj.IsFreq, stairs(obj.t, OutD); else plot(obj.t,OutD); end
        end
        clear OutD UseCols
      end
    end
    
%% ... 3. plot
    function [OutD, UseCols] = plot(obj, Rows, varargin)
      plot(obj.t(Rows), obj.X(Rows,:), varargin{:})
    end
    
%% ... 4. SED (smoothed empirical distribution)    
    function [DistPar] = SED(obj, varargin) 
% function [DistPar] = SED(Cols, Rows, DistPar, ColorMap, TightLimits, Normp)
%     M.SED plots a default smoothed empirical distribution for each row and across
%  all columns.
%     Cols and Rows correspond to columns and rows in X (tMAT.X).
%     DistPar defines the width of the SD of the convolved normal distributions
%  and is by default YRange*2/nCols, i.e., a fraction of the range of values 
%  found in X.
%     ColorMap is the colormap used to render the surface. In addition to
%  the standard Matlab colormaps ('Hot', 'Gray', etc) monochromotic
%  colormaps can be specified by the standard Matlab colors ('b', 'r', etc)
%     TightLimits constrains ylim to the center (1-2*TightLimits) of the
%  distributions in Y and may be useful when there are outliers
%     Normp indicate how to represent the probabilities of the values parallel
%  with the oridinate. 
%       Normp = true : the probablities are adjusted so that the maximal value 
%                      in each row is 1 
%       Normp = false: the integrated probablity along each t equals 1
%
      R = obj.tSEDParser(obj.X, varargin);
      if sum(R.YLim == [-1 -1]) == 2
        [md_pV_V] = obj.mdpPerc(99);
        P = md_pV_V.pV.P;
        R.YLim = [nanmin(nanmin(P(:,2))) nanmax(nanmax(P(:,2)))];
      end
      YRange = linspace(R.YLim(1), R.YLim(2),R.YRes);
      YStep = diff(YRange); YStep = YStep(1);
      if R.UseSD == 0
        UseSD = diff(R.YLim) * 4 / numel(R.Cols);
      elseif R.UseSD < 0
        UseSD = -R.UseSD*diff(R.YLim)/100; % percent of range
      else
        UseSD = R.UseSD;
      end
      YXtreme = R.YLim +0.5*[-UseSD UseSD];
      if UseSD/YStep < 2
        fprintf(2, ...
          sprintf( ...
          'tMAT WARNING: SD of convolved normal distribution is < 2*DeltaY -- Consider increasing DistPar\n',...
          YStep, UseSD))
      end
      ProbTemplate = normpdf(YRange, mean(YRange), UseSD);
      StartCopy = max(-round(numel(YRange)/2)+1,-round(4*UseSD/YStep));
      EndCopy   = min(round(numel(YRange)/2)-1,+round(4*UseSD/YStep));
      ProbTemplate = ProbTemplate(round(numel(YRange)/2) + (StartCopy:EndCopy));
      
      Z = NaN*ones(numel(YRange),numel(obj.t)); 
      
      for t = 1:numel(obj.t)
        CurM = zeros(1,numel(YRange)+numel(StartCopy:EndCopy));
        for C = 1:numel(R.Cols)
          if ~isnan(obj.X(t,C))
            if round((obj.X(t,C)-YRange(1))/YStep)+numel(ProbTemplate) > numel(CurM) ...
               ||  round((obj.X(t,C)-YRange(1))/YStep) < 1
              continue
            end
            TargetWin = -StartCopy + 1 + round((obj.X(t,C)-YRange(1))/YStep) + ...
                        (StartCopy:EndCopy);                        
            CurM(TargetWin) = CurM(TargetWin) + ProbTemplate;
          end
        end
        Z(:,t) = CurM((-StartCopy+1):(end-EndCopy-1))/numel(R.Cols);
      end      
      if R.Normp
        Z = Z./(repmat(nanmax(Z),size(Z,1),1));
      else
        Z = Z./sum(ProbTemplate);
      end
      [X, Y] = meshgrid(obj.t,YRange);
      colormap(obj.LOC_GetColorMap(R.ColorMap));
      surface(X,Y,Z, 'EdgeColor', 'none'); axis tight
      freezeColors; 
      if R.ColorBar, colorbar, cbfreeze; end
    end

   
end  % dynamic methods

%% STATIC METHODS
methods (Static)
  
function CM = LOC_GetColorMap(Color)
  if numel(Color)>1 % Assume a standard colormap
    CM = Color;
  else
    STEPS = 512;
    switch Color
      case 'c'
        CM = [zeros(1,STEPS); 0:(STEPS-1); 0:(STEPS-1)]'/STEPS;
      case 'b'
        CM = [zeros(1,STEPS); (0:(STEPS-1))/2; 0:(STEPS-1)]'/STEPS;
      case 'm'
        CM = [0:(STEPS-1); zeros(1,STEPS); 0:(STEPS-1)]'/STEPS;
      case 'y'
        CM = [0:(STEPS-1); 0:(STEPS-1); zeros(1,STEPS)]'/STEPS;
      case 'r'
        CM = [0:(STEPS-1); zeros(1,STEPS); zeros(1,STEPS)]'/STEPS;
      case 'g'
        CM = [zeros(1,STEPS); 0:(STEPS-1); zeros(1,STEPS)]'/STEPS;
      case 'w'
        CM = [0:(STEPS-1); 0:(STEPS-1); 0:(STEPS-1)]'/STEPS;
      case 'k'
        CM = [(STEPS-1):-1:0; (STEPS-1):-1:0; (STEPS-1):-1:0]'/STEPS;
    end
  end
end

%% ... 1. For compressing stacked plots
function UseCols = LOC_FindMinimumRange(D)
    OrigR = NaN*ones(size(D(:,1)));
    SkipCols = find(all(isnan(D))==1);
    UseCols = 1:size(D, 2);
    D(:,SkipCols) = [];
    UseCols(SkipCols) = [];
    TotCOLS = size(D, 2);
    for J = 1:TotCOLS-1
        dD = repmat(D(:,J),1, TotCOLS-J)-D(:,(J+1):end);
        minDiff = nanmax(dD, [],1);
        if isnan(minDiff), continue, end;
        q = find(nanmin(minDiff) == minDiff); q = q(1);
        if q ~= 1
            % Swap columns
            V = D(:,J+1); D(:,J+1) = D(:,J+q); D(:,J+q) = V;
            C = UseCols(J+1); UseCols(J+1) = UseCols(J+q); UseCols(J+q) = C;
        end
    end    
end

%% ... 2. Parsing inputs to "patch"
function R = tPatchParser(MatX, VGIN)
    Size_X = size(MatX);
    p = inputParser;
    p.addOptional('Color', 'b', @(x)(ischar(x) && numel(x)==1) ...
                  || (numel(x)==3 && max(x)<=1 && min(x)>=0));      
    p.addOptional('Rows', 1:Size_X(1), @(x)isnumeric(x) ... 
                  && sum(round(x)) == sum(x) && max(x)<=Size_X(1) ...
                  && min(x)>0);
    p.addOptional('Cols', 1:Size_X(2), @(x)isnumeric(x) ... 
                  && sum(round(x)) == sum(x) && max(x)<=Size_X(2) ...
                  && min(x)>0);
    p.addOptional('mType', 'mean', @(x)strcmpi(x,'mean') ...
                  || strcmpi(x,'median') || strcmpi(x,'md')); 
    p.addOptional('CIKind', 'Population',  @(x)strcmpi(x,'Population') ...
                  || strcmpi(x,'p') || strcmpi(x,'m')); 
    p.addOptional('CI', 95, @(x)isnumeric(x) && x<=100 && x>=0); 
    p.addOptional('LineWidth', 2, @(x)(isnumeric(x) && numel(x)==1) ...
                  || strcmpi(x,'none'));         
    p.addOptional('Alpha', 0.5, @(x)isnumeric(x) ...
                    && x>=0 && x<=1);                
    p.parse(VGIN{:});
    R = p.Results;
end
  
%% ... 3. Parsing inputs to "stack"
function R = tStackParser(MatX, VGIN)
    Size_X = size(MatX);
    p = inputParser;    
    p.addOptional('Rows', 1:Size_X(1), @(x)isnumeric(x) ... 
                  && sum(round(x)) == sum(x) && max(x)<=Size_X(1) ...
                  && min(x)>0);
    p.addOptional('Cols', 1:Size_X(2), @(x)isnumeric(x) ... 
                  && sum(round(x)) == sum(x) && max(x)<=Size_X(2) ...
                  && min(x)>0);
    p.addOptional('MinDist', 1, @(x)(isnumeric(x) && numel(x)==1)); 
    p.addOptional('Sort', 0, @(x)(islogical(x) || isnumeric(x)) ...
                                && numel(x)==1); 
    p.addOptional('Color', 'b', @(x)(ischar(x) && numel(x)==1) ...
                  || (numel(x)==3 && max(x)<=1 && min(x)>=0)); 
    p.parse(VGIN{:});
    R = p.Results;
    R.MinDist = R.MinDist/100; % MinDist is given in percent 
end
  
%% ... 4. Parsing inputs to "SED"
function R = tSEDParser(MatX, VGIN)
    Size_X = size(MatX);
    p = inputParser;    
    p.addOptional('Cols', 1:Size_X(2), @(x)isnumeric(x) ... 
                  && sum(round(x)) == sum(x) && max(x)<=Size_X(2) ...
                  && min(x)>0);
    p.addOptional('Rows', 1:Size_X(1), @(x)isnumeric(x) ... 
                  && sum(round(x)) == sum(x) && max(x)<=Size_X(1) ...
                  && min(x)>0);
    p.addOptional('Dist', 'N', @(x)(ischar(x))); 
    p.addOptional('UseSD', 0, @(x)(isnumeric(x))); 
    p.addOptional('ColorMap', 'Gray', @(x)( (ischar(x)))); 
    p.addOptional('ColorBar', false, @(x)(islogical(x))); 
    p.addOptional('YLim', [-1 -1], @(x)(isnumeric(x) && numel(x)==2));
    p.addOptional('Normp', false,  @(x)(isnumeric(x) || islogical(x))); 
    p.addOptional('YRes', 100, @(x)(isnumeric(x))); 
    p.parse(VGIN{:});
    R = p.Results;
end

%% ... 4. Creating patches
function pV = LOC_CreatePatches(InYLH, InT, r)
    BinsLeft = true; 
    PatchNumb = 0;
    while numel(InYLH)>0 && isnan(InYLH(1,1)), 
        InYLH(1,:) = []; 
        InT(1) = [];
        r(1) = [];
    end
    if numel(InT) == 0 
        pV(:,:,1) = NaN*ones(5,2);
    else
        while BinsLeft
            PatchNumb = PatchNumb + 1;
            q = find(isnan(InYLH(:,1)));
            if isempty(q)
                YLH = InYLH;
                InYLH = [];
                T = InT(1:numel(YLH(:,1)));
            else
                YLH = InYLH(1:(q(1)-1),:); 
                T = InT(1:(q(1)-1));
                InYLH(1:(q(1)-1),:) = [];
                InT(1:(q(1)-1)) = [];
            end
            LastP = numel(InT);
            pV(PatchNumb).P(:,1) = [T; T(end:-1:1); T(1)];
            pV(PatchNumb).P(:,2) = [YLH(:,1); YLH(end:-1:1,2); YLH(1,1)];
            while numel(InYLH)>0 && isnan(InYLH(1,1)), 
                InYLH(1,:) = []; 
                InT(1) = [];
            end
            BinsLeft = numel(InYLH)>0;
        end
    end
end

%% ... 5. GetVersion
function GetVersion
    VERSION = '3.0';
    fprintf(' tMAT v. %s\n', VERSION);
end    

    
end % static methods

end % classdef
