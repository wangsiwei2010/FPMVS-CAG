clear;
clc;
warning off;
addpath(genpath('./'));

%% dataset
ds = {'Caltech101-20'};

dsPath = './0-dataset/';
resPath = './res-lmd0/';
metric = {'ACC','nmi','Purity','Fscore','Precision','Recall','AR','Entropy'};

for dsi = 1
    % load data & make folder
    dataName = ds{dsi}; disp(dataName);
    load(strcat(dsPath,dataName));
    k = length(unique(Y));
    
    
    matpath = strcat(resPath,dataName);
    txtpath = strcat(resPath,strcat(dataName,'.txt'));
    if (~exist(matpath,'file'))
        mkdir(matpath);
        addpath(genpath(matpath));
    end
    dlmwrite(txtpath, strcat('Dataset:',cellstr(dataName), '  Date:',datestr(now)),'-append','delimiter','','newline','pc');
    
    %% para setting
    anchor = k ;
    d = (1)*k ;
    lambda=0;
    
    %%
    for ichor = 1:length(anchor)
        for id = 1:length(d)
            tic;
            [U,A,W,Z,iter,obj,alpha,P] = algo_qp(X,Y,lambda,d(id),anchor(ichor)); % X,Y,lambda,d,numanchor
            res = myNMIACCwithmean(U,Y,k); % [ACC nmi Purity Fscore Precision Recall AR Entropy]
            timer(ichor,id)  = toc;
            fprintf('Anchor:%d \t Dimension:%d\t Res:%12.6f %12.6f %12.6f %12.6f \tTime:%12.6f \n',[anchor(ichor) d(id) res(1) res(2) res(3) res(4) timer(ichor,id)]);
            
            resall{ichor,id} = res;
            objall{ichor,id} = obj;
            
            dlmwrite(txtpath, [anchor(ichor) d(id) res timer(ichor,id)],'-append','delimiter','\t','newline','pc');
            matname = ['_Anch_',num2str(anchor(ichor)),'_Dim_',num2str(d(id)),'.mat'];

            save([matpath,'/',matname],'Z','A','W','alpha');
            %save([matpath,'/',matname],'P');
            % save all res and obj in one mat
            %%save([resPath,'All_',dataName,'.mat'],'resall','objall','metric');
        end
    end
    clear resall objall X Y k
end


