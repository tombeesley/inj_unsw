function res = calcMissing

PNums = [1:38 40:154];

res = zeros(numel(PNums),4);

pCnt = 0;

for p = PNums;
    
    clc; p
    
    fileName = strcat('Subject', int2str(p));
    load(fileName, 'DATA_CUES_PROC');
    
    pCnt = pCnt + 1;
    
    fixCnt = 0;
    % mean number of fixations
    fixData = DATA_CUES_PROC(:,2);
    for r = 1:size(fixData,1)
        fixCnt = fixCnt + size(fixData{r},1);
    end 
    res(pCnt,1) = fixCnt/size(DATA_CUES_PROC,1);
    
    % number of trials without fixation
    fixData = DATA_CUES_PROC(:,2);
    res(pCnt,2) = sum(cellfun(@isempty,fixData));
    
    % mean prop missing before/after fill
    fillRes = cell2mat(DATA_CUES_PROC(:,4));
    res(pCnt,3:4) = mean(fillRes,1)*100;
    
end

res = [PNums' res];

end