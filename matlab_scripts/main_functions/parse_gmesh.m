function file_name = parse_gmesh()

tags = {'$MeshFormat', '$PhysicalNames', ...
    '$Nodes', '$Elements'};
parsed_data = struct();

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

[regions, nodes, elements] = mat2struct(phy_names, n_regions,...
                nodes_cell, n_nodes, elements_cell, n_elements);

[regions, replace_tags] = separate_regions(regions);
element_r = replace_region_tags(elements, n_elements, replace_tags);
[regparams, regs] = read_settings();

fclose(fid);

if(exist('results', 'dir') ~= 7), mkdir('results'); end
respth = './results/';
save([respth, strrep(file_name, '.msh', '')], 'regions', 'nodes', 'elements',...
    'n_regions', 'n_nodes', 'n_elements', 'element_r', 'regparams', 'regs')

file_name = strrep(file_name, '.msh', '');
disp('Finished parsing')