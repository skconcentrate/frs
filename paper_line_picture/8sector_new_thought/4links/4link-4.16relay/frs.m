clear all;
clc;
% 循环次数
simulateno=100;
channel_times=100;
%sumsta个随机节点，其中2*linkno个作为S和D，其余sumr个作为R
ui_pt=10;   %发送功率
ui_human_radius=0.5;
ui_linkno=4;%链路数目
ui_sumsta=24;%STA数目
ui_sumr=ui_sumsta-2*ui_linkno;%可作为R的数目
ui_bandwith=2000000000;%带宽2GHz
NL=-174 + 10*log10(ui_bandwith);%噪声功率，单位dBm
ui_sumsector=8;%扇区数设为8
ui_theta_l=360/ui_sumsector;%扇区角度值
vec_frs_bestrid=zeros(ui_linkno,simulateno);
vec_ars_bestrid4all_af=zeros(ui_linkno,simulateno);
vec_ars_bestrid4all_df=zeros(ui_linkno,simulateno);
vec_FRS_AF_RESULT=zeros(ui_linkno,simulateno);
vec_FRS_DF_RESULT=zeros(ui_linkno,simulateno);
vec_ARS_AF_RESULT=zeros(ui_linkno,simulateno);
vec_ARS_DF_RESULT=zeros(ui_linkno,simulateno);

for caltimes=1:simulateno
%source矩阵
vec_source=1:ui_linkno;

%destination矩阵
vec_destination=(ui_linkno+1):(2*ui_linkno);

%STA坐标矩阵
locate_node=zeros(2,ui_sumsta);
locate_node(1,:)=rand(1,ui_sumsta)*10;
locate_node(2,:)=rand(1,ui_sumsta)*10;

%距离矩阵
vec_stadistance=zeros(ui_sumsta);
for i_temp=1:ui_sumsta
    for j_temp=1:ui_sumsta
        if (i_temp==j_temp)
            vec_stadistance(i_temp,j_temp)=0;
        else
            vec_stadistance(i_temp,j_temp)=caldistance(locate_node,i_temp,j_temp);
        end
    end
end
clear i_temp;
clear j_temp;

%判断所有S-D间距离要>1，以便human_block可以阻挡S-D，因为human_block的直径是1m
ui_biggerthan1=0;
for i_temp=1:ui_linkno
   if (vec_stadistance(i_temp,i_temp+ui_linkno) < 1)
       ui_biggerthan1=ui_biggerthan1+1;
   end
end
if (ui_biggerthan1 > 0)
    continue;
end

%Block与S和D的距离矩阵:1：linkno；2：d2s；3:d2d
vec_block_location=zeros(3,ui_linkno);
vec_block_location(1,:)=1:ui_linkno;
for i_temp=1:ui_linkno
    ui_block_d2s=unifrnd(0,1)*(vec_stadistance(i_temp,ui_linkno+i_temp)-2*ui_human_radius)+ui_human_radius;
    ui_block_d2d=vec_stadistance(i_temp,ui_linkno+i_temp)-ui_block_d2s;
    if ((ui_block_d2s<0.5) || (ui_block_d2d<0.5))
        disp(sprintf('error!==>ui_block_d2s=%d\tui_block_d2d=%d\n',ui_block_d2s,ui_block_d2d));
    end
    vec_block_location(2,i_temp)=ui_block_d2s;
    vec_block_location(3,i_temp)=ui_block_d2d;
end
clear ui_block_d2s;
clear ui_block_d2d;
clear i_temp;

%Block阻挡S和D的角度大小矩阵：1：linkno；2：r_half_angle_2_s；3:r_half_angle_2_d
vec_block_half_angle=zeros(3,ui_linkno);
vec_block_half_angle(1,:)=1:ui_linkno;
for i_temp=1:ui_linkno
    ui_block_s_half_angle=asin(0.5/vec_block_location(2,i_temp))*180/pi;
    if (ui_block_s_half_angle<0)
        ui_block_s_half_angle=ui_block_s_half_angle+180;
    end
    ui_block_d_half_angle=asin(0.5/vec_block_location(3,i_temp))*180/pi;
    if (ui_block_d_half_angle<0)
        ui_block_d_half_angle=ui_block_d_half_angle+180;
    end
    vec_block_half_angle(2,i_temp)=ui_block_s_half_angle;
    vec_block_half_angle(3,i_temp)=ui_block_d_half_angle;    
