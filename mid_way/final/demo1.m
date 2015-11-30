tic

max_pixel_flow = 4; % this is w, this means actually a movement of 2*max_pixel_flow +1 for the object to be tracked;
patch_match_size = 3; % this is p, the size of the patch would be patch_match_size x patch_match_size
boundary_effect = 15;
threshold = 1800; % this is the threshold for the harris corner detector

srcFiles = dir('/home/sahdev/Desktop/Fall2015/ComputerVision5323/project_ideas/moving_camera/skatings2/skating2/*.jpg');  % the folder in which ur images exists
n = length(srcFiles);
labels = cell(n,1);

parfor i = 1 : n
    filename = strcat('/home/sahdev/Desktop/Fall2015/ComputerVision5323/project_ideas/moving_camera/skatings2/skating2/',srcFiles(i).name);
    labels{i} = cellstr(filename);
end
toc
I = imread(char(labels{1}));
sz = size(I);
sz_x = sz(1,1);
sz_y = sz(1,2);

boundary_effect = floor(sz_x/30);


frames = uint8(zeros(sz_x,sz_y,n));
parfor i=1:n
    frame_i = imread(char(labels{i}));
    t_s = size(frame_i,3);
    if(t_s == 3)
        frame_i = rgb2gray(frame_i);
    end
    frames(:,:,i) = frame_i;
    
end
toc

%%
strt2 = 45;
end2 = 65;
clusters = 2;

Centroid = zeros(2,clusters);
temp_pts = zeros(1,2);
for i=strt2:end2
    temp1 = frames(:,:,i);
    temp2 = frames(:,:,i+1);
    
    if i==strt2      
        pts = getFeatures(temp1,threshold);
%         temp_pts = pts;
        znt=1;
        for j=1:numel(pts)/2
            if(pts(j,1) < boundary_effect || pts(j,1) > (sz_x-boundary_effect))
                ;
            elseif (pts(j,2) < boundary_effect || pts(j,2) > (sz_y-boundary_effect))
                ;
            else
                temp_pts(znt,1) = pts(j,1);
                temp_pts(znt,2) = pts(j,2);
                znt = znt + 1;
            end
        end
    end
    
    n_corners = numel(temp_pts)/2;
    matched_Points = zeros(n_corners,2);
    for j=1:n_corners        
        matched_Points(j,:) = matchFeatures(temp1,temp2,temp_pts(j,:),max_pixel_flow,patch_match_size,boundary_effect);
    end
    
    flow_compute = matched_Points - temp_pts;
    
    %% logic for the actual corner updates
    temp2_pts = matched_Points;
    temp_corners = getFeatures(temp2,threshold);
    
    actual_index=1;
    
    actual_corners = zeros(1,2);
    znt2=1;
    for j=1:numel(temp_corners)/2
        if(temp_corners(j,1) < boundary_effect || temp_corners(j,1) > (sz_x-boundary_effect))
            ;
        elseif (temp_corners(j,2) < boundary_effect || temp_corners(j,2) > (sz_y-boundary_effect))
            ;
        else
            actual_corners(znt2,1) = temp_corners(j,1);
            actual_corners(znt2,2) = temp_corners(j,2);
            znt2 = znt2 + 1;
        end
    end
    
    
    n_corners2 = numel(actual_corners)/2;
%     for j=1:n_corners
%         min=100;
%         for k=1:n_corners2
%             dist = (temp2_pts(j,1)-actual_corners(k,1))^2 + (temp2_pts(j,1)-actual_corners(k,2))^2;
%             if(dist < min)
%                 actual_index = k;
%             end
%         end
%         matched_Points(j,1) = actual_corners(actual_index,1);
%         matched_Points(j,2) = actual_corners(actual_index,2);
%     end
    
    
    
    %% cluster analysis begins
    temp_pts = matched_Points;
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
     
    cnt=1;bnt=1;ant=1;ent =1; fnt=1;gnt=1;hnt=1;
    
    Features1 = zeros(1,2);
    Features2 = zeros(1,2);
    Features3 = zeros(1,2);
    Features4 = zeros(1,2);
    Features5 = zeros(1,2);
    Features6 = zeros(1,2);
    
    
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
        elseif(temp_idx2(j) == 5)
            Features5(fnt,:) = matched_Points(j,:);
            fnt = fnt+1;
        elseif(temp_idx2(j) == 6)
            Features6(ent,:) = matched_Points(j,:);
            gnt = gnt+1;
        end
        
    end
    
    
    
    %% plotting the convex hull
    bounds=zeros(1,2);
    
        
        k2 = convhull(Features2(:,1),Features2(:,2));
        bounds = zeros(numel(k2),2);
        for j2=1:numel(k2)
            bounds(j2,1) = Features2(k2(j2),1);
            bounds(j2,2) = Features2(k2(j2),2);
        end

 
    
    figure, imshow(temp1), hold on,
    plot(bounds(:,1),bounds(:,2),'Color','cyan')
    plot(Features1(:,1),Features1(:,2),'+','Color','yellow'),
    plot(Features2(:,1),Features2(:,2),'+','Color','red'),
    
%     plot(actual_corners(:,1),actual_corners(:,2),'+','Color','cyan'),   
    
    plot(Features3(:,1),Features3(:,2),'+','Color','blue'),
    plot(Features4(:,1),Features4(:,2),'+','Color','green'),
    plot(Features5(:,1),Features5(:,2),'+','Color','cyan'),
    plot(Features6(:,1),Features6(:,2),'+','Color','white'),
    hold off;

end
toc

