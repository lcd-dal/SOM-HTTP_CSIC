% INSPECTBACKGROUND get distribution of background data on the trained SOM
%
% [bn, ba, bb, rp] = inspectbackground(sm, tra, bdata, mode, thres,varargin)
%
% 'sm' (struct) the trained SOM
% 'tra' (struct) training data for analyzing the SOM (lebelling the nodes)
% 'bdata' (struct) the background (unknown) data
% 'mode' (string) can be normal, normalandbot, or bot
% 'thres' (number) 0 < thres < 1: threshold for identifying important nodes
%                   for each class
% 'bn/bb/ba' (number) percentage of background labelled as normal/bot/anomaly
% 'rp' (struct) the report, with multiple level of detail
%
% Copyright (c) 2016 by Duc Le
%
% Version 1.0 Duc Le 15062016


function [bn, ba, bb, rp] = inspectbackground(sm, tra, bdata, mode, thres,varargin)

detail = 0;
i=1;
while i<=length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % argument IDs
            case 'detail', i=i+1; detail = varargin{i};
        end
    end
    i = i+1;
end


if strcmp(mode,'normalandbot')
    hitn = som_hits(sm, tra.data(tra.data(:,end)==2, 1:end-1));
    hitb = som_hits(sm, tra.data(tra.data(:,end)==3, 1:end-1));
    
    [~, ind1] = sort(hitn,'descend');
    hn = cumsum(hitn(ind1))/sum(hitn);
    cpn = find(hn >= thres,1,'first');
    
    [~, ind2] = sort(hitb,'descend');
    hb = cumsum(hitb(ind2))/sum(hitb);
    cpb = find(hb >= thres,1,'first');
    
    normalneurons = ind1(1:cpn);
    botneurons = ind2(1:cpb);
    tmp = 1:size(sm.codebook,1);
    rp.anomalyneurons = tmp(~ismember(tmp,normalneurons) & ~ismember(tmp,botneurons));
    
    rp.mutualneurons = intersect(botneurons, normalneurons);
    rp.botneurons = botneurons(~ismember(botneurons,rp.mutualneurons));
    rp.normalneurons = normalneurons(~ismember(normalneurons,rp.mutualneurons));

    hitbg = som_hits(sm, bdata.data(:, 1:end-1));
    
    if detail
        bgnormal = []; qen = [];
        bganomaly = []; qea = [];
        bgbot = []; qeb = [];
        bgmutual = []; qem = [];
        [bmusbg, qebg] = som_bmus(sm, bdata.data(:, 1:end-1));
        for i = 1:length(bmusbg)
            if ismember(bmusbg(i),rp.normalneurons)
                bgnormal = [bgnormal, bdata.map(i)];
                qen = [qen, qebg(i)];
            elseif ismember(bmusbg(i),rp.botneurons)
                bgbot = [bgbot, bdata.map(i)];
                qeb = [qeb, qebg(i)];
            elseif ismember(bmusbg(i),rp.mutualneurons)
                bgmutual = [bgmutual, bdata.map(i)];
                qem = [qem, qebg(i)];
            else
                bganomaly = [bganomaly, bdata.map(i)];
                qea = [qea, qebg(i)];
            end
        end
        rp.bn = bgnormal;
        rp.ba = bganomaly;
        rp.bb = bgbot;
        rp.bm = bgmutual;
        rp.qen = qen;
        rp.qeb = qeb;
        rp.qea = qea;
        rp.qem = qem;
        rp.qe = zeros(1,6);
        rp.qe(1,1:2) = [mean(qen(qen<100)), std(qen(qen<100))];
        rp.qe(1,3:4) = [mean(qea(qea<100)), std(qea(qea<100))];
        rp.qe(1,5:6) = [mean(qeb(qeb<100)), std(qeb(qeb<100))];
    end
    
    bn = sum(hitbg(rp.normalneurons))/sum(hitbg);
    bb = sum(hitbg(rp.botneurons))/sum(hitbg);
    ba = sum(hitbg(rp.anomalyneurons))/sum(hitbg);
    
