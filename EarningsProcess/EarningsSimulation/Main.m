% This code simulates the earning process laid out in Kaplan, Moll and
% Violante (2018)

% Translates the fortran code Simulate.f90 and ComputeMoments.f90 into
% Matlab

tic
clc; clear

%% Jump process parameters
ruta = '/Users/julioartcarrillo/Documents/Work@home/HANK/Codigos/HANK_original/EarningsProcess/EarningsEstimation/earnings_estimation_output/';

dp = importdata([ruta 'parameters.txt']);


for i = 1:length(dp.data)
eval([dp.rowheaders{i} '= dp.data(i);']);
end


% This is the tricky part, similar to Merton's difussion process
phi1 = lambda1*sigma1^2/(2*delta1 + lambda1);
phi2 = lambda2*sigma2^2/(2*delta2 + lambda2);


%% Time and cross-section parameters 

nsim    = 25000;   % Number of people
dt      = 0.25;    % Time step in quarters
Tburn   = floor(100/dt)+1; % Total time steps to burn for 100 quarters
Tsim    = Tburn + floor(20/dt)+1; % Time periods to simulate
Tann    = (Tsim-Tburn)*dt/4; % Time in years


%% Pre-allocate shocks

% Chosen to replicate more accurately Kaplan et al moments 
rng(2000) % Seed of random number generator

% Normal shocks
y1rand = randn(nsim,Tsim);
y2rand = randn(nsim,Tsim);


% Uniform shocks

    %simulate Inverse Seed (Iseed) algorithm
    % Obs_data = 620107; % Provide number of observations in 1-year comparison
    % FindSeed
    % rng(Iseed(idx)); %random number generator
rng(7755)
y1jumprand = rand(nsim,Tsim);

    %simulate Inverse Seed (Iseed) algorithm
    % Obs_data = 620107; % Provide number of observations in 4-year comparison
    % FindSeed
    % rng(Iseed(idx)); %random number generator
rng(7744)
y2jumprand = rand(nsim,Tsim);

%% Initial income

%preallocate simulation matrices
y1sim = nan(nsim,Tsim);
y2sim = nan(nsim,Tsim);
ysim  = nan(nsim,Tsim);

y1jumpI = nan(nsim,Tsim);
y2jumpI = nan(nsim,Tsim);

y1sim(:,1) = phi1^.5*y1rand(:,1);
y2sim(:,1) = phi2^.5*y2rand(:,1);

ysim(:,1) = y1sim(:,1) + y2sim(:,1);

%% Poisson process

% DiscreteDist1 takes a random variable (yxjumprand) from a uniform distribution.
% If this variable is higher than threshold (given by interx(1)), then the outcome is 2, i.e. a jump



inter1 = [1-dt*lambda1, dt*lambda1];
inter2 = [1-dt*lambda2, dt*lambda2];

% tic
for i = 1:nsim
    
    for j = 1:Tsim-1
    
    % jump indicator for process 1    
    Xout = DiscreteDist1(inter1,y1jumprand(i,j));

    y1jumpI(i,j) =  Xout -1;

    %Simulation
        if y1jumpI(i,j) == 1

           y1sim(i,j+1) = sigma1*y1rand(i,j+1);

        else

           y1sim(i,j+1) = (1 - dt*delta1)*y1sim(i,j);

        end

    % jump indicator for process 2
    Xout = DiscreteDist1(inter2,y2jumprand(i,j));

    y2jumpI(i,j) =  Xout -1;

    %Simulation
        if y2jumpI(i,j) == 1

           y2sim(i,j+1) = sigma2*y2rand(i,j+1);

        else

           y2sim(i,j+1) = (1 - dt*delta2)*y2sim(i,j);

        end
        
        
    ysim(i,j+1) = y1sim(i,j+1) + y2sim(i,j+1);

    end
end
% toc

%exp of income
ylevsim = exp(ysim);

%% aggregate to annual income


% tic
for i = 1:nsim
    for j = 1:Tann
            j1 = Tburn + 1 + floor(4.0/dt)*(j-1);
            jN = j1-1 + floor(4.0/dt);
            yannlevsim(i,j) = sum(ylevsim(i,j1:jN));
    end
end
% toc
	

yannsim = log(yannlevsim);



%% Moments, according to fortran code

clc 
% central moments
muy = sum(yannsim(:,1))/nsim;
mu2y = sum((yannsim(:,1)-muy).^2)/nsim;


% central moments: 1 year log changes
mudy1 = sum(yannsim(:,2)-yannsim(:,1))/nsim;
mu2dy1 = sum((yannsim(:,2)-yannsim(:,1)-mudy1).^2)/nsim;
mu3dy1 = sum((yannsim(:,2)-yannsim(:,1)-mudy1).^3)/nsim;
mu4dy1 = sum((yannsim(:,2)-yannsim(:,1)-mudy1).^4)/nsim;

% standardised moments: 1 year log changes
if mu2dy1 > 0  
	gam3dy1 = mu3dy1/(mu2dy1^1.5);
	gam4dy1 = mu4dy1/(mu2dy1^2);
else
	gam3dy1 = 0;
	gam4dy1 = 0;
end

% central moments: 5 year log changes (i.e. 4 years)
mudy5 = sum(yannsim(:,5)-yannsim(:,1))/nsim;
mu2dy5 = sum((yannsim(:,5)-yannsim(:,1)-mudy5).^2)/nsim;
mu3dy5 = sum((yannsim(:,5)-yannsim(:,1)-mudy5).^3)/nsim;
mu4dy5 = sum((yannsim(:,5)-yannsim(:,1)-mudy5).^4)/nsim;

% standardised moments: 5 year log changes (i.e. 4 years)
if mu2dy5 > 0
	gam3dy5 = mu3dy5/(mu2dy5^1.5);
	gam4dy5 = mu4dy5/(mu2dy5^2);
else
	gam3dy5 = 0
	gam4dy5 = 0
end

%fortran code:
% fracdy1less10 = COUNT(ABS(yannsim(:,2)-yannsim(:,1)) < 0.1)/nsim

h   = abs(yannsim(:,2)-yannsim(:,1));

idx = h < 0.1;
fracdy1less10 = sum(idx)/nsim;

idx = h < 0.2;
fracdy1less20 = sum(idx)/nsim;

idx = h < 0.5;
fracdy1less50 = sum(idx)/nsim;

moments = NaN(8,1);

moments(1) = mu2y;
moments(2) = mu2dy1;
moments(3) = mu2dy5;
moments(4) = gam4dy1;
moments(5) = gam4dy5;
moments(6) = fracdy1less10;
moments(7) = fracdy1less20;
moments(8) = fracdy1less50;

disp('Moments according to fortran code')
round(moments*100)/100


% histogram(h,'Normalization','cdf')




%% Moments, alternative code

do_alternative = 0;

if do_alternative
    
    dy1 = yannsim(:,2)-yannsim(:,1);
    dy5 = yannsim(:,5)-yannsim(:,1);


    momentsALT = NaN(8,1);

    momentsALT(1) = mean(var(yannsim));
    momentsALT(2) = var(dy1);
    momentsALT(3) = var(dy5);
    momentsALT(4) = kurtosis(dy1);
    momentsALT(5) = kurtosis(dy5);
    momentsALT(6:8) = invprctile(abs(dy1),[10 20 50]/100)'/100;


    disp('Moments according to alternative code')
    round(momentsALT*100)/100

end
toc
