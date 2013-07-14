% /*************************************************************************************
%    Intel Corp.
%
%    Project Name:  60 GHz Channel Model
%    File Name:     exhaustive_search.m
%    Authors:       A. Lomayev, R. Maslennikov
%    Version:       5.0
%    History:       May 2010 created
%
%  *************************************************************************************
%    Description:
%
%    function performs exhaustive search for TX and RX sides in accordance
%    with TX and RX angles grids
%
%    [imp_res] = exhaustive_search(cfg,ch)
%
%    Inputs:
%
%       1. cfg      - part of configuration structure defining beamforming related parameters
%       2. ch.am    - amplitudes array 幅度阵列
%       3. ch.tx_az - TX azimuths array 传输端水平角度阵列
%       4. ch.tx_el - TX elevations array 仰角角度阵列
%       5. ch.rx_az - RX azimuths array RX水平角度阵列
%       6. ch.rx_el - RX elevations array  RX仰角阵列
%
%    Outputs:
%
%       1. imp_res - channel impulse response in continuous time 连续时间的脉冲响应
%
%  *************************************************************************************/
function [imp_res] = exhaustive_search(cfg,ch)

power_max = 0;
imp_res = ch.am;

% space filtering
% TX search
for i=1:length(cfg.tx_az)
    tx_az_rot = cfg.tx_az(i);
    tx_el_rot = cfg.tx_el(i);
    
    % TX antenna gain
    am_tx = ant_gain(cfg.tx_ant_type, cfg.tx_hpbw, ch.am, ch.tx_az, ch.tx_el, tx_az_rot, tx_el_rot);
    
    % RX search
    for j=1:length(cfg.rx_az)
        rx_az_rot = cfg.rx_az(j);
        rx_el_rot = cfg.rx_el(j);
        
        % RX antenna gain
        am_rx = ant_gain(cfg.rx_ant_type, cfg.rx_hpbw, am_tx, ch.rx_az, ch.rx_el, rx_az_rot, rx_el_rot);
        
        % max power selection
        if (sum(abs(am_rx).^2) > power_max)
            power_max = sum(abs(am_rx).^2);
            imp_res = am_rx;
            max_power_tx_az = tx_az_rot;
            max_power_tx_el = tx_el_rot;      
            max_power_rx_az = rx_az_rot;
            max_power_rx_el = rx_el_rot;
        end
    end
end
display(max_power_tx_az)
display(max_power_tx_el)
display(max_power_rx_az)
display(max_power_rx_el)