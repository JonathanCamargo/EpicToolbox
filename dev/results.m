%% Some plots to figure out what's happening in stairs

clc;clear;close all;

sa=load('SA1.mat');
%%
sa=timeshift(sa,'auto');
%%
% Fsm states flow:
states=cellfun(@char,sa.fsm.State.State,'UniformOutput',false);
times=sa.fsm.State.Header;

unique_states=unique(states);

A=zeros(numel(unique_states),numel(unique_states));
other_data=cell(size(A));

for i=2:numel(states)
    previdx=ismember(unique_states,states(i-1));
    newidx=ismember(unique_states,states(i));
    A(previdx,newidx)=1;
    other_data{previdx,newidx}=[other_data{previdx,newidx} times(i) ];
end

g=digraph(A,unique_states);    
p=plot(g);
f1=@(x)(x(1:end-1));f=@(x)f1(sprintf('%1.2f;',x));
info=cellfun(f,other_data,'UniformOutput',false)';
N=6;
info=reshape(info,N*N,1);
emptyInfo=cellfun(@isempty,info);
edgeInfo=info(~emptyInfo);
labeledge(p,g.Edges.EndNodes(:,1),g.Edges.EndNodes(:,2),edgeInfo);

%%

% Transition times:
T1=[11.04,13.81,16.54];
T2=[12.11,14.41,17.58];
T3=[10.83,13.59,16.29];
T4=[9.48,12.72,15.02,18.19];

i=3;

%Segment of lateStance
%a=cut(sa,T1(i),T2(i));

%Segment of EarlyStance
a=cut(sa,T4(i),T1(i))

figure(2);
figure(3);
N=5
subplot(N,1,1);
Topics.plot_generic(a,'knee.scaled_params','channels',{'ThetaEq'});
subplot(N,1,2);
Topics.plot_generic(a,'knee.scaled_params','channels',{'K'});
subplot(N,1,3);
Topics.plot_generic(a,'knee.scaled_params','channels',{'B'});
subplot(N,1,4)
Topics.plot_generic(a,'knee.joint_state');
subplot(N,1,5)
Topics.plot_generic(a,'wrench','channels',{'ForceZ'})





