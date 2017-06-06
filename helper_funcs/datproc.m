%  DATPROC Process the dataset: randomize, and split test and train sets using the original distribution or oversampling.
%
%  [train, test] = datproc(data, test_per, mode, [argID, value, ...])
%
%  'data'     (matrix) the raw input data matrix, (nsamples x ndim), last column is the label
%  'test_per' (real number) percentage of test data (0 <= test_per < 1)
%  'mode'     (string)
%               'normal'	create the test set using original data distribution
%  [argID,    (string) See below.
%    value]   (varies)
%
%  train      (struct) struct of processed training data. train.data: the
%                      data, (train.map: the map)
%  test       (struct) struct of processed testing data. test.data: the
%                      data, (test.map: the map)
%
% Here are the valid argument IDs and corresponding values.
%  'datamap'    (binary) 0 (default): not storing the map between original data and processed data, 1: store the map
%  'nclass'     (number) number of classes
% See also

% Copyright (c) 2016 by Duc Le

% Version 1.0 Duc Le 15042016
% Version 2.0 Duc Le 23012017


function [trainout, testout] = datproc(data,test_per,~,varargin)

if isstruct(data)
    inputmap = data.map;
    data = data.data;
end
classes = unique(data(:,end));
nclass = length(classes);
ncv = 1;
datamap = 0; 
i=1;
while i<=length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % argument IDs
            case 'datamap', i=i+1; datamap = varargin{i};
            case 'nclass', i=i+1; nclass = varargin{i};
            case 'cv', i=i+1; ncv = varargin{i};
        end
    end
    i = i+1;
end

% if datamap is required, create one more column at the beginning of the
% data for the map
if datamap
    if exist('inputmap','var')
        if size(inputmap,1) == 1
            data = [inputmap',data];
        else
            data = [inputmap, data];
        end
    else
        data = [(1:size(data,1))', data];
    end
end

if ncv<=1
    %% Randomly separate data into test and train by the percentage
    rand_ind = randperm(size(data,1));
    data = data(rand_ind, :); %shuffle the data
    
    %stratified
    tra = [];
    test = [];
    trcl = unique(data(:,end));
    for ii = 1:length(trcl)
        datai = data(data(:,end)==trcl(ii),:);
        ntraini = ceil((1-test_per)*sum(data(:,end)==trcl(ii)));
        tra = [tra;datai(1:ntraini,:)];
        test = [test; datai(ntraini+1:end,:)];
    end
    
    if datamap % take out the map and put into .map in structs
        trainmap = tra(:,1); tra = tra(:,2:end);
        testmap = test(:,1); test = test(:,2:end);
        trainout.data = tra;
        trainout.map = trainmap;
        testout.data=test;
        testout.map = testmap;
    else
        trainout.data = tra;
        testout.data = test;
    end
    
else
    %% n-fold cross-validation
    units = cell(nclass,ncv);
    classindex = cell(1,nclass);
    for i = 1:nclass
        tmp = find(data(:,end)== classes(i));
        classindex{i} = tmp(randperm(length(tmp)));
    end
    
    data1 = [];
    
    % separate data from each class into a number (ncv) of bins for CV
    for j = 1:nclass
        tmp = classindex{j};
        for i = 1:ncv
            units{j,i} = tmp(ceil((i-1)/ncv*length(tmp))+1:ceil(i/ncv*length(tmp)));
        end
        data1 = [data1,tmp'];
    end
    
    trainout = cell(1,ncv);
    for i = 1:ncv
        testindi = [];
        for j=1:nclass
            testindi = [testindi, units{j,i}'];
        end
        trainindi = setdiff(data1,testindi);
        traini = data(trainindi,:);
        testi = data(testindi,:);
        
        traini = traini(randperm(size(traini,1)),:);
        
        if datamap % take out the map and put into .map in structs
            trainmap = traini(:,1); traini = traini(:,2:end);
            testmap = testi(:,1); testi = testi(:,2:end);
            trainiout.data = traini;
            trainiout.map = trainmap;
            testout.data=testi;
            testout.map = testmap;
        else
            trainiout.data = traini;
            testout.data = testi;
        end
        datai.train = trainiout;
        datai.test=testout;
        trainout{i} = datai;
    end 
end
end