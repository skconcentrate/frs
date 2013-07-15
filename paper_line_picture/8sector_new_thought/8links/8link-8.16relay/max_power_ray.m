% /*************************************************************************************
%    Intel Corp.
%
%    Project Name:  60 GHz Channel Model
%    File Name:     max_power_ray.m
%    Authors:       A. Lomayev, R. Maslennikov
%    Version:       5.0
%    History:       May 2010 created
%
%  *************************************************************************************
%    Description:
%
%    function performs max power ray beamforming
%
%    [imp_res] = max_power_ray(cfg,ch)
%
%    Inputs:
%
%       1. cfg      - part of configuration structure defining beamforming related parameters
%       2. ch.am    - amplitudes array 
%       3. ch.tx_az - TX azimuths array
%       4. ch.tx_el - TX elevations array
%       5. ch.rx_az - RX azimuths array
%       6. ch.rx_el - RX elevations array
%
%    Outputs:
%
%       1. imp_res - channel impulse response in continuous time
%
%  *************************************************************************************/
function [imp_res] = max_power_ray(cfg,ch)

% find the ray with maximum power
[power_max,idx_max] = max(abs(ch.am).^2);

% apply antenna patterns steered along max power ray direction - space
% filtering
% TX side
tx_az_rot = ch.tx_az(idx_max);
tx_el_rot = ch.tx_el(idx_max);
% TX antenna gain
am_tx = ant_gain(cfg.tx_ant_type, cfg.tx_hpbw, ch.am, ch.tx_az, ch.tx_el, tx_az_rot, tx_el_rot);

% RX side
rx_az_rot = ch.rx_az(idx_max);
rx_el_rot = ch.rx_el(idx_max);
% RX antenna gain
am_rx = ant_gain(cfg.rx_ant_type, cfg.rx_hpbw, am_tx, ch.rx_az, ch.rx_el, rx_az_rot, rx_el_rot);

imp_res = am_rx;