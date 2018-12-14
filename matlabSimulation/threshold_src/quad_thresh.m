function quads = quad_thresh(image_blurred,image_gray,debug,progressbar)
quads = [];
threshim = threshold(image_gray,5/255);
waitbar(1/5,progressbar,'Finished Threshold');
if(debug == 1)
    figure;
    imshow(threshim/255);
end
segments = segmentation(threshim,debug);
waitbar(2/5,progressbar,'Finished segmentation');
quads = FitQuads(segments,image_gray,debug);
waitbar(3/5,progressbar,'Finished Fitting Quads');
end
