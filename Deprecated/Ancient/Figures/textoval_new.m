function [t, wd] = textoval_new(x, y, str)
% TEXTOVAL		Draws an oval around text objects
% 
%  [T, WIDTH] = TEXTOVAL(X, Y, STR)
%  [..] = TEXTOVAL(STR)  % Interactive
% 
% Inputs :
%    X, Y : Coordinates
%    TXT  : Strings
% 
% Outputs :
%    T : Object Handles
%    WIDTH : x and y Width of ovals 
%
% Usage Example : [t] = textoval('Visit to Asia?');
% 
% 
% Note     :
% See also TEXTBOX

% Uses :

% Change History :
% Date		Time		Prog	Note
% 15-Jun-1998	10:36 AM	ATC	Created under MATLAB 5.1.0.421

% ATC = Ali Taylan Cemgil,
% SNN - University of Nijmegen, Department of Medical Physics and Biophysics
% e-mail : cemgil@mbfys.kun.nl

%% Modified by Josh Grooms November 16th, 2011

temp = [];

switch nargin,
  case 1,
    str = x;
    if ~isa(str,'cell') str=cellstr(str); end;
    N = length(str);
    wd = zeros(N,2);
    for i=1:N,
      [x, y] = ginput(1);
      tx = text(x,y,str{i},'HorizontalAlignment','center','VerticalAlign','middle');
      [ptc wx wy] = draw_oval(tx, x, y);
      wd(i,:) = [wx wy];
      delete(tx);      
      tx = text(x,y,str{i},'HorizontalAlignment','center','VerticalAlign','middle');
      temp = [temp ; tx ptc];
    end;
  case 3,
    if ~isa(str,'cell') str=cellstr(str); end;
    N = length(str);    
    wd = zeros(N,2);
    for i=1:N,
      tx = text(x(i),y(i),str{i},'HorizontalAlignment','center','VerticalAlign','middle');
     [ptc wx wy] = draw_oval(tx, x(i), y(i));
      wd(i,:) = [wx wy];
      delete(tx);
      tx = text(x(i),y(i),str{i},'HorizontalAlignment','center','VerticalAlign','middle');      
      temp = [temp;  tx ptc];
    end;
  otherwise,
end;  

if nargout>0, t = temp; end;


function [ptc, wx, wy] = draw_oval(tx, x, y)
% Draws an oval box around a text object
      sz = get(tx,'Extent');
      wy = 0.0325;
      wx = 0.0325; 
      ptc = ellipse(x, y, wx, wy);
      set(ptc, 'FaceColor','w');


