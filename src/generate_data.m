
% This script is for simulation of buffers at each input line

% Initialization
% Number of input ports.
input_ports = 64;
% Maximum packet size
MTU = 12000;
% Arrival rate of possion distribution (packets/sec)
lambda = 4;
% Buffer initialization
buffer = 

% Generate number of packets for each input port according to 
% the possion distribution.
%This gives #packets/sec for each input port.
% no_of_packets is a vector of size 64*1
no_of_packets = poissrnd(lambda, input_ports, 1);

% Calculate packet size for each packet
for i=1:input_ports
    randi(MTU, no_of_packets, 1);
end