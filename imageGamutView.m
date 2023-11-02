%file = input("Insert file path\n",'s');
file = "D:\users\lucaa\Pictures\Sardegna 2021\Marceddi\2021\2021-08-18\export_web\_DSC6607.jpg";
img = imread(file);
%img = imgaussfilt(img,3,'FilterSize',101);
xyzImg = rgb2xyz(img,'ColorSpace','adobe-rgb-1998');
img = xyz2rgb(xyzImg,'ColorSpace','sRGB','OutputType','uint16');
imshow(img);
%%
xyzImg = rgb2xyz(img,'ColorSpace','adobe-rgb-1998');
adobeXYZ = rgb2xyz([1 0 0; 0 1 0; 0 0 1],'ColorSpace','adobe-rgb-1998');
adobex = adobeXYZ(:,1)./sum(adobeXYZ,2);
adobey = adobeXYZ(:,2)./sum(adobeXYZ,2);
srgbXYZ = rgb2xyz([1 0 0; 0 1 0; 0 0 1],'ColorSpace','sRGB');
srgbx = srgbXYZ(:,1)./sum(srgbXYZ,2);
srgby = srgbXYZ(:,2)./sum(srgbXYZ,2);
plotChromaticity();
hold on;
plot([adobex; adobex], [adobey; adobey], '-.');
plot([srgbx; srgbx], [srgby; srgby], 'k');
for r=1:101:size(xyzImg,1)
    for c=1:101:size(xyzImg,2)
        s = sum(xyzImg(r,c,:));
        x = xyzImg(r,c,1)/s;
        y = xyzImg(r,c,2)/s;
        scatter(x,y,'x','k');
    end
end