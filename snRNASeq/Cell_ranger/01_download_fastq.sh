#!/bin/bash
#SBATCH --job-name=download_files
#SBATCH --array=0-15
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:20:00
#SBATCH --output=logs/01_download/download_files_%A_%a.out

# Specify the path to your text file containing HTTP addresses
file_path="fastq_files.txt"

# Check if the file exists
if [ ! -f "$file_path" ]; then
    echo "File not found: $file_path"
    exit 1
fi

# Create a directory to store the downloaded files
download_dir="raw_fastq"
mkdir -p "$download_dir"

# Read the URL corresponding to the current SLURM task ID
url=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$file_path")

# Extract the filename from the URL
filename=$(basename "$url")

# Download the file using wget
echo "Downloading: $filename"
wget -P $download_dir $url

echo "Download completed!"
