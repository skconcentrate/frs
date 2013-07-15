%这是计算全部R的权重的code




%ui_rlos为直连链路LOS接收信号能量；ui_rri为S-R-D链路信号接收能量
    %发送功率为10dbm
    %R权重
    vec_rweight=zeros(1,ui_validrno);
    ui_rlos=-22.5-20*log10(vec_stadistance(ui_linkno,2*ui_linkno)/1000)-20*log10(60000);
    for stano=(2*ui_linkno+1):ui_sumsta
        ui_rri=-22.5-20*log10((vec_stadistance(ui_linkno,stano)+vec_stadistance(2*ui_linkno,stano))/1000)-20*log10(60000);
        vec_rweight(1,stano-2*ui_linkno)=(1-abs(ui_rri/ui_rlos-1))*sin(vec_alpha(1,stano-2*ui_linkno)*pi/360)*sin(vec_beta(1,stano-2*ui_linkno)*pi/360);
    end
    clear rri;
    clear rlos;
    clear stano;
    clear ui_rri;
    clear ui_rlos;