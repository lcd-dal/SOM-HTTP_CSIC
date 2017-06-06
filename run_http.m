% Script for running on HTTP CSIC data, 
% then save all the results and data in structured folders.

fsave = 1; %save the figures or not
autoinit = 1; % auto initialization of SOMs based ontraining data
rpath = '/home/lcd/HTTP_CSIC1/'; % result path
ncv = 3; % number of cross validation folds
% map = 1; % keep a map to original data
test_per = 0.5; %percentagee of anomalous data to be used as testing (scheme (i))


if autoinit, rpath = strcat(rpath,'ai'); end
if ncv > 0, rpath= strcat(rpath,'_',int2str(ncv),'cv'); end
if fsave, mkdir(rpath); cd(rpath); end

%% INPUT
train_norm = csvread('nt.csv');
anorm = csvread('an.csv');
test_norm = csvread('ntest.csv');

%% Run 

% data processing to split the anomalous data into 2 parts: train and test
[anormcv] = datproc(anorm,test_per,'normal','datamap',1,'cv',ncv);

for i=1:1 %or 1:ncv for n fold cross validation
    mkdir(int2str(i)); cd(int2str(i));
    training_data.data = [train_norm; anormcv{i}.train.data];
    training_data.map = [1:size(train_norm,1), anormcv{i}.train.map'];
    
    %exploit the function only to shuffle the data
    [tra, ~] = datproc(training_data,0,'normal','datamap',1);
    nclass = 2;
    thedata.tra = tra;
    httptest.data =[test_norm;anormcv{i}.test.data];
    httptest.map = [1:length(test_norm), anormcv{i}.test.map'];
    thedata.test=httptest;
    thedata.nclass = nclass;
    
    sc_june(thedata,fsave,'autoinit',autoinit,'trainlen',[100,400]);
    close all;
    sc_june_normal(thedata,fsave,'autoinit',autoinit,'trainlen',[100,400]);
    close all;
    sc_june_bot(thedata,fsave,'autoinit',autoinit,'trainlen',[100,400]);
    cd ..;
end
