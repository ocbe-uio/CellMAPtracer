%% CellsList tests
% Tracks mat file which contains list of cells:
load('ExampleData/PIP-FUCCI.tif_Tracks.mat', 'AllTracks');
T = Tracks(AllTracks.Tracks);
CellsListNames = T.getAllTracksNames();

% Create instance:
C = CellsList(CellsListNames);
C.show()

% Call all methods:
isCellDivided = C.getDividedCells();
dividedCellsNames = C.getDividedCellsNames();

isCellDaughter = C.getDaughterCells();
DaughterCellsNames = C.getDaughterCellsNames();

isCellDividedDaughter = C.getCellDividedDaughter();
DividedDaughterCellNames = C.getCellDividedDaughterNames();

AllResults = table(CellsListNames, isCellDivided,...
                    isCellDaughter, isCellDividedDaughter);

NoDividedCellsNames = C.getNoDividedCellsNames();
assert(~any(ismember(dividedCellsNames, NoDividedCellsNames)))

C.removeCell('C12.2.2');


%% Check if number of cells is correct:
C = CellsList({'K1'});
assert(isequal(C.getNumberOfCells,1))
C.show()
C = CellsList({'K1', 'K2'});
assert(isequal(C.getNumberOfCells,2))
C.show()

cprintf('_green', '\n CellsList_tests >> All tests passed! \n') ; 