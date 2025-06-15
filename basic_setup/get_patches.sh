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
[ -f "$ERROR_LOG" ] && > "$ERROR_LOG"

# URL of the LFS patches page
URL="https://www.linuxfromscratch.org/lfs/view/stable/chapter03/patches.html"

# Fetch the page and extract patch URLs
# Use curl to fetch, grep to find lines with URLs, sed to extract and clean them
urls=$(curl -s "$URL" | \
  grep -o 'https://[^"]*\.patch' | \
  sed 's/.*\(https:\/\/[^"]*\.patch\).*/\1/' | \
  sort -u)

# Debug: Print found URLs
echo "Found URLs:"
echo "$urls"
echo "----------------"

# Check if any URLs were found
if [ -z "$urls" ]; then
  echo "No patch URLs found on the page. Check the URL or page structure."
  exit 1
fi

# Count total number of URLs for progress tracking
total=$(echo "$urls" | wc -l)
current=0
failed=0

echo "Found $total patches to download."

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
echo "Download complete. $current patches processed, $failed failed."

# Remove error log if no failures
if [ $failed -eq 0 ] && [ -f "$ERROR_LOG" ]; then
  rm "$ERROR_LOG"
elif [ -f "$ERROR_LOG" ]; then
  echo "Error log created at $ERROR_LOG with $failed failed downloads."
fi