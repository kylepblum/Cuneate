function [catB,catmeanFR,catmeanX] = fitCuneateGLMs(td,ms,params)

numelMS = numel(params.idx_msInputs);
numelEMG = numel(params.idx_emgInputs);
idxCell = params.idxCell;
idxMS = 100:2:301;


if strcmpi(params.trialType,'bump')
    conds = [0 90 180 270];
elseif strcmpi(params.trialType,'all')
    conds = [0 90 180 270 0 pi/2 pi 3*pi/2];
else
    conds = [0 pi/2 pi 3*pi/2]; %Chris's data mixes radians and degrees use
    
end



for j = 1:numel(conds)
    
    dir_params.bumpDir = conds(j);
    dir_params.targDir = conds(j);
    
    if strcmpi(params.trialType,'bump')
        trialsToPlot = getBumpTrials(td,dir_params);
    elseif strcmpi(params.trialType,'all')
        if j <=4
            trialsToPlot = getBumpTrials(td,dir_params);
        else
            trialsToPlot = getActTrials(td,dir_params);
        end
    else
        trialsToPlot = getActTrials(td,dir_params);
    end
    
    for trial = 1:numel(trialsToPlot)
        
        thisTrial = trialsToPlot(trial);
        
        if strcmpi(params.trialType,'bump')
            idxFR = (td(thisTrial).idx_bumpTime):(td(thisTrial).idx_bumpTime+100);
        elseif strcmpi(params.trialType,'all')
            if ~isnan(td(thisTrial).bumpDir(thisTrial))
                idxFR = (td(thisTrial).idx_bumpTime):(td(thisTrial).idx_bumpTime+100);
            else
                idxFR = (td(thisTrial).idx_goCueTime):(td(thisTrial).idx_goCueTime+100);
            end
        else
            idxFR = (td(thisTrial).idx_goCueTime):(td(thisTrial).idx_goCueTime+100);
        end
        
        for i = 1:(numelMS+numelEMG)
            if i <= numelMS
                input(j).X(trial,:,i) = ms(thisTrial,params.idx_msInputs(i)).rd(idxMS);
            else
                input(j).X(trial,:,i) = td(thisTrial).emgNorm(idxFR,params.idx_emgInputs(i-numelMS));
            end
        end
        
        input(j).FR(trial,:) = td(thisTrial).cuneate_spikes(idxFR,idxCell);
        
    end
    
    meanX(:,:,j) = mean(input(j).X,1);
    meanFR(:,j) = mean(input(j).FR,1);
    
    mdl = fitglm(meanX(:,:,j), meanFR(:,j),'linear','Distribution', 'poisson');
    B(:,j) = mdl.Coefficients.Estimate;

    yhat(:,j) = glmval(B(:,j),meanX(:,:,j),'log');
    
    R = corrcoef(yhat(:,j),meanFR(:,j));
    R2 = R(2)^2;

end
catmeanX = [];
catmeanFR = [];

for dim = 1:size(meanX,3)
    catmeanX = [catmeanX; meanX(:,:,dim)];
    catmeanFR = [catmeanFR; meanFR(:,dim)];
end

catmdl =  fitglm(catmeanX,catmeanFR,'linear','Distribution', 'poisson');
catB = catmdl.Coefficients.Estimate;

catyhat = glmval(catB,catmeanX,'log');

carR = corrcoef(catyhat,catmeanFR);
carR2 = carR(2)^2

plot(catyhat); hold on; plot(catmeanFR);

end
