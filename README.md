

# Multi-device Data Collection for Human Activity Recognition

This repository contains the implementation of an app that focuses on optimizing data collection methods for Human Activity Recognition (HAR) by addressing data skewness, outliers, and time synchronization challenges. The goal is to improve the accuracy of real-time predictions without the need for complex preprocessing techniques.

## Contributors
- [Haardik Ravat](https://github.com/Haardik-Ravat)
- [Dhruv Mahajan ](https://github.com/Dhruv-Mahajan1)

  ## Demo




https://github.com/Haardik-Ravat/Complex-Behaviour-Recognition/assets/78262624/c35cf01c-26e3-4e79-9b30-304c88a705f6


  
  ## Data Flow
![Flowchart (1)](https://github.com/Haardik-Ravat/Complex-Behaviour-Recognition/assets/78262624/f3d00879-8370-45d2-ba70-f2e2ce40b937)



## Problem Statement

Data collection for HAR often suffers from skewed data distributions, the presence of outliers, and a lack of time synchronization across multiple sources. These issues can lead to false activity recognition and hinder context prediction accuracy. The project aims to overcome these challenges and enhance the overall performance of HAR models.

## Objective

The primary objectives of this project are:

1. Develop an app that optimizes data collection methods to reduce model complexity during training by avoiding extensive preprocessing techniques.
2. Implement time synchronization methods to handle data from multiple sources and improve context prediction results.
3. Enhance real-time predictions by utilizing noise reduction techniques to improve accuracy.

## Solution

To achieve the objectives mentioned above, the following steps were taken:

1. Data Preprocessing:
   - Utilized three individual filters, including moving average, clipping, and Butterworth, to address skewed data and outliers in complex activity recognition.

2. Time Synchronization:
   - Implemented a queue-based approach to synchronize data collected from different sources.
   - The data closest to the last appended entry in the combined queue was selected for time synchronization.
   - Time synchronization was performed for the acceleration and gyroscopic event data from sense and smartwatch sources.

3. Noise Reduction:
   - Applied filters to remove noise from incoming IMU (Inertial Measurement Unit) data.
   - The noise reduction techniques helped in improving the quality of data used for real-time predictions.










## Run Locally

### Mobile/SmartWartch app

1. Navigate to the app_client Directory:

```
cd app_client  // for mobile app
cd wear_OS  // for smartwatch
```

1. Install Dependencies:
   - Run the following command in the terminal to install dependencies specified in the `pubspec.yaml` file
     ```
     flutter pub get
     ```
2. Connect a Device:
   - Connect an Android or iOS device to your computer using a USB cable or ensure that an emulator/simulator is running.
3. Start the App:
   - To start your Flutter app on the connected device run the following command in the terminal
     ```
     flutter run
     ```
