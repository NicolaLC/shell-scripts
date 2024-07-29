#!/bin/bash

# Function to display usage information
usage() {
  echo "Usage: $0 /path/to/your/wav/files"
  echo "Example: $0 /path/to/your/wav/files"
  exit 1
}

# Check if the correct number of parameters is provided
if [ "$#" -ne 1 ]; then
  usage
fi

# Directory containing the WAV files
DIR="$1"

# Check if the provided directory exists
if [ ! -d "$DIR" ]; then
  echo "Error: Directory $DIR does not exist."
  exit 1
fi

# Function to process each WAV file
process_wav_file() {
  local input_file="$1"
  local output_file="$2"

  # Apply drum and bass style equalization
  sox "$input_file" "$output_file" \
     equalizer 80 1.5q +3 equalizer 200 1.5q +1.5 equalizer 400 1.5q +1.5 equalizer 800 1.5q +1.5 equalizer 1600 1.5q +1.5 equalizer 3200 1.5q +1.5 equalizer 6400 1.5q +1.5
}

# Iterate over each WAV file in the directory
for FILE in "$DIR"/*.wav; do
  # Check if there are no WAV files in the directory
  if [ "$FILE" = "$DIR/*.wav" ]; then
    echo "No WAV files found in the directory $DIR"
    exit 1
  fi

  # Get the base name of the file (without extension)
  BASENAME=$(basename "$FILE" .wav)

  # Output file path for equalized WAV
  OUTPUT_FILE="$DIR/${BASENAME}_drum_bass_equalized.wav"

  # Process the WAV file and create the equalized output file
  process_wav_file "$FILE" "$OUTPUT_FILE"

  # Set the output file to read-only
  chmod 444 "$OUTPUT_FILE"
done

echo "Drum and bass style equalization completed."
