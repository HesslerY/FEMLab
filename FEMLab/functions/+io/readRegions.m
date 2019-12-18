function [regions, nIt] = readRegions(files)
% regions.txt format :
%       %Faces
%           [name] [spec] [material prop] [src prop]
%       %Edges 
%           [name] [spec] [material prop] [src prop]
%
%       where :
%               - spec : [DRB/NRB/SRC/MAT]
%               - J   : Current density
%               - DRB : Dirichlet boundary condition
%               - NRB : Neumann boundary condition
%               - SRC : Source
%               - val : Value of selected DRB/NRB/SRC/MAT
%
%               - material prop : describes the material in question an
%                                 example is eps_r for electrostatic case.
%               - src prop : gives the value of the source property of the
%                             current region 

inputFile = files.regfile;

fid = fopen(inputFile);

regions = struct();
dataParsed = struct();
tags = {'$Edges', '$Faces'};
nIt = zeros(size(tags));
isParsing = 1;
iTag = 1;
nTags = length(tags);

while(isParsing)
    line = io.get_line(fid);
    if(strcmp(line, tags{iTag}))
        nItems = str2double(io.get_line(fid));
        nIt(iTag) = nItems;
        cValues = cell(nItems, 1);
        for i=1:nItems
            cValues(i) = {io.get_line(fid)};
        end
        dataParsed(iTag).cValues = cValues;
        dataParsed(iTag).nItems = nItems;
        
        endTag = strrep(tags{iTag}, '$', '$End');
        while(~strcmp(io.get_line(fid), endTag))
        end
    end
    
    iTag = iTag + 1;
    if(iTag > nTags), isParsing = 0; end
end

iReg = 1;
for iTag = 1:nTags
    for iItem = 1:dataParsed(iTag).nItems
        parts = strsplit(dataParsed(iTag).cValues{iItem});
        regions(iReg).id = str2double(parts{1});
        regions(iReg).name = parts{2};
        regions(iReg).spec = parts{3};
        regions(iReg).specnum = io.mapRegions(parts{3});
        regions(iReg).matProp = str2double(parts{4});
        regions(iReg).srcProp = str2double(parts{5});
        iReg = iReg + 1;
    end
end

fclose(fid);



