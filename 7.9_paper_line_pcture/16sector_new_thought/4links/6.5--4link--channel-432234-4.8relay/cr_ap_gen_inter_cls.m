% /*************************************************************************************
%    Intel Corp.
%
%    Project Name:  60 GHz Conference Room Channel Model
%    File Name:     cr_ap_gen_inter_cls.m
%    Authors:       A. Lomayev, R. Maslennikov
%    Version:       5.0
%    History:       May 2010 created
%
%  *************************************************************************************
%    Description:
% 
%    function returns NLOS space-temporal clusters parameters: azimuth angles
%    in [deg] relative to LOS direction for TX/RX and elevation angles, times of arrival
%    in [ns] relative to LOS time for CR environment for STA-AP subscenario
%
%    [cls] = cr_ap_gen_inter_cls(N)
%
%    Inputs:
%
%       1. N - the number of realizations
%
%    Outputs:
%
%        1. cls.toa    - times of arrival array, size 12xN
%        2. cls.tx_az  - TX azimuths array,      size 12xN
%        3. cls.tx_el  - TX elevations array,    size 12xN
%        4. cls.rx_az  - RX azimuths array,      size 12xN
%        5. cls.rx_el  - RX elevations array,    size 12xN
%
%    Row dimension in cls.x array:
%
%        1,2,3,4            - 1st order clusters
%
%        5,6,7,8,9,10,11,12 - 2nd order clusters
%
%  *************************************************************************************/
function [cls] = cr_ap_gen_inter_cls(N)

% time of arrival
cls.toa(1:4,:)  = [cr_ap_toa_1st(N);cr_ap_toa_1st(N);cr_ap_toa_1st(N);cr_ap_toa_1st(N)];
cls.toa(5:12,:) = [cr_ap_toa_2nd(N);cr_ap_toa_2nd(N);cr_ap_toa_2nd(N);cr_ap_toa_2nd(N);cr_ap_toa_2nd(N);cr_ap_toa_2nd(N);cr_ap_toa_2nd(N);cr_ap_toa_2nd(N)];

% tx azimuth

% 1st order
[az_small_p, az_large_p] = cr_ap_az_1st(N);
[az_small_n, az_large_n] = cr_ap_az_1st(N);
cls.tx_az(1:4,:) = [-az_large_n;-az_small_n;az_small_p;az_large_p];

% 2nd order
cls.tx_az(5:8,:) = -180 + 180.*rand(4,N);
cls.tx_az(9:12,:) =   0 + 180.*rand(4,N);

% tx elevation

% 1st order
cls.tx_el(1:4,:)  = [cr_ap_el_1st(N);cr_ap_el_1st(N);cr_ap_el_1st(N);cr_ap_el_1st(N)];
% 2nd order
cls.tx_el(5:12,:) = [cr_ap_el_2nd(N);cr_ap_el_2nd(N);cr_ap_el_2nd(N);cr_ap_el_2nd(N);cr_ap_el_2nd(N);cr_ap_el_2nd(N);cr_ap_el_2nd(N);cr_ap_el_2nd(N)];

% rx azimuth

% 1st order
[az_small_p, az_large_p] = cr_ap_az_1st(N);
[az_small_n, az_large_n] = cr_ap_az_1st(N);
cls.rx_az(1:4,:) = [az_small_p;az_large_p;-az_large_n;-az_small_n];

% 2nd order
cls.rx_az(5:12,:)  = cls.tx_az(5:12,:);
cls.rx_az(5:6,:)   = cls.tx_az(5:6,:) + 180;
cls.rx_az(9:10,:)  = cls.tx_az(9:10,:) - 180;

% rx elevation

% 1st order
cls.rx_el(1:4,:)  = -cls.tx_el(1:4,:);
% 2nd order
cls.rx_el(5:12,:) = -cls.tx_el(5:12,:);