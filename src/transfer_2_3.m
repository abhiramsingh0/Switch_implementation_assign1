% Function to transfer packets from layer 2 to layer 3
function[buffer_2, buffer_left_2, buffer_3, buffer_left_3] = ...
    transfer_2_3(buffer_2, buffer_left_2, buffer_3, buffer_left_3)

initialize
% loop over each switch and then for each input line of switch
for i = 1:(2 * ppswitch_input -1)
    for j = 1:output_switches
        dst_switch = buffer_2(i,j,1,1);
        % process only if valid entry is present
        if (0 ~= dst_switch) && (buffer_left_3(dst_switch, i) - ...
                buffer_2(i,j,1,3) >= 0)
            % find first zero entry
            index = find(buffer_3(dst_switch, i, :, 1) == 0, 1);
            % update buffer_3
%            try
            buffer_3(dst_switch, i, index, :) = buffer_2(i,j,1,:);
%            catch
%                fprintf('\n%d %d %d %d\n',i,j,dst_switch,isempty(index));
 %           end
            buffer_left_3(dst_switch, i) = buffer_left_3(dst_switch, i) ...
                - buffer_2(i,j,1,3);
            % update buffer_2
            buffer_left_2(i, j) = buffer_left_2(i, j) + buffer_2(i,j,1,3);
            buffer_2(i, j, 1:end-1,:) = buffer_2(i, j, 2:end,:);
            buffer_2(i, j, end, :) = [0 0 0];
        end
    end
% end of for loop (for i = 1:(2 * ppswitch_input -1))
end
% end of function
end
