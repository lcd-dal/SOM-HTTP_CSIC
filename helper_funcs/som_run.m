% SOM_RUN complete function for running som for classification
% 
% [acc,cmt,dr,sm,sm2,l1lab,bmus,hits,qe] = som_run(tra,test,maxlayer,msize,radius,trainlen,classdist,samplingmode,l2mode,[argID, value, ...])
% 
% 'tra', 'test' (matrices) training and testing data, ninstances x ndim,
%                           last column is label
% 'maxlayer' (scaler) maximum number of layers
% 'msize'    (1x2 vector) size of the SOM
% ...
% 
% 'sm' (struct) trained SOM map (level 1)
% 'sm2' (struct) trained SOM map (multi level)
% 'acc': accuracy, 'dr': detection rate, 'cmt': confusion matrix
% 'l1lab': label for layer 1 SOM, 'qe': quantizaion error

% Copyright (c) 2016 by Duc Le

% Version 1.0 Duc Le 15042016
% Version 1.1 Duc Le 19102016. Add auto initialization

function [acc,cmt,dr,sm,sm2,l1report,runtime] = som_run(tra,test,maxlayer,msize,radius,trainlen,classdist,samplingmode,varargin)

nclass = max(unique(tra(:,end)));
i=1; runlay1=1; plotmode =1;
l2mode = 'clustering';

% auto initializaion indicator. If autoinit, discard the input size,
% trainlen, radius
autoinit = 0; dataname = '';

while i<=length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % argument IDs
            case 'l2mode', i = i+1; l2mode = varargin{i};
            case 'dname', i=i+1; dataname = varargin{i};
            case 'sm', i=i+1; sm = varargin{i}; runlay1=0;
                i=i+1; l1lab = varargin{i}.l1lab;
                bmus = varargin{i}.bmus;
                hits = varargin{i}.hits;
            case 'plotmode', i=i+1; plotmode = varargin{i};
            case 'autoinit', i=i+1; autoinit = varargin{i};
        end
    end
    i = i+1;
end

tic
if runlay1
    currentlayer = 1;
    [sm,l1lab,bmus,hits] =  som_train_class(tra,'msize',msize,...
        'trainlen',trainlen,'radius',radius,'classdist', ...
        classdist,'samplingmode',samplingmode,'plotmode',plotmode, ...
        'autoinit',autoinit,'dname',dataname);
    currentlayer = currentlayer+1;
else
    currentlayer=2;
    plotdata(sm, tra(:,1:end-1),tra,plotmode);
end

[sm2] = som_analyze_cla(tra,bmus,hits,classdist,sm,l2mode,samplingmode,maxlayer,currentlayer,'autoinit', autoinit);
% end
runtime = toc;
%% TEST PART

plotm = 0;
if maxlayer > 1
    cmt = som_test(sm,sm2,test,l1lab,nclass,plotm);
else
    [cmt,qe] = somcalcqecmt(sm,test,l1lab,plotmode);
end

dr=zeros(1,nclass);
for i = 1:nclass, dr(i) = cmt(i,i)/sum(cmt(i,:)); end
s = 0;
for i=1:nclass, s=s+cmt(i,i); end
acc = s/sum(sum(cmt));
l1report.bmus = bmus;
l1report.hits = hits;
l1report.l1lab=l1lab;
if maxlayer <=1, l1report.qe=qe; end
