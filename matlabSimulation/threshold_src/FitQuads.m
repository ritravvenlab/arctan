function quads = FitQuads(segments,image,debug)
quads = [];
for i = 1:length(segments)
    quads = [quads;QuadChecker(segments(i).AddedPixels,image)];
end

if(debug)
    %Debug visualization
    figure('Name','Detected Quads with intersections');
    imshow(image);
    title('Detected Quads with intersections');
    hold on;
    for i = 1:size(quads,1)
        Seg1 = [quads(i,1),quads(i,3); quads(i,2), quads(i,4)];
        Seg2 = [quads(i,3),quads(i,5); quads(i,4), quads(i,6)];
        Seg3 = [quads(i,5),quads(i,7); quads(i,6), quads(i,8)];
        Seg4 = [quads(i,7),quads(i,1); quads(i,8), quads(i,2)];
        
        plot(Seg1(1,:),Seg1(2,:),'r-','LineWidth',2);
        plot(Seg2(1,:),Seg2(2,:),'r-','LineWidth',2);
        plot(Seg3(1,:),Seg3(2,:),'r-','LineWidth',2);
        plot(Seg4(1,:),Seg4(2,:),'r-','LineWidth',2);
        scatter([quads(i,1),quads(i,3),quads(i,5),quads(i,7)],...
            [quads(i,2),quads(i,4),quads(i,6),quads(i,8)],15,'go');
        scatter([sum(Seg1(1,:))/2,sum(Seg2(1,:))/2,sum(Seg3(1,:))/2,sum(Seg4(1,:))/2],...
            [sum(Seg1(2,:))/2,sum(Seg2(2,:))/2,sum(Seg3(2,:))/2,sum(Seg4(2,:))/2],15,'go');
    end
end


end

function quadpts = QuadChecker(this_cluster,image)
res = 0; quadpts = [];

max_nmaxima = 10;

width = size(image,2);
height = size(image,1);
sz = size(this_cluster,1);

if(sz < 4)
    return; %We cannot fit a quad with less than 4 pts
end
xmax = 0; xmin = flintmax; ymax = 0; ymin = flintmax;

%compute a bounding box around the points so we can compute all the thetas
%around a center point
for i = 1:sz
   xmax = max(xmax,this_cluster(i,1));
   xmin = min(xmin,this_cluster(i,1));
   ymax = max(ymax,this_cluster(i,2));
   ymin = min(ymin,this_cluster(i,2));
end

%Add some noise to the center point to get a more diverse set of thetas
cx = (xmin + xmax) * 0.5 + 0.05118;
cy = (ymin + ymax) * 0.5 + -0.028581;

dot = 0;

for i = 1:sz
   dx = this_cluster(i,1) - cx;
   dy = this_cluster(i,2) - cy;
   
   this_cluster(i,5) = gcordicatan2(dy,dx, luts);
   
   dot = dot + (dx*this_cluster(i,3) + dy*this_cluster(i,4));
end

if(dot < 0) %Make sure that the black border is inside the white border
    return;
end

this_cluster = sortrows(this_cluster,5); %sort points to help elimate duplicates
outpos = 1;
lastIdx = 1;
tmpArray = zeros(sz,5);
for j = 2:sz
    if(this_cluster(j,1) ~= this_cluster(lastIdx,1)...
    || this_cluster(j,2) ~= this_cluster(lastIdx,2))
    lastIdx = j;
    tmpArray(outpos,:) = this_cluster(j,:);
    outpos = outpos + 1;
    end
end

tmpArray(tmpArray(:,1) == 0,:) = []; %Clear out empty entires
this_cluster = tmpArray;             %Copy over array
sz = size(this_cluster,1);           %Update the size

if(size(this_cluster,1) < 4) %We can't fit fewer than 4 points
    return;
end

lfps = zeros(size(this_cluster,1),6); %Preallocate variable

%Precompute stats that allows us to fit lines efficently between indices
for i = 1:sz
    if(i > 1)
        lfps(i,:) = lfps(i-1,:);
    end
    delta = 0.5;
    x = floor(this_cluster(i,1) * 0.5 + delta);
    y = floor(this_cluster(i,2) * 0.5 + delta);
    ix = x;
    iy = y;
    W = 1;
    
    if(ix > 1 && ix+1 <= width && iy > 1 && iy+1 <= height)
       grad_x = image(iy,ix+1) - image(iy,ix-1);
       grad_y = image(iy+1,ix) - image(iy-1,ix);
       W = sqrt(grad_x*grad_x + grad_y*grad_y) + 1;
    end
    
    fx = x; fy = y;
    lfps(i,1) = lfps(i,1) + (W * fx);       %Mx
    lfps(i,2) = lfps(i,2) + (W * fy);       %My
    lfps(i,3) = lfps(i,3) + (W * fx * fx);  %Mxx
    lfps(i,4) = lfps(i,4) + (W * fx * fy);  %Mxy
    lfps(i,5) = lfps(i,5) + (W * fy * fy);  %Myy
    lfps(i,6) = lfps(i,6) + W;              %W
    
