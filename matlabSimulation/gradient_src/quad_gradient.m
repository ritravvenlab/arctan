function quads = quad_gradient(image_blurred,image_gray,debug,h)
%generate bit accurate lut model
global luts
luts = cordiclut_generation(11, true, 12);
%11 luts long, fixed point, 12 bits
Debug_Gradient = 0;

width = size(image_gray,2);
height = size(image_gray,1);

%Stage 2: Calculating Gradients (Without toolbox)
dx = [ 0, 0,0;...
       1, 0,-1;...
       0, 0,0];
dy = [ 0, 1,0;...
       0, 0,0;...
       0,-1,0];
Ix = conv2(image_blurred,dx,'same');  %Convolve across x direction of image
Iy = conv2(image_blurred,dy,'same');  %Convolve across y direction of image

if(Debug_Gradient == 1)
    Ixn = NormalizeVals(Ix);
    Iyn = NormalizeVals(Iy);
    figure('Name','Stage 2a(Debug): Gradient Magnitue (x direction)');
    imshow(Ixn);
    title('Stage 2a: Gradient Magnitue (x direction)');
    figure('Name','Stage 2a(Debug): Gradient Magnitue (y direction)');
    imshow(Iyn);
    title('Stage 2a: Gradient Magnitue (y direction)');
end

gm = single(Ix.^2 + Iy.^2);   %Magnitude
gd = zeros(480,640);
gd2 = atan2(Iy,Ix);
size(Iy)
size(Ix)
gd2(1:3,1:3)
for idxY = 1:480
  for idxX = 1:640
    gd(idxY,idxX) = gcordicatan2(Iy(idxY,idxX),Ix(idxY,idxX),luts);%Direction
  end
end
gd(1:3,1:3)
disp("done calcing")
waitbar(0.5/5,h,'Finished Gradient Calculation');
if(debug == 1)
figure('Name','Stage 2a: Gradient Magnitue');
imagesc(gm);
colorbar;
title('Stage 2a: Gradient Magnitue');
figure('Name','Stage 2b: Gradient Direction');
imagesc(gd);
colorbar;
title('Stage 2b: Gradient Direction');
end

min_mag = 0.004;
%Stage 3: Edge Extraction
image_edges = CalcEdges(ArraytoList(gm),ArraytoList(gd)...
    ,min_mag, height, width);
waitbar(1/5,h,'Finished Calculating Edges');
image_clusters = MergeEdges(image_edges,ArraytoList(gm),ArraytoList(gd)); %Merges the detected edges
waitbar(1.5/5,h,'Finished Merging Edges');
if(debug == 1)
%Debug Code for visualization
Cluster_Num = unique(image_clusters(:,4)); %Gets each unique cluster
current_num = 1; %holds the offset of the where we're grabbing clusters

    figure('Name','Grouped Edges');
    imshow(image_gray);
    title('Grouped Edges');
    hold on;
    for i = 1:size(Cluster_Num)
        num_of_pts = size(find(image_clusters(:,4) == Cluster_Num(i)),1);
        temp = image_clusters(current_num:num_of_pts+current_num - 1,:);
        plot(temp(:,1),temp(:,2),'*','LineWidth',2);
        current_num = current_num + num_of_pts; %Add to the offset
    end
end

%Stage 5: Segmentation 
MinCluster = 4;
FoundSegs   = Segmenter(image_clusters,ArraytoList(gd)...
    ,ArraytoList(gm),width,height);
waitbar(2/5,h,'Finished Segmenting');
if(debug == 1)
    figure('Name','Segments');
    imshow(image_gray);
    title('Segments');
    hold on;
    %Debug Code
    for k = 1:length(FoundSegs)
        LineColor = [146/255,abs(FoundSegs(k,5))/(4*pi),1];
        plot([FoundSegs(k,1),FoundSegs(k,3)],...
           [FoundSegs(k,2),FoundSegs(k,4)],...
           'LineWidth',2,'color',LineColor);%plot the segment
    end
    hold off;
end
%Stage 6: Chain Segments
linked_segments = LinkSegs(FoundSegs);
waitbar(2.5/5,h,'Finished Linking Segments');
%Stage 7: Find Quads
quads = QuadDetection(linked_segments,FoundSegs);
waitbar(3/5,h,'Finished Fitting Quads');
if(debug == 1)
    %Debug visualization
    figure('Name','Detected Quads with intersections');
    imshow(image_gray);
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

function output = NormalizeVals(input,Max,Min)
    switch nargin
        case 1
            output = (input-min(input(:)))./(max(input(:))-min(input(:)));
        otherwise
            output = (input-Min)./(Max-Min);
    end
end

function longArray = ArraytoList(Array)
%Turns a NxM array into a 1xN*M list 
Width = size(Array,2);
Height  = size(Array,1);

longArray = zeros(1,Width*Height);
for i = 1:Height
    StartIdx = ((i-1) * Width)+1;
    EndIdx   = (StartIdx + Width)-1;
    longArray(1,StartIdx:EndIdx) = Array(i,:);
end
end