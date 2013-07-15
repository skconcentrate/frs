% /*************************************************************************************
%    Intel Corp.
%
%    Project Name:  60 GHz Conference Room Channel Model
%    File Name:     cr_ap_toa_1st.m
%    Authors:       A. Lomayev, R. Maslennikov
%    Version:       5.0
%    History:       May 2010 created
%
%  *************************************************************************************
%    Description:
% 
%    function generates times of arrival in [ns] for 1st order clusters obtained
%    from wall reflections in CR environment for STA-AP subscenario
%
%    [y] = cr_ap_toa_1st(size)
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
function y = cr_ap_toa_1st(size)

u = rand(1,size);

x = [1,3,5,7,18,20];
z = [72,78875,68246,7434,8949,0]./400000;

a(1) = (z(1)-z(2))./(x(1)-x(2));
b(1) = (z(2).*x(1)-z(1).*x(2))./(x(1)-x(2));

a(2) = (z(2)-z(3))./(x(2)-x(3));
b(2) = (z(3).*x(2)-z(2).*x(3))./(x(2)-x(3));

a(3) = (z(3)-z(4))./(x(3)-x(4));
b(3) = (z(4).*x(3)-z(3).*x(4))./(x(3)-x(4));

a(4) = (z(4)-z(5))./(x(4)-x(5));
b(4) = (z(5).*x(4)-z(4).*x(5))./(x(4)-x(5));

a(5) = (z(5)-z(6))./(x(5)-x(6));
b(5) = (z(6).*x(5)-z(5).*x(6))./(x(5)-x(6));


c(1) = -(a(1)./2).*(x(1).^2) - b(1).*x(1);
u1 = (a(1)./2).*(x(2).^2) + b(1).*x(2) + c(1);

c(2) = u1 - (a(2)./2).*(x(2).^2) - b(2).*x(2);
u2 = (a(2)./2).*(x(3).^2) + b(2).*x(3) + c(2);

c(3) = u2 - (a(3)./2).*(x(3).^2) - b(3).*x(3);
u3 = (a(3)./2).*(x(4).^2) + b(3).*x(4) + c(3);

c(4) = u3 - (a(4)./2).*(x(4).^2) - b(4).*x(4);
u4 = (a(4)./2).*(x(5).^2) + b(4).*x(5) + c(4);

c(5) = u4 - (a(5)./2).*(x(5).^2) - b(5).*x(5);

index = find((u >= 0) & (u <= u1));
y(index) = (-b(1) + sqrt(b(1).^2 - 2.*a(1).*(c(1)-u(index))))./a(1);
index = find((u > u1) & (u <= u2));
y(index) = (-b(2) + sqrt(b(2).^2 - 2.*a(2).*(c(2)-u(index))))./a(2);
index = find((u > u2) & (u <= u3));
y(index) = (-b(3) + sqrt(b(3).^2 - 2.*a(3).*(c(3)-u(index))))./a(3);
index = find((u > u3) & (u <= u4));
y(index) = (-b(4) + sqrt(b(4).^2 - 2.*a(4).*(c(4)-u(index))))./a(4);
index = find((u > u4) & (u <= 1));
y(index) = (-b(5) + sqrt(b(5).^2 - 2.*a(5).*(c(5)-u(index))))./a(5);