%All-in-one split color analysis

%Need:
%   - .bin molecule list split into left and right halves (add
%   SplitOneSubFolder to path and run)
%   - standard warp file generated between the two halves as a tform struct

%Usage:
% - give path to standard warp file in Step1_MapCoordinates
% - set parameters for molecule matching and color assignment
% - select left and right .bin file at prompt (note: left file is assumed
%   to be long pass channel of t685lpxr
% - color-assigned .bin file is automatically generated in same path


%add path for dependencies
addpath ../common

Step1_MapCoordinates
IterateMapping_1
Step2_3SplitColorN2




% The MIT License (MIT)
% 
% Copyright (c) 2013 Thomas Park
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.