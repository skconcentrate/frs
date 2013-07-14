% /*************************************************************************************
%    Intel Corp.
%
%    Project Name:  60 GHz Conference Room Channel Model
%    File Name:     cr_sta_gen_inter_cls.m
%    Authors:       A. Lomayev, R. Maslennikov
%    Version:       5.0
%    History:       May 2010 created
%
%  *************************************************************************************
%    Description:
% 
%    function returns NLOS space-temporal clusters parameters: azimuth/elevation angles
%    in [deg] relative to LOS direction for TX/RX, times of arrival in [ns] relative
%    to LOS time for CR environment for STA-STA subscenario
%
%    [cls] = cr_sta_gen_inter_cls(N)
%
%    Inputs:
%
%       1. N - the number of realizations
%
%    Outputs:
%
%        1. cls.toa   - times of arrival array, size 17xN
%        2. cls.tx_az - TX azimuths array,      size 17xN
%        3. cls.tx_el - TX elevations array,    size 17xN
%        4. cls.rx_az - RX azimuths array,      size 17xN
%        5. cls.rx_el - RX elevations array,    size 17xN
%
%    Row dimension in cls.x array:
%
%    1                       - 1st order ceiling cluster
%    2,3,4,5                 - 1st order wall clusters
%
%    6,7,8,9                 - 2nd order wall-ceiling (ceiling-wall) clusters
%    10,11,12,13,14,15,16,17 - 2nd order wall clusters
%
%  *************************************************************************************/
function [cls] = cr_sta_gen_inter_cls(N)

% time of arrival
cls.toa(1,:)     = cr_sta_toa_1st_up(N);
cls.toa(2:5,:)   = [cr_sta_toa_1st_side(N);cr_sta_toa_1st_side(N);cr_sta_toa_1st_side(N);cr_sta_toa_1st_side(N)];

cls.toa(6:9,:)   = [cr_sta_toa_2nd_sideup(N);cr_sta_toa_2nd_sideup(N);cr_sta_toa_2nd_sideup(N);cr_sta_toa_2nd_sideup(N)];
cls.toa(10:17,:) = [cr_sta_toa_2nd_side(N);cr_sta_toa_2nd_side(N);cr_sta_toa_2nd_side(N);cr_sta_toa_2nd_side(N);cr_sta_toa_2nd_side(N);cr_sta_toa_2nd_side(N);cr_sta_toa_2nd_side(N);cr_sta_toa_2nd_side(N)];

% tx azimuth
cls.tx_az(1,:)   = zeros(1,N);

[az_small_p, az_large_p] = cr_sta_az_1st_side(N);
[az_small_n, az_large_n] = cr_sta_az_1st_side(N);

cls.tx_az(2:5,:) = [-az_large_n;-az_small_n;az_small_p;az_large_p];
cls.tx_az(6:9,:) = [-az_large_n;-az_small_n;az_small_p;az_large_p];

cls.tx_az(10:13,:) = -180 + 180.*rand(4,N);
cls.tx_az(14:17,:) =    0 + 180.*rand(4,N);

% tx elevation
cls.tx_el(1,:) = cr_sta_el_1st_up(N);
cls.tx_el(2:5,:) = zeros(4,N);
cls.tx_el(6:9,:) = [cr_sta_el_2nd_sideup(N);cr_sta_el_2nd_sideup(N);cr_sta_el_2nd_sideup(N);cr_sta_el_2nd_sideup(N)];
cls.tx_el(10:17,:) = zeros(8,N);

% rx azimuth
cls.rx_az(1,:) = zeros(1,N);

[az_small_p, az_large_p] = cr_sta_az_1st_side(N);
[az_small_n, az_large_n] = cr_sta_az_1st_side(N);

cls.rx_az(2:5,:) = [az_small_p;az_large_p;-az_large_n;-az_small_n];
cls.rx_az(6:9,:) = [az_small_p;az_large_p;-az_large_n;-az_small_n];

cls.rx_az(10:17,:) = cls.tx_az(10:17,:);
cls.rx_az(10:11,:) = cls.tx_az(10:11,:) + 180;
cls.rx_az(14:15,:) = cls.tx_az(14:15,:) - 180;

% rx elevation
cls.rx_el(1,:) = cls.tx_el(1,:);
cls.rx_el(2:5,:) = zeros(4,N);
cls.rx_el(6:9,:) = cls.tx_el(6:9,:);
cls.rx_el(10:17,:) = zeros(8,N);