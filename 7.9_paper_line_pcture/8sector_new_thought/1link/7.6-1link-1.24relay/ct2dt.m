% /*************************************************************************************
%    Intel Corp.
%
%    Project Name:  60 GHz Channel Model
%    File Name:     ct2dt.m
%    Authors:       A. Lomayev, R. Maslennikov
%    Version:       5.0
%    History:       May 2010 created
%
%  *************************************************************************************
%    Description:
% 
%    function returns channel response due to target sample rate
%
%    [h_dt] = ct2dt(h_ct, t, sample_rate)
%
%    Inputs:
%
%    1. h_ct        - continuous time channel impulse response
%    2. t           - continuous time in [ns]
%    3. sample_rate - sample rate in [GHz]
% 
%    Outputs:
%
%    1. h_dt - discrete time channel impulse response
%
%  *************************************************************************************/
function [h_dt] = ct2dt(h_ct, t, sample_rate)

t_s = 1./sample_rate;

t_0 = t - min(t);

N = round(max(t_0)./t_s) + 1;

h_dt = zeros(1,N);

for ray_ix = 1:length(t_0)
    time_bin = round(t_0(ray_ix)./t_s) + 1;
    h_dt(time_bin) = h_dt(time_bin) + h_ct(ray_ix);
end