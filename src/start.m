% script to repeatedly check for drop of packets
% for changing buffer size, update no_of_packets field and 
% entries field which represent no of entries in one buffer
count = 0;
parfor i = 1:30
    drop_occurs=startup();
    if drop_occurs > 0
        count = count + 1;
    end
end
fprintf('\n no of drops: %d',count);