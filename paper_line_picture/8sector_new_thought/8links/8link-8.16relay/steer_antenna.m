% /*************************************************************************************
%    Intel Corp.
%
%    Project Name:  60 GHz Channel Model
%    File Name:     steer_antenna.m
%    Authors:       A. Lomayev, R. Maslennikov
%    Version:       5.0
%    History:       May 2010 created
%
%  *************************************************************************************
%    Description:
% 
%    function returns amplitudes weighted by gain coefficients calculated
%    for steerable directional antenna model
%
%    [amg] = steer_antenna(am,el,hpbw)
%
%    Inputs:
%
%       1. am   - array of input amplitudes
%       2. el   - elevation angles array
%       3. hpbw - half-power antenna beam width
%
%    Outputs:
%
%       1. amg  - array of output amplitudes weighted by antenna gain coefficients
%
%  *************************************************************************************/
function [amg] = steer_antenna(am,el,hpbw)

G0 = 10*log10((1.6162./sin(hpbw*pi/180/2))^2);
theta_ml = 2.6*hpbw;
G_side = -0.4111.*log(hpbw)-10.597;
G = G0 - 3.01 .* (2.*abs(el)./hpbw).^2;

pos=find(abs(el)>theta_ml/2);
G(pos)=G_side;

g = 10.^(G/20);

amg = am.*(g.');