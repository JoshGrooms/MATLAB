% OBJECT - A universal base class template for all of the MATLAB classes I have written.

%% CHANGELOG
%   Written by Josh Grooms on 20150211
%		20150727:	Implemented the static utility method IsTrue for converting strings into Boolean values.



%% CLASS DEFINITION
classdef (Abstract, HandleCompatible) Entity
    


	%% UNIVERSAL UTILITIES
	methods
		function Save(H, name)
			H.NotYetImplemented();
		end
	end
	
	methods (Static)
		function b = IsTrue(x)
		% ISTRUE - Converts inputs of various types to their equivalent Boolean logical values.
		%
		%	This method attempts to convert any input into a MATLAB logical value, provided that the conversion is possible.
		%	Certain MATLAB programs (in particular the graphics system) have made use of alternative values that behave just
		%	like Booleans, which introduces unnecessary complexity and confusion when using such systems. Some of my
		%	custom-written code does away with this extra syntax and instead translates such values to actual Booleans. The
		%	functionality coded here performs the necessary translation.
		%
		%	ISTRUE is mostly intended to operate on English language words, but will in theory work with any type of input.
		%	Word strings to be converted are tested for membership (case insensitive) with a library of truth values that
		%	include:
		%
		%		'activate', 'active', 'affirmative', 'confirm', 'enable', 'enabled', 'on', 'true', 'yes', 'y'
		%
		%	If a string is found to be a member of this set, then a logical TRUE value is returned. Otherwise, the input is
		%	converted to a logical FALSE value. Cell arrays of strings are tested element-by-element, and the output of
		%	this method will be a Boolean array of equivalent size.
		%
		%	Input types other than strings are converted by calling the LOGICAL function. Thus, for supported native types
		%	and any 3rd party types that implement a LOGICAL conversion method, ISTRUE should successfully perform the
		%	translation. However, inputting unsupported types to this method will result in conversion errors generated by
		%	the LOGICAL function.
		%
		%	SYNTAX:
		%		b = Entity.IsTrue(x)
		%
		%	OUTPUT:
		%		b:		BOOLEAN or [ BOOLEANS ]
		%				A Boolean or array of Booleans that is of the same size and dimensionality as the input. Output
		%				values correspond directly with inputs and will take on TRUE values when inputs are recognized as
		%				belonging to a set of truth values or when they can be natively converted to TRUE using the
		%				LOGICAL function. Otherwise, FALSE values will be returned.
		%
		%	INPUT:
		%		x:		STRING or { STRINGS } or ANYTHING
		%				Technically, inputs of any type may be supplied to this function. However, ISTRUE is primarily
		%				intended to work with a string or a cell array of strings that can be translated into Booleans. 
		%
		%	See also: istrue, logical
			
			truths = { 'activate', 'active', 'affirmative', 'confirm', 'enable', 'enabled', 'on', 'true', 'yes', 'y' };
			
			if islogical(x)
				b = x;
			elseif ischar(x)
				b = ismember(lower(x), truths);
			elseif iscell(x)
				b = cellfun(@Entity.IsTrue, x);
			else
				b = logical(x);
			end
		end
	end
	
	
    
    %% ERROR HANDLING
    methods (Hidden, Access = protected)
        function AssertSingleObject(H)
        % ASSERTSINGLEOBJECT - Throws a standardized exception if an array of multiple objects is detected.
            if (numel(H) > 1)
                fname = dbstack(1);
                throwAsCaller(Object.MultipleObjectException(inputname(1), fname.name));
            end
        end
        function AssertMultipleObjects(H)
		% ASSERTMULTIPLEOBJECTS - Throws a standardized exception if a single object is illegally detected.
            if (numel(H) < 2)
                fname = dbstack(1);
                throwAsCaller(Object.SingleObjectException(inputname(1), fname.name));
            end
        end
        function NotYetImplemented(~)
        % NOTYETIMPLEMENTED - Throws a standardized exception to indicate that functionality has not yet been implemented.
            fname = dbstack(1);
            throwAsCaller(Object.NotImplementedException(fname.name));
		end
    end
    
    methods (Hidden, Static, Access = protected)
        function E = MultipleObjectException(vname, fname)
        % MULTIPLEOBJECTEXCEPTION - Constructs a standard exception to be thrown when illegal object arrays are detected.
        %
        %   INPUTS:
        %       vname:      STRING
        %                   The name of the offending variable in the function workspace.
        %
        %       fname:      STRING
        %                   The name of the function or file in which the problem was detected.
            E = MException('Object:MultipleObjects', 'The argument %s in %s cannot be an array of objects.', vname, fname);
        end
        function E = NotImplementedException(fname)
        % NOTIMPLEMENTEDEXCEPTION - Constructs a standard exception to be thrown when unimplemented functionality is invoked.
            E = MException('Object:NotImplemented', 'The functionality in %s has not yet been implemented.', fname);
        end
        function E = SingleObjectException(vname, fname)
		% SINGLEOBJECTEXCEPTION - Constructs a standard exception to be thrown when object arrays are required.
            E = MException('Object:SingleObject', 'The argument %s in %s must be an array of objects.', vname, fname);
        end
    end
    
    
    
end