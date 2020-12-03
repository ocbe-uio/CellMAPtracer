classdef CellsList < handle
  %% CELLSLIST is class to keep list of cells and returns information about them.
  
  properties
    CellNamesList % Cell matrix with names
  end
  
  methods
    function obj = CellsList(CellNames)
      obj.CellNamesList = CellNames;
    end
    
    function show(obj)
      for i = 1:obj.getNumberOfCells(), disp(obj.CellNamesList{i}), end
    end
    
    function TotalNumberOfCells = getNumberOfCells(obj)
      TotalNumberOfCells = numel(obj.CellNamesList);
    end
    
    % Divided cells (parent cells)
    function DividedCells = getDividedCells(obj) % Parent cells
      DividedCells = cellfun(@obj.isCellDivided,obj.CellNamesList);
    end
    
    function dividedCellsNames = getDividedCellsNames(obj)
      dividedCellsNames = obj.CellNamesList(obj.getDividedCells);
    end
    
    % No divided Cells:
    function NoDividedCellsNames = getNoDividedCellsNames(obj)
      NoDividedCellsNames = obj.CellNamesList(~obj.getDividedCells);
    end
    
    % Daughter cells:
    function DaughterCells = getDaughterCells(obj)
      DaughterCells = cellfun(@obj.isCellDaughter,obj.CellNamesList);
    end
  
    function DaughterCellsNames = getDaughterCellsNames(obj)
      DaughterCellsNames = obj.CellNamesList(obj.getDaughterCells);
    end
    
    % Divided-Daughter cells 
    function isDividedDaughterCell = getCellDividedDaughter(obj)
      isDivided = getDividedCells(obj);
      isDaughter = getDaughterCells(obj);
      isDividedDaughterCell = isDivided & isDaughter;
    end
   
    function DividedDaughterCellNames = getCellDividedDaughterNames(obj)
      DividedDaughterCellNames = obj.CellNamesList(obj.getCellDividedDaughter);
    end
   
    function isDivided = isCellDivided(obj, cellname)
      isParent = false(obj.getNumberOfCells(),1);
      for i = 1:obj.getNumberOfCells()
        % For each name check if there is the same name with '1' or '2' in the
        % end. If it is, it means that cell divided:
        % Note: it is possible that user clicked division and then remove
        % one of divided cell. In that case there will be C1 and C1.1
        % Even if after division is only one cell, it is still count as
        % parent: (2020-03-03)
        if any(strcmp(obj.CellNamesList, [cellname '.1'])) ||...
            any(strcmp(obj.CellNamesList, [cellname '.2']))
          isParent(i) = true;
        end
      end
      isDivided = any(isParent);
    end
    
    function removeCell(obj, cellname)
      try
        toRemove = strcmp(obj.CellNamesList, cellname);
        obj.CellNamesList(toRemove) = [];
      catch
      end
    end
  end
  
  methods (Static)
    function isDaughter = isCellDaughter(CellName)
      % Cells which contains '.' in name are doughter cells
      isDaughter = contains(CellName,'.');
    end
  end
end