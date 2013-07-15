function output=caldistance(locate_node,i_temp,j_temp)
difx=locate_node(1,j_temp)-locate_node(1,i_temp);
dify=locate_node(2,j_temp)-locate_node(2,i_temp);
 stadistance=sqrt(difx*difx+dify*dify);
 
output=stadistance;