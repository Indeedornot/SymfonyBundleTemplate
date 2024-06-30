#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 source_directory destination_directory [env_file]"
    exit 1
fi

# Assign arguments to variables for better readability
src_dir=$1
dest_dir=$2

# Check if the .env file path is provided as an argument
if [ "$#" -eq 3 ]; then
    env_file=$3
else
    env_file="$dest_dir/.template.env"
fi

# Remove everything but the .env file from the output directory
for item in "$dest_dir"/*; do
    if [ "$item" != "$env_file" ]; then
        rm -rf "$item"
    fi
done

# Check if the .env file exists
if [ ! -f "$env_file" ]; then
    echo "Error: .env file not found"
    exit 1
fi

# Load environment variables from the .env file and build the list of variables for envsubst
var_names=""
while IFS= read -r line
do
    if [[ ! $line == \#* ]]; then
        varname=$(echo "$line" | cut -d '=' -f 1)
        export "$line"
        if [ -z "$var_names" ]; then
            var_names="\$${varname}"
        else
            var_names="${var_names},\$$varname"
        fi
    fi
done < "$env_file"

#only print when env path parameter is not set
if [ "$#" -lt 3 ]; then
    echo "Environment variables loaded from $env_file"
    echo "Variables: $var_names"
fi

# Create the destination directory if it doesn't exist
mkdir -p "$dest_dir"

# Iterate over all files and directories in the source directory, including hidden ones
for src_item in "$src_dir"/{,.[!.],..?}*; do
    # Skip if the glob didn't match anything
    [ -e "$src_item" ] || continue
    # Skip the .template.env file
    if [ "$src_item" == "$src_dir/.template.env" ]; then
        continue
    fi
    # Get the filename
    filename=$(basename "$src_item")
    # Create the destination file path
    filename=$(echo "$filename" | envsubst "$var_names")
    dest_item="$dest_dir/$filename"
    # Check if the current item is a directory
    if [ -d "$src_item" ]; then
        # If the directory is vendor or var, copy it without processing
        if [[ "$src_item" =~ $src_dir/(vendor|var|node_modules|.git|.idea) ]]; then
            cp -r "$src_item" "$dest_item"
        else
            mkdir -p "$dest_item"
            "$0" "$src_item" "$dest_item" "$env_file"
        fi
    else
      echo "Processing $src_item -> $dest_item"
      envsubst "$var_names" < "$src_item" > "$dest_item"
    fi
done

# Unset the exported environment variables
while IFS= read -r line
do
    if [[ ! $line == \#* ]]; then
        varname=$(echo "$line" | cut -d '=' -f 1)
        unset "$varname"
    fi
done < "$env_file"