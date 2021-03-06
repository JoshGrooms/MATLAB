classdef BrainPlot < Window
% BRAINPLOT - Displays data in an EEG- or fMRI-style plot or montage of plots.
%   
%	This object displays EEG or MRI data in a montage. It accepts 3-4D MRI images and 2-3D EEG data arrays, as described
%   below. For MRI data, data are displayed as color-coded images. EEG data is displayed as a color-coded scaled spatial
%   layout of EEG electrodes.
%
%   SYNTAX:
%       brainData = BrainPlot(data, 'PropertyName', PropertyValue...)
%
%   OPTIONAL OUTPUT:
%       H:                      BRAINPLOT
%                               A handle to the outputted data object containing all necessary information to create an
%                               image montage. This output is optional.
%
%   INPUTS:
%       data:                   2D, 3D, or 4D ARRAY
%                               The data to be plotted. Data must be the specified format to work with this object. MRI
%                               data can be 2, 3, or 4 dimensional. EEG data can be either 1, 2, or 3 dimensional.
%                               Threshold data by setting insignificant values to NaN.
%
%                               OPTIONS:
%                                   MRI Data:
%                                   [X, Y]          - A single 2D MRI image.
%                                   [X, Y, Z]       - A single 3D MRI image. Slices will be plotted vertically.
%                                   [X, Y, Z, Var1] - 3D MRI images across some variable (e.g. time). Slices will be 
%                                                     plotted vertically and the 4th dimension will be plotted
%                                                     horizontally.
%
%                                   EEG Data:
%                                   [C]             - A vector of data (one point per channel).
%                                   [C, Var1]       - An array of data where each row corresponds to a single channel's 
%                                                     data across some other variable (e.g. time or time shift). The
%                                                     second dimension will be plotted horizontally.
%                                   [C, Var1, Var2] - EEG data across two variables. Each column of the array will be 
%                                                     plotted horizontally and each page will be plotted veritcally.
%
%   OPTIONAL INPUTS:
%       'Anatomical':           3D ARRAY --> [ X, Y, Z ]
%                               An anatomical (T1) 3D image. Input these data in the same spatial format as the
%                               "plotData" parameter, with the same number of slices. The anatomical image will be
%                               displayed on thresholded data in place of values that do not pass significance testing.
%                               DEFAULT: []
%
%       'AxesColor':            STRING or [ DOUBLE, DOUBLE, DOUBLE ] --> [ R, G, B ]
%                               The color of the bounding axes box and all associated text. Acceptable inputs include
%                               standard MATLAB string color specifiers or a vector of RGB values.
%                               DEFAULT: 'w' OR [1 1 1]
%   
%       'CLim':                 [ DOUBLE, DOUBLE ] --> [ MIN, MAX ]
%                               A two-element vector specifying the [MIN MAX] in data units to be mapped to color
%                               extremes. By default, this parameter is calculated automatically using absolute data
%                               extremes.
%                               DEFAULT: [-max(abs(data(:))), max(abs(data(:)))]
%
%       'Color':                STRING or [ DOUBLE DOUBLE DOUBLE ] --> [ R, G, B ]
%                               The background color of the figure and all axes. Acceptable inputs include standard
%                               MATLAB string color specifiers or a vector of RGB values.
%                               DEFAULT: 'k' OR [0 0 0]
%
%       'ColorbarLabel':        STRING
%                               The vertical text label for the colorbar.
%                               DEFAULT: []
%
%       'Colormap':             COLORMAP
%                               The colormap being utilized by the figure.
%                               DEFAULT: jet(256)
%
%       'MajorFontSize':        DOUBLE
%                               The size in font units of the major text elements visible on the montage. This parameter
%                               affects all title-like strings, including x- and y-axis labels, the plot title, and the
%                               colorbar label.
%                               DEFAULT: 25
%
%       'MinorFontSize':        DOUBLE
%                               The size in font units of the minor text elements visible on the montage. This parameter
%                               affects all tick labels, including those for the x- and y-axes as well as the colorbar
%                               tick labels.
%                               DEFAULT: 20
%   
%       'Title':                STRING
%                               The plot title string.
%                               DEFAULT: []
%
%       'XLabel':               STRING
%                               The x-axis label string (same as the built-in axes property). Just input the string here
%                               (using "set" or dot-notation) and it will automatically be added to the plot and
%                               colored.
%                               DEFAULT: []
%
%       'XTickLabel':           { STRINGS } or [ DOUBLES ]
%                               The x-axis tick labels (same as the built-in axes property). Just add the array or cell
%                               array of labels to this property (using "set" or dot-notation) and it will be
%                               automatically added to the plot and colored.
%                               DEFAULT: []
%
%       'YLabel':               STRING
%                               The y-axis label string (same as the built-in axes property). Just add the array or cell
%                               array of labels to this property (using "set" or dot-notation) and it will be
%                               automatically added to the plot and colored.
%                               DEFAULT: []
%
%       'YTickLabel':           { STRINGS } or [ DOUBLES ]
%                               The y-axis tick labels (same as the built-in axes property). Just add the array or cell
%                               array of labels to this property (using "set" or dot-notation) and it will be
%                               automatically added to the plot and colored.
%                               DEFAULT: []
%
%       'Zoom':                 DOUBLE
%                               The fraction of the size of each montage element that should be cropped out. This value
%                               controls how much the image displayed in each element's axes will be zoomed in or out
%                               on. It can be thought of as a percentage of the length and height that will be removed
%                               before being displayed. Inputted values for this argument must be less than 1 since
%                               cropping out the whole image would be pointless. The default value of 0.1 crops 10% of
%                               the image length and height, divided between both sides (i.e. 5% left, 5% right, 5% top, 
%                               5% bottom).
%                               DEFAULT: 0.1

