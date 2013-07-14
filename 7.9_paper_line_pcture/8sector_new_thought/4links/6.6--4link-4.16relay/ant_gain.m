% /*************************************************************************************
%    Intel Corp.
%
%    Project Name:  60 GHz Channel Model
%    File Name:     ant_gain.m
%    Authors:       A. Lomayev, R. Maslennikov
%    Version:       5.0
%    History:       May 2010 created
%
%  *************************************************************************************
%    Description:
%
%    function returns amplitudes weighted by antenna gain for target antenna space position
%
%    [amg] = ant_gain(ant_type,hpbw,am,az,el,az_rot,el_rot)
%
%    Inputs:
%
%       1. ant_type - antenna type 天线类型
%       2. hpbw     - half-power beamwidth for steerable directional antenna model
%       3. am       - amplitudes array  幅度数组
%       4. az       - TX/RX azimuths array  TX/RX方位角数组
%       5. el       - TX/RX elevations array  TX/RX仰角数组
%       6. az_rot   - azimuth rotation angle of antenna beam  天线波束的水平旋转角度
%       7. el_rot   - elevation rotation angle of antenna beam 天线波束的仰角旋转角度
% 
%    Outputs:
%
%       1. amg - output amplitudes weighted by antenna gain coefficients
%
%  *************************************************************************************/
function [amg] = ant_gain(ant_type,hpbw,am,az,el,az_rot,el_rot)

switch(ant_type)
    case 0, % isotropic radiator
        amg = am;
    case 1, % steerable directional antenna
        [az,el] = basic2rot(az,el,mod(az_rot+90,360),el_rot,0);
        amg = steer_antenna(am,el,hpbw);
end