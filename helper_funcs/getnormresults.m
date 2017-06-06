% GETNORMRESULTS get results from training schemes using only normal data
%
% [cmt, dr, acc, qe0] = getnormresults(sm, tra, test, varargin)
% 'sm' (struct) the trained SOM
% 'tra' (struct) training data for analyzing the SOM (lebelling the nodes)
% 'test' (struct) testing data
%
% cmt: confusion matrix, dr: detection rates, acc: accuracy, qe0:
% summarization of qes
%
% Copyright (c) 2016 by Duc Le
%
% Version 1.0 Duc Le 15062016


function [cmt, dr, acc, qe0] = getnormresults(sm, tra, test, varargin)

thres_factor1=.99; % percentage of data accumulated by the counted nodes
data = 1;
detail = 0;
i=1;

qe0.class = cell(1,2);
qe0.node =  cell(1,size(sm.codebook,1));
qe0.classc = cell(1,2);
qe0.classi = cell(1,2);


while i<=length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % argument IDs
            case 'thres_factor1', i=i+1; thres_factor1 = varargin{i};
            case 'threshold1', i=i+1; threshold1 = varargin{i};
            case 'details', i=i+1; detail = varargin{i};
        end
    end
    i = i+1;
end

if data == 1
    test.data(:,end)=test.data(:,end)-1;
end

if detail == 0
    test.data(test.data(:,end)>1,end)=2;
else
    qe0.class = cell(1,max(test.data(:,end)));
end

%trainhits
h = som_hits(sm, tra.data(:,1:end-1));
% [bmus, qes] = som_bmus(sm,tra.data(:,1:end-1),'all');


if exist('threshold1','var')
    ignodes1 = find(h <= threshold1);
else
    [~, ind] = sort(h,'descend');
    hb = cumsum(h(ind))/sum(h);
    cp = find(hb >= thres_factor1,1,'first');
    ignodes1 = ind(cp+1:end);
end

cmt = zeros(2);
if detail
    cmt= zeros(3);
end

if data  == 1 || data==2
    for i=1:size(test.data,1)
        [b, qe] = som_bmus(sm,test.data(i,1:end-1),1);
        if ismember(b, ignodes1)
            if (detail && test.data(i,end) > 2)
                cmt(test.data(i,end),test.data(i,end)) = cmt(test.data(i,end),test.data(i,end)) +1;
            else
                cmt(test.data(i,end),2) = cmt(test.data(i,end),2) +1;
            end
            
            if test.data(i,end) < 2 % normal (but classified as bot)
                qe0.classi{1,test.data(i,end)} = [qe0.classi{1,test.data(i,end)}, qe];
            else % bot, and classified as bot
                qe0.classc{1,2} = [qe0.classc{1,2}, qe];
            end
        else
            cmt(test.data(i,end),1) = cmt(test.data(i,end),1) +1;
            if test.data(i,end) >= 2
                qe0.classi{1,2} = [qe0.classi{1,2}, qe];
            else
                qe0.classc{1,1} = [qe0.classc{1,1}, qe];
            end
        end
        
        qe0.class{1,test.data(i,end)} =  [qe0.class{1,test.data(i,end)}, qe];
        qe0.node{b} = [qe0.node{b}, qe];
        
    end
end

dr = [cmt(1,1)/sum(cmt(1,:)), cmt(2,2)/sum(cmt(2,:))];
acc = (cmt(1,1)+cmt(2,2))/sum(sum(cmt));
if length(cmt) >=3 && sum(cmt(3,:)) > 0
    dr = [dr,cmt(3,3)/sum(cmt(3,:))];
    acc = (cmt(1,1)+cmt(2,2)+cmt(3,3))/sum(sum(cmt));
end
