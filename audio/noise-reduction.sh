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

# Function to process each channel of a multi-channel WAV file
process_channels() {
  local input_file="$1"
  local output_file_prefix="$2"

  # Get the number of channels in the input file
  channels=$(soxi -c "$input_file")

  # Iterate over each channel and process separately
  for (( channel=1; channel <= $channels; channel++ )); do
    # Extract each channel into a separate file
    channel_file="${output_file_prefix}_channel${channel}.wav"
    sox "$input_file" "$channel_file" remix "$channel"

    # Generate a noise profile for this channel
    noise_profile="${channel_file%.wav}_noise.prof"
    sox "$channel_file" -n noiseprof "$noise_profile"

    # Apply noise reduction to this channel
    output_file="${channel_file%.wav}_denoised.wav"
    sox "$channel_file" "$output_file" noisered "$noise_profile" 0.21

    # Set the output file to read-only
    chmod 444 "$output_file"

    # Optionally, replace the original channel file with the denoised version
    # mv "$output_file" "$channel_file"

    # Clean up noise profile file
    rm "$noise_profile"
  done
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

  # Process each channel of the WAV file
  process_channels "$FILE" "$DIR/${BASENAME}"
done

echo "Noise reduction completed."
