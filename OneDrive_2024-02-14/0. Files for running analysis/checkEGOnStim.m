function detected = checkEGOnStim(x,y,stimArray)

detected = 0;
for s = 1:size(stimArray,1)
    checks = [x>stimArray(s,1) y>stimArray(s,2) x<stimArray(s,3) y<stimArray(s,4)]; %this checks the LTRB dimensions of the shape.
    if sum(checks)==4;
        detected = s;
        return
    end
end

end