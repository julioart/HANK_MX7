% clc;
clear;
close all;

%% PARAMETERS
InputDir = '~/FortranOutputDir/BaselineOutputSubdir/'; %path to fortran output

InputDir = '~/FortranOutputDir/HPCMXtry13/'; %path to fortran output

% InputDir = '~/FortranOutputDir/MXtry/'; %path to fortran output
% 
nexp = 15;

%% load workspaces
load([InputDir '/Steadystate_workspace.mat']);

NOFS = load([InputDir '/IRF_Monetary_NOFS_workspace.mat']);
tstep   = load([InputDir '/deltatransvec.txt']);
tpoints = cumsum(tstep);
T       = length(tstep);
for ip = 1:nexp
	PE{ip} = load([InputDir '/IRF_Monetary_PE' int2str(ip) '_workspace.mat']);
end


%% steady state components
C = initss.Ec;
I = initss.investment;
G = initss.govexp;
AC = initss.Eadjcost;
NX = initss.worldbond.*initss.rb;
BW = -(initss.rborr - initss.rb).*initss.EbN;
RE = initss.profit - initss.dividend;
PA = initss.priceadjust;

PI = initss.pi;

AD = C + I + G + AC + NX + BW + PA;
Y = initss.output;

Ctot = C + AC + BW;
Itot_hh = (initss.Ea-initss.equity).*initss.deprec;
    

Rb = initss.rb;


%% transition components

bmk.C = NOFS.sticky.Ec;
bmk.I = NOFS.sticky.investment;
bmk.G = NOFS.sticky.govexp;
bmk.AC = NOFS.sticky.Eadjcost;
bmk.NX = NOFS.sticky.netexports;
bmk.NXalt = NOFS.sticky.worldbond.*NOFS.sticky.rb;
bmk.BW = -(NOFS.sticky.rborr - NOFS.sticky.rb).*NOFS.sticky.EbN;
bmk.RE = NOFS.sticky.profit - NOFS.sticky.dividend;
bmk.PA = NOFS.sticky.priceadjust;

bmk.PI = NOFS.sticky.pi;

bmk.Ctot = bmk.C + bmk.AC + bmk.BW;
 
bmk.AD = bmk.Ctot + bmk.I + bmk.G + bmk.NX + bmk.BW + bmk.PA;

bmk.Y = NOFS.sticky.output;

bmk.Rb = NOFS.sticky.rb;

%% Price experiments

for i = 1:nexp
    pe{i}.C = PE{i}.sticky.Ec;
    pe{i}.I = PE{i}.sticky.investment;
    pe{i}.G = NOFS.sticky.govexp;
    pe{i}.AC = PE{i}.sticky.Eadjcost;
    pe{i}.NX = NOFS.sticky.netexports;
    pe{i}.BW = -(PE{i}.sticky.rborr - PE{i}.sticky.rb).*PE{i}.sticky.EbN;
    pe{i}.RE = NOFS.sticky.profit - NOFS.sticky.dividend;
    pe{i}.PA = NOFS.sticky.priceadjust;
    pe{i}.Ctot = pe{i}.C+pe{i}.AC +pe{i}.BW;
    
    pe{i}.PI = PE{i}.sticky.pi;

    
end    
%% define adjustment costs residually

ACres = Y - (AD - AC);
bmk.ACres = bmk.Y - (bmk.AD - bmk.AC);

% A =[C+BW I G ACres]/Y


 %% decompose deviations from steady state
 
 dtot.Y = (bmk.Y-Y);
 dtot.C = (bmk.C-C);
 dtot.I = (bmk.I-I);
 dtot.G = (bmk.G-G);
 dtot.AC = (bmk.AC-AC);
 dtot.NX = (bmk.NX-NX);
 dtot.BW = (bmk.BW-BW);
 dtot.RE = (bmk.RE-RE);
 dtot.PA = (bmk.PA-PA);
 dtot.AD = (bmk.AD-AD);
 dtot.Ctot = (bmk.Ctot-Ctot);
 dtot.PI = (bmk.PI-PI);
