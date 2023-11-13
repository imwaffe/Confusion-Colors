clear;

import functions.*;

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

protan = [0.7465  0.2535];
deutan = [1.4000 -0.4000];
tritan = [0.1748  0.0004];



% ----------------------- USER SETTINGS START ----------------------- %
% ------------------ enter here your custom values ------------------ %

col = [200 100 100]; % target color (RGB values between 0 and 255)
extension = 0.25; % distance between chosen and generated colors (in linear rgb units)

bitDepth = 8; % bit depth per channel
RGB2XYZ = sRGB2XYZ; % conversion matrix from RGB space to XYZ space
gamma = 2.2; % color space native gamma

deficiency = deutan; % chosen deficiency (protan, deutan, tritan)

displayCubePlot = false; % true to display plot of the RGB cube
displayColorsPreview = true; % true to display the preview of the generated colors

% ------------------------ USER SETTINGS END ------------------------ %


maxVal = 2^bitDepth-1;
XYZ2sRGB = inv(RGB2XYZ);

k = ([0 0 0]);
r = ([1 0 0]);
g = ([0 1 0]);
b = ([0 0 1]);
c = ([0 1 1]);
m = ([1 0 1]);
y = ([1 1 0]);
w = ([1 1 1]);


col = col/maxVal;
col = real(col.^gamma);
col_xyz = sRGB2XYZ*col';
col_xyz = col_xyz';
r0 = XYZ2sRGB * [
    deficiency(1)*col_xyz(2)/deficiency(2);
    col_xyz(2);
    (1-deficiency(1)-deficiency(2))*col_xyz(2)/deficiency(2)
    ];
r0 = r0';

D = col-r0;
D = D/norm(D); % versor from copunctual point to chosen color

mat(:,:,1) = createMatrix(k,g,r);
mat(:,:,2) = createMatrix(b,c,m);
mat(:,:,3) = createMatrix(b,k,m);
mat(:,:,4) = createMatrix(c,g,w);
mat(:,:,5) = createMatrix(m,r,w);
mat(:,:,6) = createMatrix(b,k,c);

points = [];
intersect = [];

for i=1:6
    if dot(D,mat(4,:,i)) ~= 0 % if ray and plane normal are NOT parallel continue
        p = intersectionPoint(r0,D,mat(:,:,i));
        q1 = dot(p-mat(1,:,i), mat(2,:,i)/norm(mat(2,:,i)));
        q2 = dot(p-mat(1,:,i), mat(3,:,i)/norm(mat(3,:,i)));
        if q1 <= norm(mat(2,:,i)) && q1 >=0 && q2 <= norm(mat(3,:,i)) && q2 >= 0
            points(end+1,:) = real(p);
            intersect(end+1, :) = p;
        end
    end
end

ppp = points(2,:);


% col0 = (points(1,:)*pivot + points(2,:)*(1-pivot));
col0 = col;
%if(norm(col0 - points(1,:)) > norm(col0 - points(2,:)))
    col1 = real(col0*(1-extension) + points(1,:)*extension);
%else
    col0 = real(col0*(1-extension) + points(2,:)*extension);
%end

% DISPLAY RGB CUBE PLOT
if displayCubePlot == true
    hold on;
    plotcube(ones(1,3),zeros(1,3),.05,[0 0 0]);
    plot3([r0(1),ppp(1)],[r0(2),ppp(2)],[r0(3),ppp(3)])
    scatter3(col1(1),col1(2),col1(3),100,'md','filled');
    grid on;
    
    xlabel('r','FontSize',20,'FontWeight','bold')
    ylabel('g','FontSize',20,'FontWeight','bold')
    zlabel('b','FontSize',20,'FontWeight','bold')

    copunctualPointPlot = scatter3(r0(1),r0(2),r0(3),300,'r*');
    refColorPlot = scatter3(col(1),col(2),col(3),300,'rd','filled');
    computedColorPlot = scatter3(col0(1),col0(2),col0(3),100,'md','filled');
    scatter3(intersect(1,1),intersect(1,2),intersect(1,3),100,'k.');
    intersectionPointPlot = scatter3(intersect(2,1),intersect(2,2),intersect(2,3),100,'k.');
    hold off;

    legend([copunctualPointPlot refColorPlot computedColorPlot intersectionPointPlot],...
    {'Protan copunctual point','Target color','Confusion colors','Intersection with rgb cube'});
end

col = real(col.^(1/gamma));
col0 = real(col0.^(1/gamma));
col1 = real(col1.^(1/gamma));

dE0 = rgb_dE(col,col0);
dE1 = rgb_dE(col,col1);

% DISPLAY OUTPUT COLORS
if displayColorsPreview == true
    figure;
    subplot(1,3,1);
    rectangle('Position',[0,0,1,1],'FaceColor',col0);
    title("Before target");
    subplot(1,3,2);
    rectangle('Position',[0,0,1,1],'FaceColor',col);
    title("Target color");
    subplot(1,3,3);
    rectangle('Position',[0,0,1,1],'FaceColor',col1);
    title("After target");
end

% PRINT RESULTS IN CONSOLE WINDOW
fprintf("\nTarget color: RGB[%d,%d,%d], hex(%s)\n",round(col*maxVal), rgb2hex(col*maxVal));
fprintf("Color before target: RGB[%d,%d,%d], hex(%s)",round(col0*maxVal), rgb2hex(col0*maxVal));
fprintf("\tDE*76 from target: %f\n",dE0);
fprintf("Color after target: RGB[%d,%d,%d], hex(%s)",round(col1*maxVal), rgb2hex(col1*maxVal));
fprintf("\tDE*76 from target: %f\n",dE1);
fprintf("Distance between target and generated colors in linear rgb units: %f\n",extension);
fprintf("Intersection points between ray and linear rgb cube: (%f,%f,%f) (%f,%f,%f)\n",intersect(1,:),intersect(2,:));

%% FUNCTIONS
% define parametric cube
function [M] = createMatrix(c0,c1,c2)
    M(1,:) = c0; % plane origin
    M(2,:) = c1-c0; % firt plane parallel vector
    M(3,:) = c2-c0; % second plane parallel vector
    M(4,:) = cross(M(2,:),M(3,:))/norm(cross(M(2,:),M(3,:))); % plane normal
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