%% DEPENDENCIES
%
%   @Window
%   
%   assignInputs
%   scale2rgb
%   where

%% CHANGELOG
%   Written by Josh Grooms on 20130626
%       20130702:   Implemented MRI plotting capabilities. Also implemented anatomical underlay for thresholded images.
%       20130711:   Implemented a function for save figure images. Added documentation for "CLim" property.
%       20130717:   Set the default window position to screen center.
%       20130809:   Re-wrote the method TOGGLELISTENERS here (removed from WINDOWOBJ). Updated to work with re-written
%                   WINDOWOBJ.
%       20140625:   Removed dependencies on my personal file structure. Updated documentation. Changed some default 
%                   settings of the Store function and implemented file overwrite protection. 
%       20140828:   Major reorganization and update to this class (essentially a rewrite). Updated for compatibility
%                   with major updates to the WINDOW class (formerly WINDOWOBJ). Moved the code for several methods here
%                   to the class definition file and eliminated some superfluous methods altogether. Compeletely
%                   reorganized the class properties and changed the way users/programs interface with them. Implemented
%                   several new features, in particular some relating to plot labeling (e.g. tick labels, titles, etc.).
%       20140829:   Bug fixes for yesterday's class rewrite. Implemented/improved get and set methods for axes tick
%                   labels.
%       20141106:   Implemented the ability to zoom in on montage element images by cropping out some of the image
%                   margins. This is controlled by the new public property Zoom. Set a new default value for this
%                   property of 0.1, which works well for BOLD volumes.
%		20141204:	Updated to use the new input argument assignment system. Changed the constructor to always require a
%					data set input. Implemented a function that recycles an existing montage and overwrites the plotted
%					images using a new inputted data set. Implemented a refresh method for updating displayed data.
%					Removed the line border around the primary axes because this no longer displays correctly. Removed
%					the graphics buffer flush that occurred after plotting to each montage element. This always looked
%					nice to me, but it's bogging down the new HG2 graphics system in R2014b too much to be kept.

