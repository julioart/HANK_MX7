
close all

Y = 100*log(NOFS.sticky.output./NOFS.initss.output);
C = 100*log(NOFS.sticky.Ec./NOFS.initss.Ec);
P = 400.*NOFS.sticky.pi;
R = 400*(NOFS.sticky.rb-NOFS.initss.rb);


m = mean(P(1:4))/mean(Y(1:4))




%%
mx = 2.112726157329186; %Mexico
mu = 2.025026990543237; %US



y = -2:.05:2;
px = mx*y; 
pu = mu*y;

plot(y,[px' pu'])