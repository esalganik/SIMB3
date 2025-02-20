%% Dataset import
close all; clear; clc; 
ncvars =  {'time','lat','lon','z','hi','hs','sur','int','bot','T','hi_west','hs_west','sur_west','int_west','bot_west'};
projectdir = 'C:\Users\evgenii.salganik\Documents\MATLAB\SIMB3';
dinfo = dir( fullfile(projectdir, '*.nc') );
num_files = length(dinfo);
filenames = fullfile( projectdir, {dinfo.name} );
label = {dinfo.name};
time = cell(num_files,1); hi = time; hs = time; hi_west = time; hs_west = time; T = time;
for K = 1 : num_files
  this_file = filenames{K};
  label{K} = label{K}(1:5);
  time{K} = ncread(this_file, ncvars{1}); % days since 1978-09-01
  t_0 = (datetime('01-Sep-1978 00:00')); t{K} = t_0 + days(time{K});
  z{K} = ncread(this_file, ncvars{4});
  hi{K} = ncread(this_file, ncvars{5});
  hs{K} = ncread(this_file, ncvars{6});
  sur{K} = ncread(this_file, ncvars{7});
  int{K} = ncread(this_file, ncvars{8});
  T{K} = ncread(this_file, ncvars{10});
  hi_west{K} = ncread(this_file, ncvars{11});
  hs_west{K} = ncread(this_file, ncvars{12});
  sur_west{K} = ncread(this_file, ncvars{13});
  int_west{K} = ncread(this_file, ncvars{14});
end
clearvars ncvars projectdir dinfo filenames num_files this_file K time t_0

%%
figure
tile = tiledlayout(3,2); tile.TileSpacing = 'compact'; tile.Padding = 'compact';
nexttile([1 2])
load('batlow50.mat'); 
for i = 1:length(t)
    plot(t{i},hs{i},'color',batlow50(i,:)); hold on
end
hYLabel = ylabel('Snow depth (m)'); set([ hYLabel gca],'FontSize',8,'FontWeight','normal');
leg = legend(label,'box','off','NumColumns',1); set(leg,'FontSize',6,'Location','bestoutside','orientation','horizontal'); leg.ItemTokenSize = [30*0.33,18*0.33];
nexttile([1 2])
for i = 1:length(t)
    plot(t{i},hi{i},'color',batlow50(i,:)); hold on
end
hYLabel = ylabel('Ice thickness (m)'); set([ hYLabel gca],'FontSize',8,'FontWeight','normal');

% Snow and ice thickness comparison
nexttile
x = cell2mat(hs);
y = cell2mat(hs_west); y(y < 0) = NaN; y(y > 2) = NaN;
N = hist3([x,y],'Nbins',[1 1]*20);
N_pcolor = N';
N_pcolor(size(N_pcolor,1)+1,size(N_pcolor,2)+1) = 0;
xl = linspace(min(x),max(x),size(N_pcolor,2)); % Columns of N_pcolor
yl = linspace(min(y),max(y),size(N_pcolor,1)); % Rows of N_pcolor
imagesc(xl,yl,N_pcolor); hold on % contourplot
load('batlowW.mat'); colormap(flipud(batlowW));
ax = gca; ax.ZTick(ax.ZTick < 0) = [];
set(gcf, 'renderer', 'opengl');
plot([-.1 .7],[-.1 .7],'--','color','k','LineWidth',2.5);
xlim([xl(1)-0.5*(xl(2)-xl(1)) 0.7]); ylim([yl(1)-0.5*(yl(2)-yl(1)) 0.7]);
hXLabel = xlabel('Snow depth, reprocessed (m)'); hYLabel = ylabel('Snow depth, West (m)'); set([hXLabel hYLabel gca],'FontSize',8,'FontWeight','normal'); set(gca,'YDir','normal');

nexttile
x = cell2mat(hi);
y = cell2mat(hi_west); y(y < 0) = NaN; y(y > 5) = NaN;
N = hist3([x,y],'Nbins',[1 1]*15);
N_pcolor = N';
N_pcolor(size(N_pcolor,1)+1,size(N_pcolor,2)+1) = 0;
xl = linspace(min(x),max(x),size(N_pcolor,2)); % Columns of N_pcolor
yl = linspace(min(y),max(y),size(N_pcolor,1)); % Rows of N_pcolor
imagesc(xl,yl,N_pcolor); hold on % contourplot
load('batlowW.mat'); colormap(flipud(batlowW));
ax = gca; ax.ZTick(ax.ZTick < 0) = [];
set(gcf, 'renderer', 'opengl');
plot([-.1 4],[-.1 4],'--','color','k','LineWidth',2.5);
xlim([0 4]); ylim([0 4]);
hXLabel = xlabel('Ice thickness, reprocessed (m)'); hYLabel = ylabel('Ice thickness, West (m)'); set([hXLabel hYLabel gca],'FontSize',8,'FontWeight','normal'); set(gca,'YDir','normal');
clearvars ax hXLabel hYLabel tile N N_pcolor ax batlowW x y xl yl

%% Example of temperature measuments
figure
i = 10; % selected buoy
dTdz = diff(T{i},1,2);
range = -20:2:20;
contourf(datenum(t{i}),z{i}(1:end-1),dTdz'*10,range,'-','ShowText','off','LabelSpacing',400,'edgecolor','none'); hold on
plot(datenum(t{i}),sur_west{i},'k:','LineWidth',3); plot(datenum(t{i}),int_west{i},'k:','LineWidth',3); % Interfaces from West (2015)
plot(datenum(t{i}),sur{i},'b:','LineWidth',3); plot(datenum(t{i}),int{i},'b:','LineWidth',3); % Reprocessed interfaces
load('batlow.mat'); colormap(batlow); % colormap(parula);
hYLabel = ylabel('Depth (m)'); set([hYLabel gca],'FontSize',7,'FontWeight','normal');
hBar1 = colorbar; ylabel(hBar1,'Vertical temp. grad. (°C/m)','FontSize',7);
name=convertStringsToChars(label{i}); title(sprintf('Vert. temp. gradient, %s',name(1:5)),'FontSize',8,'FontWeight','normal');
leg = legend('','West (2020)','','Updated','box','on','NumColumns',1); set(leg,'FontSize',6,'Location','northwest','orientation','horizontal'); leg.ItemTokenSize = [30*0.5,18*0.5];
ylim([round(min(int{i}),1)-0.2 round(max(sur{i}),1)+0.1]);
datetick('x','mmm','keepticks','keeplimits'); xtickangle(0);