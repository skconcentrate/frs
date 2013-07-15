% /*************************************************************************************
%    Intel Corp.
%
%    Project Name:  60 GHz Conference Room Channel Model
%    File Name:     cr_test.m
%    Authors:       A. Lomayev, R. Maslennikov
%    Version:       5.0
%    History:       May 2010 created
%
%  *************************************************************************************
%    Description:
%
%    test
%
%  *************************************************************************************/
function path_loss_db = path_los_simu(dis,angle_,beamwidth)
rand('state',sum(100*clock));
randn('state',sum(100*clock));

[imp_res,path_loss_db] = cr_ch_model(dis,angle_,beamwidth);
