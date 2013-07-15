% 输入参数为：
%     cfg：场景配置信息
%     ch：信道脉冲响应
%     tx_az_rot：发射端水平旋转角度
%     tx_el_rot：发射端仰角旋转角度
%     rx_az_rot：接收端水平旋转角度
%     rx_el_rot：接收端仰角旋转角度
function [imp_res,power_rx] = steer_imp(cfg,ch,tx_az_rot,tx_el_rot,rx_az_rot,rx_el_rot)

% space filtering   
% TX antenna gain
am_ch = ch.am;
ch_gain = sum(abs(am_ch).^2);
ch_gain_db = 10*log10(ch_gain);
% display(ch_gain_db)
am_tx = ant_gain(cfg.tx_ant_type, cfg.tx_hpbw, ch.am, ch.tx_az, ch.tx_el, tx_az_rot, tx_el_rot);
       
% RX antenna gain
am_rx = ant_gain(cfg.rx_ant_type, cfg.rx_hpbw, am_tx, ch.rx_az, ch.rx_el, rx_az_rot, rx_el_rot);
rot_angle_now = tx_el_rot;
power_rx = sum(abs(am_rx).^2);
power_rx_db = 10*log10(power_rx);
imp_res = am_rx;
% display(rot_angle_now)
% display(power_rx)
% display(power_rx_db)
