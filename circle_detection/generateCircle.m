function [centre radius] = generateCircle(P1, P2, P3)

    %% extract the x and y coordinates from the points
    x1 = P1(1);
    x2 = P2(1);
    x3 = P3(1);

    y1 = P1(2);
    y2 = P2(2);
    y3 = P3(2);

    slope_1 = P2 - P1;
    slope_2 = P3 - P2;

    %% ensure slope are not vertical, interchange points to change slopes
    if(slope_1 == 0)
        tmp = P2;
        P2 = P3;
        P3 = tmp;
        slope_1 = P2 - P1;
    end
    if(slope_2 == 0)
        tmp = P1;
        P1 = P2;
        P2 = tmp;
        slope_2 = P3 - P2;
    end

    grad_a = slope_1(2) / slope_1(1);
    grad_b = slope_2(2) / slope_2(1);

    %% Collinearity check
    if abs(grad_a-grad_b) == 0
        centre = [0 0];
        radius = -1;  
        return
    end

    %% interchange the points If grad_a=0
    if abs(grad_a) ==0
        tmp = grad_a;
        grad_a = grad_b;
        grad_b = tmp;
        tmp = P1;
        P1 = P3;
        P3 = tmp;
    end

    %% Now we see where the 2 perpendiculars drawn from the mid point of the 2 lines meet to find the center of the circle 
    centre(1) = ( grad_a*grad_b*(y1-y3) + grad_b*(x1+x2) - grad_a*(x2+x3) ) / (2*(grad_b-grad_a));
    centre(2) = ((x1+x2)/2 - centre(1)) / grad_a + (y1+y2)/2;

    %% compute radius as the distance from center to any of the other 3 points,
    % say P2 here
    radius = sqrt((centre(1) - x2)^2 + (centre(2) -y2)^2);
end
