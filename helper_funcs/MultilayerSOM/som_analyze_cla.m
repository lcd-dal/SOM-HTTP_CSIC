% SOM_ANALYZE_CLA analyze the prev layer SOM and feed data to next layer by
% calling lay2train

function [sm2] = som_analyze_cla(tra,bmus,hits,classdist,sm,l2mode,samplingmode, maxlayer, currentlayer, varargin )
i=1;
autoinit=1;
while i<=length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % argument IDs
            case 'autoinit', i=i+1; autoinit = varargin{i};
        end
    end
    i = i+1;
end

nclass = size(classdist,1);
if currentlayer <= maxlayer

    lay2 = struct;
    lay2.indicator = [];
    lay2.data = {};
    datasize = 0;

    if strcmp(samplingmode,'normal')
        h1=hits./repmat(classdist(unique(tra(:,end))),size(hits,1),1);
    else
        h1 = hits;
    end
    h1=h1./repmat(sum(h1,2),1,size(h1,2));
    for i=1:size(hits,1)
        if strcmp(l2mode,'indiv') && sum(hits(i,:)) < 1000 
            lay2.indicator = [lay2.indicator; zeros(1,nclass)];
        else
            indi = zeros(1,nclass);
            for j = 1:nclass
                if h1(i,j) > .01
                    indi(j) = 1;
                end
            end
            lay2.indicator = [lay2.indicator; indi];
            lay2.data{i} = tra(bmus==i,:);
            datasize = datasize+size(lay2.data{i},1);
        end
    end
    
    if strcmp(l2mode,'indiv')
        sm2 = lay2train(lay2,l2mode,samplingmode,classdist,currentlayer,'pca',0,'autoinit', autoinit);
    end

else
    sm2=struct;
end

end

