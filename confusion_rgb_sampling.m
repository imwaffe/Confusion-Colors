clear;
%clc;

Adobe2XYZ = [
0.6097559  0.2052401  0.1492240;
 0.3111242  0.6256560  0.0632197;
 0.0194811  0.0608902  0.7448387;
 ];
ProPhoto2XYZ = [
    0.7976749  0.1351917  0.0313534;
 0.2880402  0.7118741  0.0000857;
 0.0000000  0.0000000  0.8252100;
 ];
sRGB2XYZ = [
 0.4360747  0.3850649  0.1430804;
 0.2225045  0.7168786  0.0606169;
 0.0139322  0.0971045  0.7141733;
    ];
XYZ2sRGB = inv(Adobe2XYZ);

gamma = 2.2;
pivot = 0.5;
extension = 0.4;
brightness = 0.6;
alpha = 0;

k = ([0 0 0]);
r = ([1 0 0]);
g = ([0 1 0]);
b = ([0 0 1]);
c = ([0 1 1]);
m = ([1 0 1]);
y = ([1 1 0]);
w = ([1 1 1]);

protan = [0.7465  0.2535];
deutan = [1.4000 -0.4000];
tritan = [0.1748  0.0004];

deficiency = protan;
% col = hsv2rgb([0.35 0.8 brightness]);
col = [0.7 0.7 0.8];
col = real(col.^gamma);
extension = extension*(1-brightness*alpha);
col_xyz = sRGB2XYZ*col';
col_xyz = col_xyz';
r0 = XYZ2sRGB * [deficiency(1)*col_xyz(2)/deficiency(2); col_xyz(2); (1-deficiency(1)-deficiency(2))*col_xyz(2)/deficiency(2)];
r0 = r0';
% r0 = xyz2rgb([deficiency(1) deficiency(2) (1-deficiency(1)-deficiency(2))]);
%r0 = real(r0.^gamma);
[r0(1)/rssq(r0) r0(2)/rssq(r0) r0(3)/rssq(r0)]
%%
D = col-r0;
D = D/norm(D);

mat(:,:,1) = createMatrix(k,g,r);
mat(:,:,2) = createMatrix(b,c,m);
mat(:,:,3) = createMatrix(b,k,m);
mat(:,:,4) = createMatrix(c,g,w);
mat(:,:,5) = createMatrix(m,r,w);
mat(:,:,6) = createMatrix(b,k,c);

points = [];

%subplot(1,3,1);
hold on;
plotcube(ones(1,3),zeros(1,3),.05,[0 0 0]);
for i=1:6
    if dot(D,mat(4,:,i)) ~= 0
        %quiver3(mat(1,1,i),mat(1,2,i),mat(1,3,i),mat(2,1,i),mat(2,2,i),mat(2,3,i));
        %quiver3(mat(1,1,i),mat(1,2,i),mat(1,3,i),mat(3,1,i),mat(3,2,i),mat(3,3,i));
        p = intersectionPoint(r0,D,mat(:,:,i))
        q1 = dot(p-mat(1,:,i), mat(2,:,i)/norm(mat(2,:,i)));
        q2 = dot(p-mat(1,:,i), mat(3,:,i)/norm(mat(3,:,i)));
        if q1 <= norm(mat(2,:,i)) && q1 >=0 && q2 <= norm(mat(3,:,i)) && q2 >= 0
            points(end+1,:) = real(p);
            intersectionPointPlot = scatter3(p(1),p(2),p(3),100,'k.');
        end
    end
end

copunctualPointPlot = scatter3(r0(1),r0(2),r0(3),300,'r*');
ppp = points(2,:);
%quiver3(r0(1),r0(2),r0(3),ppp(1),ppp(2),ppp(3),'AutoScaleFactor',1);
plot3([r0(1),ppp(1)],[r0(2),ppp(2)],[r0(3),ppp(3)])

points
% col0 = (points(1,:)*pivot + points(2,:)*(1-pivot));
col0 = col;
%if(norm(col0 - points(1,:)) > norm(col0 - points(2,:)))
    col1 = real(col0*(1-extension) + points(1,:)*extension);
%else
    col0 = real(col0*(1-extension) + points(2,:)*extension);
%end
refColorPlot = scatter3(col(1),col(2),col(3),300,'rd','filled');
computedColorPlot = scatter3(col0(1),col0(2),col0(3),100,'md','filled');
scatter3(col1(1),col1(2),col1(3),100,'md','filled');
hold off

col0 = real(col0.^(1/gamma));
col1 = real(col1.^(1/gamma));

dE = rgb_dE(col0,col1)

grid on;

xlabel('r','FontSize',20,'FontWeight','bold')
ylabel('g','FontSize',20,'FontWeight','bold')
zlabel('b','FontSize',20,'FontWeight','bold')

legend([copunctualPointPlot refColorPlot computedColorPlot intersectionPointPlot],...
{'Protan copunctual point','Target color','Confusion colors','Intersection with rgb cube'});
%subplot(1,3,2);
%rectangle('Position',[0,0,1,1],'FaceColor',col0);
%subplot(1,3,3);
%rectangle('Position',[0,0,1,1],'FaceColor',col1);

function [M] = createMatrix(c0,c1,c2)
    M(1,:) = c0;
    M(2,:) = c1-c0;
    M(3,:) = c2-c0;
    M(4,:) = cross(M(2,:),M(3,:))/norm(cross(M(2,:),M(3,:)));
end

function [P] = intersectionPoint(r0,D,M)
    P = r0 + (dot(M(1,:)-r0, M(4,:))/dot(D,M(4,:)))*D;
end

function [a] = angleVect(v1,v2,n)
    a = atan2(dot(cross(v1,v2),n),dot(v1,v2));
end

function [dE] = rgb_dE(c1, c2)
    dE = norm( rgb2lab(c1)-rgb2lab(c2) );
end