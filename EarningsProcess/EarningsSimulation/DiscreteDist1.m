function Xout = DiscreteDist1(inter,lran)


Xout = 0;

if lran <= inter(1)
    
   Xout = 1;
   
else 
    
    if lran  <= sum(inter) && lran > inter(1)
        
    Xout = 2;

    end
    
end