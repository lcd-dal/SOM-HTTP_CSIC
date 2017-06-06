%  PLOTDATA Calculates BMUs, hit matrices and plot hit figures.
%
%  [bmu,hits,nhit] = plotdata(sm, d, dlab, plotmode, [value])
%
%  'sm' (struct) the trained SOM map
%  'd'  (matrix) the data, ninstances x ndim
%  'dlab'   (vector) the vector containing data labels, 1 x ninstances
%  'plotmode' (scale)
%                   0 no plot
%                   1 plot in pie chart fot hit in each node,and hit in
%                       non-pure nodes
%                   3 plot in different figures for each node
%                   4 plot in one map the hit of all class, as hex on each
%                     node
%    [value]   (varies) See below.
%
%  bmu      (vector) bmus of instances in the data
%  hits     (matrix) nnodes x nclass matrix contains hit by class per each
%                       node
%  nhit     (matrix) nnodes x nclass matrix contains normalized hit by
%                       class per each node
%
% Here are the valid values.
%  'classdist'    (vector) class distribution in the data
%  'samplingmode'    (string) samplingmode
%  'tit'     (string) title for the figure

% Copyright (c) 2016 by Duc Le

% Version 1.0 Duc Le 15042016

function [bmu,hits,nhit] = plotdata(varargin)
mode = 'crisp';
sm = varargin{1}; d = varargin{2}; dlab = varargin{3}; plotmode = varargin{4};

if size(d,1) ==0
    return
end

if nargin >=5
    classdist = varargin{5};
    if nargin >= 6
        samplingmode = varargin{6};
        if nargin >= 7
            tit = varargin{7};
        end
    end
end

bmu = som_bmus(sm,d);
class = unique(dlab(:,end));
nclass = length(class);
hits = zeros(size(sm.codebook,1),nclass);

for k = 1:nclass
    hits(:,k) = som_hits(sm,d(dlab(:,end)==class(k),:),mode);
end

if nargin < 5
    sumhit = repmat(sum(hits,1),size(hits,1),1);
    color = jet(nclass);
else
    sumhit = repmat(classdist(class),size(hits,1),1);
    color = jet(size(classdist,2));
    color = color(class,:);
end

nhit = hits./sumhit;

if plotmode > 0
    figure('vis','off');
    
    a = sum(hits,2);
    a = sqrt(a/max(a));
    
    %% plot umatrix and hit
    if plotmode == 4
        if nargin >=6
            colormap(0.6*(pink));
            if nargin >= 7
                umathandle = som_show(sm,'umati',{'all',tit});
            else
                umathandle = som_show(sm,'umati','all');
            end
            h = [];
            for i=1:nclass
                d1 = d(dlab(:,end) == class(i),:);
                h1=som_hits(sm,d1,mode);
                h= [h,h1];
            end
            for i=1:nclass
                % s = (max(h(:,i))/max(max(h)))^(1/3);
                % s = (max(h(:,i))/max(max(h)));
                handles(i) = som_show_add('hit',h(:,i),'Markercolor',color(i,:));%,'MarkerSize',s);
            end
            
            if length(handles) > 1
                l = legend(handles,'Normal','Anomalous','Location','bestoutside');
            end
        end
    end
    
    %% deprecated
    if plotmode ==1
        figure;
        x=hits;y = nhit;
        for i = 1:size(x,1)
            % remove all the pure nodes
            if max(x(i,:))/sum(x(i,:))>.99
                x(i,:) = 0; y(i,:) = 0;
            end
        end
        
        if nargin >=6 && strcmp(samplingmode,'oversampling')
            %             som_pieplane(sm, x,color,a);figure;
            som_pieplane(sm, hits,color,a);
            
        else
            % plot the non-pure nodes
            subplot(1,2,1); som_pieplane(sm, x,color,a);
            subplot(1,2,2); som_pieplane(sm, y,color,a);
            figure;
            % plot all
            subplot(1,2,1); som_pieplane(sm, hits,color,a)
            subplot(1,2,2); som_pieplane(sm, nhit,color,a)
        end
    end
    
    if plotmode ==3
        figure;
        colormapigray = ones(64,3) - colormap('gray');
        colormap(colormapigray);
        for k=1:nclass
            subplot(1,nclass,k);
            som_cplane(sm, hits(:,k));
            set(gca,'FontSize',10);
            if class(k) == 1, title('Background');
            elseif class(k) == 2, title('Normal');
            else, title('Botnet');
            end
        end
    end
end