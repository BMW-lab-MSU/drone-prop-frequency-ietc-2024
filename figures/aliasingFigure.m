datapath = "/vol/blackmore/drone-lidar/summer2024-drone-data/stan-fpv-feather/";
h5Name = "stan-fpv-feather-17-51-42-tilt-60-fr-40-fl-40-br-40-bl-40.hdf5";

[h5data, h5meta] = loadh5(datapath + h5Name);

data = squeeze(h5data.data.data(1,:,:));
timestamps = h5data.data.timestamps(1,:) * 1e-9;

Ts = mean(diff(timestamps));
fs = 1/Ts;

rangebin = 122;3

droneSignal = data(rangebin,:,:);

[droneSpectrum, f] = computeSpectrum(droneSignal, fs);


fig = figure('Units','inches','Position',[0, 0, 3.5, 2.0]);
plot(f, droneSpectrum, 'LineWidth', 2);
xlabel('Frequency [Hz]','FontSize',9);
ylabel('Intensity [V^2]','FontSize',9);
ylim([0,9500])
box off;


prop_freqs = [
        h5data.parameters.prop_frequency.back_left.avg(1),
        h5data.parameters.prop_frequency.back_right.avg(1),
        h5data.parameters.prop_frequency.front_left.avg(1),
        h5data.parameters.prop_frequency.front_right.avg(1),
    ];
colors = colororder;
j = 2;
for prop_freq = max(prop_freqs)
    if prop_freq > 0
        for i=1:4
            lineObj = xline(prop_freq*i, 'Color','k', 'LineStyle', '--', 'Alpha', 0.8*(5-i)/4, 'LineWidth', 1.2);
        end
    end
    j = j+1;
end


% plot the alises
f1 = max(prop_freqs);
lineObj = xline(fs - 4*f1, '--', 'Color', colors(3,:), 'Alpha', 0.8, 'LineWidth', 1.2);
lineObj = xline(fs - 5*f1, '--', 'Color', colors(3,:), 'Alpha', 0.6, 'LineWidth', 1.2);
lineObj = xline(fs - 6*f1, '--', 'Color', colors(3,:), 'Alpha', 0.4, 'LineWidth', 1.2);
lineObj = xline(-fs +  7*f1, '--', 'Color', colors(3,:), 'Alpha', 0.2, 'LineWidth', 1.2);
%lineObj = xline(-fs +  8*f1, 'k--', 'Alpha', 0.5, 'LineWidth', 4);



set(gca, 'FontSize',9)
set(gca, 'FontName','Times New Roman')

textbox = annotation("textbox", [0.38, 0.1, 0.3, 0.75]);
textbox.EdgeColor = "none";
textbox.FitBoxToText = "off";
annotationStr = [
            "f_1"
        ];
textbox.String = annotationStr;
textbox.FontSize = 9;

textbox = annotation("textbox", [0.60, 0.1, 0.3, 0.75]);
textbox.EdgeColor = "none";
textbox.FitBoxToText = "off";
annotationStr = [
            "f_2"
        ];
textbox.String = annotationStr;
textbox.FontSize = 9;

textbox = annotation("textbox", [0.82, 0.1, 0.3, 0.75]);
textbox.EdgeColor = "none";
textbox.FitBoxToText = "off";
annotationStr = [
            "f_3"
        ];
textbox.String = annotationStr;
textbox.FontSize = 9;

textbox = annotation("textbox", [0.64, 0.1, 0.3, 0.5]);
textbox.EdgeColor = "none";
textbox.FitBoxToText = "off";
annotationStr = [
            "f_s - f_4"
        ];
textbox.String = annotationStr;
textbox.FontSize = 9;
textbox = annotation("textbox", [0.41, 0.1, 0.3, 0.5]);
textbox.EdgeColor = "none";
textbox.FitBoxToText = "off";
annotationStr = [
            "f_s - f_5"
        ];
textbox.String = annotationStr;
textbox.FontSize = 9;

textbox = annotation("textbox", [0.25, 0.1, 0.3, 0.5]);
textbox.EdgeColor = "none";
textbox.FitBoxToText = "off";
annotationStr = [
            "f_s - f_6"
        ];
textbox.String = annotationStr;
textbox.FontSize = 9;

textbox = annotation("textbox", [0.15, 0.1, 0.3, 0.35]);
textbox.EdgeColor = "none";
textbox.FitBoxToText = "off";
annotationStr = [
            "-f_s + f_7"
        ];
textbox.String = annotationStr;
textbox.FontSize = 9;

xlim([0,fs/2])

exportgraphics(fig, 'aliasing.pdf')


%%
function [magnitude, f] = computeSpectrum(signal, fs)
    arguments
        signal double
        fs (1,1) double
    end

    nSamples = width(signal);

    magnitude = abs(fft(signal, [], 2)).^2;
    magnitude = magnitude(:,1:nSamples/2);

    f = linspace(0, fs/2, nSamples/2);
end
