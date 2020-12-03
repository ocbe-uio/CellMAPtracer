function cyclePhase = Geminin_Cdt1(RGB, ~, ~, parameters)
%% Alghorithm:
      % Phase   Red       Green     Blue
      % G1(1)     Presence  Absence
      % S(2)       Presence  Presence
      % G2(3)    Absence   Presence
      
    if nargin < 4
      Minimum_Green_Signal_in_S_phase = 0.1;
      Minimum_Red_Signal_in_S_phase = 0.1;
      Minimal_Signal = 0.1;
    else
      Minimum_Green_Signal_in_S_phase = parameters.Minimum_Green_Signal_in_S_phase;
      Minimum_Red_Signal_in_S_phase   = parameters.Minimum_Red_Signal_in_S_phase;
      Minimal_Signal = parameters.Minimal_Signal;
    end

      cyclePhase = nan(size(RGB,1),1);
      % Apply moving avarage as simplest filtering
      FilteredRGB = movmean(RGB,3,'Endpoints','shrink');
      
      Red   = FilteredRGB(:,1);
      Green = FilteredRGB(:,2);
  
      cyclePhase(Green < Minimal_Signal) = 1; %G1
      cyclePhase(Green > Minimum_Green_Signal_in_S_phase &...
                   Red > Minimum_Red_Signal_in_S_phase)  = 2; % S
       
      cyclePhase(Green > Minimum_Green_Signal_in_S_phase &...
                  Red < Minimum_Red_Signal_in_S_phase)  = 3; % G2      
      
      % G1->S->G2, any other order should be removed:
      c = diff(cyclePhase);
      while any(c<0)
        qq = find(c<0, 1,'First');
        cyclePhase(qq+1) = cyclePhase(qq);
        c = diff(cyclePhase);
      end
        