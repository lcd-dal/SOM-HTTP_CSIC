%  SC_JUNE_NORMAL Run som on the NORMAL data only (isot or (normal) part of CTU13).
%  Then save all the results and figures
%
%  sc_june_normal(data, fsave, [argID,value,...])
%
%  'data' (struct) struct contain randomized training and testing data
%  'fsave'  (binary) 0: not save the figs, 1: save
%  'dlab'   (vector) the vector containing data labels, 1 x ninstances
%   [argID, value]   (string, varies) See in function.

% Copyright (c) 2016 by Duc Le

% Version 1.0 Duc Le 15062016


function sc_june_normal(data, fsave, varargin)

normal_thres = 0.95; % threshold to determine which SOM node is normal
msize = [20 20]; radius = [6 1.5 1.5 1.5];
trainlen=[200 200];
samplingmode = 'normal';
% auto initialization
autoinit = 0;
dataname = ''; plottest = 1;
normalize_mode = 'var';
i=1;
while i<=length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % argument IDs
            case 'threshold', i=i+1; thres = varargin{i};
            case 'msize', i=i+1; msize = varargin{i};
            case 'autoinit', i=i+1; autoinit = varargin{i};
            case 'trainlen', i=i+1; trainlen = varargin{i};
            case 'plottest', i=i+1; plottest = varargin{i};
            case 'normalizemode', i=i+1; normalize_mode = varargin{i};
        end
    end
    i = i+1;
end


%% DATA PROC
[ tra1, tra1b, tra, test1, ~, classdist] = normalizedata( data, normalize_mode, 'normal', 0 );

%% train the som and get results
[sm1,~,~,~,~,runtime] =  som_train_class(tra1.data,'msize',msize,'dname',dataname,...
    'trainlen',trainlen,'radius',radius,'classdist',classdist,'samplingmode',samplingmode,'autoinit',autoinit);
[cmt, dr, acc, qe] = getnormresults(sm1, tra1, test1,'thres_factor1',normal_thres,'details',1);

%% PLOT

if fsave
    fname = 'normal';
    mkdir(fname); cd(fname);
end

plotdata(sm1, tra.data(:,1:end-1),tra.data,4,classdist,samplingmode,'SOM_hits-all-class_Umat');
savef(fsave,'SOM_hits-all-class_Umat');

for i = 2:max(tra.data(:,end))
    tmp = strcat('SOM_hits-class',int2str(i),'_Umat');
    plotdata(sm1, tra.data(tra.data(:,end)==i,1:end-1),tra.data(tra.data(:,end)==i,:),4,classdist,samplingmode,tmp);
    savef(fsave,tmp);
end

plotdata(sm1, tra.data(tra.data(:,end)>1,1:end-1),tra.data(tra.data(:,end)>1,end),4,classdist,samplingmode,'SOM_hits-normal-and-bot_Umat');
savef(fsave,'SOM_hits-normal-and-bot_Umat');

if plottest
    for i = 2:max(test1.data(:,end))
        tmp = strcat('Test_SOM_hits-class',int2str(i),'_Umat');
        plotdata(sm1, test1.data(test1.data(:,end)==i,1:end-1),test1.data(test1.data(:,end)==i,:),4,classdist,samplingmode,tmp);
        savef(fsave,tmp);
    end

    plotdata(sm1, test1.data(:,1:end-1),test1.data,4,classdist,samplingmode,'Test_SOM_hits-normal-and-bot_Umat');
    savef(fsave,'Test_SOM_hits-normal-and-bot_Umat');    
    
end


if fsave
    clearvars tmp str fname tra tra1 tra1b test test1 spambase ans l2mode makedir msize radius i fsave ;
    if length(strfind(dataname,'CTU13')) <1
        clearvars ba1 bb1 bn1 rp1;
    end
    save('normal.mat');
    cd ..;
end

end