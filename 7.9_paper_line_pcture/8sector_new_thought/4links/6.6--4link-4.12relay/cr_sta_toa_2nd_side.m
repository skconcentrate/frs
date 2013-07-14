% /*************************************************************************************
%    Intel Corp.
%
%    Project Name:  60 GHz Conference Room Channel Model
%    File Name:     cr_sta_toa_2nd_side.m
%    Authors:       A. Lomayev, R. Maslennikov
%    Version:       5.0
%    History:       May 2010 created
%
%  *************************************************************************************
%    Description:
% 
%    function generates times of arrival in [ns] for 2nd order clusters
%    obtained from wall reflections in CR environment for STA-STA subscenario
%
%    [y] = cr_sta_toa_2nd_side(size)
%
%    Inputs:
%
%       1. size - target size of returned array
%
%    Outputs:
%
%       1. y - times of arrival array
%
%  *************************************************************************************/
function [y] = cr_sta_toa_2nd_side(size)

u = rand(1,size);

x = [10,20,30];

a = 0.08;
b = 0.02;

c(1) = -a.*x(1);
u1 = a.*x(2) + c(1);

c(2) = u1 - x(2).*b;

index = find((u >= 0) & (u < u1));
y(index) = (u(index) - c(1))./a;
index = find((u >= u1) & (u <= 1));
y(index) = (u(index) - c(2))./b;