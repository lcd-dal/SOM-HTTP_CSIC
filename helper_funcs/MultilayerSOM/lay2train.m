%  LAY2TRAIN Train layer 2 (and possibly 3,4,5,...) layer of SOM

%  [ sMap, data, bmus,hits ] = lay2train( lay2dat, mode, samplingmode,classdist,layer, [argID, value, ...])
%
%  'lay2dat'     (matrix) training data, (nsamples x ndim), last column is the label
%  'mode'     (string)
%               'indiv' train nextlayer maps for each node
%  'classdist'  (vector) class distribution
%  'layer'  (number) the layer

% Copyright (c) 2016 by Duc Le

% Version 1.0 Duc Le 18042016



function [ sMap, data ] = lay2train( lay2dat, mode, samplingmode,classdist,layer, varargin )

% threshold for identify which node will be expanded to next layer
threshold = .97;

i=1;
autoinit=1;
while i<=length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % argument IDs
            case 'maxlayer', i=i+1; maxlayer = varargin{i};
            case 'autoinit', i=i+1; autoinit = varargin{i};
        end
    end
    i = i+1;
end

indmat = lay2dat.indicator;
hs = [];
for i=1:size(indmat,2), hs = [hs, 2^(i-1)]; end
realind = sum(indmat.* repmat(hs,size(indmat,1),1),2);

sMap = struct;

indica = find(realind ~= 0);

sMap.ind = indica;
sMap.maps = {};
sMap.lab = {};

if strcmp(mode,'indiv') 
%% individually train next layer for each node
sMap.pointer = zeros(1, length(indmat));
sMap.pointer(indica) = indica;

for i=1:length(indica)
	data = lay2dat.data{indica(i)};
	% hard coded sizes of higher layer maps and training length if autoinit
	% = 0
	[sm2, lab2] = som_train_class(data,'msize',[15 15],'classdist',classdist,...
		'samplingmode',samplingmode,'trainlen',[100 400],'autoinit',autoinit);
	sMap.maps{indica(i)} = sm2;
	sMap.lab{indica(i)}=lab2;
end
end
end
