%% generate several keys for monte carlo simulations
clc;clear all;close all;
N = 8;
M = 8;
tic
Ngen = 1e4;
init = round(rand(Ngen,N-1));
for k = 1:Ngen
h = commsrc.pn('GenPoly',[7 6 0],'InitialStates',init(k,:));
% Forming the s matrix
for i=1:M
    for j=1:N
        s(i,j,k) = generate(h);
    end
end
end
s(find(s==1))=-1;
s(find(s==0))=1;
toc
%%
init_state = round(rand(1,N-1))
h = commsrc.pn('GenPoly',[7 6 0],'InitialStates',init_state);
% sequences each of length 512 see matlab doc for commsrc.pn for the
% polynomial reference
% Forming the s matrix
for i=1:M
    for j=1:N
        s1(i,j) = generate(h);
    end
end
s1(find(s1==1))=-1;
s1(find(s1==0))=1;
%%
count = 0;
for i = 1:Ngen
    count = count+isequal(s(:,:,i),s1);
end
count