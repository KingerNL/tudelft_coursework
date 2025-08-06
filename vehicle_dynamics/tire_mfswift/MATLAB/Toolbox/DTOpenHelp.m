function DTOpenHelp(topicID)
% opens the help file at the location 'topicID'. 
%
% Author: TNO, Leneman, oct 2008
%
% Overloaded: 
% - openHelp without specifying a topicID will open the help file
%    at the first page
%
% Requires:
% - hh.exe, which is part of operating system

[ToolBoxPath, name, ext] = fileparts(which('DTOpenHelp'));
HelpFile = [ToolBoxPath '\..\..\Manuals\MFTyre-MFSwift_Help.chm'];
if exist('topicID', 'var')
    eval(sprintf('dos(''hh.exe -mapid %d %s &'');', topicID, HelpFile));
else
    eval(sprintf('dos(''hh.exe %s &'');', HelpFile));
end
