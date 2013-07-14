% /*************************************************************************************
%    Intel Corp.
%
%    Project Name:  60 GHz Conference Room Channel Model
%    File Name:     cr_ap_az_1st.m
%    Authors:       A. Lomayev, R. Maslennikov
%    Version:       5.0
%    History:       May 2010 created
%
%  *************************************************************************************
%    Description:
% 
%    function generates azimuth angles in [deg] for 1st order clusters obtained from wall
%    reflections in CR environment for STA-AP subscenario
%
%    [az_small, az_large] = cr_ap_az_1st(size)
%
%    Inputs:
%
%       1. size - target size of returned arrays
%
%    Outputs:
%
%       1. az_small - small azimuth angles array
%       2. az_large - large azimuth angles array
% 
%  *************************************************************************************/
function [az_small, az_large] = cr_ap_az_1st(size)

% sector parameters
a = 135./80;
b = 45;
sigma = 35;

sh_bound = 90;
ln_bound = 180;

for i=1:size
    az_large(i) = 181;
    while (az_large(i) > 180)
        az_small(i) = rand(1,1).*sh_bound;
        az_large(i) = (a.*az_small(i) + b) + sigma.*(rand(1,1));
    end
end