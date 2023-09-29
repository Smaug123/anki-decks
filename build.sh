#!/bin/sh

input_folder=$1
anki_bin=$2
out=$3

mkdir -p "$out"

for item in "$input_folder"/*.json; do
  output_file=$(echo "$item" | sed 's/\.json$/.apkg/')
  # Invoke the binary command on the item
  echo "$item"
  echo "$out/$output_file"
  "$anki_bin" render --output "$out/$output_file" "$item"
done
