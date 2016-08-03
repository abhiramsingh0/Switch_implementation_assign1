
% This script is for simulation of buffers at each input line

% Initialization

% Number of input ports.
input_ports = 64;
% Maximum packet size
MTU = 12000;
% Arrival rate of possion distribution (packets/sec)
lambda = 4;
% entries in array
entries = 100;
% input buffer size (max 20 packets of size 12k)
max_buf_size = 20 * 12000;
% Buffer initialization(each port buffer size = max_size * MTU bits)
buffer(input_ports, 1) = max_buf_size;
% packet size
pkt_size = zeros(input_ports, entries);

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
    while sum(temp) > buffer(i,1)
        temp = temp(1, 1:(end-1));
    end
    if length(temp) > 1 
        pkt_size(i,:) = enqueue(pkt_size(i,:), temp);
    else
        fprintf('some packets are dropped');
    end
end
