
% This script is for simulation of buffers at each input line

%% =========== Initialization =============

% Number of input ports.
input_ports = 64;       % N
% Number of output ports.
output_ports = 64;
% Maximum packet size
MTU = 12000;
% Arrival rate of possion distribution (packets/sec)
lambda = 4;
% entries in array
entries = 100;
% input buffer size (max 20 packets of size 12k)
max_buf_size = 20 * MTU;


% input lines(per switch) to first layer
input_lines = ceil(sqrt(input_ports));                  % n
% calcualte total number of input lines at layer 2
input_lines_2 = (2*input_lines-1)*ceil((input_ports/input_lines));
% calcualte total number of input lines at layer 3
input_lines_3 = (2*input_lines-1)*ceil((input_ports/input_lines));

%% ============ Part Allocate buffer for first layer ============
% Buffer initialization(each port buffer size = max_size * MTU bits)
buffer_1(1:input_ports, 1) = max_buf_size;
% packet size
pkt_size = zeros(input_ports, entries);
% buffer holding output port of each packet
%dst_port_1 = zeros(input_ports, entries);

fprintf('\nprogram paused, press enter to continue\n');
pause;

%% ============ Part  Generate data for input buffers ============
%                           (generated every second)
% Generate number of packets for each input port according to 
% the possion distribution.
%This gives #packets/sec for each input port.
% no_of_packets is a vector of size 64*1
no_of_packets = poissrnd(lambda, input_ports, 1);

% Calculate packet size for each packet
% randi generates array having number between 1-MTU
% assign genearated values to buffer of corresponding port.
% if total packet length is greater than max_buf_size then drop few packets.
for i=1:input_ports
    temp = randi(MTU, 1, no_of_packets(i));
    if isempty(temp)
        fprintf('\n no packet arrived for input line %d\n',i);
    else        
        while sum(temp) > buffer_1(i,1)
            temp = temp(1, 1:(end-1));
        end
        if length(temp) >= 1 
            pkt_size(i,:) = enqueue(pkt_size(i,:), temp);
            buffer_1(i) = buffer_1(i) - sum(temp);
        elseif isempty(temp)
            fprintf('\n some packets are dropped %d\n',i);  % also count size of packet
        end
    end
end

%% ============ Part  Allocate buffer for middle layer ============
% allocate buffer for middle layer switches
% calculate no of intermediate switches as 2*N^(1/2)-1 (general case)
% specific to project is N = 64 and n = 8 --> #switches at 1st layer = 8
% therefore #switches at second layer = 15 each of 8 * 8

% allocate maximum buffer size 
buffer_2(1:input_lines_2, 1) = max_buf_size;

% packet size
pkt_size_2 = zeros(input_lines_2, entries);

% buffer holding output port of each packet
%dst_port_2 = zeros(input_ports, entries);
%% === Part  Allocate buffer at the output (for observation/sec) ===

% allocate maximum buffer size 
buffer_3(1:input_lines_3, 1) = max_buf_size;

% packet size
pkt_size_3 = zeros(input_lines_3, entries);

% buffer holding output port of each packet
%dst_port_3 = zeros(input_ports, entries);
%% ===========  generate output port for each packet ==============
%                        (generated every second)
% For switching data from input layer buffer to middle layer buffer..
% output ports are randomly selected for packets at the head of buffer and 
 

% generate output line for each packet

%{
for i = 1:input_ports
    temp = randi(output_ports, 1, no_of_packets(i));
    if isempty(temp)
        fprintf('\n no packet arrived for input line %d\n',i);
    else        
        while sum(temp) > buffer_1(i,1)
            temp = temp(1, 1:(end-1));
        end
        if length(temp) >= 1 
            dst_port_1(i,:) = enqueue(dst_port_1(i,:), temp);
        elseif isempty(temp)
            fprintf('\n some packets are dropped %d\n',i);  % also count size of packet
        end
    end
end
%}
%% ========= find line number for middle layer buffer ========
%                        (called every 1/5 of second)
% Round Robin algorithm is used for switching packets to middle layer.
% this algorithm selects middle layer switch randomly but also considering
% ....the fact that inputs from same switch are not sent to the same switch
% .... in the middle layer.

% input_lines = n
% middle layer selected lines for each input line

% array to store middle layer line number
middle_line = zeros(input_ports, 1);
% array to select switch from next layer
select_switch = 1:(2*input_lines-1);
% selecting packet from each input line
for i = 1:input_ports
    if isempty(pkt_size(i,1))
    else
        % select middle layer switch
        % randomly select index of array, value represents selected switch
        index = randi(length(select_switch));
        %  find line number corresponding to the selected switch
        middle_line(i) = (select_switch(index)-1)*input_lines + ...
            (rem(i,input_lines)+1);                                        % check its validity
        % delete the selected switch entry from array so that inputs from 
        % same switch do not go to same next layer switch
        select_switch(index) = [];
    end
    % condition to reset select_switch
    if(isempty(rem(i,input_lines)))
        select_switch = 1:(2*input_lines-1);
    end
end

%% ============ forward packets from layer 1 to layer 2 ============
%                    (called every 1/5 of second)
% delete each packet from layer 1 and move it to end of buffer in layer 2.

for i = 1:input_ports
    [pkt_size(i,:), size] = dequeue(pkt_size(i,:));
%    [dst_port_1(i,:), port] = dequeue(dst_port_1(i,:));
    buffer_1(i) = buffer_1(i) + size;
    % before enqueue also check that buffer at middle layer switch is
    % free or not. 
    %Currently assuming that it is free.
    pkt_size_2() = enqueue(pkt_size_2(middle_line(i),:), size);
%    dst_port_2() = enqueue(dst_port_2(middle_line(i),:), port);
    buffer_2(i) = buffer_2(i) - size;
end

%%  ============ forward packets from layer 2 to layer 3 ============
%                    (called every 1/5 of second)
% delete each packet from layer 1 and move it to end of buffer in layer 2.
% before deleting packet ensure that no other packet is going to the same 
% output port.

for i = 1:input_lines_2
    if(pkt_size_2(i,1) == 0)
        continue;
    else
        % select switch at layer 3
        switch_no = dst_port_2(i,1) / input_lines;
        % find line number at that switch
        line_no = (switch_no - 1 ) * (2*input_lines-1) + ...
            (i/(input_ports/input_lines));                                  %check validity
        % dequeue from layer 2 and input at layer 3
        [pkt_size(i,:), size] = dequeue(pkt_size(i,:));
%        [dst_port_1(i,:), port] = dequeue(dst_port_1(i,:));
        buffer_1(i) = buffer_1(i) + size;
        % before enqueue also check that buffer at middle layer switch is
        % free or not. 
        %Currently assuming that it is free.
        pkt_size_2() = enqueue(pkt_size_2(middle_line(i),:), size);
 %       dst_port_2() = enqueue(dst_port_2(middle_line(i),:), port);
        buffer_2(i) = buffer_2(i) - size;
    end
end

%%  ============ forward packets from layer 3 to output port ============
%                    (called every 1/5 of second)
% delete each packet from layer 1 and move it to end of buffer in layer 2.

for i = 1:input_ports
    [pkt_size(i,:), value] = dequeue(pkt_size(i,:));
    buffer_1(i) = buffer_1(i) + value;
    % before enqueue also check that buffer at middle layer switch is
    % free or not. 
    %Currently assuming that it is free.
    pkt_size_2() = enqueue(pkt_size_2(middle_line(i),:), value);
    buffer_2(i) = buffer_2(i) - value;
end

