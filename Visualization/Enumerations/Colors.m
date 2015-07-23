% COLORS - A library of frequenctly used color values.

%% CHANGELOG
%   Written by Josh Grooms on 20150211



%% CLASS DEFINITION
classdef Colors


    
	%% DATA
    properties (Constant)
        
        % Principal Colors
        Black       = Color(0, 0, 0);			% The color black	(RGB = [0, 0, 0]).
        Blue        = Color(0, 0, 1);			% The color blue	(RGB = [0, 0, 1]).
        Cyan        = Color(0, 1, 1);			% The color cyan	(RGB = [0, 1, 1]).
        Gray        = Color(0.5, 0.5, 0.5);		% The color gray	(RGB = [0.5, 0.5, 0.5]).
        Green       = Color(0, 1, 0);			% The color green	(RGB = [0, 1, 0]).
        Magenta     = Color(1, 0, 1);			% The color magenta (RGB = [1, 0, 1]).
		Orange		= Color(1, 0.5, 0);			% The color orange	(RGB = [1, 0.5, 0]).
        Red         = Color(1, 0, 0);			% The color red		(RGB = [1, 0, 0]).
        White       = Color(1, 1, 1);			% The color white	(RGB = [1, 1, 1]).
		Violet		= Color(0.5, 0, 1);			% The color violet	(RGB = [0.5, 0, 1]).
        Yellow      = Color(1, 1, 0);			% The color yellow	(RGB = [1, 1, 0]).
    
        % Others
        VibrantBlue = Color(0, 0.75, 1);		% A vibrant blue color used extensively in my personalized color schemes.
        
	end
        
    
	
end