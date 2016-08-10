function[drop_size] = setup(size_buffer)
%% ==================== initialize variables ===================
initialize
seconds = 5000;
% number of packets
max_packets = size_buffer;
% maximum size of buffer
max_buf_size = max_packets * MTU;

% initialize input layer buffers
buffer_1 = zeros(input_ports, entries, 3);
buffer_left_1(1:input_ports, :) = max_buf_size;

% initialize middle layer buffers
buffer_2 = zeros((2 * ppswitch_input -1), (input_ports/ppswitch_input), ...
    entries, 3);

buffer_left_2 = zeros((2 * ppswitch_input -1),(input_ports/ppswitch_input));
buffer_left_2(:,:) = max_buf_size;

% initialize 3rd layer buffers
buffer_3 = zeros(output_switches, (2 * ppswitch_input -1), entries, 3);

buffer_left_3 = zeros(output_switches, (2 * ppswitch_input -1));
buffer_left_3(:,:) = max_buf_size;

%% iterate over time

for i = 1:seconds
    %% ================ Generate data for input buffers =================
    %                           (called every second)
    [buffer_1, buffer_left_1, drop_size] = data_generation( buffer_1, ...
        buffer_left_1);
    if 0 ~= drop_size
%        fprintf('\npackets are dropped at input layer\n');
%        fprintf('\nstopping program, increase buffer size\n');
%        fprintf('\n i = %d\n',i);
        break;
    end
    % processsing for each 200ms
    for j = 1:5
        %% =================== forward 3-output =====================
        %                        (called every 1/5 of second)
        [buffer_3, buffer_left_3] = transfer_3_output(buffer_3, buffer_left_3);

        %% ======================= forward 2-3 =====================
        %                        (called every 1/5 of second)
        [buffer_2, buffer_left_2, buffer_3, buffer_left_3] = transfer_2_3( ...
            buffer_2, buffer_left_2, buffer_3, buffer_left_3);
        
        %% ======================= forward 1-2 =======================
        %                        (called every 1/5 of second)
        [buffer_1, buffer_left_1, buffer_2, buffer_left_2] = transfer_1_2( ...
            buffer_1, buffer_left_1, buffer_2, buffer_left_2);
    end
end
end