% /*************************************************************************************
%    Intel Corp.
%
%    Project Name:  60 GHz Channel Model
%    File Name:     angles_grid.m
%    Authors:       A. Lomayev, R. Maslennikov
%    Version:       5.0
%    History:       May 2010 created
%
%  *************************************************************************************
%    Description:
%
%    function returns azimuth and elevation angels determining spatial beam
%    positions for suboptimal coverage of spherical sector surface for fixed
%    level of allowed minimum value of antenna gain
%
%    essential assumption is that antenna beam has azimuth symmetry,
%    therefore lines of equal antenna gain are circles
%
%    [az,el] = angles_grid(alpha,sec_bound,psi)
%
%    Inputs:
%
%       1. alpha     - doubled elevation angle in [deg] corresponding to minimum allowed
%       antenna gain level
%       2. sec_bound - elevation angle in [deg] limiting spherical sector
%       3. psi       - minimum allowed elevation overlapping in [deg] between antenna
%       beam elevation angle outside the sector and sector bound
%
%    Outputs:
%
%       1. az - array of azimuth angles 方位角阵列
%       2. el - array of elevation angles 仰角阵列
%
%  *************************************************************************************/
function [az,el] = angles_grid(alpha,sec_bound,psi)

% radian to degree and vice versa conversion constants
d2r = pi./180;
r2d = 180./pi;

% calculation of beta angle
beta = (2.*atan((sqrt(3)./2).*tan((alpha.*d2r)./2))).*r2d;

% initialization
az = [];
el = [];
n = 1;
delta = 1;

% iteration procedure for rows in 60 degree sector coverage
while(delta > 0)
    k = [1:n];
    thi_nk = (n-k).*(60./n);
    theta_nk = double_rot(k.*beta,(n-k).*beta,thi_nk);
    delta = sec_bound - (min(theta_nk(1:end))-alpha./2);
    
    if (delta > 0)
        az = [az,thi_nk];
        el = [el,theta_nk];
    end    
    n = n + 1;
end

% exclude elevations which are not satisfied to minimum allowed overlapping
% with sector bound
index = find((el > sec_bound) & ((sec_bound - (el - alpha./2)) < psi));
el(index) = [];
az(index) = [];

% repetition of 60 degree sector for whole spherical sector
az = [0,az,60+az,120+az,180+az,240+az,300+az];
el = [0,el,el,el,el,el,el];

% double rotation function
function [theta] = double_rot(theta1,theta2,thi)

d2r = pi./180;
r2d = 180./pi;

theta1 = theta1.*d2r;
theta2 = theta2.*d2r;
thi = thi.*d2r;

a = cos(theta2);
b = cos(theta1);
c = sin(theta1).*cos(thi);

det = c.^2+b.^2-a.^2;
index = find(abs(det) < 1e-15);
det(index) = 0;

x = (a.*b-c.*sqrt(det))./(c.^2+b.^2);

theta = acos(x).*r2d;