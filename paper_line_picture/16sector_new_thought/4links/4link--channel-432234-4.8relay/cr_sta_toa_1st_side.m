% /*************************************************************************************
%    Intel Corp.
%
%    Project Name:  60 GHz Conference Room Channel Model
%    File Name:     cr_sta_toa_1st_side.m
%    Authors:       A. Lomayev, R. Maslennikov
%    Version:       5.0
%    History:       May 2010 created
%
%  *************************************************************************************
%    Description:
% 
%    function generates times of arrival in [ns] for 1st order clusters obtained
%    from wall reflections in CR environment for STA-STA subscenario
%
%    [y] = cr_sta_toa_1st_side(size)
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
function [y] = cr_sta_toa_1st_side(size)

u = rand(1,size);

x = [4,7,11,23];
z = [0,0.182,0.05,0];

a(1) = (z(1)-z(2))./(x(1)-x(2));
b(1) = (z(2).*x(1)-z(1).*x(2))./(x(1)-x(2));

a(2) = (z(2)-z(3))./(x(2)-x(3));
b(2) = (z(3).*x(2)-z(2).*x(3))./(x(2)-x(3));

a(3) = (z(3)-z(4))./(x(3)-x(4));
b(3) = (z(4).*x(3)-z(3).*x(4))./(x(3)-x(4));

c(1) = (b(1).^2 - (b(1)+x(1).*a(1)).^2)./(2.*a(1));
u1 = ((a(1).*x(2)+b(1)).^2-(b(1).^2-2.*a(1).*c(1)))./(2.*a(1));

c(2) = ((b(2).^2+2.*a(2).*u1)-(x(2).*a(2)+b(2)).^2)./(2.*a(2));
u2 = ((a(2).*x(3)+b(2)).^2-(b(2).^2-2.*a(2).*c(2)))./(2.*a(2));

c(3) = ((b(3).^2+2.*a(3).*u2)-(x(3).*a(3)+b(3)).^2)./(2.*a(3));

index = find((u >= 0) & (u <= u1));
y(index) = (-b(1) + sqrt(b(1).^2 - 2.*a(1).*(c(1)-u(index))))./a(1);
index = find((u > u1) & (u <= u2));
y(index) = (-b(2) + sqrt(b(2).^2 - 2.*a(2).*(c(2)-u(index))))./a(2);
index = find((u > u2) & (u <= 1));
y(index) = (-b(3) + sqrt(b(3).^2 - 2.*a(3).*(c(3)-u(index))))./a(3);