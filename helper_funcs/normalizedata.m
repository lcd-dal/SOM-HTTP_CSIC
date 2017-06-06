function [ tra1, tra1b, tra, test1, nclass, classdist] = normalizedata( data, normalizemode, trainmode, runpca )
%NORMALIZEDATA Normalize/Standardize the data. Do PCA after that if
%indicated
pca_cutpoint = 0.95;

tra = data.tra;
test = data.test;
nclass = data.nclass;


%% Normalize/Standardize and split into sets
if strcmp(trainmode,'both') %use both classes for training
    tmp = tra.data(:,end)==1;
    % tra1: real train set
    tra1=tra; tra1.data(tmp,:)=[]; tra1.map(tmp)=[];
elseif strcmp(trainmode,'normal') % use only normal for training
    tmp = (tra.data(:,end)<=1 | tra.data(:,end)>=3);
    tra1=tra; tra1.data(tmp,:)=[]; tra1.map(tmp)=[];
elseif strcmp(trainmode,'malicious') % use only malicious for training
    tmp = (tra.data(:,end)<=2);
    tra1=tra; tra1.data(tmp,:)=[]; tra1.map(tmp)=[];
end

if runpca
    %% PCA if speccified
    del = [];
    for i=1:size(tra1.data,2)-1
        if length(unique(tra1.data(:,i)))==1
            del = [del,i];
        end
    end
    
    tra.data(:,del)=[]; tra1.data(:,del)=[]; test.data(:,del)=[];
    
    datmean = mean(tra1.data(:,1:end-1));
    datstd = std(tra1.data(:,1:end-1));
    [coeff, tmp, latent] = pca(zscore(tra1.data(:,1:end-1)));
    nlatent = cumsum(latent)/sum(latent);
    cutpoint = find(nlatent> pca_cutpoint,1,'first');
    
    display(strcat('# dimensions after PCA: ',num2str(cutpoint)))
    tra1.data = [tmp(:,1:cutpoint),tra1.data(:,end)];
    
    tmp = tra.data(:,1:end-1);
    tmp = (tmp - repmat(datmean,size(tmp,1),1))./repmat(datstd,size(tmp,1),1);
    tmp = tmp*coeff;
    tra.data = [tmp(:,1:cutpoint),tra.data(:,end)];
    tra1b.data = tra.data(tra.data(:,end)==1,:);
    tra1b.map = tra.map(tra.data(:,end)==1);
    
    tmp = test.data(:,1:end-1);
    tmp = (tmp - repmat(datmean,size(tmp,1),1))./repmat(datstd,size(tmp,1),1);
    tmp = tmp*coeff;
    test.data = [tmp(:,1:cutpoint),test.data(:,end)];
    test1.data = test.data(test.data(:,end)>1,:);
    test1.map = test.map(test.data(:,end)>1);
else
    %% only normalize/standardize
    % str: struct data of str1
    
    if ~strcmp(normalizemode,'no')
        str = som_data_struct(tra1.data(:,1:end-1));
        str = som_normalize(str,normalizemode);
        % update tra1
        tra1.data(:,1:end-1) = str.data;
        % update tra
        tmp = som_normalize(tra.data(:,1:end-1),str);
        tra.data = [tmp, tra.data(:,end)];

        % tra1b: train set with only background
        tra1b.data = tra.data(tra.data(:,end)==1,:);
        tra1b.map = tra.map(tra.data(:,end)==1);
        % update test: real test set used for calculating results
        tmp = test.data(:,end)>1;
        test1.data = test.data(tmp,:);
        test1.map = test.map(tmp);
        tmp = som_normalize(test1.data(:,1:end-1),str);
        test1.data = [tmp, test1.data(:,end)];
    else
        tra1b.data = tra.data(tra.data(:,end)==1,:);
        tra1b.map = tra.map(tra.data(:,end)>1);
        test1.data = test.data(test.data(:,end)>1,:);
        test1.map = test.map(test.data(:,end)>1);
    end

end

for i=1:max(unique(data.test.data(:,end)))
    classdist(i) = sum(tra1.data(:,end)==i);
end
%  test_balance = datproc(test1.data,0,'balance');

end

