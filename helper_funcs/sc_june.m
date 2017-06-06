%  SC_JUNE Run som on the data (isot or (normal+bot+cc) part of CTU13).
%  Then save all the results and figures
%
%  sc_june(data, fsave, [argID,value,...])
%
%  'data' (struct) struct contain randomized training and testing data
%  'fsave'  (binary) 0: not save the figs, 1: save
%  'dlab'   (vector) the vector containing data labels, 1 x ninstances
%   [argID, value]   (string, varies) See in function.

% Copyright (c) 2016 by Duc Le

% Version 1.0 Duc Le 15062016


function sc_june(data, fsave, varargin)

thres  = .99;
% auto initialization
autoinit = 0; 
msize = [30 30]; radius = [10 3 3 3];
% test_per = 0.4;
trainlen=[200 200];
samplingmode = 'normal';
normalize_mode = 'var';
makedir = 1; dataname = 'any'; plottest = 1;
i=1;
while i<=length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % argument IDs
            case 'threshold', i=i+1; thres = varargin{i};
            case 'msize', i=i+1; msize = varargin{i};
            case 'autoinit', i=i+1; autoinit = varargin{i};
            case 'nomkdir', makedir = 0;
            case 'trainlen', i=i+1; trainlen = varargin{i};
            case 'plottest', i=i+1; plottest = varargin{i};
            case 'normalizemode', i=i+1; normalize_mode = varargin{i};
        end
    end
    i = i+1;
end


%% DATA PROC

[ tra1, tra1b, tra, test1, nclass, classdist] = normalizedata( data, normalize_mode, 'both', 0 );

%% train normal and bot
    
% 1 layer SOM
maxlayer = 1;
[acc1,cmt,dr,sm1,~, l1report, runtime] = som_run(tra1.data,test1.data,maxlayer,msize,...
    radius,trainlen,classdist,samplingmode,'plotmode',0,'autoinit',autoinit);

% get reference results from multilayer SOM, with 6x6 layer 1
l2mode = 'indiv'; maxlayer = 3;
msizei = [6 6]; radius = [3 1 1 1];
[acc4,cmt4,dr4,smi,smi2, ~,runtimei] = som_run(tra1.data,test1.data,maxlayer,...
    msizei,radius,trainlen,classdist,samplingmode,'l2mode',l2mode,'plotmode',0);



%% PLOT

if (fsave && makedir)
    fname = 'normalandmal';
    mkdir(fname); cd(fname);
end

% plotdata(sm1, tra.data(:,1:end-1),tra.data,4,classdist,samplingmode,'SOM_hits-all-class_Umat');
% savef(fsave,'SOM_hits-all-class_Umat');

for i = 2:max(tra.data(:,end))
    tmp = strcat('SOM_hits-class',int2str(i),'_Umat');
    plotdata(sm1, tra.data(tra.data(:,end)==i,1:end-1),tra.data(tra.data(:,end)==i,end),4,classdist,samplingmode,'');
    savef(fsave,tmp);
end

plotdata(sm1, tra1.data(:,1:end-1),tra1.data,4,classdist,samplingmode,'');
savef(fsave,'SOM_hits-normal-and-bot_Umat');

if plottest
    for i = 2:max(test1.data(:,end))
        tmp = strcat('Test_SOM_hits-class',int2str(i),'_Umat');
        plotdata(sm1, test1.data(test1.data(:,end)==i,1:end-1),test1.data(test1.data(:,end)==i,:),4,classdist,samplingmode,'');
        savef(fsave,tmp);
    end

    plotdata(sm1, test1.data(:,1:end-1),test1.data,4,classdist,samplingmode,'');
    savef(fsave,'Test_SOM_hits-normal-and-bot_Umat');
end


if fsave
    clearvars tmp str fname tra tra1 tra1b test test1 spambase ans l2mode makedir msize radius i fsave ;
    if length(strfind(dataname,'CTU13')) <1
        clearvars ba1 bb1 bn1 rp1;
    end
    save('normalandmal.mat');
    cd ..;
end

end