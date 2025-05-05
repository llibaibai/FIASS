clc;
clear all;

% Set the folder path
folderPath = 'E:\your\path\here';

% Get the file information of all TIF files in the folder
filePattern = fullfile(folderPath, '*.tif');
pngFiles = dir(filePattern);

% Extract numbers from file names and sort by numbers
fileNumbers = zeros(1, length(pngFiles));

for j = 1:length(pngFiles)
    baseFileName = pngFiles(j).name;
    numbers = regexp(baseFileName, '\d+', 'match'); 
    if ~isempty(numbers)
        fileNumbers(j) = str2double(numbers{1}); 
    end
end

% Sort files numerically
[~, sortedIndices] = sort(fileNumbers);

% **Initialize variables to store grayscale value sum and average**
sumGrayValues = zeros(1, length(pngFiles));
meanGrayValues = zeros(1, length(pngFiles));
fileNames = cell(1, length(pngFiles));  

% Create a folder "PICTURE" to save pictures
saveFolder = fullfile(folderPath, 'PICTURE');
if ~exist(saveFolder, 'dir')
    mkdir(saveFolder);  
end

% Adjustable rectangle side length (e.g. 50 pixels per side)
squareSize = 50;  

% Traverse all images and apply manually selected rectangular areas
for i = 1:length(pngFiles)
    sortedIndex = sortedIndices(i);
    baseFileName = pngFiles(sortedIndex).name;
    fullFileName = fullfile(folderPath, baseFileName);
    disp(['Processing files£º', fullFileName]);

    % Read color images
    img = imread(fullFileName);

    % Get the size of the image
    [imgHeight, imgWidth, ~] = size(img);

    % Display the image and let the user interactively select the center point of the rectangle
    figure(1);
    imshow(img);
    colormap(hot);
    title(['Please click to select the center of the rectangle - ', baseFileName]);

    % Get the center point of the rectangle clicked by the user
    [centerX, centerY] = ginput(1);  
    centerX = round(centerX);  
    centerY = round(centerY);

    close;

    % **Calculate the coordinates of the square selection area**
    halfSize = floor(squareSize / 2);  
    x1 = max(centerX - halfSize, 1); 
    y1 = max(centerY - halfSize, 1);
    x2 = min(centerX + halfSize, imgWidth);
    y2 = min(centerY + halfSize, imgHeight);

    % **Draw a square box on the current color image**
    imgWithSquare = insertShape(img, 'Rectangle', [x1, y1, squareSize, squareSize], 'Color', 'red', 'LineWidth', 2);

    % Display the color image of the drawn area
    figure(2);
    imshow(imgWithSquare);
    title(['Select the area (red box) - ', baseFileName]);

    % **Save the color picture with the selection to the PICTURE folder**
    selectedRegionFile = fullfile(saveFolder, ['selected_', baseFileName(1:end-3), 'png']);
    imwrite(imgWithSquare, selectedRegionFile);
    disp(['Image saved with selection£º', selectedRegionFile]);

    % Convert to grayscale image for grayscale value calculation
    grayImg = rgb2gray(img);  

    % Extract the gray value of the rectangular area
    selectedGrayValues = grayImg(y1:y2, x1:x2);

    % Calculate the sum and mean of gray values
    sumGrayValues(i) = sum(selectedGrayValues(:));
    meanGrayValues(i) = mean(selectedGrayValues(:));
    fileNames{i} = baseFileName;  
    
    % Output result
    fprintf('document: %s\n', baseFileName);
end

% **Smoothing parameter settings**
windowSize = 5; 
smoothedMeanGrayValues = smoothdata(meanGrayValues, 'movmean', windowSize);

% **Calculate the normalized value after normalization and smoothing**
maxMeanGrayValue = max(meanGrayValues);
normalizedValues = meanGrayValues / maxMeanGrayValue;
smoothedNormalizedValues = smoothedMeanGrayValues / maxMeanGrayValue;

% **Export data to Excel**
outputFile = fullfile(folderPath, 'analyze.xlsx');

% Combine data (correct dimension problem)
dataCell = [{'FileName', 'SumGrayValue', 'MeanGrayValue', 'NormalizedGrayValue', 'SmoothedMean', 'SmoothedNormalized'}; ...
            [fileNames', ...
             num2cell(sumGrayValues'), ...
             num2cell(meanGrayValues'), ...
             num2cell(normalizedValues'), ...
             num2cell(smoothedMeanGrayValues'), ...  
             num2cell(smoothedNormalizedValues')]];  

xlswrite(outputFile, dataCell);
