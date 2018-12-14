function segments = segmentation(image,debug)
width = size(image,2);
height = size(image,1);
UF_Idx = [1:width*height-1,1]';
UF_sz = ones(width*height,1);

for y = 5:height-5
    for x = 5:width-5
        v = image(y,x);
        if(v == 127) %Index is not an edge
            continue;
        end
        this_px = y*width+x; %Hashed value of px coord
        
        if(image(y+0,x+1) == v)
            next_px = (y*width)+(0*width)+(x+1); %Hashed value of px coord
            
               [root,roota,rootb] = connectNodes(UF_Idx,UF_sz,this_px,next_px);
                if(roota == root)
                    UF_Idx(rootb == UF_Idx) = roota;
                    UF_sz(roota) = UF_sz(roota) + UF_sz(rootb);
                else
                    UF_Idx(roota == UF_Idx) = rootb;
                    UF_sz(rootb) = UF_sz(roota) + UF_sz(rootb);
                end
        end
        
        if(image(y+1,x+0) == v)
            next_px = (y*width)+(1*width)+(x+0);
               [root,roota,rootb] = connectNodes(UF_Idx,UF_sz,this_px,next_px);
                if(roota == root)
                    UF_Idx(rootb == UF_Idx) = roota;
                    UF_sz(roota) = UF_sz(roota) + UF_sz(rootb);
                else
                    UF_Idx(roota == UF_Idx) = rootb;
                    UF_sz(rootb) = UF_sz(roota) + UF_sz(rootb);
                end
        end
        
        if(v == 255)
            if(image(y+1,x-1) == v)
                next_px = (y*width)+(1*width)+(x-1);
               [root,roota,rootb] = connectNodes(UF_Idx,UF_sz,this_px,next_px);
                if(roota == root)
                    UF_Idx(rootb == UF_Idx) = roota;
                    UF_sz(roota) = UF_sz(roota) + UF_sz(rootb);
                else
                    UF_Idx(roota == UF_Idx) = rootb;
                    UF_sz(rootb) = UF_sz(roota) + UF_sz(rootb);
                end
            end
            if(image(y+1,x+1) == v)
                next_px = (y*width)+(1*width)+(x+1);
                [root,roota,rootb] = connectNodes(UF_Idx,UF_sz,this_px,next_px);
                if(roota == root)
                    UF_Idx(rootb == UF_Idx) = roota;
                    UF_sz(roota) = UF_sz(roota) + UF_sz(rootb);
                else
                    UF_Idx(roota == UF_Idx) = rootb;
                    UF_sz(rootb) = UF_sz(roota) + UF_sz(rootb);
                end
            end
        end
    end
end

if(debug == 1)
    Valid_Clusters = UF_Idx((UF_sz(:) >= 4));
    logical_arr = ismember(UF_Idx(:),Valid_Clusters);
    debugplot = uint8(zeros(height,width,3));
    color = zeros(height*width,3);
    for y = 2:height-1
        for x = 2:width-1
            if(~logical_arr(y*width+x))
                continue;
            end
            v = UF_Idx(y*width+x);
            if(color(v,1) == 0) 
                color(v,1) = uint8(255*rand());
                color(v,2) = uint8(255*rand());
                color(v,3) = uint8(255*rand());
            end
            debugplot(y,x,1) = color(v,1);
            debugplot(y,x,2) = color(v,2);
            debugplot(y,x,3) = color(v,3);
        end
    end
    figure;
    imshow(debugplot);
end

nclustermap = 2*width*height - 1;
clustermap(nclustermap,1) = struct('clusterid',[],'AddedPixels',[]);
clusterIdx = 1;

