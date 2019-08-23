
% clc;
clear;
% close all;


%% LOAD WORKSPACES
% InputDir = '~/FortranOutputDir/BaselineOutputSubdir/'; %path to fortran output
% InputDir = '~/FortranOutputDir/MXtry0/'; %path to fortran output
InputDir = '~/FortranOutputDir/HPCMXtry16/'; %path to fortran output

load([InputDir '/Steadystate_workspace.mat']);

% %% Lorenz curve illiquid wealth
% illpopfrac = cumsum(adelta.*gamargallinc);
% illpopfrac(ngpa) = 1;
% illpopfrac = [0; illpopfrac];
% illwealthfrac = cumsum(agrid.*adelta.*gamargallinc);
% illwealthfrac = illwealthfrac ./ illwealthfrac(ngpa);
% illwealthfrac= [0; illwealthfrac];
% datalorenzill = load('lorenz_ill.txt');
% 
% 
% 
% % top illiquid shares
% 
% ill_share_top10pc = 1-interp1(illpopfrac(2:ngpa+1),illwealthfrac(2:ngpa+1),0.9);
% ill_share_top1pc = 1-interp1(illpopfrac(2:ngpa+1),illwealthfrac(2:ngpa+1),0.99);
% ill_share_top01pc = 1-interp1(illpopfrac(2:ngpa+1),illwealthfrac(2:ngpa+1),0.999);
% ill_share_bot50pc = interp1(illpopfrac(2:ngpa+1),illwealthfrac(2:ngpa+1),0.5);
% ill_share_bot25pc = interp1(illpopfrac(2:ngpa+1),illwealthfrac(2:ngpa+1),0.25);
% ill_gini = initss.GINIa;
% 
% %% Lorenz curve liquid wealth
% liqpopfrac = cumsum(bdelta.*gbmargallinc);
% illpopfrac(ngpb) = 1;
% liqwealthfrac = cumsum(bgrid.*bdelta.*gbmargallinc);
% liqwealthfrac = liqwealthfrac ./ liqwealthfrac(ngpb);
% datalorenzliq = load('lorenz_liq.txt');
% 
% 
% % top liquid shares
% 
% liq_share_top10pc = 1-interp1(liqpopfrac,liqwealthfrac,0.9);
% liq_share_top1pc = 1-interp1(liqpopfrac,liqwealthfrac,0.99);
% liq_share_top01pc = 1-interp1(liqpopfrac,liqwealthfrac,0.999);
% liq_share_bot50pc = interp1(liqpopfrac,liqwealthfrac,0.5);
% liq_share_bot25pc = interp1(liqpopfrac,liqwealthfrac,0.25);
% liq_gini = initss.GINIb;

%%


%% WEALTH DISTRIBUTION

%data annual output (who knows from where...
% maybe is GDP per capita in PPP times average household size in US of 2.6 members)
dataannoutput = 115000;

%income grid to match agrid and bgrid
yygrid = permute(repmat(ygrid, [1 size(agrid,1) size(bgrid,1)]),[2 3 1]);

%grid for labor income (normalized with annual output)
grlabincmat = dataannoutput .*hour .* initss.wage .* yygrid ./initss.output;
grlabinc = reshape(grlabincmat,ngpa*ngpb*ngpy,1);
grlabincdist = reshape(gjoint.*abydelta,ngpa*ngpb*ngpy,1);

[grlabinc , tempind] = sort([grlabinc]);
grlabincdist = grlabincdist(tempind);

grlabinccum = cumsum(grlabincdist);

%% liquid wealth distribution - equally spaced bins;
liqspace=1; %steps in thousands
liqcdf = cumsum(bdelta.*gbmargallinc);
liqbinmin = floor(bgrid(1).*dataannoutput/(4*initss.output*1000));
liqbinmax = ceil(bgrid(ngpb).*dataannoutput/(4*initss.output*1000));
liqbin = [liqbinmin:liqspace:liqbinmax]';
nliqbin = size(liqbin,1);

liqbincdf = interp1(bgrid.*dataannoutput/(4*initss.output*1000),liqcdf,liqbin);
liqbincdf(1) = 0;
liqbincdf(nliqbin) = 1;
liqbinpdf = [liqbincdf(1:nliqbin)] - [0;liqbincdf(1:nliqbin-1)];


% truncation of liquid assets
liqbintrunc = liqbin(liqbin<=250);
liqbinpdftrunc = liqbinpdf(liqbin<=250);
liqbinpdftrunc(end) = liqbinpdftrunc(end) + sum(liqbinpdf(liqbin>250));

