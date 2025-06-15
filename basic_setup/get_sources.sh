#!/bin/bash

# Ensure LFS variable is set
if [ -z "$LFS" ]; then
  echo "Error: LFS variable is not set. Please set it before running the script."
  exit 1
fi

# Create sources directory if it doesn't exist
mkdir -p "$LFS/sources"

# File to store errors
ERROR_LOG="$LFS/sources/error.log"
# Clear error log if it exists
> "$ERROR_LOG"

# URL of the LFS packages page
URL="https://www.linuxfromscratch.org/lfs/view/stable/chapter03/packages.html"

# Fetch the page and extract package URLs
# Using curl to fetch, grep to find URLs, sed to clean them up
urls=$(curl -s "$URL" | \
  grep -o 'https://[^"]*\.\(tar\.gz\|tar\.bz2\|tar\.xz\|tgz\)' | \
  sed 's/.*\(https:\/\/[^"]*\.\(tar\.gz\|tar\.bz2\|tar\.xz\|tgz\)\).*/\1/' | \
  sort -u)

# Check if any URLs were found
if [ -z "$urls" ]; then
  echo "No package URLs found on the page."
  exit 1
fi

# Count total number of URLs for progress tracking
total=$(echo "$urls" | wc -l)
current=0
failed=0

echo "Found $total packages to download."

# Loop through each URL
while IFS= read -r url; do
  ((current++))
  filename=$(basename "$url")
  echo "[$current/$total] Downloading $filename..."

  # Download using wget, continue on failure, save to $LFS/sources
  if ! wget -q --no-check-certificate "$url" -O "$LFS/sources/$filename"; then
    echo "Failed to download $filename"
    echo "$url" >> "$ERROR_LOG"
    ((failed++))
  else
    echo "Successfully downloaded $filename"
  fi
done <<< "$urls"

# Print summary
echo "Download complete. $current packages processed, $failed failed."

# Remove error log if no failures
if [ $failed -eq 0 ] && [ -f "$ERROR_LOG" ]; then
  rm "$ERROR_LOG"
fi
