% script to repeatedly check for drop of packets
% for changing buffer size, update no_of_packets field
buf_size = 1:10:200;
drop_occurs = zeros(1,length(buf_size));
parfor j = 1:length(buf_size)
    count = 0;
    drop_occurs(j) = setup(buf_size(j));
    %fprintf('\n no of drops: %d %d',drop_occurs(j),j);
end
index = find(drop_occurs == 0,1);
if isempty(index)
    printf('\nbuffer size needs to be more\n');
else
    fprintf('\n For 5000 seconds');
    printf('\n optimal buffer size is %d*12000 bits\n',buf_size(index));
end