figure;
f   = bar(liqbintrunc, liqbinpdftrunc,'histc');
sh  = findall(gcf,'marker','*'); delete(sh);
set(f,'FaceColor','blue','EdgeColor','red','LineWidth',0.05);
xlim([-20 251]);
ylim([0 0.04]);
text(0,0.035,['$\leftarrow Pr(b=0)=' num2str(round(gbmargallinc(11).*bdelta(11),2)) '$'],'FontSize',20,'interpreter','latex','Color','b');
text(0,0.025,['$\leftarrow Pr(b \in (0,\$2,000])=' num2str(round(liqbinpdf(liqbin==0)+liqbinpdf(liqbin==1)-gbmargallinc(11).*bdelta(11),2)) '$'],'FontSize',20,'interpreter','latex','Color','r');
text(90,0.015,['$Pr(b \geq \$250,000)=' num2str(round(liqbinpdftrunc(end),2)) '\rightarrow $'],'FontSize',20,'interpreter','latex','Color','k');
grid;
xlabel('\$ Thousands','FontSize',20,'interpreter','latex');
title('Liquid wealth distribution','FontSize',20,'interpreter','latex');
set(gca,'FontSize',16) ;
alpha(0.7)
% if Save==0
%     print('-depsc',[SaveDir '/fig_1a']);
% end

%% illiquid wealth distribution - equally spaced bins;
illspace = 10; %thousands
illcdf = cumsum(adelta.*gamargallinc);
illbinmin = illspace;
illbinmax = ceil(agrid(ngpa).*dataannoutput/(4*initss.output*1000));
illbin = [illbinmin:illspace:illbinmax]';
nillbin = size(illbin,1);
illbincdf = interp1(agrid.*dataannoutput/(4*initss.output*1000),illcdf,illbin);
illbincdf(nillbin) = 1;
illbinpdf = [illbincdf(1:nillbin)] - [0;illbincdf(1:nillbin-1)];
illbin = illbin-illspace;

illbintrunc = illbin(illbin<=1000);
illbinpdftrunc = illbinpdf(illbin<=1000);
illbinpdftrunc(end) = illbinpdftrunc(end) + sum(illbinpdf(illbin>1000));


figure;
f   = bar(illbintrunc/1000, illbinpdftrunc,'histc');
sh  = findall(gcf,'marker','*'); delete(sh);
set(f,'FaceColor','blue','EdgeColor','red','LineWidth',0.2);
str = ['$\leftarrow Pr(a=0)=' num2str(round(gamargallinc(1).*adelta(1),2)) '$'];
text(0,0.09,str,'FontSize',20,'interpreter','latex','Color','b');
str = ['$\leftarrow Pr(a \in(0,\$10,000])=' num2str(round(illbinpdf(1) - gamargallinc(1).*adelta(1),2)) '$'];
text(0,0.07,str,'FontSize',20,'interpreter','latex','Color','r');
text(0.37,0.02,['$Pr(a \geq \$1,000,000)=' num2str(round(illbinpdftrunc(end),2)) '\rightarrow $'],'FontSize',20,'interpreter','latex','Color','k');

grid;
xlim([0 1.01]);
ylim([0 0.2]);
xlabel('\$ Millions','FontSize',20,'interpreter','latex');
title('Illiquid wealth distribution','FontSize',20,'interpreter','latex');
set(gca,'FontSize',16) ;
alpha(0.7)

% if Save==0
%     print('-depsc',[SaveDir '/fig_1b']);
% end





%% SCALAR TABLES FOR CALIBRATION
format long;
disp(' ');
disp(['Mean Iliquid Wealth  = '  ,num2str((initss.Ea./(4*initss.output)*100)/100)]);
disp(['Mean Liquid Wealth   = '  ,num2str((initss.Eb./(4*initss.output)*100)/100)]);
disp(['Frac $b=0$ and $a=0$ = '  ,num2str((initss.FRACb0a0*100)/100)]);
disp(['Frac $b=0$ and $a>0$ = '  ,num2str((initss.FRACb0aP*100)/100)]);
disp(['Frac $b<0$           = '  ,num2str((initss.FRACbN*100)/100)]);

return
disp(['Mean Iliquid Wealth  = '  ,num2str(round(initss.Ea./(4*initss.output)*100)/100)]);
disp(['Mean Liquid Wealth   = '  ,num2str(round(initss.Eb./(4*initss.output)*100)/100)]);
disp(['Frac $b=0$ and $a=0$ = '  ,num2str(round(initss.FRACb0a0*100)/100)]);
disp(['Frac $b=0$ and $a>0$ = '  ,num2str(round(initss.FRACb0aP*100)/100)]);
disp(['Frac $b<0$           = '  ,num2str(round(initss.FRACbN*100)/100)]);

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
