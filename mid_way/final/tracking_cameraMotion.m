tic

max_pixel_flow = 4; % this is w, this means actually a movement of 2*max_pixel_flow +1 for the object to be tracked;
patch_match_size = 3; % this is p, the size of the patch would be patch_match_size x patch_match_size

srcFiles = dir('/home/sahdev/Desktop/Fall2015/ComputerVision5323/project_ideas/moving_camera/set5/*.jpg');  % the folder in which ur images exists
n = length(srcFiles);
labels = cell(n,1);

parfor i = 1 : n
    filename = strcat('/home/sahdev/Desktop/Fall2015/ComputerVision5323/project_ideas/moving_camera/set5/',srcFiles(i).name);
    labels{i} = cellstr(filename);
end
toc
I = imread(char(labels{1}));
sz = size(I);
sz_x = sz(1,1);
sz_y = sz(1,2);

frames = uint8(zeros(sz_x,sz_y,n));
parfor i=1:n
    frame_i = imread(char(labels{i}));
    frame_i = rgb2gray(frame_i);
    frames(:,:,i) = frame_i;
    
end
toc

%%
strt2 = 65;
end2 = 77;
clusters = 2;

Centroid = zeros(2,clusters);

for i=strt2:end2
    temp1 = frames(:,:,i);
    temp2 = frames(:,:,i+2);
    
    if i==strt2      
        pts = getCorners(temp1);
    end
    
    n_corners = numel(pts)/2;
    matched_Points = zeros(n_corners,2);
    for j=1:n_corners
        matched_Points(j,:) = matchFeatures(temp1,temp2,pts(j,:),max_pixel_flow,patch_match_size);
    end
    flow_compute = matched_Points - pts;
    mag = flow_compute(:,1).^2 + flow_compute(:,2).^2;
     flow2 = [flow_compute, matched_Points];
     
     if(i == strt2)
        [idx,Centroid] = kmeans(flow2,clusters);
     end
     
     [idx2,Centroid2] = kmeans(flow2,clusters);
     temp_Centroid2 = Centroid2;
     temp_idx2 = idx2;
     
     % following code maps clusters to their respective initial clusters
     % this part basically tracks the clusters
     
     for j=1:clusters
         min=9999;
         for k=1:clusters
             dist = (Centroid(j,3)-Centroid2(k,3))^2 + (Centroid(j,4)-Centroid2(k,4))^2 ;
             k;
             if(dist < min)
                 min = dist;
                 C_k = k;
             end
         end
         
         j;
         C_k;
%           disp('NEXT')
         for k_c=1:n_corners
             if(idx2(k_c) == C_k)
                 temp_idx2(k_c) = j;
             end
         end
     end
     
    cnt=1;bnt=1;ant=1;ent =1;
    Features1 = zeros(1,2);
    Features2 = zeros(1,2);
    Features3 = zeros(1,2);
    Features4 = zeros(1,2);
    
    
    for j=1:n_corners
        if(temp_idx2(j) == 1)
            Features1(cnt,:) = matched_Points(j,:);
            cnt = cnt+1;
        elseif(temp_idx2(j) == 2)
            Features2(bnt,:) = matched_Points(j,:);
            bnt = bnt+1;
        elseif(temp_idx2(j) == 3)
            Features3(ant,:) = matched_Points(j,:);
            ant = ant+1;
        elseif(temp_idx2(j) == 4)
            Features4(ent,:) = matched_Points(j,:);
            ent = ent+1;
        end
        
    end
    figure, imshow(temp1), hold on, plot(Features1(:,1),Features1(:,2),'+','Color','yellow'),
    plot(Features2(:,1),Features2(:,2),'+','Color','red'),
    plot(Features3(:,1),Features3(:,2),'+','Color','blue'),
    plot(Features4(:,1),Features4(:,2),'+','Color','green'),
    hold off;

end
toc

