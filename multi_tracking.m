tic
video = VideoReader('atrium.avi');
% video = VideoReader('visiontraffic.avi');
nFrames = video.NumberOfFrames;
vidHeight = video.Height;
vidWidth = video.Width;

mov(1:nFrames) = struct('cdata', zeros(vidHeight,vidWidth, 3, 'uint8'),'colormap',[]);
parfor k = 1 : nFrames
    mov(k).cdata = read(video,k);
    mov(k).cdata = rgb2gray(mov(k).cdata);
end
toc

temp2 =3;
%% 
P1=6;
strt2 = 405;
end_it = 409;
occlusion_threshold = 90;
moving_objects = 3;
for i=strt2:end_it
    temp1 = mov(i).cdata - mov(i-1).cdata;
    
    
    %% FEATURE 1 using (i) and (i-1)
    pts = detectHarrisFeatures(temp1);
    y = floor(pts.Location(:,1));  % this is y
    x = floor(pts.Location(:,2));  % this is x
    n = numel(x);
    Features1 = zeros(n,2);
    Features1(:,1) = y;
    Features1(:,2) = x;
    
    %% FEATURE 1 using (i+1) and (i)
    temp2 = mov(i+1).cdata - mov(i).cdata;
    pts2 = detectHarrisFeatures(temp2);
    y2 = floor(pts2.Location(:,1));  % this is y
    x2 = floor(pts2.Location(:,2));  % this is x
    n2 = numel(x2);
    Features2 = zeros(n2,2);
    Features2(:,1) = y2;
    Features2(:,2) = x2;      
    
    %% do clustering to track individual objects    
     if i == strt2
        [idx,Centroid] = kmeans(Features1,moving_objects);
        cnt=1;    
    %     Group1,Group2,Group3,g1,g2,g3
        g1=1;g2=1;g3=1;
        Group1 =zeros(0,2);
        Group2 =zeros(0,2);
        Group3 =zeros(0,2);
        
        for j=1:numel(Features1)/2
            if(idx(j,1) == 1)
                Group1(g1,1) = Features1(j,1);
                Group1(g1,2) = Features1(j,2);
                g1 = g1+1;
            elseif(idx(j,1) == 2)
                Group2(g2,1) = Features1(j,1);
                Group2(g2,2) = Features1(j,2);
                g2 = g2+1;
            elseif(idx(j,1) == 3)
                Group3(g3,1) = Features1(j,1);
                Group3(g3,2) = Features1(j,2);
                g3 = g3+1;
            end
        end
     end
%    figure, imshow(mov(i).cdata), hold on, plot(y,x,'+','Color','yellow'),hold off  
   
   
    %% tracking clusters     
       % sample feature points randomly to track them
    if i == strt2
        while(1)
            P1 = datasample(Group1(:,:),1);
            if (P1(1,1) ==0 && P1(1,2) ==0)
                continue;
            else
                break;
        
            end
        end
        while(1)
            P2 = datasample(Group2(:,:),1);
            if (P2(1,1) ==0 && P2(1,2) ==0)
                continue;
            else
                break;
        
            end
        end
        while(1)
            P3 = datasample(Group3(:,:),1);
            if (P3(1,1) ==0 && P3(1,2) ==0)
                continue;
            else
                break;
        
            end
        end     
    end
    % till here we have 3 sampled points from each of the 3 clusters
    distances = pdist2(P1,Features2);    
    [dist, matched_index] = min(distances);    
    target_point1 = Features2(matched_index,:);
    P1 = target_point1;
    
    distances = pdist2(P2,Features2);    
    [dist, matched_index] = min(distances);    
    target_point2 = Features2(matched_index,:);
    P2 = target_point2;
    
    distances = pdist2(P3,Features2);    
    [dist, matched_index] = min(distances);    
    target_point3 = Features2(matched_index,:);
    P3 = target_point3;
    

     %% for the convex hull
     if((g1-1)>2)
        kover = convhull(Group1(:,1),Group1(:,2));
        bounds1 = zeros(numel(kover),2);
        for j=1:numel(kover)
            bounds1(j,1) = Group1(kover(j),1);
            bounds1(j,2) = Group1(kover(j),2);
        end
        figure, imshow(mov(i+1).cdata), hold on, plot(bounds1(:,1),bounds1(:,2),'Color','cyan'), 
        plot(bounds2(:,1),bounds2(:,2),'Color','red'),
        plot(bounds3(:,1),bounds3(:,2),'Color','yellow'),
        hold off
   
     end
     if((g2-1)>2)
        kover = convhull(Group2(:,1),Group2(:,2));
        bounds2 = zeros(numel(kover),2);
        for j=1:numel(kover)
            bounds2(j,1) = Group2(kover(j),1);
            bounds2(j,2) = Group2(kover(j),2);
        end
         figure, imshow(mov(i+1).cdata), hold on, plot(bounds2(:,1),bounds2(:,2),'Color','red'),hold off
     end
     if((g3-1)>2)
         kover = convhull(Group3(:,1),Group3(:,2));
         bounds3 = zeros(numel(kover),2);
         for j=1:numel(kover)
             bounds3(j,1) = Group3(kover(j),1);
             bounds3(j,2) = Group3(kover(j),2);
         end
         figure, imshow(mov(i+1).cdata), hold on, plot(bounds3(:,1),bounds3(:,2),'Color','yellow'),hold off
     end 
end

toc
