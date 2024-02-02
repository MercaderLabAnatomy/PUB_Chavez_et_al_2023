import os
import argparse
import pandas as pd
import numpy as np
from skimage.io import imread
from skimage.measure import regionprops

# Create an argument parser
parser = argparse.ArgumentParser(description='create global binary images')
parser.add_argument('--folder_path', type=str, help='Folder path of the binary images')
parser.add_argument('--channel', type=str, help='Channel to analyze')
args = parser.parse_args()

folder_path = args.folder_path
channel = args.channel

# Function to extract region properties
def extract_region_properties(label_image, intensity_image):
    # Calculate region properties
    properties = regionprops(label_image, intensity_image)
    
    # Calculate additional properties
    regions = []
    
    for prop in properties:
        label = prop.label
        mean_intensity = prop.intensity_mean
        max_intensity = prop.intensity_max
        min_intensity = prop.intensity_min
        median_intensity = np.median(intensity_image[prop.coords[:, 0], prop.coords[:, 1], prop.coords[:, 2]])
        # only include labels 2,3,4
        if label in [2,3,4]:
            regions.append([label,median_intensity,mean_intensity,max_intensity,min_intensity])
        else:
            continue
    
    # Define column names
    column_names = ['label', 'median_intensity','mean_intensity','max_intensity','min_intensity']
    
    df = pd.DataFrame(regions, columns=column_names)
    return df

# Function to process images and save as CSV
def process_images(label_folder, intensity_folder, output_folder):
    intensity_files = [f for f in os.listdir(intensity_folder) if f.startswith(channel)]
    
    for intensity_file in intensity_files:
        intensity_path = os.path.join(intensity_folder, intensity_file)
        label_file = intensity_file.replace('C1',channel).replace('.tif','_MC_regions.tif')
        label_path = os.path.join(label_folder, label_file)
        intensity_filename = os.path.splitext(intensity_file)[0]     
        label_image = imread(label_path)
        intensity_image = imread(intensity_path)     
        df = extract_region_properties(label_image, intensity_image)     
        output_file = os.path.join(output_folder, f"{intensity_filename}_region_properties.csv")
        df.to_csv(output_file, index=False)
        print(f"Region properties extracted and saved for {intensity_filename}")

# Specify the input and output paths
label_folder = os.path.join(folder_path,'C1_labels_regions')
intensity_folder = os.path.join(folder_path,'C1')
output_folder = os.path.join(folder_path,'output_GFP')

# Create the output folder if it doesn't exist
if not os.path.exists(output_folder):
    os.makedirs(output_folder)

# Process images and save as CSV
process_images(label_folder, intensity_folder, output_folder)