elseif strcmp(mode, 'normal')
    hitn = som_hits(sm, tra.data(tra.data(:,end)==2, 1:end-1));
    
    [~, ind1] = sort(hitn,'descend');
    hn = cumsum(hitn(ind1))/sum(hitn);
    cpn = find(hn >= thres,1,'first');
    
    rp.normalneurons = ind1(1:cpn);
    tmp = 1:size(sm.codebook,1);
    rp.anomalyneurons = tmp(~ismember(tmp,rp.normalneurons));
    
    hitbg = som_hits(sm, bdata.data(:, 1:end-1));
    
    if detail
        bgnormal = []; qen  =[];
        bganomaly = []; qea = [];
        [bmusbg, qebg] = som_bmus(sm, bdata.data(:, 1:end-1));
        for i = 1:length(bmusbg)
            if ismember(bmusbg(i),rp.normalneurons)
                bgnormal = [bgnormal, bdata.map(i)];
                qen = [qen, qebg(i)];
            else
                bganomaly = [bganomaly, bdata.map(i)];
                qea = [qea, qebg(i)];
            end
        end
        rp.bn = bgnormal;
        rp.ba = bganomaly;
        rp.qen = qen;
        rp.qea = qea;
        rp.qe = zeros(1,4);
        rp.qe(1,1:2) = [mean(qen(qen<100)), std(qen(qen<100))];
        rp.qe(1,3:4) = [mean(qea(qea<100)), std(qea(qea<100))];
    end
    
    bn = sum(hitbg(rp.normalneurons))/sum(hitbg);
    bb = 0;
    ba = sum(hitbg(rp.anomalyneurons))/sum(hitbg);
    
elseif strcmp(mode,'bot')
    hitb = som_hits(sm, tra.data(tra.data(:,end)>=3, 1:end-1));
    
    [~, ind1] = sort(hitb,'descend');
    hb = cumsum(hitb(ind1))/sum(hitb);
    cpb = find(hb >= thres,1,'first');
    
    rp.botneurons = ind1(1:cpb);
    tmp = 1:size(sm.codebook,1);
    rp.notbotneurons = tmp(~ismember(tmp,rp.botneurons));
    
    hitbg = som_hits(sm, bdata.data(:, 1:end-1));    
    
    if detail
        bgbot = []; qeb  =[];
        bganomaly = []; qea = [];
        [bmusbg, qebg] = som_bmus(sm, bdata.data(:, 1:end-1));
        for i = 1:length(bmusbg)
            if ismember(bmusbg(i),rp.botneurons)
                bgbot = [bgbot, bdata.map(i)];
                qeb = [qeb, qebg(i)];
            else
                bganomaly = [bganomaly, bdata.map(i)];
                qea = [qea, qebg(i)];
            end
        end
        rp.bb = bgbot;
        rp.ba = bganomaly;
        rp.qeb = qeb;
        rp.qea = qea;
        rp.qe = zeros(1,4);
        rp.qe(1,1:2) = [mean(qea(qea<100)), std(qea(qea<100))];
        rp.qe(1,3:4) = [mean(qeb(qeb<100)), std(qeb(qeb<100))];
    end
    
    bb = sum(hitbg(rp.botneurons))/sum(hitbg);
    bn = 0;
    ba = sum(hitbg(rp.notbotneurons))/sum(hitbg);

elseif strcmp(mode,'zeus')
    hitz = som_hits(sm, tra.data);
    
    [~, ind1] = sort(hitz,'descend');
    hz = cumsum(hitz(ind1))/sum(hitz);
    cp = find(hz >= thres,1,'first');
    
    rp.botneurons = ind1(1:cp);
    tmp = 1:size(sm.codebook,1);
    rp.notbotneurons = tmp(~ismember(tmp,rp.botneurons));
    
    hitbg = som_hits(sm, bdata);
    
    bb = sum(hitbg(rp.botneurons))/sum(hitbg);
    bn = 0;
    ba = sum(hitbg(rp.notbotneurons))/sum(hitbg);
end
    

end