# SVM Analysis
> **Goal:** Prove that a male and female mouse produce different cell activities on mouse interaction (bout)
> 
> This project is to programmatically generate graphs that represent a mouse's cell activity during a bout and compare sets of bouts against each other to match similarities
### tl;dr
1. Asks *user* to choose *data file*
2. Applies a *Gaussian Filter* on dataset containing all cell activities
3. Matches each mouse bout with a timestamp where each timestamp corresponds to a set of cell activities
4. Performs a correlation between two sections of bouts (i.e., N1 vs N2; N1 vs A1; N2 vs A2; N1 vs A2)
5. Performs SVM between two sections of bouts for a X number of times and generates an accuracy between a shuffled test and controlled test
### Data
- **NeuAll:** Representation of all cells' activation. *Columns* represent a timestamp of the entire time series and *rows* represent the cell in question. Each cell activation is represented as a binary (0: off; 1: on).
- **BehavMouse\[N/A\]:** Representation of the mouse N or A interacting with object X. It is a 1D matrix where each interaction is represented as a binary (0: off; 1: on).
- **frameSec\[1/2\]\[Start/End\]:** Timestamp of a specific mouse. (e.g., frameSec1Start := 1 means that the section 1 starts on timestamp 1 of *NeuAll*). The dataset provides 4 timestamps (i.e., start and end for section 1; start and end for section 2).
### Project Structure
#### Updated Project Structure
```
|_ run.m                        # User runs this file (main file)
|
|_ utils                        # Folder with helper methods
|  |_ loadFolder.m
|  |_ loadFile.m
|  |_ loadData.m
|  |_ defineNeuroResponse.m
|  |_ defineBouts.m
|  |_ decodeSVM.m
|  |_ createFolder.m
|  |_ createCsvIfNotExist.m
|  |_ appendSpecialRowToCsv.m
|  |_ appendDefaultRowToCsv.m
|
|_ svm                          # Actual SVM methods written by previous dev
|  |_ Neuro_Responces.m
|  |_ MouseClass.m
|  |_ Linear_decoding.m
|  |_ gaussFilt.m
|  |_ Balancing_samples.m

```
#### Old Project Structure
**NOTE: You'll have to move all files from `svm` to `archive` to run `archive` code**
- `main.m`: Program that generates the coefficient correlation and svm accuracy
- `MouseClass.m`: Organize section timestamp for each mouse
- `gaussFilt.m`: Apply Gaussian Filtering to dataset. Explained in **3. Gaussian Filtering**
- `Neuro_Responses.m`: Transforms raw data to a matrix that matches bout with their corresponding timestamps. Explained in **4. Bout Annotation**
- `Linear_decoding.m`: Runs the SVM. Explained in **6. SVM generation**
- `Balancing_samples.m`: Helper function to patch missing data
- `old-main.m`: Previous developer's `main.m` file
### How to run
0. Ensure that you have a valid MATLAB installation.
1. Download codebase and ensure all files in the section above are within the same folder (files cannot be in subfolders)
2. Open `run.m` on MATLAB
