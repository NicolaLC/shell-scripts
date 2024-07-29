#!/bin/bash

# Function to display usage information
usage() {
  echo "Usage: $0 /path/to/your/wav/files artist album genre year"
  echo "Example: $0 /path/to/your/wav/files 'Sample Artist' 'Sample Album' 'Sample Genre' '2024'"
  exit 1
}

# Check if the correct number of parameters is provided
if [ "$#" -ne 5 ]; then
  usage
fi

# Directory containing the WAV files
DIR="$1"
ARTIST="$2"
ALBUM="$3"
GENRE="$4"
YEAR="$5"

# Check if the provided directory exists
if [ ! -d "$DIR" ]; then
  echo "Error: Directory $DIR does not exist."
  exit 1
fi

# Check if there are any WAV files in the directory
if ! ls "$DIR"/*.wav 1> /dev/null 2>&1; then
  echo "No WAV files found in the directory $DIR"
  exit 1
fi

# Iterate over each WAV file in the directory
for FILE in "$DIR"/*.wav; do
  # Get the base name of the file (without extension)
  BASENAME=$(basename "$FILE" .wav)

  # Use ffmpeg to set the metadata attributes and specify the output format
  ffmpeg -i "$FILE" \
         -metadata title="$BASENAME" \
         -metadata artist="$ARTIST" \
         -metadata album="$ALBUM" \
         -metadata genre="$GENRE" \
         -metadata year="$YEAR" \
         -f wav -codec copy "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
done

echo "Metadata update completed."
