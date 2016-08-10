% Function to transfer packets from layer 2 to layer 3
function[buffer_3, buffer_left_3] = transfer_3_output(...
    buffer_3, buffer_left_3)

initialize
% switch remove data from buffer_3 such that no two packets with same
% destination port are processed simultaneously
for i = 1:output_switches
out_ports = buffer_3(i,:,1,2);
    for k = 1:ppswitch_output
        port_j = find(out_ports == k);
        % if no packet is destined for kth port then do nothing
        if(isempty(port_j))
        else
            % randomly select one buffer for processing packet
            index = randi(length(port_j));
            % process packet from selected buffer
            buffer_left_3(i, port_j(index)) = buffer_left_3( ...
                i, port_j(index)) + buffer_3(i,port_j(index),1,3);
            buffer_3(i, port_j(index), 1:end-1, :) = ...
                buffer_3(i, port_j(index), 2:end, :);
        end
    end
% end of for loop (for i = 1:output_switches)
end

% end of function
end
 