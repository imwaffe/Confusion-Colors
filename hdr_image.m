kernelSize = 5;
stdDev = 0.8;
gamma = 2.4;
correctGamma = false;
gaussFilt = true;
file = 'orgosolo.png';

clear("image", "topImg", "baseImg");

image = imread(file);
%for r=0:31
%    for c=0:15
%        image(r+1,c+1) = uint16(r*16+c)*0x80u16;
%    end
%end
image = imadjust(image,[],[],1/gamma);

for r=1:size(image,1)
    for c=1:size(image,2)
        v = (image(r,c)/0x80u16);
        topImg(r,c) = uint8(bitand(v,0xFFu16));
        baseImg(r,c) = uint8(0xFFu16*bitget(v,9));
    end
end

if(gaussFilt)
    baseImg = imgaussfilt(baseImg,stdDev,'FilterSize',kernelSize);
    topImg = imgaussfilt(topImg,stdDev,'FilterSize',kernelSize);
end
if(correctGamma)
    topImg = imadjust(topImg,[],[],gamma);
end

if ~exist("fig") || ~isprop(fig,"Number")
    fig = figure('units','normalized','outerposition',[0 0 1 1]);
    set(fig, 'MenuBar', 'none');
end

set(0, 'CurrentFigure', fig);
%subplot(1,3,2);
%imshow(image);
subplot(1,2,1);
imshow(topImg);
subplot(1,2,2);
imshow(flipdim(baseImg,2));