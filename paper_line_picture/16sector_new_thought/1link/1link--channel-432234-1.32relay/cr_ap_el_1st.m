% /*************************************************************************************
%    Intel Corp.
%
%    Project Name:  60 GHz Conference Room Channel Model
%    File Name:     cr_ap_el_1st.m
%    Authors:       A. Lomayev, R. Maslennikov
%    Version:       5.0
%    History:       May 2010 created
%
%  *************************************************************************************
%    Description:
% 
%    function generates elevation angles in [deg] for 1st order clusters obtained from wall
%    reflections in CR environment for STA-AP subscenario
%
%    [y] = cr_ap_el_1st(size)
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
function y = cr_ap_el_1st(size)

u = rand(1,size);

x = [-52,-37,-22,-13];

a = 1./132;
b = 1./22;
d = 1./44;

c(1) = -a.*x(1);
u1 = a.*x(2) + c(1);

c(2) = u1 - x(2).*b;
u2 = b.*x(3) + c(2);

c(3) = u2 - x(3).*d;

index = find((u >= 0) & (u < u1));
y(index) = (u(index) - c(1))./a;
index = find((u >= u1) & (u <= u2));
y(index) = (u(index) - c(2))./b;
index = find((u >= u2) & (u <= 1));
y(index) = (u(index) - c(3))./d;