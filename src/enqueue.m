% implementation of queue enqueue operations
% current implementation do not need it

function [queue] = enqueue(queue, value)

% insert only if number of non zero entries are less than total entries
% insert at first zero value position
if length(queue) - length(find(queue)) >= length(value)
    pos = find(queue == 0, 1);
    queue(pos:pos+length(value)-1) = value;
else
    fprintf('\n memory full in terms of number of packet entries\n');
end

end