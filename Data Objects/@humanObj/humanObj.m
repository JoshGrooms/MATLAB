classdef (Abstract) humanObj < hgsetget
%HUMANOBJ An abstract class that sets up BOLD, EEG, and relation data objects.
%   This class exists only to provide a backbone for subclasses containing human neuroimaging data. It provides
%   universal properties and methods that should be included in all data objects.

%% CHANGELOG
%   Written by Josh Grooms
%       20130707:   Removed property "ScanDate", which should now be included under the "Acquisition" property.
%       20130708:   Cleaned up commenting that is now outdated
%       20130906:   Renamed "GlobalRegressed" property to "GSR" for consistency.
%       20140711:   Implemented set-access restrictions for several important common properties so that accidentally 
%                   overwriting them is more difficult. Moved the implementation of some common subclass methods here to
%                   make code maintenance a little easier (STORE, TOSTRUCT).
%       20140714:   Implemented methods to upgrade older saved data objects after the class definitions here and in
%                   any subclasses have changed (even if the changes are dramatic). Changed the FILTERED, GSR, and
%                   ZSCORED property names to reflect newer coding standards for clarity (now prepended with IS).
%       20140829:   Reorganized and cleaned up code for this class. Removed implementations for some incomplete methods 
%                   that were going to be difficult to finish.
%       20140902:   Implemented some status properties that take their values from standardized preprocessing parameter 
%                   log entries. Implemented a data cache to store data loaded from MatFiles.
    
