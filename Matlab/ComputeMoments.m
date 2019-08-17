
clc;
clear;
close all;


%% LOAD WORKSPACES
% InputDir = '~/FortranOutputDir/BaselineOutputSubdir/'; %path to fortran output
InputDir = '~/FortranOutputDir/OnlySS/'; %path to fortran output
load([InputDir '/Steadystate_workspace.mat']);

%% Lorenz curve illiquid wealth
illpopfrac = cumsum(adelta.*gamargallinc);
illpopfrac(ngpa) = 1;
illpopfrac = [0; illpopfrac];
illwealthfrac = cumsum(agrid.*adelta.*gamargallinc);
illwealthfrac = illwealthfrac ./ illwealthfrac(ngpa);
illwealthfrac= [0; illwealthfrac];
datalorenzill = load('lorenz_ill.txt');



% top illiquid shares

ill_share_top10pc = 1-interp1(illpopfrac(2:ngpa+1),illwealthfrac(2:ngpa+1),0.9);
ill_share_top1pc = 1-interp1(illpopfrac(2:ngpa+1),illwealthfrac(2:ngpa+1),0.99);
ill_share_top01pc = 1-interp1(illpopfrac(2:ngpa+1),illwealthfrac(2:ngpa+1),0.999);
ill_share_bot50pc = interp1(illpopfrac(2:ngpa+1),illwealthfrac(2:ngpa+1),0.5);
ill_share_bot25pc = interp1(illpopfrac(2:ngpa+1),illwealthfrac(2:ngpa+1),0.25);
ill_gini = initss.GINIa;

%% Lorenz curve liquid wealth
liqpopfrac = cumsum(bdelta.*gbmargallinc);
illpopfrac(ngpb) = 1;
liqwealthfrac = cumsum(bgrid.*bdelta.*gbmargallinc);
liqwealthfrac = liqwealthfrac ./ liqwealthfrac(ngpb);
datalorenzliq = load('lorenz_liq.txt');


% top liquid shares

liq_share_top10pc = 1-interp1(liqpopfrac,liqwealthfrac,0.9);
liq_share_top1pc = 1-interp1(liqpopfrac,liqwealthfrac,0.99);
liq_share_top01pc = 1-interp1(liqpopfrac,liqwealthfrac,0.999);
liq_share_bot50pc = interp1(liqpopfrac,liqwealthfrac,0.5);
liq_share_bot25pc = interp1(liqpopfrac,liqwealthfrac,0.25);
liq_gini = initss.GINIb;


%% SCALAR TABLES FOR CALIBRATION
format long;
disp(' ');
disp(['Mean Iliquid Wealth  = '  ,num2str(initss.Ea./(4*initss.output))]);
disp(['Mean Liquid Wealth   = '  ,num2str(round(initss.Eb./(4*initss.output)*100)/100)]);
disp(['Frac $b=0$ and $a=0$ = '  ,num2str(round(initss.FRACb0a0*100)/100)]);
disp(['Frac $b=0$ and $a>0$ = '  ,num2str(round(initss.FRACb0aP*100)/100)]);
disp(['Frac $b<0$           = '  ,num2str(round(initss.FRACbN*100)/100)]);

return
disp(' ');
disp(['Liquid Wealth: top 10% share  = '  ,num2str(liq_share_top10pc)]);
disp(['Liquid Wealth: top 1% share   = '  ,num2str(liq_share_top1pc)]);
disp(['Liquid Wealth: top 0.1% share = '  ,num2str(liq_share_top01pc)]);
disp(['Liquid Wealth: bot 50% share  = '  ,num2str(liq_share_bot50pc)]);
disp(['Liquid Wealth: bot 25% share  = '  ,num2str(liq_share_bot25pc)]);
disp(['Liquid Wealth: gini           = '  ,num2str(liq_gini)]);
disp(' ');
disp(['Iliquid Wealth: top 10% share  = '  ,num2str(ill_share_top10pc)]);
disp(['Iliquid Wealth: top 1% share   = '  ,num2str(ill_share_top1pc)]);
disp(['Iliquid Wealth: top 0.1% share = '  ,num2str(ill_share_top01pc)]);
disp(['Iliquid Wealth: bot 50% share  = '  ,num2str(ill_share_bot50pc)]);
disp(['Iliquid Wealth: bot 25% share  = '  ,num2str(ill_share_bot25pc)]);
disp(['Iliquid Wealth: gini           = '  ,num2str(ill_gini)]);
