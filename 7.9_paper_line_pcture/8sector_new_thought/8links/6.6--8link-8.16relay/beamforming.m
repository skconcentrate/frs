% /*************************************************************************************
%    Intel Corp.
%
%    Project Name:  60 GHz Channel Model
%    File Name:     beamforming.m
%    Authors:       A. Lomayev, R. Maslennikov
%    Version:       5.0
%    History:       May 2010 created
%
%  *************************************************************************************
%    Description:
%
%    function returns channel impulse response in continuous time
%
%    [imp_res,toa] = beamforming(cfg,ch)
%
%    Inputs:
%
%       1. cfg      - part of configuration structure defining beamforming related parameters
%       2. ch.am    - amplitudes array
%       3. ch.toa   - times of arrival array
%       4. ch.tx_az - TX azimuths array
%       5. ch.tx_el - TX elevations array
%       6. ch.rx_az - RX azimuths array
%       7. ch.rx_el - RX elevations array
%
%    Outputs:
%
%       1. imp_res - channel impulse response
%       2. toa     - times of arrival corresponded to imp_res values
%
%  *************************************************************************************/
% 输入参数为cfg,ch，和角度
% 这个角度是什么？
function [imp_res,toa,path_db] = beamforming(cfg,ch,angle_)

toa = ch.toa;

% conversion of angles to new TX/RX coordinates
% (x-axis along LOS, z-axis normal to horizontal plane, y-axis is added for right tern)
% azimuth angle thi: [0:360], elevation angle theta: [0:180]
ch.tx_az = mod(360 + ch.tx_az,360);
ch.rx_az = mod(360 + ch.rx_az,360);
ch.tx_el = 90 - ch.tx_el;
ch.rx_el = 90 - ch.rx_el;
rot_angle = angle_;

% select beamforming algorithm
switch (cfg.bf_alg)
    case 0, % max power ray algorithm
        imp_res = max_power_ray(cfg,ch);
        
    case 1, % max power exhaustive search algorithm
        switch (cfg.matlab_c) % select Matlab/C function
            case 0,
                imp_res = exhaustive_search(cfg,ch);
            case 1,
                imp_res = exhaustive_search_mex(cfg,ch);
                imp_res = imp_res.';
            otherwise,
                error('Prohibited value of "cfg.matlab_c" parameter');
        end
    case 2,
            [imp_res,path_power] = steer_imp(cfg,ch,rot_angle,97.7403,0,0);
            % 91.0624 78.3859  106.2602 is the best elebation angle for 
            % 15,30,60 respectively  97.7403  22.5 degree
            path_db = 10*log10(path_power);   
    otherwise,
        error('Prohibited value of "cfg.bf_alg" parameter');
end

% sort impulse response values
[toa,ind_sort] = sort(toa);
imp_res = imp_res(ind_sort);