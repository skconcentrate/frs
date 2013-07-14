function output=calangle(locate_node,i_temp,j_temp)
difx=locate_node(1,j_temp)-locate_node(1,i_temp);
dify=locate_node(2,j_temp)-locate_node(2,i_temp);
staangle=atand(dify/difx);

if (difx<0 && dify<0 && staangle>0)
    staangle=staangle+180;
elseif (difx<0 && dify>0 && staangle<0)
    staangle=staangle+180;
elseif (difx>0 && dify<0 && staangle<0)
    staangle=staangle+360;
else
    staangle=staangle;
end
 
output=staangle;