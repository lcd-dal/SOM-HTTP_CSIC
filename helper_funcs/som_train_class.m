% SOM_TRAIN_CLASS train som for classification application.
%
% [sm,lab,bmus,hits,nhit] = som_train_class(data, [argID, value, ...])
%
% 'data' (matrix)   the input processed training data
%  [argID,    (string) See in function.
%    value]   (varies)
%
% 'sm' (struct) the trained SOM, only 1 layer
% 'lab' (vector)  label of nodes in the SOM
% 'hits' (matrix) nnodes x nclasses, hit matrix of data on the SOM
% 'nhit' (matrix) nnodes x nclasses, normalized hit matrix of data on the SOM

% Copyright (c) 2016 by Duc Le

% Version 1.0 Duc Le 15042016
% Version 1.1 Duc Le 19102016. Add auto initialization

function [sm,lab,bmus,hits,nhit,runtime] = som_train_class(varargin)

data = varargin{1};
class = unique(data(:,end));

msize = [12 12]; radius = [6 1.5 1.5 1.5];
trainlen=[200 800];

samplingmode = 'normal';
lattice = 'hexa'; neigh = 'gaussian';
plotmode = 0;
autoinit = 0; % auto initializaion indicator
dataname = '';
i=2;
while i<=length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % argument IDs
            case 'msize', i=i+1; msize = varargin{i};
            case 'dname', i=i+1; dataname = varargin{i};
            case 'lattice', i=i+1; lattice = varargin{i};
            case 'samplingmode', i=i+1; samplingmode = varargin{i};
            case 'classdist', i=i+1; classdist = varargin{i};
            case 'radius', i=i+1; radius = varargin{i};
            case 'trainlen', i=i+1; trainlen = varargin{i};
            case 'neigh', i=i+1; neigh = varargin{i};
            case 'plotmode', i=i+1; plotmode = varargin{i};
            case 'autoinit', i=i+1; autoinit = varargin{i};
        end
    end
    i = i+1;
end

tra = data;
str = tra(:,1:end-1);

radius_coarse = radius(1:2);
radius_fine = radius(3:4);
trainlen_coarse = trainlen(1);
trainlen_fine = trainlen(2);
tic

% SOM initialization
if ~autoinit
    smI = som_lininit(str, 'msize', msize, 'lattice', lattice, ...
        'shape', 'sheet');
    % Coarse training: (do this for backward compatibility)
    smC = som_batchtrain(smI, str, 'radius', radius_coarse, ...
        'trainlen', trainlen_coarse, 'neigh', neigh);
    % Fine training:
    sm = som_batchtrain(smC, str, 'radius', radius_fine,...
        'trainlen', trainlen_fine, 'neigh', neigh);
    
else % automatically initialization
    smI = som_lininit(str, 'lattice', lattice, 'shape', 'sheet','dname',dataname);
    if max(smI.topol.msize)<=6
        smI = som_lininit(str, 'msize',[6,6], 'lattice', lattice, 'shape', 'sheet','dname',dataname);
    end
    
    if min(smI.topol.msize)<6
        idx = find(smI.topol.msize == min(smI.topol.msize));
        if idx==2
            smI = som_lininit(str, 'msize',[max(smI.topol.msize),6], 'lattice', lattice, 'shape', 'sheet','dname',dataname);
        else
            smI = som_lininit(str, 'msize',[6,max(smI.topol.msize)], 'lattice', lattice, 'shape', 'sheet','dname',dataname);
        end
    end
    radius_coarse = [0.25*max(smI.topol.msize), max(1,0.05*min(smI.topol.msize))];
    radius_fine = [radius_coarse(2), radius_coarse(2)];
    %trainlen_fine = 200;
    
    % Coarse training: (do this for backward compatibility)
    smC = som_batchtrain(smI, str, 'radius', radius_coarse, ...
        'trainlen', trainlen_coarse, 'neigh', neigh);
    % Initial Fine training:
    sm = som_batchtrain(smC, str, 'radius', radius_fine,...
        'trainlen', trainlen_fine, 'neigh', neigh);
    
    % Stopping rule
    R = 1000000; % any large number bigger than norm(sm.codebook)
    
    while R - norm(sm.codebook) > 0
        R = norm(sm.codebook);
        sm = som_batchtrain(sm, str, 'radius', radius_fine, ...
            'trainlen', 1, 'neigh', neigh);
    end
    
end
runtime = toc;

[bmus,hits,nhit] = plotdata(sm, str,tra,plotmode,classdist);

nhits = hits;
if strcmp(samplingmode,'normal')
    classdist = classdist(class);
    nhits = nhits./repmat(classdist,size(nhits,1),1);
end

lab = zeros(1, size(sm.codebook,1));
for i = 1:size(sm.codebook,1)
    lab(i) = class(find(nhits(i,:)==max(nhits(i,:)),1,'last'));
end

end