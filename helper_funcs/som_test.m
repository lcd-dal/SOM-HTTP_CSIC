% SOM_TEST Test the trained multi-layer SOM on the test data. It can also
% plot the data on levels of the map

% 'cmt' (matrix) nclass x nclass: confusion matrix

function [cmt] = som_test(sm,sm2,test,lab,nclass,plotm)

[bmus, hits] = plotdata(sm, test(:,1:end-1), test,plotm);
classdist = sum(hits,1);

cmt = zeros(nclass);

l1map.maps{1} = sm;
l1map.nextlayer = sm2;
l1map.lab{1} = lab;
l1map.pointer = ones(1,size(sm.codebook,1));

if plotm
    cmt = recurCal(l1map,test);
else
    for ii = 1:size(test,1)
        out = recurCal2(l1map,test(ii,:),bmus(ii));
        cmt(test(ii,end),out) = cmt(test(ii,end),out) +1;
    end
end


    function cmatrix = recurCal(smap, testdata)
        cmatrix = zeros(length(classdist));
        
        if isfield(smap,'nextlayer')
            nLay2Maps = length(smap.nextlayer.maps);
            data2Lay2 = cell(1,nLay2Maps);
        end
        nextlayTest = [];
        [bmus2] = plotdata(smap.maps{1}, testdata(:,1:end-1), testdata,plotm, classdist);
        for i = 1:length(bmus2)
            if isfield(smap,'nextlayer')
                p = smap.nextlayer.pointer(bmus2(i));
            else
                p=0;
            end
            if p ~= 0
                if sum(smap.nextlayer.pointer)
                    nextlayTest = [nextlayTest; testdata(i,:)];
                end
                
                if plotm
                    if isempty(data2Lay2{p}),
                        data2Lay2{p} = testdata(i,:);
                    else
                        data2Lay2{p} = [data2Lay2{p}; testdata(i,:)];
                    end
                end
            end
            
            if p == 0
                cmatrix(testdata(i,end),smap.lab{1}(bmus2(i))) = cmatrix(testdata(i,end),smap.lab{1}(bmus2(i)))+1;
            end
        end
        
        if  isfield(smap,'nextlayer') && sum(smap.nextlayer.pointer)
            cmatrix = cmatrix+recurCal(smap.nextlayer,nextlayTest);
        end
        
        if plotm && isfield(smap,'nextlayer')
            for i = 1:nLay2Maps
                if ~isempty(smap.nextlayer.maps{i})
                    plotdata(smap.nextlayer.maps{i}, data2Lay2{i}(:,1:end-1), data2Lay2{i}(:,end),2,classdist);
                end
            end
        end
    end


%% Subfunction for finding output class of a test instance from multilayer SOM
    function classout = recurCal2(smap, testinstance,bmu1)
        ind = smap.pointer(bmu1);
        if ind ~= 0
            if isfield(smap,'pca')
                pcaparam = smap.pca{ind};
                if size(pcaparam.stdparam,1)==2
                    t1 = ((testinstance(pcaparam.ind)-pcaparam.stdparam(1,:))./pcaparam.stdparam(2,:))*pcaparam.coeff;
                else
                    t1 = (testinstance(pcaparam.ind)-pcaparam.stdparam(1,:))*pcaparam.coeff;
                end
                testinstance =  [t1(1:pcaparam.cutpoint), testinstance(end)];
            end

            if ~isempty(smap.maps{ind})
                bmu = som_bmus(smap.maps{ind},testinstance(1:end-1));  

                if isfield(smap,'nextlayer') && isstruct(smap.nextlayer)
                        classout = recurCal2(smap.nextlayer, testinstance, bmu);

                elseif isfield(smap,'nextlayer') && iscell(smap.nextlayer) 
                    if ind <= size(smap.nextlayer,2)    
                        nextmap = smap.nextlayer{ind};
                            if ~isempty(nextmap)
                                classout = recurCal2(nextmap, testinstance, bmu);
                            end
                    end
                end
                if ~exist('classout','var') || classout == -1
                    classout = smap.lab{ind}(bmu);
                end
            else
                classout = -1;
            end

        else
            classout = -1;
        end

    end
end