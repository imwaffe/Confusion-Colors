clear all

protan = [0.7465  0.2535  0.0000];
deutan = [1.4000 -0.4000  0.0000];
tritan = [0.1748  0.0004  0.8210];

deficiency = deutan;
input = [0.2 0.9 0.4];
distance = 0.07;
input_xyz = rgb2xyz(input);

while(1)
    output_xyz = input_xyz+distance/norm(deficiency-input_xyz)*(deficiency-input_xyz);
    output_rgb = round(xyz2rgb(output_xyz),4);
    input_rgb = round(xyz2rgb(input_xyz),4);
    if exist("xyPlot")
        figure(xyPlot);
    else
        xyPlot = figure;
    end
    plotChromaticity();
    hold on
    plot(input_xyz(1),input_xyz(2),'x');
    plot(deficiency(1),deficiency(2),'o');
    if exist("newPosition")
        delete(newPosition);
    end
    newPosition = plot(output_xyz(1),output_xyz(2),'.');
    xlim([-0.5, 2]);
    ylim([-1, 1.5]);
    hold off
    
    if exist("colorBoxes")
        figure(colorBoxes);
    else
        colorBoxes = figure;
    end 
    try
        subplot(1,2,1);
        rectangle('Position',[0,0,1,1],'FaceColor',input_rgb);
        subplot(1,2,2);
        rectangle('Position',[0,0,1,1],'FaceColor',output_rgb);
    catch
        warning('Invalid output color');
        subplot(1,2,1);
        rectangle('Position',[0,0,1,1],'FaceColor',[0 0 0]);
        subplot(1,2,2);
        rectangle('Position',[0,0,1,1],'FaceColor',[0 0 0]);
    end
    
    figure(xyPlot);
    [click_x, click_y, click_button] = ginput(1);
    if(click_button == 1)
        deficiency = [click_x click_y deficiency(3)];
    elseif(click_button == 3)
        input_xyz = [click_x click_y input_xyz(3)];
    end
end
