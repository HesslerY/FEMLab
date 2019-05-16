clearvars
clc
close all

addpath('functions')

files = io.parse_gmesh();

[prob_opt, msh_opt] = io.problem_info_ui(files);

if(files.f_changed)
    
    msh.prep_field_data(files, msh_opt)
    slv.calc_A(files, prob_opt)
    slv.eval_A(files)
    
    if(strcmp(prob_opt.class, 'Mstatic'))
        slv.calc_B(files, prob_opt)
    else
        slv.calc_E(files, prob_opt)
    end
    
end

prob_opt.field = def.get_field(prob_opt.class);

slv.calc_W(files, prob_opt, 1:4)

gfx.display(files, prob_opt, 'MSH')
gfx.display(files, prob_opt, prob_opt.field, 'type', 'quiv', 'axeson', false, 'format', '-depsc')
gfx.display(files, prob_opt, prob_opt.field, 'type', 'abstri')
gfx.display(files, prob_opt, prob_opt.field, 'type', 'abs')
gfx.display(files, prob_opt, 'A', 'type', 'abstri')
gfx.display(files, prob_opt, 'A', 'type', 'abs')


% for validation purpose to select circular mesh edge and circular source
% region in the coil examples
% vld.compare_solutions(files, 1000, prob_opt, msh_opt, 1)