
%Mexico
kappa0_w	= 0.08;%0.04383;%8.866261638040071E-002;%!0.04383
kappa2_w	= 0.35;%6.055910350823953E-002;%!0.40176

kappa1_w	= 8.198069654434172E-002;
kappa1_wB	= ((1.0-kappa0_w)*(1.0+kappa2_w))^(-1.0/kappa2_w);

% US
kappa0_w	= 0.04383;
kappa2_w	= .8 ;0.40176;
kappa1_wB	= ((1.0-kappa0_w)*(1.0+kappa2_w))^(-1.0/kappa2_w);


a = 2;

d = -5:0.001:5;

k = kappa0_w*abs(d) + kappa1_wB*abs(d/a).^kappa2_w*a;

hold on
plot(d,k)