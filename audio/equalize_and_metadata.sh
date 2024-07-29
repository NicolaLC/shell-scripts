#!/bin/bash

# Function to display usage information
usage() {
  echo "Usage: $0 /path/to/your/wav/files \"artist\" \"album\" \"genre\" \"year\""
  echo "Example: $0 /path/to/your/wav/files \"Artist Name\" \"My Album\" \"Drum & Bass\" \"2024\""
  exit 1
}

# Function to set metadata attributes for a WAV file using ffmpeg
set_metadata() {
  local input_file="$1"
  local wav_file="$2"
  local artist="$3"
  local album="$4"
  local genre="$5"
  local year="$6"
  
  # Extract the base name of the file without extension for the title
  local title=$(basename "$input_file" .wav)

  # Set metadata attributes using ffmpeg
  ffmpeg -i "$wav_file" -i "/home/nicola/Downloads/TheSurprise/album_image.jpeg" -metadata title="$title" -metadata artist="$artist" \
         -metadata album="$album" -metadata genre="$genre" -metadata year="$year" \
         -codec copy "${wav_file%.wav}_temp.wav"

  # Overwrite the original WAV file with the updated metadata
  mv "${wav_file%.wav}_temp.wav" "$wav_file"
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

# Function to process each WAV file
process_wav_file() {
  local input_file="$1"
  local output_file="$2"
  local original_file="$3"

  # Apply drum and bass style equalization with reduced gain to avoid clipping
  sox "$input_file" "$output_file" \
     equalizer 80 1.5q +3 equalizer 200 1.5q +1.5 equalizer 400 1.5q +1.5 equalizer 800 1.5q +1.5 equalizer 1600 1.5q +1.5 equalizer 3200 1.5q +1.5 equalizer 6400 1.5q +1.5

  sox "$input_file" "$output_file"

  # Set metadata attributes for the equalized output file
  set_metadata "$input_file" "$output_file" "$ARTIST" "$ALBUM" "$GENRE" "$YEAR"

  # Keep a copy of the original file with the same name
  cp "$input_file" "$original_file"
  
  # Set the equalized file to read-only
  chmod 444 "$output_file"
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
  OUTPUT_FILE="$DIR/${BASENAME}_equalized.wav"

  # Original file path to keep a copy
  ORIGINAL_FILE="$FILE"

  # Process the WAV file and save the equalized version with metadata, keep the original
  process_wav_file "$FILE" "$OUTPUT_FILE" "$ORIGINAL_FILE"
done

echo "Drum and bass style equalization and saving completed."
