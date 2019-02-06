% parsing the input file
clearvars
clc

regions = struct('dim', {}, 'tag', {}, 'name', {});
nodes = struct('x', {}, 'y', {}, 'z', {});
elements = struct('type', {}, 'n_tags',...
    {}, 'tags', {}, 'nodes', {});
tags = {'$MeshFormat', '$PhysicalNames', ...
    '$Nodes', '$Elements'};
parsed_data = struct();

mesh_format = '';

[file_name, file_path] = uigetfile('*.msh', 'Select mesh file');
input_file = [file_path,file_name];
fid = fopen(input_file);

is_parsing = 1;
i_tag = 1;
n_tags = numel(tags);

[line, err] = get_line(fid);
if(strcmp(line, tags{i_tag}) && err == 0)
    mesh_format = get_line(fid);
    end_tag = strrep(tags{i_tag}, '$', '$End');
    while(~strcmp(get_line(fid), end_tag))
    end
    i_tag = i_tag + 1;
end
while(is_parsing)
    line = get_line(fid);
    if(strcmp(line, tags{i_tag}))
        n_items = str2double(get_line(fid));
        val_cell = cell(n_items, 1);
        for i=1:n_items
            val_cell(i) = {get_line(fid)};
        end
        parsed_data(i_tag-1).val_cell = val_cell;
        parsed_data(i_tag-1).n_items = n_items;
        
        end_tag = strrep(tags{i_tag}, '$', '$End');
        while(~strcmp(get_line(fid), end_tag))
        end
    end
    
    i_tag = i_tag + 1; 
    if(i_tag > n_tags), is_parsing = 0; end
    
end

phy_names = parsed_data(1).val_cell; n_regions = parsed_data(1).n_items;
nodes_cell = parsed_data(2).val_cell; n_nodes = parsed_data(2).n_items;
elements_cell = parsed_data(3).val_cell; n_elements = parsed_data(3).n_items;

nodes_mat = cell2mat(nodes_cell);
elements_mat = cell2mat(elements_cell);

for i_region = n_regions:-1:1
    line = strsplit(phy_names{i_region}, ' ');
    regions(i_region).dim = str2double(line{1});
    regions(i_region).tag = str2double(line{2});
    regions(i_region).name = strrep(line{3}, '"', '');
end

for i_node = n_nodes:-1:1
    nodes(i_node).x = nodes_mat(i_node, 2);
    nodes(i_node).y = nodes_mat(i_node, 3);
    nodes(i_node).z = nodes_mat(i_node, 4);
end

for i_elem = n_elements:-1:1
    elements(i_elem).type = elements_mat(i_elem, 2);
    elements(i_elem).n_tags = elements_mat(i_elem, 3);
    i_tags = 3+elements(i_elem).n_tags;
    elements(i_elem).tags = elements_mat(i_elem,...
        4:3+elements(i_elem).n_tags);
    i_end = size(elements_mat, 2) - 2 + elements(i_elem).type;
    elements(i_elem).nodes = elements_mat(i_elem, i_tags+1:i_end);
end

if(exist('results', 'dir') ~= 7), mkdir('results'); end
respth = './results/';
save([respth, strrep(file_name, '.msh', '')], 'regions', 'nodes', 'elements',...
    'n_regions', 'n_nodes', 'n_elements')
clearvars
disp('Finished parsing')