%% TODOS
%   - Merge PLOTEEG static method & the separate EEGMAP function.
%   - Make axis tick labels that can be rotated & more finely controlled.
%   - Implement variable numbers of axis tick labels



    %% Brain Plot Properties
    
    properties (Dependent)
        AxesColor               % The color of the primary plot axes.
        CLim                    % The [MIN, MAX] data values that are mapped to colormap extremes.
        ColorbarLabel           % A label string for the plot's colorbar.
        Title                   % The title string of the plot.
        XLabel                  % The x-axis label string.
        XTickLabel              % The individual x-axis tick labels.
        YLabel                  % The y-axis label string.
        YTickLabel              % The individual y-axis tick labels.
    end

    properties (AbortSet)
        Anatomical              % A 3D array containing an anatomical brain image (only applies to MRI-type plots).
        MajorFontSize           % The font size (in font units) of major plot text (e.g. titles, axis titles, etc.).
        MinorFontSize           % The font size (in font units) of minor plot text (e.g. axis tick labels).
        Zoom                    % The zoom level or fraction of each montage element's size that has been cropped out.
    end
    
    properties (Access = private, Hidden)
        ElementAspect           % The normalized [WIDTH, HEIGHT] of each montage element.
        ElementSize             % The [WIDTH, HEIGHT] of each montage element in pixels.
        MontageSize             % The [NUMROWS, NUMCOLS] of the whole montage.
        PlotType                % The BrainPlotType enumerator specifying the type of data being displayed.
        XTick                   % The array of tick positions for the primary x-axis.
        YTick                   % The array of tick positions for the primary y-axis.
    end
    
    
    
    %% Constructor Method
    methods
        function H = BrainPlot(plotData, varargin)
        %BRAINPLOT - Constructs a window object & initializes the plotting environment.
		
            % Initialize a window object for displaying the data
            H = H@Window(...
                'MenuBar', 'none',...
                'NumberTitle', 'off',...
                'Position', WindowPositions.CenterCenter,...
                'Size', WindowSizes.FullScreen); drawnow
			
			% Ensure that a numeric data array was inputted
			assert(nargin >= 1, 'Constructing an image montage requires an inputted data set at minimum.');
			assert(isnumeric(plotData), 'Only numeric data arrays may be displayed using BrainPlot');
			
			% Override defaults with any user inputs
			function Defaults	
				Anatomical = [];
				AxesColor = 'k';
				Background = Colors.White;
				CLim = [];
				ColorbarLabel = [];
				Colormap = Colormaps.Jet;
				MajorFontSize = 25;
				MinorFontSize = 20;
				Title = [];
				XLabel = [];
				XTickLabel = [];
				YLabel = [];
				YTickLabel = [];
				Zoom = 0.025;		
			end
			assign(@Defaults, varargin);

			% Determine the type of data based on its dimensionality
			if (size(plotData, 1) == 68)
				DEPRECATED Montage.EEG
				return;
			end
			H.PlotType = BrainPlotTypes.MRI;

			% Construct the montage (ordering of events here is important)
			H.Data = plotData;
			H.InitializePrimaryAxes;
			H.Colorbar = colorbar('EastOutside');
			H.DetermineMontageDimensionality;
			H.CalculateElementSize;
			H.CalculateAxesTickSpacing;
			H.FitPrimaryAxesToMontage;
			H.InitializeMontageAxes;
			
			% Transfer user inputs to object properties
			H.Anatomical = Anatomical;
			H.AxesColor = AxesColor;
			H.Background = Background;
			H.CLim = CLim;
			H.ColorbarLabel = ColorbarLabel;
			H.Colormap = Colormap;
			H.MajorFontSize = MajorFontSize;
			H.MinorFontSize = MinorFontSize;
			H.Title = Title;
			H.XLabel = XLabel;
			H.XTickLabel = XTickLabel;
			H.YLabel = YLabel;
			H.YTickLabel = YTickLabel;
			H.Zoom = Zoom;
			
			H.Plot();
			
        end
    end
    
    
    
    %% Public Methods
    methods
        
        % Store the image
        Store(brainData, varargin)
        
		function Recycle(H, data, title)
		% RECYCLE - Recycles an existing montage object by replacing the plotted data with a new data set.
		%
		%	SYNTAX:
		%		H.Recycle(data)
		%		H.Recycle(data, title)
		%		Recycle(H,...)
		%
		%	INPUTS:
		%		H:			BRAINPLOT
		%					A reference to a single pre-existing BRAINPLOT montage object.
		%
		%		data:		[ NUMERICS ]
		%					A new array of numeric data to be plotted. This array must be the same size as the data
		%					array that was used to construct the original montage (i.e. through the constructor method).
		%					In other words, SIZE(data) must be equal to SIZE(H.DATA).
		%
		%	OPTIONAL INPUT:
		%		title:		STRING
		%					A new title string to be displayed above the montage that will replace any existing title.
		%					If this argument is omitted, the title from the previous montage will remain unchanged.
		%					DEFAULT: H.Title
			if (nargin == 2); title = H.Title; end
			assert(isequal(size(data), size(H.Data)),...
				'Recycling an existing montage requires subsequent data sets to be the same size as the original.');
			H.Data = data;
			H.Title = title;
			H.Plot();
		end
		function Refresh(H)
		% REFRESH - Redraws the plots in each individual montage element using stored data.
		%
		%	This function refreshes the plots across the entire montage, overwritting any existing plots with updated
		%	renderings. REFRESH is useful when changing properties of the figure axes that are required by the
		%	individual plots themselves in order to be displayed properly (e.g. the CLim property). In such cases, the
		%	existing plots must be completely redrawn in order to incorporate those changes. REFRESH uses the montage
		%	object's stored data array to redraw the images.
		%
		%	SYNTAX:
		%		H.Refresh()
		%		Refresh(H)
		%
		%	INPUT:
		%		H:		BRAINPLOT
		%				A reference to a single BrainPlot montage object.
			H.Plot();
		end
		
    end
    
    
    
    %% Get & Set Methods
    methods
        
        % Get methods
        function color  = get.AxesColor(H)
            color = get(H.Axes.Primary, 'XColor');
        end
        function clim   = get.CLim(H)
            clim = get(H.Axes.Primary, 'CLim');
        end
        function clabel = get.ColorbarLabel(H)
            clabel = get(get(H.Colorbar, 'YLabel'), 'String');
        end
        function title  = get.Title(H)
            title = get(get(H.Axes.Primary, 'Title'), 'String');
        end
        function xlabel = get.XLabel(H)
            xlabel = get(get(H.Axes.Primary, 'XLabel'), 'String');
        end
        function xtick  = get.XTickLabel(H)
            xtick = get(H.Axes.Primary, 'XTickLabel');
        end
        function ylabel = get.YLabel(H)
            ylabel = get(get(H.Axes.Primary, 'YLabel'), 'String');
        end
        function ytick  = get.YTickLabel(H)
            ytick = get(H.Axes.Primary, 'YTickLabel');
        end
        
        % Set methods
        function set.AxesColor(H, color)
            set(H.Axes.Primary, 'XColor', color, 'YColor', color);
            set(get(H.Axes.Primary, 'Title'), 'Color', color);
            set(get(H.Axes.Primary, 'XLabel'), 'Color', color);
            set(get(H.Axes.Primary, 'YLabel'), 'Color', color);
            set(get(H.Colorbar, 'YLabel'), 'Color', color);
        end
        function set.CLim(H, clim)
			if (isempty(clim))
				climBound = max(abs(H.Data(:)));
				clim = [-climBound, climBound];
			elseif (length(clim) == 1)
				clim = [-clim, clim];
			end
            set(H.Axes.Primary, 'CLim', clim);
			H.Refresh();
        end
        function set.ColorbarLabel(H, clabel)
            set(get(H.Colorbar, 'YLabel'), 'String', clabel);
        end
        function set.MajorFontSize(H, fsize)
            set(get(H.Colorbar, 'YLabel'), 'FontSize', fsize);
            set(get(H.Axes.Primary, 'Title'), 'FontSize', fsize);
            set(get(H.Axes.Primary, 'XLabel'), 'FontSize', fsize);
            set(get(H.Axes.Primary, 'YLabel'), 'FontSize', fsize);
            H.MajorFontSize = fsize;
        end
        function set.MinorFontSize(H, fsize)
            set(H.Colorbar, 'FontSize', fsize);
            set(H.Axes.Primary, 'FontSize', fsize);
            H.MinorFontSize = fsize;
        end
        function set.Title(H, title)
            set(get(H.Axes.Primary, 'Title'), 'String', title);
        end
        function set.XLabel(H, xlabel)
            set(get(H.Axes.Primary, 'XLabel'), 'String', xlabel);
        end
        function set.XTickLabel(H, tlabels)
            set(H.Axes.Primary, 'XTick', H.XTick, 'XTickLabel', tlabels);
        end
        function set.YLabel(H, ylabel)
            set(get(H.Axes.Primary, 'YLabel'), 'String', ylabel);
        end
        function set.YTickLabel(H, tlabels)
            set(H.Axes.Primary, 'YTick', H.YTick, 'YTickLabel', tlabels);
        end
        function set.Zoom(H, margin)
            
            assert(isscalar(margin) & margin < 1, 'The new element margin must be a scalar less than 0.5 (half the image size).');
            H.Zoom = margin;
            margin = [0, 1] + ([1, -1] .* margin * 0.5);
            for a = 1:numel(H.Axes.Montage)
                set(H.Axes.Montage(a), 'XLim', margin, 'YLim', margin);
            end
        end
    end
    
    
    
    %% Static Methods
    methods (Static)
        
        % Plot a colored spatial map of EEG electrodes
        PlotEEG(A, data, showLabels);
        % Generate fused functional & anatomical images
        fusedImage = FuseImages(boldImage, anatomicalImage, clim)
        
    end
    
    
    
    %% Private Methods
    methods (Access = private)
        
        function CalculateElementSize(H)
        % CALCULATEELEMENTSIZE - Calculates the size of montage elements.
            posAxes = get(H.Axes.Primary, 'Position');
            asize = posAxes(3:4);
            width = asize(1)/H.MontageSize(2);
            height = width * (H.ElementAspect(2) / H.ElementAspect(1));
            if (height * H.MontageSize(1) > asize(2))
                height = asize(2) / H.MontageSize(1);
                width = height * (H.ElementAspect(1) / H.ElementAspect(2));
            end
            H.ElementSize = [width, height];
		end
        function CalculateAxesTickSpacing(H)
        % CALCULATEAXESTICKSPACKING - Determines the spacing between X- & Y-axis ticks.
            xSpacing = 1/H.MontageSize(2);
            ySpacing = 1/H.MontageSize(1);
            xHalfSpacing = 0.5*xSpacing;
            yHalfSpacing = 0.5*ySpacing;
            H.XTick = linspace(xHalfSpacing, 1 - xHalfSpacing, H.MontageSize(2));
            H.YTick = linspace(yHalfSpacing, 1 - yHalfSpacing, H.MontageSize(1));
        end
        function DetermineMontageDimensionality(H)
        % DETERMINEMONTAGEDIMENSIONALITY - Determines montage size [NUMROWS, NUMCOLS] & the aspect ratio of elements.
			switch (H.PlotType) 
				case BrainPlotTypes.EEG
					H.MontageSize = [size(H.Data, 3), size(H.Data, 2)];         % [numRows, numCols]
					H.ElementAspect = [1, 1];                                   % [width, height], square plots
				case BrainPlotTypes.MRI
					H.MontageSize = [size(H.Data, 3), size(H.Data, 4)];         % [numRows, numCols]
					H.ElementAspect = [size(H.Data, 1), size(H.Data, 2)];       % Reversed (MRI data are permuted later)
					H.ElementAspect = H.ElementAspect./max(H.ElementAspect);    % [width, height], scaled to max value
			end
        end
        function FitPrimaryAxesToMontage(H)
        % FITPRIMARYAXESTOMONTAGE - Fits the primary axes to the montage.
            posFig = getpixelposition(H.FigureHandle);
            apos = [0, 0, H.ElementSize .* [H.MontageSize(2) H.MontageSize(1)]];
            apos(1) = (posFig(1) + posFig(3) - apos(3)) / 2;
            apos(2) = (posFig(2) + posFig(4) - apos(4)) / 2;
            set(H.Axes.Primary, 'Position', apos);
        end
        function InitializePrimaryAxes(H)
        % INITIALIZEPRIMARYAXES - Creates axes that contain & label the image montage.
            H.Axes.Primary = axes(...
                'Units', 'pixels',...
                'Box', 'on',...
                'Color', 'none',...
                'Parent', H.FigureHandle,...
                'TickLength', [0 0],...
                'XLim', [0 1],...
                'XTick', [],...
                'YLim', [0 1],...
                'YTick', []);
        end
        function InitializeMontageAxes(H)
        % INITIALIZEMONTAGEAXES - Create an array of axes to serve as the individual montage elements.
            H.Axes.Montage = zeros(H.MontageSize);
            apos = get(H.Axes.Primary, 'Position');
            epos = [0, 0, H.ElementSize];
            for a = 1:H.MontageSize(1)
                for b = 1:H.MontageSize(2)
                    epos(1) = (b - 1) * H.ElementSize(1) + apos(1) - 1;
                    epos(2) = (a - 1) * H.ElementSize(2) + apos(2) + 1;
                    H.Axes.Montage(a, b) = H.NewElement(epos);
                end
            end
            H.Axes.Montage = flipdim(H.Axes.Montage, 1);    % Flipped so ordering starts from the upper left corner
        end
        function Plot(H)
        % PLOT - Plots the inputted data in the image montage.
            switch (H.PlotType)
                % Plot colored EEG electrode spatial maps
                case BrainPlotTypes.EEG
                    for a = 1:H.MontageSize(1)
                        for b = 1:H.MontageSize(2)
