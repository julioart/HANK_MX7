
% Description: In the web,
% https://laravel-news.com/iseed-laravel-inverse-seed-generator says that

% Inverse seed generator (iSeed) is a Laravel 4 package that provides a method to generate a new seed file based on data from the existing database table.


% clear
% clc



%%


% % Provide number of observations in sample
% Obs_data = 620107;

disp(['Number of obs are:   ' num2str(Obs_data)])



%Grid of Iseed
Iseed = (1:8000)';

    Obs = NaN(length(Iseed),1);

    for i = 1:length(Iseed)

        b = str2double(regexp(num2str(Iseed(i)),'\d','match'));
        Obs(i) = prod([Iseed(i) b]);

    end


obj = (Obs - Obs_data).^2;

idx = obj == min(obj);

disp(['Your Iseed is:   ' num2str(Iseed(idx))])

