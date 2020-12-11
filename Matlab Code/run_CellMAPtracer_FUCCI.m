function run_CellMAPtracer_FUCCI(Multitiff_path, Tracks_path)

set_paths

if nargin < 1
  Multitiff_path = '/home/kamil/dev/CellMAPtracer-FUCCI/ExampleData/July7 con A1_2-1.tif';
  Tracks_path = '/home/kamil/dev/CellMAPtracer-FUCCI/ExampleData/Experiment Name July7 con A1_2-1.tif_Tracks.mat';
end
M = MainWindow;
M.set_tiff_and_tracks_from_outside(Multitiff_path, Tracks_path)

