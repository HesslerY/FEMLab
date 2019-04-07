function calc_B(files, prob_opt, msh_opt)
% CALC_B - Calculates the magnetic field from the previously calculated
% potentials. First the magnetic field defined in the middle of the
% triangle is calculated and from those the field in the triangle nodes.
%
% Syntax:  calc_B(files, prob_opt)
%
% Inputs:
%    files - struct containing file and result paths
%    prob_opt - struct containing information about the problem ( the
%    problem can be 'planar' or 'axissymetric')
%
% Outputs:
%    none
%
% Other m-files required: calc_tri_B.m, calc_weighted_B.m 
%
% Subfunctions: none
% MAT-files required: None
%
% Author: Eniz Museljic
% email: eniz.m@outlook.com
% Mar 2019


disp('-Calculating magnetic field ...')
tic

npoints = 30;

[xlims,ylims] = msh.get_xy_lims(files);
[X,Y] = msh.get_xy_mesh(msh_opt,xlims,ylims,npoints);

slv.calc_tri_B(files, prob_opt)
slv.calc_tri_point_B(files)
[B, Bx, By] = slv.eval_B(files, X, Y);
save(files.respth, 'B', 'Bx', 'By', 'X', 'Y', '-append')


disp(['  Finished (Elapsed time : ', num2str(toc) ' s)'])