end
    
ksz = min(20, floor(sz/12));

if(ksz < 2) %kernel too small abort
    return;
end

errs = zeros(sz,1);
for i = 0:sz
   i0 = floor(mod((i + sz - ksz), sz-1))+2;
   i1 = floor(mod(i+ksz,sz-1))+2;

   [~,test,~] = fit_line(lfps,sz,i0,i1); 
   errs(i+1) = test;
end
    
%low pass the errors
y = zeros(sz,1);
sigma = 1;
cutoff = 0.05;
fsz = sqrt(-log(cutoff)*2*sigma*sigma) + 1;
fsz = floor(2*fsz+1);

f = zeros(fsz,1);

for i = 1:fsz
    j = i - fsz / 2;
    f(i) = exp(-j*j/(2*sigma*sigma));
end

for iy = 1:sz
    acc = 0;
    for i = 1:fsz
        acc = acc + errs(floor(mod(iy + i - fsz / 2 + sz,sz))+1) * f(i);
    end
    y(iy) = acc;
end

errs = y;

maxima = zeros(sz,1);
maxima_errs = zeros(sz,1);
nmaxima = 1;

for i = 1:sz
    next_pt = floor(mod(i,sz-1))+1;
    prev_pt = floor(mod(i+sz-2,sz))+1;
    if(errs(i) > errs(next_pt) && errs(i) > errs(prev_pt))
        maxima(nmaxima) = i;
        maxima_errs(nmaxima) = errs(i);
        nmaxima = nmaxima + 1;
    end
end
nmaxima = nmaxima - 1;
if (nmaxima < 4)
    return;
end


if(nmaxima > max_nmaxima)
    
end

max_dot = cos(10*(pi/180));
max_mse = 10;
best_error = realmax;

for m0 = 1:nmaxima-3
    i0 = maxima(m0);
    for m1 = m0+1:nmaxima-2
    i1 = maxima(m1);
    [params01,err01,mse01] = fit_line(lfps,sz,i0,i1);
    if(isempty(mse01) || isnan(mse01))
        continue;
    end
    if(mse01 > max_mse)
        continue;
    end
        for m2 = m1+1:nmaxima-1
            i2= maxima(m2);
            [params12,err12,mse12] = fit_line(lfps,sz,i1,i2);
            if(isempty(mse12) || isnan(mse12))
                continue;
            end
            if(mse12 > max_mse)
                continue;
            end

            dot = params01(3)*params12(3) + params01(4)*params12(4);
            if(abs(dot) > max_dot)
                continue;
            end

                for m3 = m2+1:nmaxima-0
                i3= maxima(m3);
                [params23,err23,mse23] = fit_line(lfps,sz,i2,i3);
                if(isempty(mse23) || isnan(mse23))
                    continue;
                end
                if((mse23 > max_mse))
                    continue;
                end
                [params30,err30,mse30] = fit_line(lfps,sz,i3,i0);
                if(mse30 > max_mse || isnan(mse30))
                    continue;
                end

                err = err01 + err12 + err23 + err30;
                if(err < best_error)
                    best_error = err;
                    best_idxs = [i0,i1,i2,i3];
                end
                end
        end
    end 
end
if(best_error == realmax)
    return;
end




quadpts = [this_cluster(best_idxs(1),1)/2,this_cluster(best_idxs(1),2)/2;this_cluster(best_idxs(2),1)/2,this_cluster(best_idxs(2),2)/2;this_cluster(best_idxs(3),1)/2,this_cluster(best_idxs(3),2)/2;this_cluster(best_idxs(4),1)/2,this_cluster(best_idxs(4),2)/2];
% lines = zeros(4,4);    
% for i = 1:4
%     i0 = best_idxs(i);
%     i1 = best_idxs(floor(mod(i,4))+1);
%     
%     [lines(i,:),~,err] = fit_line(lfps,sz,i0,i1);
%     
%     if(err > 10)
%         quadpts = [];
%         return;
%     end
% end
% 
% for i = 1:4
%     A00 =  lines(i,4); A01 = lines(floor(mod(i,4))+1,4);
%     A10 = -lines(i,3); A11 = lines(floor(mod(i,4))+1,3);
%     B0  = -lines(i,1) + lines(floor(mod(i,4))+1,1);
%     B1  = -lines(i,2) + lines(floor(mod(i,4))+1,2);
%     
%     det = A00 * A11 - A10 * A01;
%     
%     W00 = A11 / det; W01 = -A01 / det;
%     
%     if(abs(det) < 0.001)
%         quadpts = [];
%         return;
%     end
%     
%     L0 = W00*B0 + W01*B1;
%     
%     quadpts(i,1) = lines(i,1) + L0*A00;
%     quadpts(i,2) = lines(i,2) + L0*A10;
% end

