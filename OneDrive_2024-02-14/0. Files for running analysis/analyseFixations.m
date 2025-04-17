function allResults = analyseFixations

%PNums = 97:154;
PNums = 21;


allResults = zeros(numel(PNums), 15);

pCnt = 0;

for p = PNums;
    
    
    
    fileName = strcat('Subject', int2str(p));
    load(fileName, 'DATA_CUES_PROC');
    details = cell2mat(DATA_CUES_PROC(:,1));
    
    results = zeros(60,5);
    
    for t = 1:60
        
        tData = DATA_CUES_PROC{t,2};
                
        for f = 1:size(tData,1)
           
            if details(t,3) == 1 % target on left or right
                AOI = checkEGOnStim(tData(f,1),tData(f,2),[160 290 860 790; 1060 290 1760 790]);
            else
                AOI = checkEGOnStim(tData(f,1),tData(f,2),[1060 290 1760 790; 160 290 860 790]);
            end 
            
            if AOI > 0
                if sum(results(t,:)) == 0
                    results(t,5) = AOI;
                end
                results(t,AOI) = results(t,AOI) + 1; % accumulate entries on AOI
                results(t,AOI+2) = results(t,AOI+2) + tData(f,3); % accumulate time on AOI
            end
            
            
        end
        
        
        
    end
    
    
    % average data for allresults array
    pCnt = pCnt + 1;
    
    results = [details results];
    
    step = 1;
    for tt = 1:3
        tempRes = results(results(:,2)==tt,:);
        allResults(pCnt,step:step+3) = mean(tempRes(:,4:7),1);
        allResults(pCnt,step+4) = mean(tempRes(:,8)==1,1);
        step = step + 5;
    end



end

allResults = [PNums' allResults];
%save('allResults') - code from meeting w Ange to save on the spot

writematrix(allResults, 'Fixationdata.xls') %VM added the save as excel sheet code - not sure if it will stuff anything
%up but it worked for now.
end