%  dtot.Itot_hh = (bmk.Itot_hh-Itot_hh);
 
  %%
var = {'C','I','AC','BW','Ctot'};
 for j = 1:numel(var)
     for i = 1:nexp
        eval(sprintf('dpe{i}.%s =pe{i}.%s -%s;',var{j},var{j},var{j}));
     end   
    
 end    

 
 
%% tables

tsetA{1} = 1;
tsetA{2} = [1:3];
tsetA{3} = [1:6];
tsetA{4} = [1:12];

for i = 1:4
    tsetRb_A{i} = tsetA{i}+1;
end

% tsetA{2} = find(tpoints<=1.00001);
% tsetA{3} = find(tpoints<=2.00001);
% tsetA{4} = find(tpoints<=4.00001);


tab = zeros(14,4);
elastdenom = zeros(1,4);

for col = 1:4
    tset = tsetA{col};
    tsetRb = tsetRb_A{col};
    
%     1
    %real rate change
    row = 1;
%     tab(row,col) = sum(bmk.Rb(tset).*tstep(tset))./ sum(tstep(tset))-Rb ;
    tab(row,col) = sum(bmk.Rb(tsetRb).*tstep(tsetRb))./ sum(tstep(tsetRb))-Rb ;
    elastdenom(1,col) = sum(bmk.Rb(tsetRb).*tstep(tsetRb))./ sum(tstep(tsetRb))-Rb ;
    
%     2
    %nominal rate change
    row = row+1;
    tab(row,col) = (sum(NOFS.sticky.rnom(tset).*tstep(tset))./ sum(tstep(tset))-initss.rnom) ;

%     3
    %inflation change
    row = row+1;
    tab(row,col) = (sum(NOFS.sticky.pi(tset).*tstep(tset))./ sum(tstep(tset))-initss.pi) ;

%     4
    %marginal cost change
    row = row+1;
    tab(row,col) = (sum(NOFS.sticky.mc(tset).*tstep(tset))./ sum(tstep(tset))-initss.mc)./initss.mc;

%     5
    %profit change
    row = row+1;
    tab(row,col) = (sum(NOFS.sticky.profit(tset).*tstep(tset))./ sum(tstep(tset))-initss.profit)./initss.profit;

%     6
    %equity change
    row = row+1;
    tab(row,col) = (sum(NOFS.sticky.equity(tset).*tstep(tset))./ sum(tstep(tset))-initss.equity)./initss.equity;

%     7
    %Y change and elasticity
    row = row+1;
    tab(row,col) = sum(dtot.Y(tset).*tstep(tset)./Y)./ sum(tstep(tset));

%     8
    row = row+1;
    tab(row,col) = tab(row-1,col) ./ elastdenom(1,col) ;

%     9
    %I change and elasticity
    row = row+1;
    tab(row,col) = sum(dtot.I(tset).*tstep(tset)./I)./ sum(tstep(tset));
%     10
    row = row+1;
    tab(row,col) = tab(row-1,col) ./ elastdenom(1,col) ;

%     11
    %G change and elasticity
    row = row+1;
    tab(row,col) = sum(dtot.G(tset).*tstep(tset)./G)./ sum(tstep(tset));
%     12
    row = row+1;
    tab(row,col) = tab(row-1,col) ./ elastdenom(1,col) ;

%     13
    %C change and elasticity
    row = row+1;
    tab(row,col) = sum(dtot.C(tset).*tstep(tset)./C)./ sum(tstep(tset));