end
clear ui_block_s_half_angle;
clear ui_block_d_half_angle;
clear i_temp;
    
%角度矩阵
vec_angle=zeros(ui_sumsta);
for i_temp=1:ui_sumsta
    for j_temp=1:ui_sumsta
        if (i_temp==j_temp)
            vec_angle(i_temp,j_temp)=0;
        else
            vec_angle(i_temp,j_temp)=calangle(locate_node,i_temp,j_temp);
        end
    end
end
clear i_temp;
clear j_temp;

%扇区号矩阵
%vec_sectorid=zeros(ui_sumsta);
vec_sectorid=floor(vec_angle/ui_theta_l)+1;
for i_temp=1:ui_sumsta
    vec_sectorid(i_temp,i_temp)=0;
end
clear i_temp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      FRS(fast relay selection)                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for link_temp=1:ui_linkno
    vec_sectorweight=zeros(1,ui_sumsta);
    
    ui_d_sectorid=vec_sectorid(vec_source(link_temp),vec_destination(link_temp));
    %先靠D所在S的扇区id筛选出可用R集合（+/-1,2）
    ui_right1=ui_d_sectorid+1;
    ui_left1=ui_d_sectorid-1;
    ui_right2=ui_d_sectorid+2;
    ui_left2=ui_d_sectorid-2;
    if (ui_left1<=0)
        ui_left1=ui_left1+ui_sumsector;
    end
    if (ui_left2<=0)
        ui_left2=ui_left2+ui_sumsector;
    end
    if (ui_right1>8)
        ui_right1=rem(ui_right1,ui_sumsector);
    end
    if (ui_right2>8)
        ui_right2=rem(ui_right2,ui_sumsector);
    end
    clear ui_d_sectorid;
    
    %左右1扇区权重0.3，左右2扇区权重0.2，其余扇区权重0
    for stano=(2*ui_linkno+1):ui_sumsta
        if (vec_sectorid(link_temp,stano)==ui_left1 || vec_sectorid(link_temp,stano)==ui_right1)
            vec_sectorweight(1,stano)=1;
        elseif (vec_sectorid(link_temp,stano)==ui_left2 || vec_sectorid(link_temp,stano)==ui_right2)
            vec_sectorweight(1,stano)=0;
        else
            vec_sectorweight(1,stano)=0;
        end
    end
    clear stano;
    clear ui_left1;
    clear ui_left2;
    clear ui_right1;
    clear ui_right2;
    
    %取出扇区权重非0的下标,即R的id
    vec_validsectorno=zeros(1,ui_sumr);
    vec_validsectorno=find(vec_sectorweight);
    
    ui_validrno=nnz(vec_validsectorno);%扇区权重非0的R的个数
    if (ui_validrno == 0)
        continue;
    end
    
    %ui_rlos为直连链路LOS接收信号能量；ui_rri为S-R-D链路信号接收能量
    %链路权重
    
    %LOS链路的信号接收能量in dB
    vec_rlos=zeros(1,channel_times);
    for channel_temp=1:channel_times
        vec_rlos(1,channel_temp)=ui_pt+path_los_simu(vec_stadistance(link_temp,2*link_temp),vec_angle(link_temp,2*link_temp)-vec_sectorid(link_temp,2*link_temp)*ui_theta_l,ui_theta_l);
    end
    vec_rlos_sort=sort(vec_rlos);
    vec_rlos_top90=vec_rlos_sort(1,(channel_times*0.1+1):channel_times);
    ui_rlos=mean(vec_rlos_top90)-20-NL;
    clear channel_temp;
    
    %NLOS链路：S-R，R-D的path_loss，以及S-R-D链路的接收信号能量in dB，最终计算链路权重r_weight
    vec_rri=zeros(1,ui_validrno);
    vec_rweight=zeros(1,ui_validrno);
    % %     vec_rri_pw=zeros(1,ui_validrno);
    for stano=1:ui_validrno
        %S-R链路path_loss
        vec_rri_sr_los=zeros(1,channel_times);
        for channel_temp=1:channel_times
            vec_rri_sr_los(1,channel_temp)=path_los_simu(vec_stadistance(link_temp,vec_validsectorno(stano)),abs(vec_angle(link_temp,vec_validsectorno(stano))-vec_sectorid(link_temp,vec_validsectorno(stano))*ui_theta_l),ui_theta_l);
            if ((vec_angle(link_temp,vec_validsectorno(stano))>vec_angle(link_temp,ui_linkno+link_temp)-vec_block_half_angle(2,link_temp)) && (vec_angle(link_temp,vec_validsectorno(stano))<vec_angle(link_temp,ui_linkno+link_temp)+vec_block_half_angle(2,link_temp)))
                vec_rri_sr_los(1,channel_temp)=vec_rri_sr_los(1,channel_temp)-20;
            end
        end
        vec_rri_sr_los_sort=sort(vec_rri_sr_los);
        vec_rri_sr_los_top90=vec_rri_sr_los_sort(1,(channel_times*0.1+1):channel_times);
        ui_rri_sr_los=mean(vec_rri_sr_los_top90);
        clear channel_temp; 
        
        %R-D链路path_loss
        vec_rri_rd_los=zeros(1,channel_times);
        for channel_temp=1:channel_times
            vec_rri_rd_los(1,channel_temp)=path_los_simu(vec_stadistance(link_temp+ui_linkno,vec_validsectorno(stano)),abs(vec_angle(vec_validsectorno(stano),link_temp+ui_linkno)-vec_sectorid(vec_validsectorno(stano),link_temp+ui_linkno)*ui_theta_l),ui_theta_l);
            if ((vec_angle(ui_linkno+link_temp,vec_validsectorno(stano))>vec_angle(ui_linkno+link_temp,link_temp)-vec_block_half_angle(3,link_temp)) && (vec_angle(ui_linkno+link_temp,vec_validsectorno(stano))<vec_angle(ui_linkno+link_temp,link_temp)+vec_block_half_angle(3,link_temp)))
                vec_rri_rd_los(1,channel_temp)=vec_rri_rd_los(1,channel_temp)-20;
            end
        end
        vec_rri_rd_los_sort=sort(vec_rri_rd_los);
        vec_rri_rd_los_top90=vec_rri_rd_los_sort(1,(channel_times*0.1+1):channel_times);
        ui_rri_rd_los=mean(vec_rri_rd_los_top90);
        clear channel_temp;
        
        %S-R-D链路的接收信号能量in dB
        vec_rri(1,stano)=ui_pt+ui_rri_sr_los+ui_rri_rd_los-NL;
        
        %链路权重计算
