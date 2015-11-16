
function P = matchCorners(I,I2,Point_p)

    w=2;
    p=3;
    x2 = 0;
    y2 = 0;

    SSD = 0;
    for i=-w:w
        for j=-w:w
            ssd = 0;
            temp1 = Point_p(1,2); % gets the x coordinate
            temp2 = Point_p(1,1); % gets the y coordinate
            px_corr = 15;
%             if(temp1 <=px_corr || temp2<=px_corr || temp1>=size_x-px_corr || temp2>=size_y-px_corr)
%                 SSD(i+w+1,j+w+1) = 9999;
%                 break
%             end
            mask1 = I(temp1-p:temp1+p,temp2-p:temp2+p);
            mask2 = I2(temp1-p+i:temp1+p+i,temp2-p+j:temp2+p+j);
            dif_mask = mask2-mask1;
            dif_mask = dif_mask.^2;
            SSD(i+w+1,j+w+1) = sum(sum(dif_mask));
        end
    end
    [t1 it1] = min(SSD);
    [t2 it2] = min(t1);
    [t3 it3] = min(SSD,[],2);
    [t4 it4] = min(t3);
    x2 = Point_p(1,2) + it4 -(w+1);
    y2 = Point_p(1,1) + it2 -(w+1);

%     figure, imshow(I);
%     imshow(I2),hold on, plot(y2,x2,'+','Color','red'),hold off
    P = [x2 y2];
end
