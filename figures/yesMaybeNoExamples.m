datapath = "/vol/blackmore/drone-lidar/summer2024-drone-data/stan-fpv-feather/";
yesH5Name = "stan-fpv-feather-15-13-14-tilt-80-fr-40.hdf5";
maybeH5Name = "stan-fpv-feather-14-42-31-tilt-0-fr-60.hdf5";
noH5Name = "stan-fpv-feather-14-45-23-tilt-10-fr-50.hdf5";

[yesH5data, h5meta] = loadh5(datapath + yesH5Name);

yesData = squeeze(yesH5data.data.data(1,:,:));
yesTimestamps = yesH5data.data.timestamps(1,:) * 1e-9;

yesTs = mean(diff(yesTimestamps));
yesFs = 1/yesTs;

[maybeH5data, h5meta] = loadh5(datapath + maybeH5Name);

maybeData = squeeze(maybeH5data.data.data(1,:,:));
maybeTimestamps = maybeH5data.data.timestamps(1,:) * 1e-9;

maybeTs = mean(diff(maybeTimestamps));
maybeFs = 1/maybeTs;


[noH5data, h5meta] = loadh5(datapath + noH5Name);

noData = squeeze(noH5data.data.data(1,:,:));
noTimestamps = noH5data.data.timestamps(1,:) * 1e-9;

noTs = mean(diff(noTimestamps));
noFs = 1/noTs;


%%
fontSize = 9;
fontName = "Times New Roman";

%%

fig = figure('Units','inches','Position',[0, 0, 3.5, 3.5]);

tlayout = tiledlayout(3,1);
tlayout.TileSpacing = "tight";
tlayout.Padding = "tight";


%% yes spectrum
yesRangebin = 121;

droneSignal = yesData(yesRangebin,:);

[droneSpectrum, f] = computeSpectrum(droneSignal, yesFs);

nexttile
plot(f, droneSpectrum, 'LineWidth', 1.5);
ylim([0,2.5])
box off;

prop_freq = yesH5data.parameters.prop_frequency.front_right.avg(1);

lineObj = xline(prop_freq, 'Color','k', 'LineStyle', '--', 'Alpha', 0.5, 'LineWidth', 1.2);

atitle = title('(a)','HorizontalAlignment','left','FontSize',fontSize,'FontName',fontName,'Units','normalized')
atitle.Position = [0.02 0.9 0];

xticklabels([])
xlim([0,1600])


%% maybe spectrum
maybeRangebin = 121;

droneSignal = maybeData(maybeRangebin,:);

[droneSpectrum, f] = computeSpectrum(droneSignal, maybeFs);


nexttile
plot(f, droneSpectrum, 'LineWidth', 1.5);
ylim([0,2.5])
box off;


prop_freq = maybeH5data.parameters.prop_frequency.front_right.avg(1);

lineObj = xline(prop_freq, 'Color','k', 'LineStyle', '--', 'Alpha', 0.5, 'LineWidth', 1.2);

xticklabels([])
xlim([0,1600])


btitle = title('(b)','HorizontalAlignment','left','FontSize',fontSize,'FontName',fontName,'Units','normalized')
btitle.Position = [0.02 0.9 0];

%% no spectrum
noRangebin = 121;

droneSignal = noData(noRangebin,:);

[droneSpectrum, f] = computeSpectrum(droneSignal, noFs);


nexttile
plot(f, droneSpectrum, 'LineWidth', 1.5);

ylim([0,0.5])
box off;


prop_freq = noH5data.parameters.prop_frequency.front_right.avg(1);

lineObj = xline(prop_freq, 'Color','k', 'LineStyle', '--', 'Alpha', 0.5, 'LineWidth', 1.2);

xlim([0,1600])

ctitle = title('(c)','HorizontalAlignment','left','FontSize',fontSize,'FontName',fontName,'Units','normalized')
ctitle.Position = [0.02 0.9 0];
%%
xlim([0,1600])

tlayout.XLabel.String = "Frequency [Hz]";
tlayout.XLabel.FontName = fontName;
tlayout.XLabel.FontSize = fontSize;

tlayout.YLabel.String = "Intensity [V^2]";
tlayout.YLabel.FontName = fontName;
tlayout.YLabel.FontSize = fontSize;

[tlayout.Children.FontName] = deal(fontName,fontName,fontName);
[tlayout.Children.FontSize] = deal(fontSize,fontSize,fontSize);


%%

exportgraphics(fig, 'yes-maybe-no-examples.pdf')


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
