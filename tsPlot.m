function [hIsopycs, hTS] = tsPlot(SA, CT, plotData, numIsopycs, colContour)
%tsPlot Plot density contours for temperature and salinity data
%   INPUTS:
%       SA (required): Absolute Salinity range or data from gsw_SA_from_SP 
%           [Nx1 or MxN]
%       CT (required): Conservative Temperature range or data from 
%           gsw_CT_from_t [Nx1 or MxN]
%       plotData: 0 to only plot density contours (default is 1)
%       numIsopycs: number of isopycnals to plot (scalar; default is 10)
%       colContour: color for contour lines/labels (may be 1x3 or matlab
%          color string; default is 'k')
%
%   OUTPUTS:
%       hIsopycs, hTS: handles for density contours and T-S data scatter,
%          respectively
% 
% dependencies: Gibbs-SeaWater (GSW) Oceanographic Toolbox
%       http://www.teos-10.org/software.htm#1
%
% (margaret lindeman 01 june 2021)

if ~exist('gsw_sigma0')
    error('Error: Add GSW toolbox to path. See doc for more info.')
end

if size(SA) ~= size(CT)
    error('Error: SA and CT must have the same dimensions.')
end

%% defaults and plot settings
pD_def = 1;
nI_def = 10;
cC_def = 'k';

% plot settings: contour lines
sigmaRound = 0.25; % round densities to nearest ___
lwContour = 1; % contour line width

% plot settings: T-S data
colData = [0, 0.447, 0.741]; % matlab default blue
scatSize = 20; % data scatter size

% plot settings: axis labels
labelSA = 'Absolute Salinity [g/kg]';
labelCT = ['Conservative Temperature [' char(176) 'C]'];

%% setup
if nargin == 2
    plotData = pD_def;
    numIsopycs = nI_def;
    colContour = cC_def;
elseif nargin == 3
    numIsopycs = nI_def;
    colContour = cC_def;
elseif nargin == 4
    colContour = cC_def;
end

if sum(size(SA)>1)>1
    SA = SA(:);
    CT = CT(:);
end

%% calculations

% calculate densities for data range
sigmaAll = gsw_sigma0(SA, CT);
sigmaBounds = [round(min(sigmaAll)/sigmaRound)*sigmaRound,...
    round(max(sigmaAll)/sigmaRound)*sigmaRound];

% define isopycnal contour values
sigmaRange = sigmaBounds(2)-sigmaBounds(1);
sigmaDelta = round(sigmaRange/numIsopycs/sigmaRound)*sigmaRound;

if sigmaDelta == 0
    sigmaDelta = sigmaRound;
end

vIsopycs = sigmaBounds(1):sigmaDelta:sigmaBounds(2);

% create grid of SA, CT, sigma
gridSA = linspace(min(SA),max(SA));
gridCT = linspace(min(CT),max(CT));

[X, Y] = meshgrid(gridSA, gridCT);
gridSigma = gsw_sigma0(X, Y);


%% plotting

% plot density contours
[C, hIsopycs] = contour(X, Y, gridSigma, vIsopycs,'color',colContour,...
    'linewidth',lwContour);
clabel(C, hIsopycs, 'color', colContour);

% plot T-S data
if plotData == 1
    hold on
    hTS = scatter(SA, CT, scatSize, colData, 'filled');
    hold off
else
    hTS = NaN;
end

% add axis labels
xlabel(labelSA)
ylabel(labelCT)

end