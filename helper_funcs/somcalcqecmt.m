%  SOMCALCQECMT get summarization of qe for nodes, classes, correct and
%  incorrect data, as well as confusion matrix from the trained SOM and
%  testing data
%
%  [cmt, qe] = somcalcqecmt( sm, test, l1lab, plotmode )
%
% Copyright (c) 2016 by Duc Le
%
% Version 1.0 Duc Le 15062016


function [ cmt, qe ] = somcalcqecmt( sm,test,l1lab,plotmode )

nclass = max(unique(l1lab));

qe.class = cell(1,nclass);
qe.node =  cell(1,length(l1lab));
qe.classc = cell(1,nclass);
qe.classi = cell(1,nclass);

plotdata(sm, test(:,1:end-1),test,plotmode);
[test_bmus,qes] = som_bmus(sm,test(:,1:end-1));
cmt = zeros(nclass);
for u=1:size(test,1)
    c = test_bmus(u);
    cmt(test(u,end),l1lab(c)) = cmt(test(u,end),l1lab(c))+1;

    qe.class{1,test(u,end)} =  [qe.class{1,test(u,end)}, qes(u)];
    qe.node{c} = [qe.node{c}, qes(u)];

    if test(u,end) == l1lab(c)
        qe.classc{1,test(u,end)} = [qe.classc{1,test(u,end)}, qes(u)];
    else
        qe.classi{1,test(u,end)} = [qe.classi{1,test(u,end)}, qes(u)];
    end

end

end