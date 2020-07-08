unique_states=unique(states);

A=zeros(numel(unique_states),numel(unique_states));

for i=2:numel(states)
    previdx=ismember(unique_states,states(i-1));
    newidx=ismember(unique_states,states(i));
    A(previdx,newidx)=1;
end

g=digraph(A,unique_states);    
plot(g);