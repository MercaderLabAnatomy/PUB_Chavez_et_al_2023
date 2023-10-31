#!/usr/bin/env python
# coding: utf-8

import os
import argparse
import pandas as pd
import numpy as np
from skimage.io import imread
from skimage.measure import regionprops
import pyclesperanto_prototype as cle  # version 0.24.1

# Create an argument parser
parser = argparse.ArgumentParser(description='create global binary images')
parser.add_argument('folder_path', type=str, help='Folder path of the binary images')
args = parser.parse_args()


# Function to extract region properties
def calculate_medians(label_image, intensity_image):
    

    label_image = cle.merge_touching_labels(label_image)

    # Calculate region properties
    properties = regionprops(label_image, intensity_image)
    
    # Calculate additional properties
    regions = []
    
    for prop in properties:
        label = prop.label     
        median_intensity = np.median(intensity_image[prop.coords[:, 0], prop.coords[:, 1], prop.coords[:, 2]])
        regions.append([label,median_intensity])
    
    # Define column names
    column_names = ['label', 'median_intensity']
    
    df = pd.DataFrame(regions, columns=column_names)
    return df


    
    
# Function to process images and save as CSV
def process_images(label_folder, intensity_folder, output_folder):
    intensity_files = [f for f in os.listdir(intensity_folder) if f.startswith('C2')]
    
    for intensity_file in intensity_files:
        intensity_path = os.path.join(intensity_folder, intensity_file)
        label_file = intensity_file.replace('C2', 'C1').replace('.tif', '_regions.tif')
        label_path = os.path.join(label_folder, label_file)
        intensity_filename = os.path.splitext(intensity_file)[0]
        
        label_image = imread(label_path)
        intensity_image = imread(intensity_path)
        
        df = calculate_medians(label_image, intensity_image)
        
        output_file = os.path.join(output_folder, f"{intensity_filename}_medians.csv")
        df.to_csv(output_file, index=False)
        print(f"Region properties extracted and saved for {intensity_filename}")

# Specify the input and output paths
label_folder = os.path.join(args.folder_path,'C1_MC')
intensity_folder = os.path.join(args.folder_path,'C2')
output_folder = os.path.join(args.folder_path,'output_medians')

# Create the output folder if it doesn't exist
if not os.path.exists(output_folder):
    os.makedirs(output_folder)

# Process images and save as CSV
process_images(label_folder, intensity_folder, output_folder)