if(1) %Check if the quad is large enough
    area = 0;
    length = zeros(3,1);
    for i = 1:3
       idxa = i;
       idxb = floor(mod(i,3))+1;
       length(i) = sqrt((quadpts(idxb,1) - quadpts(idxa,1)).^2 +...
                        (quadpts(idxb,2) - quadpts(idxa,2)).^2);
    end
    p = sum(length) / 2;
    area = area + (sqrt(p*(p-length(1))*(p-length(2))*(p-length(3))));
    idxs = [3,4,1,3];
    for i = 1:3
       idxa = idxs(i);
       idxb = idxs(i+1);
       length(i) = sqrt((quadpts(idxb,1) - quadpts(idxa,1)).^2 +...
                        (quadpts(idxb,2) - quadpts(idxa,2)).^2);
    end
    p = sum(length) / 2;
    area = area + (sqrt(p*(p-length(1))*(p-length(2))*(p-length(3))));

    d = 8;
    if (area < d*d)
        quadpts = [];
        return;
    end
end

if(1)
    total = 0;
    
    for i = 1:4
       i0 = i; i1 = floor(mod(i,4))+1; i2 = floor(mod(i+1,4))+1;
       
       theta0 = gcordicatan2(quadpts(i0,2) - quadpts(i1,2),...
                      quadpts(i0,1) - quadpts(i1,1));
       theta1 = gcordicatan2(quadpts(i2,2) - quadpts(i1,2),...
                      quadpts(i2,1) - quadpts(i1,1));
                  
       dtheta = theta0 - theta1;
       
       %Have to shift by 2PI
       if(dtheta < 0)
           dtheta = dtheta + (2*pi);
       end
       
       %Reject if the theta deviates too much or too little
       if(dtheta < (10*(pi/180)) || dtheta > (pi - (10*(pi/180))))
           quadpts = [];
           return;
       end
       
       total = total + dtheta; 
    end
    
    %We are looking for 2PI
    if(total < 6.2 || total > 6.4)
        quadpts = [];
        return;
    end
    
end

quadpts = [quadpts(4,:),quadpts(3,:),quadpts(2,:),quadpts(1,:)];

end

function [lineparm, err, mse] = fit_line(lf_pts, sz, i0, i1)
lineparm = []; err = []; mse = [];
if(i0 == i1)
    return;
end

if(i0 <= 1 || i1 <= 1 || i0 > sz || i1 > sz)
    return;
end

%Mx = 0; My = 0; Mxx = 0; Myy = 0; W = 0;

if (i0 < i1)
    N = (i1) - (i0) + 1;
    Mx  = lf_pts(i1,1); %Mx
    My  = lf_pts(i1,2); %My
    Mxx = lf_pts(i1,3); %Mxx
    Mxy = lf_pts(i1,4); %Mxy
    Myy = lf_pts(i1,5); %Myy
    W   = lf_pts(i1,6); %W
    
    if(i0 > 1)
        Mx  = Mx  - lf_pts(i0-1,1); %Mx
        My  = My  - lf_pts(i0-1,2); %My
        Mxx = Mxx - lf_pts(i0-1,3); %Mxx
        Mxy = Mxy - lf_pts(i0-1,4); %Mxy
        Myy = Myy - lf_pts(i0-1,5); %Myy
        W   = W   - lf_pts(i0-1,6); %W
    end
else
    if(i0 < 2)
        return;
    end
    
    Mx  = lf_pts(sz,1) - lf_pts(i0-1,1);
    My  = lf_pts(sz,2) - lf_pts(i0-1,2);
    Mxx = lf_pts(sz,3) - lf_pts(i0-1,3);
    Mxy = lf_pts(sz,4) - lf_pts(i0-1,4);
    Myy = lf_pts(sz,5) - lf_pts(i0-1,5);
    W   = lf_pts(sz,6) - lf_pts(i0-1,6);
    
    Mx  = Mx  + lf_pts(i1,1); %Mx
    My  = My  + lf_pts(i1,2); %My
    Mxx = Mxx + lf_pts(i1,3); %Mxx
    Mxy = Mxy + lf_pts(i1,4); %Mxy
    Myy = Myy + lf_pts(i1,5); %Myy
    W   = W   + lf_pts(i1,6); %W
    
    N = sz - (i0) + (i1) + 1;
end
if(N <= 2)
    return;
end

Ex = Mx / W;
Ey = My / W;
Cxx = Mxx / W - Ex*Ex;
Cxy = Mxy / W - Ex*Ey;
Cyy = Myy / W - Ey*Ey;

normal_theta = 0.5 * gcordicatan2(-2*Cxy,(Cyy-Cxx));
nx = cos(normal_theta);
ny = sin(normal_theta);

lineparm = [Ex,Ey,nx,ny];

err = nx*nx*N*Cxx + 2*nx*ny*N*Cxy + ny*ny*N*Cyy;
if(isnan(err))
    Ohno =1;
end
mse = nx*nx*Cxx + 2*nx*ny*Cxy + ny*ny*Cyy;
end