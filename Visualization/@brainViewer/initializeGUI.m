function initializeGUI(brainData)
%INITIALIZEGUI
%
%   Written by Josh Grooms on 20131208


%% Initialize GUI Elements
% Set up a settings drop-down menu
brainData.Menus.Settings.Main = uimenu(brainData.FigureHandle, 'Label', 'Settings');

% Set up a toggle for anatomical direction labels
brainData.Menus.Settings.DirectionLabels = uimenu(brainData.Menus.Settings.Main,...
    'Label', 'Direction Labels',...
    'Callback', @(src, evt) brainData.toggleDirectionLabels(src, evt));

% Set up & populate a menu for changing anatomical brain renderings
brainData.Menus.Settings.Render.Main = uimenu(brainData.Menus.Settings.Main, 'Label', 'Brain Rendering');
brainOpts = {'Colin', 'MNI', 'MNIHD'};
for a = 1:length(brainOpts)
    brainData.Menus.Settings.Render.(brainOpts{a}) = uimenu(brainData.Menus.Settings.Render.Main,...
        'Label', brainOpts{a},...
        'Callback', @(src, evt) brainData.changeBrain(src, evt));
end
set(brainData.Menus.Settings.Render.(brainData.AnatomicalBrain), 'Checked', 'on');

% Set up & populate a drop-down menu for changing slice planes
brainData.Menus.Settings.SlicePlane.Main = uimenu(brainData.Menus.Settings.Main, 'Label', 'Slice Plane');
planeOpts = {'Coronal', 'Sagittal', 'Transverse'};
for a = 1:length(planeOpts)
    brainData.Menus.Settings.SlicePlane.(planeOpts{a}) = uimenu(brainData.Menus.Settings.SlicePlane.Main,...
        'Label', planeOpts{a},...
        'Callback', @(src, evt) brainData.changeSlicePlane(src, evt));
end
set(brainData.Menus.Settings.SlicePlane.(brainData.SlicePlane), 'Checked', 'on');


%% Adjust Figure & Axes Properties
% Initialize figure callback functions
set(brainData.FigureHandle,...
    'WindowButtonDownFcn', @(src, evt) brainData.clickFcn(src, evt),...
    'WindowButtonUpFcn', @(src, evt) brainData.releaseFcn(src, evt),...
    'WindowScrollWheelFcn', @(src, evt) brainData.sliceFcn(src, evt));

% Generate a color mapping for the figure
cmap = gray(256);
set(brainData.FigureHandle, 'Colormap', cmap);

% Set up axes to contain the brain model
axesColor = [0 0 0];
axLims = brainData.Parameters.AxisLimits;
brainData.Axes = axes(...
    'Color',                axesColor,...
    'DataAspectRatio',      brainData.Parameters.DataAspectRatio,...
    'DataAspectRatioMode',  'manual',...
    'View',                 [35 30],...
    'XColor',               axesColor,...
    'XLim',                 [1, axLims(1)],...
    'XLimMode',             'manual',...
    'XTick',                [],...
    'YColor',               axesColor,...
    'YLim',                 [1, axLims(2)],...
    'YLimMode',             'manual',...
    'YTick',                [],...
    'ZColor',               axesColor,...
    'ZLim',                 [1 axLims(3)],...
    'ZLimMode',             'manual',...
    'ZTick',                []);


%% Place Anatomical Direction Labels on the Plot
axOffset = 25;
brainData.Text.Directions.Right = text(...
    axLims(1)/2,...
    -axOffset,...
    axLims(3)/2,...
    'Right',...
    'Color', [1 1 1],...
    'FontSize', 16,...
    'FontWeight', 'bold',...
    'Visible', 'off');
brainData.Text.Directions.Left = text(...
    axLims(1)/2,...
    axLims(2) + axOffset,...
    axLims(3)/2,...
    'Left',...
    'Color', [1 1 1],...
    'FontSize', 16,...
    'FontWeight', 'bold',...
    'Visible', 'off');
brainData.Text.Directions.Rostral = text(...
    axLims(1) + axOffset,...
    axLims(2)/2,...
    axLims(3)/2,...
    'Rostral',...
    'Color', [1 1 1],...
    'FontSize', 16,...
    'FontWeight', 'bold',...
    'Visible', 'off');
brainData.Text.Directions.Caudal = text(...
    -axOffset,...
    axLims(2)/2,...
    axLims(3)/2,...
    'Caudal',...
    'Color', [1 1 1],...
    'FontSize', 16,...
    'FontWeight', 'bold',...
    'Visible', 'off');
brainData.Text.Directions.Dorsal = text(...
    axLims(1)/2,...
    axLims(2)/2,...
    axLims(3) + axOffset,...
    'Dorsal',...
    'Color', [1 1 1],...
    'FontSize', 16,...
    'FontWeight', 'bold',...
    'Visible', 'off');
brainData.Text.Directions.Ventral = text(...
    axLims(1)/2,...
    axLims(2)/2,...
    -axOffset,...
    'Ventral',...
    'Color', [1 1 1],...
    'FontSize', 16,...
    'FontWeight', 'bold',...
    'Visible', 'off');


%% Place a Slice Position Indicator on the Window
brainData.Text.Slice.String = uicontrol(brainData.FigureHandle,...
    'Units', 'normalized',...
    'Style', 'text',...
    'BackgroundColor', get(brainData.FigureHandle, 'Color'),...
    'FontUnits', 'points',...
    'FontSize', 25,...
    'ForegroundColor', 'w',...
    'Position', [0.8 0 0.1 0.075],...
    'String', 'Slice: ');
brainData.Text.Slice.Number = uicontrol(brainData.FigureHandle,...
    'Units', 'normalized',...
    'Style', 'text',...
    'BackgroundColor', get(brainData.FigureHandle, 'Color'),...
    'FontUnits', 'points',...
    'FontSize', 25,...
    'FontWeight', 'bold',...
    'ForegroundColor', [0 0.6 1],...
    'Position', [0.9 0 0.1 0.075],...
    'String', num2str(brainData.SlicePosition));
