# FIASS
# MATLAB Image Processing Scripts - README

## Introduction
This repository contains two MATLAB scripts designed for processing TIF-format images. The scripts extract grayscale or green channel data from specified regions, perform smoothing and normalization, and are particularly useful for cell image analysis.

---

## Script Overview

### 1. `Sigletrangle_smooth.m`
- **Functionality**:
  - Processes images sequentially.
  - Allows interactive selection of a rectangular region centered on a user-clicked point.
  - Calculates grayscale statistics (sum, mean) and applies smoothing/normalization.
- **Outputs**:
  - Marked images with red rectangles (saved in `PICTURE` folder).
  - Excel file (`analyze.xlsx`) containing raw and processed data.

### 2. `REGION_smooth.m`
- **Functionality**:
  - Automatically divides images into fixed-size sub-regions (e.g., 40×40 pixels).
  - Extracts green channel values, applies smoothing, and normalizes data relative to the first image.
- **Outputs**:
  - Marked images with red borders (saved in `region` folder).
  - Excel file (`region_analysis.xlsx`) with smoothed and normalized values for each sub-region.

---

## Requirements
- **MATLAB Version**: R2018b or newer.
- **Toolboxes**: Image Processing Toolbox.

---

## Usage Guide

### Setup
1. **Folder Structure**:
   - Place all TIF images in a single folder.
   - Ensure filenames include numeric indices (e.g., `image_001.tif`) for correct ordering.

2. **Path Configuration**:
   - Update the `folderPath` variable in both scripts to your image folder:
     - `Sigletrangle_smooth.m`:
       ```matlab
       folderPath = 'E:\your\path\here'; % Replace with your path
       ```
     - `REGION_smooth.m`:
       ```matlab
       folderPath = 'C:\your\path\here'; % Replace with your path
       ```

### Running `Sigletrangle_smooth.m`
1. **Parameters**:
   - Adjust rectangle size (default: 50 pixels):
     ```matlab
     squareSize = 50; % Modify as needed
     ```
   - Smoothing window size (default: 5 frames):
     ```matlab
     windowSize = 5;
     ```

2. **Execution**:
   - Run the script. For each image:
     - Click the center of the target region in the pop-up window.
     - The script saves marked images and exports data automatically.

### Running `REGION_smooth.m`
1. **Parameters**:
   - Sub-region size (default: 50 pixels):
     ```matlab
     regionSize = 50; % Modify as needed
     ```
   - Smoothing window size (default: 5 frames):
     ```matlab
     windowSize = 5;
     ```

2. **Execution**:
   - Run the script. No user interaction is required.
   - Outputs include marked images and Excel files with region-wise data.

---

## Output Files

### `Sigletrangle_smooth.m`
- **`PICTURE` Folder**:
  - `selected_*.tif`: Images with red rectangles marking selected regions.
- **`analyze.xlsx`**:
  - Columns: `FileName`, `SumGrayValue`, `MeanGrayValue`, `NormalizedGrayValue`, `SmoothedMean`, `SmoothedNormalized`.

### `REGION_smooth.m`
- **`region` Folder**:
  - `*_marked.tif`: Images with red borders around sub-regions.
- **`region_analysis.xlsx`**:
  - Columns: `FileName`, `RegionX_Smoothed`, `RegionX_Normalized` (for each sub-region X).

---

## Troubleshooting

1. **Images Processed Out of Order**:
   - Ensure filenames contain consecutive numbers (e.g., `image_1.tif`, `image_2.tif`).

2. **Regions Exceed Image Boundaries**:
   - Verify image dimensions are larger than `squareSize` or `regionSize`.

3. **Excel Write Failures**:
   - Close any open Excel files before running scripts.

4. **Undefined Function Errors**:
   - Confirm the Image Processing Toolbox is installed.