%     14
    row = row+1;
    tab(row,col) = tab(row-1,col) ./ elastdenom(1,col) ;


    %rb: direct (ies, hh wealth)
    row = row+1;
    tab(row,col) = sum(dpe{4}.C(tset).*tstep(tset))./sum(dtot.C(tset).*tstep(tset));

    %W + profits: indirect
    row = row+1;
    tab(row,col) = sum(dpe{3}.C(tset).*tstep(tset))./sum(dtot.C(tset).*tstep(tset));

    %ra: indirect
    row = row+1;
    tab(row,col) = sum(dpe{5}.C(tset).*tstep(tset))./sum(dtot.C(tset).*tstep(tset));

    %equity: indirect
    row = row+1;
    tab(row,col) = sum(dpe{6}.C(tset).*tstep(tset))./sum(dtot.C(tset).*tstep(tset));

    %transfer: indirect
    row = row+1;
    tab(row,col) = sum(dpe{7}.C(tset).*tstep(tset))./sum(dtot.C(tset).*tstep(tset));

    %all at same time
    row = row+1;
    tab(row,col) = sum(dpe{8}.C(tset).*tstep(tset))./sum(dtot.C(tset).*tstep(tset));

    %W: indirect
    row = row+1;
    tab(row,col) = sum(dpe{1}.C(tset).*tstep(tset))./sum(dtot.C(tset).*tstep(tset));

    %profits: indirect
    row = row+1;
    tab(row,col) = sum(dpe{2}.C(tset).*tstep(tset))./sum(dtot.C(tset).*tstep(tset));

    %transfer from rb only
    row = row+1;
    tab(row,col) = sum(dpe{9}.C(tset).*tstep(tset))./sum(dtot.C(tset).*tstep(tset));

    %transfer excluding transfer from rb
    row = row+1;
    tab(row,col) = sum(dpe{10}.C(tset).*tstep(tset))./sum(dtot.C(tset));

    %transfer excluding transfer from rb
    row = row+1;
    tab(row,col) = sum(dpe{13}.C(tset).*tstep(tset))./sum(dtot.C(tset));

    
    %PI change and elasticity
    row = row+1;
    tab(row,col) = sum(dtot.PI(tset).*tstep(tset))./ sum(tstep(tset));
    row = row+1;
    tab(row,col) = tab(row-1,col) ./ elastdenom(1,col) ;

    
    
end    

% % table for paper:
% finaltable = zeros(9,1);
% finaltable(1) = 4*tab(1,4);
% finaltable(2) = tab(8,4);
% finaltable(3) = tab(10,4);
% finaltable(4) = tab(14,4);
% finaltable(5) = tab(13,4)*tab(15,4)/tab(1,4);
% finaltable(6) = tab(15,4);
% finaltable(7) = tab(16,4);
% finaltable(8) = tab(19,4);
% finaltable(9) = tab(17,4)+tab(18,4);
% 
% format long;
% disp(finaltable);


%%

% clc
% table for paper:
% finaltable = zeros(10,2);

clear finaltable

i = 1;

list_row = 0;
if list_row
    %number of row
    finaltable(:,1) = 1:10;
    i = i + 1;
end

%Change in rb
finaltable(1,i) = 4*tab(1,4)*100;
%elast Y
finaltable(2,i) = tab(8,4);
%elast I
finaltable(3,i) = tab(10,4);
%elast C
finaltable(4,i) = tab(14,4);
%PE elast C
finaltable(5,i) = tab(13,4)*tab(15,4)/tab(1,4);
%Direct eff
finaltable(6,i) = tab(15,4)*100;
%Indirect eff:wages
finaltable(7,i) = tab(16,4)*100;
%Indirect eff:Transfers
finaltable(8,i) = tab(19,4)*100;
%Indirect eff:asset prices
finaltable(9,i) = (tab(17,4)+tab(18,4))*100;
%Elast PI
finaltable(10,i) = tab(27,4);

finaltable = round(finaltable*10)/10;
finaltable(6:9,i) = round(finaltable(6:9,i));

format short;
disp('Input for table 7 - last row is elast of pi');

disp(finaltable);

disp('Slope of Inflation-Output Trade-off');
finaltable(10,i)/finaltable(2,i)*4

