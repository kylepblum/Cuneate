function [] = nnmfCuneate(td,params)

idxCell = params.idxCell;


if strcmpi(params.trialType,'bump')
    conds = [0 90 180 270];
else
    conds = [0 pi/2 pi 3*pi/2]; %Chris's data mixes radians and degrees use
end


    catInput = [];

for j = 1:numel(conds)
    dir_params.bumpDir = conds(j);
    dir_params.targDir = conds(j);
    if strcmpi(params.trialType,'bump')
        trialsToUse = getBumpTrials(td,dir_params);
    else
        trialsToUse = getActTrials(td,dir_params);
    end
    
    for trial = 1:numel(trialsToUse)
        
        thisTrial = trialsToUse(trial);
        
        if strcmpi(params.trialType,'bump')
            idxFR = (td(thisTrial).idx_bumpTime):(td(thisTrial).idx_bumpTime+100);
        else
            idxFR = (td(thisTrial).idx_goCueTime):(td(thisTrial).idx_goCueTime+100);
        end
      
        input(j).FR(trial,:) = td(thisTrial).cuneate_spikes(idxFR,idxCell);
       
    end
%      catInput = [catInput; input(j).FR];
    
end

catInput = [input(1).FR(1:100,:) input(2).FR(1:100,:) input(3).FR(1:100,:) input(4).FR(1:100,:)];
[w,h] = nnmf(catInput,2);

yhat = w*h;
yhat_bar = mean(yhat);

meanFRtot = mean(catInput);

R = corrcoef(yhat_bar,meanFRtot);
R2 = R(2).^2;

end