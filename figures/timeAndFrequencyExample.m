datapath = "/vol/blackmore/drone-lidar/field-test-data/combined/";
h5Name = "combined-stan-fpv-53.0m-tilt-30-fr-50-fl-50-br-50-bl-50.hdf5";

[h5data, h5meta] = loadh5(datapath + h5Name);

data = squeeze(h5data.data.data(1,:,:));
timestamps = h5data.data.timestamps(1,:) * 1e-9;

Ts = mean(diff(timestamps));
fs = 1/Ts;

slope = 0.14911515;
offset = -2.516595;
nRangebins = height(data);
distance = (0:nRangebins) * slope + offset;

%%
rangebin = 368;

droneSignal = data(rangebin,:);

[droneSpectrum, f] = computeSpectrum(droneSignal, fs);


%%

fig = figure('Units','inches','Position',[0, 0, 3.5, 3.5]);

tlayout = tiledlayout(3,9);
tlayout.TileSpacing = "compact";
tlayout.Padding = "loose";

%% time domain image
nexttile([2 7]);

maxTimeIdx = 128;
distIdx = 300:428;
imagesc(timestamps(1:maxTimeIdx) * 1e3,distance(distIdx),data(distIdx,1:maxTimeIdx));

% flip y-axis
axis xy;

cbar = colorbar;
cbar.Label.String = "Magnitude [V]";
cbar.Layout.Tile = 8;
cbar.Layout.TileSpan = [2, 2];
xlabel("Time [ms]")
ylabel("Distance [m]")

imax = gca;
imtitle = title('(a)','HorizontalAlignment','left','Units','points','Position', [-30, 125, 0])

%% spectrum
nexttile(19,[1 9])

plot(f, droneSpectrum, 'LineWidth', 1.2);
xlabel('Frequency [Hz]','FontSize',9);
ylabel('Intensity [V^2]','FontSize',9);
ylim([0,550])
box off;


prop_freqs = [
        h5data.parameters.prop_frequency.back_left.avg(1),
        h5data.parameters.prop_frequency.back_right.avg(1),
        h5data.parameters.prop_frequency.front_left.avg(1),
        h5data.parameters.prop_frequency.front_right.avg(1),
    ];
colors = colororder;
for prop_freq = prop_freqs(4)
    if prop_freq > 0
        for i=1:2
            lineObj = xline(prop_freq*i, 'Color','k', 'LineStyle', '--', 'Alpha', 0.8*(5-i)/4, 'LineWidth', 1.2);
        end
    end
end


xlim([0,fs/2])

specax = gca;

spectitle = title('(b)','HorizontalAlignment','left','Units','points','Position', [-30, 55, 0])



%%
set(imax, 'FontSize',9)
set(imax, 'FontName','Times New Roman')
set(specax, 'FontSize',9)
set(specax, 'FontName','Times New Roman')



%%

exportgraphics(fig, '53-meter-example.pdf')


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
