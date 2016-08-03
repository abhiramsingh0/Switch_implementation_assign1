function [ queue, value ] = dequeue( queue )
% Implementation of queue dequeue operations
% current implementation do not need it

% Check if atleast one non-zero entry exist in queue
% take first value from the queue and rotate so that 2nd entry is first in
% the queue
if length(find(queue)) > 1
    value = queue(1 ,1);
    queue(1 ,1) = 0;
    queue = queue';
    circshift(queue, length(queue));
    queue = queue';
else
    fprintf('\n queue already empty \n');
    value = 0;
end

end

