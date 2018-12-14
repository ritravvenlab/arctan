function threshim = threshold(image,min_wb_diff)
width = size(image,2);
height = size(image,1);
tilesz = 4;
tw = floor(width/tilesz);
th = floor(height/tilesz);
threshim = zeros(height,width);

local_max = zeros(th,tw);
local_min = zeros(th,tw);
for ty = 0:th-1
    for tx = 0:tw-1
        max = 0; min = 255;
        for dy = 1:tilesz
            for dx = 1:tilesz 
                v = image(((ty)*tilesz)+dy,(tx)*tilesz+dx);
                
                if(v < min)
                    min = v;
                end
                if(v > max)
                    max = v;
                end
            end
        end
        local_min(ty+1,tx+1) = min;
        local_max(ty+1,tx+1) = max;
    end
end
% figure; imshow(local_min/1);
% figure; imshow(local_max/1);
% figure; imshow((local_max-local_min)/1);

if(1)
%Make copies of the local min/max and convolve it again to reduce
%artifacts and abrupt changes
tmp_min = zeros(th,tw);
tmp_max = zeros(th,tw);
for ty = 0:th-1
    for tx = 0:tw-1
        this_min = 255; this_max = 0;
        
        for dy = 2:4
            if(ty+(dy-2) < 1 || ty+(dy-2) > th)
                continue;
            end
            for dx = 2:4
                if(tx+(dx-2) < 1 || tx+(dx-2) > tw)
                    continue;
                end
            if(this_min > local_min((ty+(dy-2)),(tx+(dx-2))))
                this_min = local_min((ty+(dy-2)),(tx+(dx-2)));
            end
            
            if(this_max < local_max((ty+(dy-2)),(tx+(dx-2))))
                this_max = local_max((ty+(dy-2)),(tx+(dx-2)));
            end            
            
            end
        end
    tmp_min(ty+1,tx+1) = this_min;
    tmp_max(ty+1,tx+1) = this_max;
    end

end
local_max = tmp_max;
local_min = tmp_min;
end

% figure; imshow(local_min/1);
% figure; imshow(local_max/1);
% figure; imshow((local_max-local_min)/1);


for ty = 1:th
    for tx = 1:tw
        this_diff = local_max(ty,tx)-local_min(ty,tx);
        if(this_diff < min_wb_diff)
            for dy = 1:tilesz
            y = (ty-1)*tilesz + dy;
            if(y > height)
                continue;
            end
                for dx = 1:tilesz
                    x = (tx-1)*tilesz + dx;
                    if(x > width)
                        continue;
                    end
                    threshim(y,x) = 127;
                end
            end
            continue;
        end
        thresh = local_min(ty,tx) + (local_max(ty,tx) - local_min(ty,tx)) / 2;
        for dy = 1:tilesz
            y =(ty-1)*tilesz + dy;
            for dx = 1:tilesz
                x = (tx-1)*tilesz + dx;
                v = image(y,x);
                if(v > thresh)
                   threshim(y,x) = 255;
                else
                   threshim(y,x) = 0;
                end
            end
        end
    end
end

end