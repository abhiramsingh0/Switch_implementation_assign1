% Function to transfer packets from layer 1 to layer 2
function[buffer_1, buffer_left_1, buffer_2, buffer_left_2] = ...
        transfer_1_2(buffer_1, buffer_left_1, buffer_2, buffer_left_2)

    initialize
    success = 0;
% forward packets from each input layer buffer 
for i = 1:input_ports
    % forward only if some packet is present in the buffer otherwise go to
    % the next buffer
    if buffer_1(i,1,1) ~= 0
        % find switch no for current buffer
        input_switch = ceil(i / ppswitch_input);
        min_buf_len = entries;
        min_j = 1;
        % try sending packet to different switch of next layer if selected
        % switch line of middle layer is full. Also find switch with min 
        % queue length and then forward
        for j = 1:(2 * ppswitch_input -1)
            middle_switch = randi((2 * ppswitch_input -1));
            % find non zero entries of corresponding buffer
            buf_len = length(find(buffer_2(middle_switch,input_switch,:,1)));
%            fprintf('%d %d %d\n',buf_len,input_switch,middle_switch);
            if buf_len < min_buf_len
                min_buf_len = buf_len;
                min_j = middle_switch;
            end
            % find destination switch for all buffers for jth switch
            dest_switch = buffer_2(middle_switch,:,buf_len+1,1);
            % check if there is same destination switch entry is already
            % present or not
            if (isempty(find(dest_switch == buffer_1(i,1,1),1)) && ...
                    (buffer_left_2(middle_switch,input_switch) - buffer_1(i,1,3)) >= 0)
                % update buffer_2
                buffer_2(middle_switch, input_switch, buf_len+1, :) = buffer_1(i,1,:);
                buffer_left_2(middle_switch, input_switch) = ...
                    buffer_left_2(middle_switch, input_switch) - buffer_1(i,1,3);
                % update buffer_1
                buffer_left_1(i) = buffer_left_1(i) + buffer_1(i,1,3);
                buffer_1(i,1:end-1,:)= buffer_1(i,2:end,:);
                buffer_1(i,end,:) = [0 0 0];
                % set flag
                success = 1;
                break;
            end
        end
        if success == 0 && (buffer_left_2(min_j,input_switch) - ...
                buffer_1(i,1,3)) >= 0
            % insert at the minimum legth queue
            %middle_switch = randi((2 * ppswitch_input -1));
            %index = find(buffer_2(min_j, input_switch, :, 1) ...
             %   == 0, 1);
            % update buffer_2
            buffer_2(min_j, input_switch, min_buf_len+1, :) = ...
                buffer_1(i,1,:);
            buffer_left_2(min_j, input_switch) = ...
                buffer_left_2(min_j, input_switch) - ...
                buffer_1(i,1,3);
            % update buffer_1
            buffer_left_1(i) = buffer_left_1(i) + buffer_1(i,1,3);
            buffer_1(i,1:end-1,:)= buffer_1(i,2:end,:);
            buffer_1(i,end,:) = [0 0 0];
        end
    end
end

% end of function
end