for y = 5:height-5
    for x = 5:width-5
        v0 = image(y,x);
        if(v0 == 127)
            continue;
        end
        
        rep0 = getRepresentative(UF_Idx, y*width+x);
        UF_Idx(y*width+x) = rep0;
        
        %connect [1,0]
        v1 = image(y+0,x+1);
        if(v0 + v1 == 255)
            rep1 = getRepresentative(UF_Idx,(y+0)*width+(x+1));
            UF_Idx((y+0)*width+(x+1)) = rep1;
            if(rep0 < rep1)
                clusterid = uint64(uint64(bitshift(rep1,32)) + uint64(rep0));
            else
                clusterid = uint64(uint64(bitshift(rep0,32)) + uint64(rep1));
            end
            
            debug1 = uint64(u64hash_2(clusterid));
            cluster_id = uint64(mod(uint64(debug1)...
                                   ,uint64(nclustermap)));
            
            if(~isempty(clustermap(cluster_id).clusterid))
                newValues = [2*x + 1,2*y + 0,1*(v1-v0),0*(v1-v0)];
                clustermap(cluster_id).AddedPixels...
                    = [clustermap(cluster_id).AddedPixels;newValues];
            else
                newValues = [2*x + 1,2*y + 0,1*(v1-v0),0*(v1-v0)];
                clustermap(cluster_id).clusterid = cluster_id;
                clustermap(cluster_id).AddedPixels = newValues;
            end
        end
        
        %connect [0,1]
        v1 = image(y+1,x+0);
        if(v0 + v1 == 255)
            rep1 = getRepresentative(UF_Idx,(y+1)*width+(x+0));
            UF_Idx((y+1)*width+(x+0)) = rep1;
            if(rep0 < rep1)
                clusterid = uint64(uint64(bitshift(rep1,32)) + uint64(rep0));
            else
                clusterid = uint64(uint64(bitshift(rep0,32)) + uint64(rep1));
            end
            debug1 = uint64(u64hash_2(clusterid));
            cluster_id = uint64(mod(uint64(debug1)...
                                   ,uint64(nclustermap)));
            
            if(~isempty(clustermap(cluster_id).clusterid))
                newValues = [2*x + 0,2*y + 1,0*(v1-v0),1*(v1-v0)];
                clustermap(cluster_id).AddedPixels...
                    = [clustermap(cluster_id).AddedPixels;newValues];
            else
                newValues = [2*x + 0,2*y + 1,0*(v1-v0),1*(v1-v0)];
                clustermap(cluster_id).clusterid = cluster_id;
                clustermap(cluster_id).AddedPixels = newValues;
            end
        end
        
        %connect [-1,1]
        v1 = image(y+1,x-1);
        if(v0 + v1 == 255)
            rep1 = getRepresentative(UF_Idx,(y+1)*width+(x-1));
            UF_Idx((y+1)*width+(x-1)) = rep1;
            if(rep0 < rep1)
                clusterid = uint64(uint64(bitshift(rep1,32)) + uint64(rep0));
            else
                clusterid = uint64(uint64(bitshift(rep0,32)) + uint64(rep1));
            end
            debug1 = uint64(u64hash_2(clusterid));
            cluster_id = uint64(mod(uint64(debug1)...
                                   ,uint64(nclustermap)));         
            if(~isempty(clustermap(cluster_id).clusterid))
                newValues = [2*x - 1,2*y + 1,-1*(v1-v0),1*(v1-v0)];
                clustermap(cluster_id).AddedPixels...
                    = [clustermap(cluster_id).AddedPixels;newValues];
            else
                newValues = [2*x - 1,2*y + 1,-1*(v1-v0),1*(v1-v0)];
                clustermap(cluster_id).clusterid = cluster_id;
                clustermap(cluster_id).AddedPixels = newValues;
            end
        end
        
        %connect [1,1]
        v1 = image(y+1,x+1);
        if(v0 + v1 == 255)
            rep1 = getRepresentative(UF_Idx,(y+1)*width+(x+1));
            UF_Idx((y+1)*width+(x+1)) = rep1;
            if(rep0 < rep1)
                clusterid = uint64(uint64(bitshift(rep1,32)) + uint64(rep0));
            else
                clusterid = uint64(uint64(bitshift(rep0,32)) + uint64(rep1));
            end
            
            debug1 = uint64(u64hash_2(clusterid));
            cluster_id = uint64(mod(uint64(debug1)...
                                   ,uint64(nclustermap)));
            
            if(~isempty(clustermap(cluster_id).clusterid))
                newValues = [2*x + 1,2*y + 1,1*(v1-v0),1*(v1-v0)];
                clustermap(cluster_id).AddedPixels...
                    = [clustermap(cluster_id).AddedPixels;newValues];
            else
                newValues = [2*x + 1,2*y + 1,1*(v1-v0),1*(v1-v0)];
                clustermap(cluster_id).clusterid = cluster_id;
                clustermap(cluster_id).AddedPixels = newValues;
            end
        end
        
    end
end

clusterIdx = 1;
for i = 1:length(clustermap)
    if(~isempty(clustermap(i).clusterid))
        if(length(clustermap(i).AddedPixels) > 5 &&...
           length(clustermap(i).AddedPixels) < (3*(2*width+2*height)))
            clusters(clusterIdx) = clustermap(i);
            clusterIdx = clusterIdx + 1;
        end
    end
end

if(debug == 1)
    debugplot = uint8(zeros(height,width,3));
    color = zeros(1,3);
    for i = 1:length(clusters)
        this_cluster = clusters(i);
        
        color(1) = uint8(255*rand());
        color(2) = uint8(255*rand());
        color(3) = uint8(255*rand());
            
        for j = 1:length(this_cluster.AddedPixels)
            x = floor(this_cluster.AddedPixels(j,1)/2);
            y = floor(this_cluster.AddedPixels(j,2)/2);
            debugplot(y,x,1) = color(1);
            debugplot(y,x,2) = color(2);
            debugplot(y,x,3) = color(3);
        end
    end
    figure;
    imshow(debugplot);
end

segments = clusters;
end

function hash = u64hash_2(hash)
hash = uint64(hash) * uint64(1543);
hash = uint64(bitshift(hash,-32,'uint64'));
end

% Gets the representative of the node
function root = getRepresentative(UFArray,NodeId)
    parent = UFArray(NodeId);
    if(parent == NodeId) %If it is it's own rep return
        root = NodeId;
    else
        root = UFArray(parent);
    end
end

%connects and merges the two trees together
function [root,aRoot,bRoot] = connectNodes(UF_Idx,UF_sz,aId,bId)

    aRoot = getRepresentative(UF_Idx,aId); %Get rep of a
    bRoot = getRepresentative(UF_Idx,bId); %Get rep of b

    if(aRoot==bRoot) %It's already connected!
        root=aRoot;  %Return the root
        return;
    end
    
    if(UF_sz(aRoot) > UF_sz(bRoot)) %Larger tree wins!
        root=aRoot; %Return the new root
        return;
    else
        root=bRoot; %Return the new root
        return;
    end
end
