
%Mexico

close all
%%
kk = 1;%[0.05:.1:5];

for i = 1:length(kk)
kappa0_w	= 0.01;%4.649554980188626E-002;
kappa2_w	= 4;%kk(i);%1.16488398350350;

kappa1_w	= 1.854462208602996E-002;
kappa1_wB	= ((1.0-kappa0_w)*(1.0+kappa2_w))^(-1.0/kappa2_w);

% % US
% kappa0_w	= 0.04383;
% kappa2_w	= 0.40176;
% kappa1_wB	= ((1.0-kappa0_w)*(1.0+kappa2_w))^(-1.0/kappa2_w);


a = 2;

d = -5:0.001:5;

k = kappa0_w*abs(d) + kappa1_w*abs(d/a).^kappa2_w*a;

figure(1)
pause(.1)
hold on
% plot(d,k,'k')
plot(d,k,'r')
ylim([0 .1])

end