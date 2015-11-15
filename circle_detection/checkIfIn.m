function [flag] = checkIfIn(P,center2,radius,w)

    dist = sqrt( (P(1,1)-center2(1,1))^2 + (P(1,2)-center2(1,2))^2);
    if (dist > (radius - w) && dist < (radius + w))
        flag = 1;
    else
        flag = 0;
    end
end

