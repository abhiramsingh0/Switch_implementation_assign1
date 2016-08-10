%% function to generate data at input buffers of switch 
function[buffer_1, buffer_left_1, drop_size] = data_generation(...
    buffer_1, buffer_left_1)

initialize
% generate packets for each input port according to possion distribution
% no_of_packets is a vector of size = (input_ports * 1)
no_of_packets = poissrnd(lambda, input_ports, 1);

% for each packet in a buffer, find its size and fix destination port
for i=1:input_ports
    % processing is done on buffer if only some packet is generated for it
    if no_of_packets(i) ~= 0 
        % packet size
        temp3 = randi([min_pkt_size, MTU], 1, no_of_packets(i));
        % output port 1-64
        temp = randi(output_ports, 1, no_of_packets(i));
         % output switch 1-8
        temp1 = zeros(1, no_of_packets(i));
        % output port (1-8) for switch selected in above step 
        temp2 = zeros(1, no_of_packets(i));
        % calculate output layer switch number and its port
        for j=1: no_of_packets(i)
            temp1(1,j) = ceil(temp(j) / ppswitch_input);
            temp2(1,j) = temp(j) - (temp1(j) - 1) * ppswitch_input ;
        end
        % check if existing pcaket buffer size and new does not exceed
        % maximum limit otherwise cut down packets
        drop_size = 0;
        while sum(temp3) > buffer_left_1(i,1)
%            fprintf('\n%d %d %d\n',i,sum(temp3),buffer_left_1(i,1));
            drop_size = drop_size + temp3(1,end);
            temp3 = temp3(1, 1:(end-1));
            temp1 = temp1(1, 1:(end-1));
            temp2 = temp2(1, 1:(end-1));            
        end
        % print if some packets are dropped
        if 0 ~= drop_size
%            fprintf('\n some packets are dropped at input line %d',i);
%            fprintf('\n total size of dropping %d\n', drop_size);
            return
        end
        % insert newly generated packets in buffers
        if length(temp1) >= 1
            buffer_1(i,:,3) = enqueue(buffer_1(i,:,3), temp3);
            buffer_1(i,:,1) = enqueue(buffer_1(i,:,1), temp1);
            buffer_1(i,:,2) = enqueue(buffer_1(i,:,2), temp2);
            buffer_left_1(i) = buffer_left_1(i) - sum(temp3);
        end
    end
%end of for loop (for i=1:input_ports)
%fprintf('\n program paused, press enter\n');
%pause
end
% end of function
end