%% TODOS
%   - Fix problems with implementation of MATFILE
%       > Expand indexing capabilities inside of .mat files
%       > Implement dynamic data loading to allow seamless data modification without overwriting the original


    %% Properties Common to All Human Data
    
    properties (AbortSet)
        UseMatFileStorage = false;  % Boolean indicating whether MatFiles should be used when storing objects
    end
    
    properties (Dependent)
        
        IsDetrended                 % Boolean indicating whether the data time series has been detrended
        IsFiltered                  % Boolean indicating whether the data time series has been filtered
        IsResampled                 % Boolean indicating whether the data time series has been resampled
        
    end
    
    properties (AbortSet, SetAccess = protected)
    
        % General
        Data                        % The data being stored within the object
        Scan                        % Integer indicating the scan number of a subject's data set
        ScanState                   % String indicating whether data is from resting or task states
        Subject                     % Integer indicating the subject number of the data set
        
        % Acquisition & processing 
        Acquisition                 % All parameters related to the acquisition of raw data
        Bandwidth                   % The high and low-pass cutoffs for the filtered data (in Hz)
        IsGlobalRegressed           % Boolean indicating whether the global signal has been regressed
        IsZScored                   % Boolean indicating whether the data is scaled to zero mean & unit variance
        Preprocessing               % All parameters related to the preprocessing of raw data
        
        % Storage
        SoftwareVersion             % The software version behind the data object construction
        StorageDate                 % Date string of data storage date
        StoragePath                 % Path string indicating where the data is stored
        
    end
    
    properties (Access = protected, Abstract, Hidden)
        DataCache
    end
    
    properties (Abstract, Constant, Hidden)
        LatestVersion
    end

       
    
    %% General Utilities
    methods (Abstract)
        
        paramStruct = Parameters(dataObject)
        varargout   = Plot(dataObject, varargin)
        
    end
    
    
    
    %% Object Conversion Methods
    methods
        function dataStruct = ToStruct(dataObject)
            %TOSTRUCT - Converts human data objects into data structures.
            %   This function is used to convert data objects into data structures. Structures are a value-type in
            %   MATLAB and as such are often easier and more intuitive to deal with in this language. Additionally, they
            %   offer a lot more flexibility in terms of dynamic field creation and removal.
            %
            %   However, there are downsides to this conversion. While structures appear not to suffer from the code
            %   bload that classes can have, most of the quality control benefits inherent to classes are lost. Examples
            %   include: type-safe methods, subclassing, resticted access to fields/methods, and validation of field
            %   modifications. Also, as a reference-type, the correct use of classes can eliminate some significant
            %   computational overhead that is incurred when using a structure (this is especially apparent for large
            %   data sets).
            %
            %   This method exists so that the user may freely work with a human data set without any restrictions or
            %   the need to work with the specialized class methods.
            %
            %   SYNTAX:
            %   dataStruct = ToStruct(dataObject)
            %
            %   OUTPUT:
            %   dataStruct:     STRUCT
            %                   A value-type human data structure in exactly the same apparent format as the inputted
            %                   data object. This structure may be editted freely but can no longer be used with any of
            %                   the methods that are associated with the original object's class.
            %
            %   INPUT:
            %   dataObject:     HUMANOBJ
            %                   A reference-type human data object that is typically generated by preprocessing raw
            %                   data.
            dataStruct(numel(dataObject)) = struct();
            propNames = properties(dataObject(1));
            for a = 1:numel(dataObject)
                for b = 1:length(propNames)
                    dataStruct(a).(propNames{b}) = dataObject(a).(propNames{b});
                end
            end
            dataStruct = reshape(dataStruct, size(dataObject));
        end           % Convert a data object into a data structure
    end
    
    methods (Abstract)
        [dataArray, legend] = ToArray(dataObject, dataStr)      % Pull important data out of a data object
        [dataMatrix, idsNaN] = ToMatrix(dataObject, removeNaNs) % Flatten primary data to a matrix & remove NaNs
    end
    
    methods (Abstract, Static)
        output = loadobj(input)                                 % Control the loading of older data objects
    end
    
    methods (Static, Access = protected)    
        dataStruct = upgrade(dataStruct)                        % Upgrade an older loaded data object
        
        function version = currentSoftwareVersion 
            humanMeta = ?humanObj;
            propNames = {humanMeta.PropertyList.Name}';
            version = humanMeta.PropertyList(strcmpi(propNames, 'LatestVersion')).DefaultValue;
        end
    end
    
    
    
    %% Signal Processing Methods
    methods 
        
        function Detrend(dataObject, order)
            %DETREND - Saves detrending parameters to the data object preprocessing parameter log.
            %
            %   SYNTAX:
            %   Detrend(dataObject, order)
            %
            %   INPUTS:
            %   dataObject:     HUMANOBJ
            %                   A human data object containing time series that were just detrended.
            %
            %   order:          INTEGER
            %                   Any positive integer representing the order of the polynomial used for detrending. 
            %                   EXAMPLES:
            %                       1 - Linear detrend
            %                       2 - Quadratic detrend
            %                       3 - Cubic detrend
            %                       .
            %                       .
            %                       .
            
            dataObject.Preprocessing.Parameters.Detrending = struct(...
                'DetrendOrder', order,...
                'IsDetrended', true);
        end
        function Filter(dataObject, passband, phaseDelay, useZeroPhaseFilter, window, windowLength)
            %FILTER - Saves filtering parameters to the data object preprocessing parameter log.
            %
            %   SYNTAX:
            %   Filter(dataObject, passband, phaseDelay, useZeroPhaseFilter, window, windowLength)
            %
            %   INPUT:
            %   dataObject:             HUMANOBJ
            %                           A human data object containing time series that were just filtered.
            %
            %   OPTIONAL INPUTS:
            %   passband:               [DOUBLE, DOUBLE]
            %                           The passband (in Hertz) that is desired. This is specified as a two-element
            %                           vector in the form [HIGHPASS LOWPASS].
            %
            %   useZeroPhaseFilter:     BOOLEAN
            %                           A Boolean indicating whether or not to use a zero-phase distorting filter. Using
            %                           this kind of filter means that no phase delay was imposed on the data set and
            %                           thus no samples needed to be cropped out.
            %
            %   window:                 STRING
            %                           The name of the window used in filtering of the time series data. This input is
            %                           specified as a string.
            %
            %   windowLength:           INTEGER
            %                           The length of the window (in seconds) for the FIR filter.
            
            dataObject.Preprocessing.Parameters.Filtering = struct(...
                'IsFiltered', true,...
                'Passband', passband,...
                'PhaseDelay', phaseDelay,...
                'Window', window,...
                'WindowLength', windowLength,...
                'ZeroPhaseFiltered', useZeroPhaseFilter);
        end
            
    end
    
    methods (Abstract)
        Preprocess(dataObject, paramStruct)         % Preprocess human data objects from raw data files
        Regress(dataObject, signal)                 % Regress one or more signals from the primary object data
        Resample(dataObject, fs)
        ZScore(dataObject)                          % Z-Score the primary data inside the data object
    end
    
    
    
    %% Universal Methods
    methods
        Store(dataObject, varargin);                    % Store a data object on the hard drive
        
        function AssertSingleObject(dataObject)
            %ASSERTSINGLEOBJECT - Throws an error if an array of multiple data objects is detected.
            if numel(dataObject) > 1
                error('Only one data object may be inputted at a time');
            end
        end
        function LoadData(dataObject)
            %LOADDATA - Loads MATFILE data archives referenced by the data object.
            if isa(dataObject.Data, 'matlab.io.MatFile')
                dataObject.Data = load(dataObject.Data.Properties.Source);
            end
        end 
    end
    
    methods
        function isDetrended    = get.IsDetrended(dataObject)
            isDetrended = dataObject.IsPreprocessed('Detrending', 'IsDetrended');
        end
        function isFiltered     = get.IsFiltered(dataObject)
            isFiltered = dataObject.IsPreprocessed('Filtering', 'IsFiltered');
        end
        function isResampled    = get.IsResampled(dataObject)
            isResampled = dataObject.IsPreprocessed('Resampling', 'IsResampled');
        end
    end
    
    methods (Access = protected)
        function isPreprocessed = IsPreprocessed(dataObject, stageName, statusName)
            isPreprocessed = false;
            if (isfield(dataObject.Preprocessing.Parameters, stageName))
                if (dataObject.Preprocessing.Parameters.(statusName))
                    isPreprocessed = true;
                end
            end
        end
    end
    
    
   
end