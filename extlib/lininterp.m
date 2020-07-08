function ans = lininterp(A,data_pts)

r = length(A);
num = floor((data_pts-r)/(r-1)); % int number to be inserted in each gap
remd = rem((data_pts-r),(r-1)); % remander of the division
if remd ~= 0
    half1 = round(remd/2); % # of first half values
    half2 = remd - half1; % # of sec half values
    mid = round(r/2); % loc of the midpt
    half1_start = mid-half1;
    half2_start = mid+half2;
else
    half1_start = -1;
    half2_start = -1;
end


B = [];
for i = 1:length(A)-1
   if length(find(half1_start:half2_start-1 ==i)) == 1
       vec = linspace(A(i),A(i+1),num+3);
       if i ~= 1
           vec(1)=[];
       end           
       B = [B vec];
   else
       vec = linspace(A(i),A(i+1),num+2);
       if i ~= 1
           vec(1)=[];
       end
       B = [B vec];
   end
end

ans = B;
end