% /*************************************************************************************
%    Intel Corp.
%
%    Project Name:  60 GHz Conference Room Channel Model
%    File Name:     cr_sta_el_2nd_sideup.m
%    Authors:       A. Lomayev, R. Maslennikov
%    Version:       5.0
%    History:       May 2010 created
%
%  *************************************************************************************
%    Description:
% 
%    function generates elevation angles in [deg] for 2nd order clusters obtaind
%    from wall-ceiling (ceiling-wall) reflections in CR environment for STA-STA subscenario
%
%    [y] = cr_sta_el_2nd_sideup(size)
%
%    Inputs:
%
%       1. size - target size of returned array
%
%    Outputs:
%
%       1. y - elevation angles array
%
%  *************************************************************************************/
function [y] = cr_sta_el_2nd_sideup(size)

u = rand(1,size);

x = [30,52,63];
z = [0,0.062,0];

a(1) = (z(1)-z(2))./(x(1)-x(2));
b(1) = (z(2).*x(1)-z(1).*x(2))./(x(1)-x(2));

a(2) = (z(2)-z(3))./(x(2)-x(3));
b(2) = (z(3).*x(2)-z(2).*x(3))./(x(2)-x(3));

c(1) = (b(1).^2 - (b(1)+x(1).*a(1)).^2)./(2.*a(1));

umax = ((a(1).*x(2)+b(1)).^2-(b(1).^2-2.*a(1).*c(1)))./(2.*a(1));

c(2) = ((b(2).^2+2.*a(2).*umax)-(x(2).*a(2)+b(2)).^2)./(2.*a(2));

index = find((u >= 0) & (u < umax));
y(index) = (-b(1) + sqrt(b(1).^2 - 2.*a(1).*(c(1)-u(index))))./a(1);
index = find((u >= umax) & (u <= 1));
y(index) = (-b(2) + sqrt(b(2).^2 - 2.*a(2).*(c(2)-u(index))))./a(2);