% %         vec_rri_pw(1,stano)=(10^(vec_rri(1,stano)/10))/(10^(NL/10));
        vec_rweight(1,stano)=(10^(vec_rri(1,stano)/10)); 
    end
    %计算所有S-R-D链路的链路权重结束
    clear stano;
    
    %归一化链路权重r_weight
    vec_rweight_unit=zeros(1,ui_validrno);
    ui_sum_rweight=sum(vec_rweight(1,:));
    for stano=1:ui_validrno
% %         vec_rweight(1,stano)=vec_rri_pw(1,stano)/sum(vec_rri_pw(1,:));
        vec_rweight_unit(1,stano)=vec_rweight(1,stano)/ui_sum_rweight;
    end    
    clear stano;
        
    %vec_sumweight:总权重矩阵：求总权重
    vec_sumweight=zeros(2,ui_validrno);
    for stano=1:ui_validrno
        vec_sumweight(1,stano)=vec_validsectorno(stano);
        vec_sumweight(2,stano)=vec_rweight_unit(1,stano)*vec_sectorweight(1,vec_validsectorno(stano));
    end
    clear stano;
    
    %以vec_sumweight第2行总权重为标准对矩阵按列升序排序，权重最大的排在最后
    vec_sortweight=zeros(2,ui_validrno);
    [temp,index]=sort(vec_sumweight(2,:));%以第2行大小作为排序标准
    for i_temp=1:ui_validrno
        vec_sortweight(:,i_temp)=vec_sumweight(:,index(i_temp));
    end
    clear temp;
    clear i_temp;
    clear index;
    
    %暂时选取最优的R作为唯一的R
    vec_frs_bestrid(link_temp,caltimes)=vec_sortweight(1,ui_validrno);
   
