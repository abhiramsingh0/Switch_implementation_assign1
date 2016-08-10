%% ================= variables initialization script ===================

% number of input ports
input_ports = 64;
% number of output ports
output_ports = 64;
% number of input ports per switch at input layer
ppswitch_input = 8;
% number of input ports per switch at output layer
ppswitch_output = 8;
% number of switches at the output layer
output_switches = ceil(input_ports/ppswitch_input);
% arrival rate (possion)
lambda = 4;
% assumed minimum packet size
min_pkt_size = 200;
% max value to keep track of number of packets in any buffer
entries = 200;
% maximum packet size
MTU = 12000;
% number of packets
no_of_packets = 40;
% maximum size of buffer
max_buf_size = no_of_packets * MTU;