clc;
clear all;

% Parameter settings
folderPath = 'E:\your\path\here';
regionSize = 50;      % Area size
windowSize = 5;       % Smoothing window size

% Create output folder
outputFolder = fullfile(folderPath, 'region');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Prepare for file processing
% Get file list
filePattern = fullfile(folderPath, '*.tif');
tifFiles = dir(filePattern);

% File sorting
fileNumbers = zeros(1, length(tifFiles));
for j = 1:length(tifFiles)
    numbers = regexp(tifFiles(j).name, '\d+', 'match');
    fileNumbers(j) = str2double(numbers{1});
end
[~, sortedIndices] = sort(fileNumbers);

% Main processing flow
% Initialize storage structure
allRegionData = [];
smoothedData = [];
normalizedData = [];

% First pass: Collect all regional data
for j = 1:length(sortedIndices)
    % Read image
    img = imread(fullfile(folderPath, tifFiles(sortedIndices(j)).name));
    
    % Draw a red border and save
    [markedImg, regionCoordinates] = drawRegionBorders(img, regionSize);
    imwrite(markedImg, fullfile(outputFolder, [tifFiles(sortedIndices(j)).name(1:end-4) '_marked.tif']));
    
    % Extract green channel data
    greenData = img(:, :, 2);
    
    % Collect regional data
    regionValues = getRegionValues(greenData, regionCoordinates);
    allRegionData = [allRegionData; regionValues];
end

% Second pass: data processing
% Smoothing
smoothedData = smoothdata(allRegionData, 1, 'movmean', windowSize);

% Normalization (compared with the first picture)
baseValues = smoothedData(1, :);
normalizedData = zeros(size(smoothedData));
for k = 1:size(smoothedData, 2)
    if baseValues(k) > 0
        normalizedData(:, k) = smoothedData(:, k) / baseValues(k);
    else
        normalizedData(:, k) = 0;
    end
end

% Generate output table
header = {'FileName'};
for regionID = 1:size(smoothedData, 2)
    header{end+1} = sprintf('Region%d_Smoothed', regionID);
    header{end+1} = sprintf('Region%d_Normalized', regionID);
end

results = cell(length(sortedIndices)+1, length(header));
results(1,:) = header;

for j = 1:length(sortedIndices)
    results{j+1,1} = tifFiles(sortedIndices(j)).name;
    colIdx = 2;
    for regionID = 1:size(smoothedData, 2)
        results{j+1,colIdx} = smoothedData(j, regionID);
        results{j+1,colIdx+1} = normalizedData(j, regionID);
        colIdx = colIdx + 2;
    end
end

% Save to Excel
xlswrite(fullfile(outputFolder, 'region_analysis.xlsx'), results);

% Helper function
function [markedImg, regionCoordinates] = drawRegionBorders(img, regionSize)
    % Draw a red area border
    markedImg = img;
    [rows, cols, ~] = size(img);
    regionCoordinates = struct('x', [], 'y', []);
    
    % Red border parameters
    borderColor = uint8([255 0 0]);  % RGB Red
    borderWidth = 2;
    
    regionCounter = 1;
    for y = 1:regionSize:rows
        for x = 1:regionSize:cols
            if y+regionSize-1 <= rows && x+regionSize-1 <= cols
                % Record area coordinates
                regionCoordinates(regionCounter).x = [x, x+regionSize-1];
                regionCoordinates(regionCounter).y = [y, y+regionSize-1];
                
                % Draw four sides
	% Left side
                markedImg(y:y+regionSize-1, x:x+borderWidth-1, :) = ...
                    repmat(reshape(borderColor,1,1,3), [regionSize, borderWidth]);
                % Right
                markedImg(y:y+regionSize-1, x+regionSize-borderWidth:x+regionSize-1, :) = ...
                    repmat(reshape(borderColor,1,1,3), [regionSize, borderWidth]);
                % Top
                markedImg(y:y+borderWidth-1, x:x+regionSize-1, :) = ...
                    repmat(reshape(borderColor,1,1,3), [borderWidth, regionSize]);
                % Below
                markedImg(y+regionSize-borderWidth:y+regionSize-1, x:x+regionSize-1, :) = ...
                    repmat(reshape(borderColor,1,1,3), [borderWidth, regionSize]);
                
                regionCounter = regionCounter + 1;
            end
        end
    end
end

function regionValues = getRegionValues(channelData, regionCoordinates)
    % Get area data
    regionValues = zeros(1, length(regionCoordinates));
    for k = 1:length(regionCoordinates)
        xRange = regionCoordinates(k).x(1):regionCoordinates(k).x(2);
        yRange = regionCoordinates(k).y(1):regionCoordinates(k).y(2);
        region = channelData(yRange, xRange);
        regionValues(k) = mean(region(:));
    end
end