end
clear link_temp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      ARS(all relay selection)                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for link_temp=1:ui_linkno
    
    %遍历计算每个R链路的信道容量C
    vec_rsnr4all=zeros(5,ui_sumr);
    
    %LOS链路的信号接收能量in dB
    vec_rlos=zeros(1,channel_times);
    for channel_temp=1:channel_times
        vec_rlos(1,channel_temp)=ui_pt+path_los_simu(vec_stadistance(link_temp,2*link_temp),vec_angle(link_temp,2*link_temp)-vec_sectorid(link_temp,2*link_temp)*ui_theta_l,ui_theta_l);
    end
    vec_rlos_sort=sort(vec_rlos);
    vec_rlos_top90=vec_rlos_sort(1,(channel_times*0.1+1):channel_times);
    ui_rlos=mean(vec_rlos_top90)-20-NL;
    clear channel_temp;
    
    %vec_rsnr4all矩阵5行ui_sumr列：1.R-ID，2.S-R的信号接收能量in dB（发10dBm），3.R-D的信号接收能量in
    %dB（发10dBm），4.C_AF，5.C_DF
    for stano=1:ui_sumr
        %第1行：R-ID
        vec_rsnr4all(1,stano)=stano+2*ui_linkno;
        
        %第2行：S-R链路SNR
        vec_srdbsnr4all=zeros(1,channel_times);
        for channel_temp=1:channel_times
            vec_srdbsnr4all(1,channel_temp)=ui_pt+path_los_simu(vec_stadistance(link_temp,stano+2*ui_linkno),abs(vec_angle(link_temp,stano+2*ui_linkno)-vec_sectorid(link_temp,stano+2*ui_linkno)*ui_theta_l),ui_theta_l);
            if ((vec_angle(link_temp,stano+2*ui_linkno)>vec_angle(link_temp,2*link_temp)-vec_block_half_angle(2,link_temp)) && (vec_angle(link_temp,stano+2*ui_linkno)<vec_angle(link_temp,2*link_temp)+vec_block_half_angle(2,link_temp)))
                vec_srdbsnr4all(1,channel_temp)=vec_srdbsnr4all(1,channel_temp)-20;
            end
        end
        vec_srdbsnr4all_sort=sort(vec_srdbsnr4all);
        vec_srdbsnr4all_top90=vec_srdbsnr4all_sort(1,(channel_times*0.1+1):channel_times);
        ui_srdbsnr4all=mean(vec_srdbsnr4all_top90)-NL;
        clear channel_temp;
        vec_rsnr4all(2,stano)=ui_srdbsnr4all;
        
        %第3行：R-D链路SNR
        vec_rddbsnr4all=zeros(1,channel_times);
        for channel_temp=1:channel_times
            vec_rddbsnr4all(1,channel_temp)=ui_pt+path_los_simu(vec_stadistance(2*link_temp,stano+2*ui_linkno),abs(vec_angle(stano+2*ui_linkno,2*link_temp)-vec_sectorid(stano+2*ui_linkno,2*link_temp)*ui_theta_l),ui_theta_l);
            if ((vec_angle(2*link_temp,stano+2*ui_linkno)>vec_angle(2*link_temp,link_temp)-vec_block_half_angle(3,link_temp)) && (vec_angle(2*link_temp,stano+2*ui_linkno)<vec_angle(2*link_temp,link_temp)+vec_block_half_angle(3,link_temp)))
                vec_rddbsnr4all(1,channel_temp)=vec_rddbsnr4all(1,channel_temp)-20;
            end
        end
        vec_rddbsnr4all_sort=sort(vec_rddbsnr4all);
        vec_rddbsnr4all_top90=vec_rddbsnr4all_sort(1,(channel_times*0.1+1):channel_times);
        ui_rddbsnr4all=mean(vec_rddbsnr4all_top90)-NL;
        clear channel_temp;
        vec_rsnr4all(3,stano)=ui_rddbsnr4all;
        
        ui_SNRsd4all=(10^(ui_rlos/10))/(10^(NL/10));
        ui_SNRsr4all=(10^(ui_srdbsnr4all/10))/(10^(NL/10));
        ui_SNRrd4all=(10^(ui_rddbsnr4all/10))/(10^(NL/10));
        ui_caf_ars=0.5*ui_bandwith*log2(1+ui_SNRsd4all+ui_SNRsr4all*ui_SNRrd4all/(ui_SNRsr4all+ui_SNRrd4all+1));
        ui_cdf_ars=0.5*ui_bandwith*min(log2(1+ui_SNRsr4all),log2(1+ui_SNRsd4all+ui_SNRrd4all));
        vec_rsnr4all(4,stano)=ui_caf_ars;
        vec_rsnr4all(5,stano)=ui_cdf_ars;
    end
    clear stano;
    clear ui_rri4all;
    %clear ui_rlos;

    %以vec_sumweight第4行C_AF为标准对矩阵按列升序排序，C_AF最大的排在最后
    vec_sortrsnr4all_af=zeros(5,ui_sumr);
    [temp,index]=sort(vec_rsnr4all(4,:));%以4行大小作为排序标准
    for i_temp=1:ui_sumr
        vec_sortrsnr4all_af(:,i_temp)=vec_rsnr4all(:,index(i_temp));
    end
    clear temp;
    clear i_temp;
    clear index;
    
    %以vec_sumweight第5行C_DF为标准对矩阵按列升序排序，C_DF最大的排在最后
    vec_sortrsnr4all_df=zeros(5,ui_sumr);
    [temp,index]=sort(vec_rsnr4all(5,:));%以5行大小作为排序标准
    for i_temp=1:ui_sumr
        vec_sortrsnr4all_df(:,i_temp)=vec_rsnr4all(:,index(i_temp));
    end
    clear temp;
    clear i_temp;
    clear index;
    
    %暂时选取最优的R作为唯一的R
    vec_ars_bestrid4all_af(link_temp,caltimes)=vec_sortrsnr4all_af(1,ui_sumr);
    vec_ars_bestrid4all_df(link_temp,caltimes)=vec_sortrsnr4all_df(1,ui_sumr);
    vec_ARS_AF_RESULT(link_temp,caltimes)=vec_sortrsnr4all_af(4,ui_sumr);
    vec_ARS_DF_RESULT(link_temp,caltimes)=vec_sortrsnr4all_df(5,ui_sumr);
    
    if (0 ~= vec_frs_bestrid(link_temp,caltimes))
        if ((vec_sortrsnr4all_af(4,ui_sumr) < vec_rsnr4all(4,vec_frs_bestrid(link_temp,caltimes)-2*ui_linkno)) || (vec_sortrsnr4all_df(5,ui_sumr) < vec_rsnr4all(5,vec_frs_bestrid(link_temp,caltimes)-2*ui_linkno)))
            disp(sprintf('wrong no:af=%d\tdf=%d\tfrs=%d\t%d\n',vec_sortrsnr4all_af(4,ui_sumr),vec_sortrsnr4all_df(5,ui_sumr),vec_rsnr4all(4,vec_frs_bestrid(link_temp,caltimes)-2*ui_linkno),vec_rsnr4all(5,vec_frs_bestrid(link_temp,caltimes)-2*ui_linkno)));
        end

        %FRS方式下选择R的信道容量：由于ARS将所有的R的信道容量计算出来，所以FRS的信道容量不需要重复计算，只需要将对应的ID的R的信道容量值取出即可
        vec_FRS_AF_RESULT(link_temp,caltimes)=vec_rsnr4all(4,vec_frs_bestrid(link_temp,caltimes)-2*ui_linkno);
        vec_FRS_DF_RESULT(link_temp,caltimes)=vec_rsnr4all(5,vec_frs_bestrid(link_temp,caltimes)-2*ui_linkno);
    end
    
end

clear link_temp;

end

ui_mean_frs_caf=mean(vec_FRS_AF_RESULT);
ui_mean_frs_cdf=mean(vec_FRS_DF_RESULT);
ui_mean_ars_caf=mean(vec_ARS_AF_RESULT);
ui_mean_ars_cdf=mean(vec_ARS_DF_RESULT);
ui_caf_percent=ui_mean_frs_caf/ui_mean_ars_caf;
ui_cdf_percent=ui_mean_frs_cdf/ui_mean_ars_cdf;
ui_mean_frs_af=mean(ui_mean_frs_caf);
ui_mean_frs_df=mean(ui_mean_frs_cdf);
ui_mean_ars_af=mean(ui_mean_ars_caf);
ui_mean_ars_df=mean(ui_mean_ars_cdf);
disp(sprintf('FRS:\t%d\t%d\n',ui_mean_frs_af,ui_mean_frs_df));
disp(sprintf('ERS:\t%d\t%d\n',ui_mean_ars_af,ui_mean_ars_df));
disp(sprintf('%d\t%d\n',ui_caf_percent,ui_cdf_percent));