%                             BrainPlot.PlotEEG(H.Axes.Montage(a, b), H.Data(:, b, a), false);
                        end
                    end
                
                % Plot colored MRI images
                case BrainPlotTypes.MRI
                    data = permute(H.Data, [2 1 3 4]);
                    data = flipdim(data, 3);
                    
                    if (~isempty(H.Anatomical)); 
                        anatomical = permute(double(H.Anatomical), [2 1 3]);
                        anatomical = flipdim(anatomical, 3);
                    else
                        anatomical = [];
                    end
                    
                    for a = 1:H.MontageSize(1)
                        for b = 1:H.MontageSize(2)
                            currentData = data(:, :, a, b);
                            if isempty(anatomical)
                                currentData = scale2rgb(currentData, 'CLim', H.CLim, 'Colormap', H.Colormap);
                            else
                                currentData = H.FuseImages(currentData, anatomical(:, :, a), H.CLim);
                            end
                            image(...
                                'CData', currentData,...
                                'Parent', H.Axes.Montage(a, b),...
                                'XData', [0, 1],...
                                'YData', [0, 1]);
                        end
                    end       
                    
            end
        end
        
        function A = NewElement(H, position)
        % NEWELEMENT - Creates individual montage element axes at the specified position.
        %
        %   SYNTAX:
        %       A = NewElement(H, position)
        %       A = H.NewElement(position)
        %
        %   OUTPUT:
        %       A:          HANDLE
        %                   A handle to the axes graphics object that is generated by this method.
        %
        %   INPUTS:
        %       H:          BRAINPLOT
        %                   A single BrainPlot object to which a new element should be added.
        %
        %       position:   [ DOUBLE, DOUBLE, DOUBLE, DOUBLE ] --> [ X, Y, WIDTH, HEIGHT ]
        %                   A four-element position-size vector indicating where the new montage element should be
        %                   placed in the figure and how big it should be. Position is specified using the first two
        %                   elements of this vector and is relative to the boundaries of the primary axes. Size is
        %                   specified through the last two elements of this vector.
            A = axes(...
                'Units', 'pixels',...
                'Box', 'off',...
                'CLim', H.CLim,...
                'CLimMode', 'manual',...
                'Color', 'none',...
                'Parent', H.FigureHandle,...
                'Position', position,...
                'XLim', [0, 1],...
                'XTick', [],...
                'YLim', [0, 1],...
                'YTick', []);
        end
        
    end
    
    
    
end