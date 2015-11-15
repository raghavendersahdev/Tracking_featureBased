t = im2bw(temp1,0.05);

se1 = strel('disk',1);

se12 = strel('disk',4);
sel3 = strel('rectangle', [40 10]);

t2 = imerode(t,se1);
t3 = imdilate(t2,se12);
% t4 = imdilate(t3,se12);
% t4 = imdilate(t4,se12);
% t4 = imdilate(t4,se12);

H = vision.BlobAnalysis;
C = vision.ConnectedComponentLabeler;
C.LabelMatrixOutputPort = true;
C.LabelCountOutputPort = false;
labeled = step(C, t3);

H.AreaOutputPort = false;
H.CentroidOutputPort = true;
H.BoundingBoxOutputPort = true;
H.MaximumCount = 3;
labeled2 = step(H,t3);
