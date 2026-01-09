# Navigate to folder in which you want to download Transdecoder
cd /path/to/project_folder
# Download the zip file for TransDecoder 5.7.1
wget https://github.com/TransDecoder/TransDecoder/archive/refs/tags/TransDecoder-v5.7.1.tar.gz
--2024-11-07 09:31:46--  https://github.com/TransDecoder/TransDecoder/archive/refs/tags/TransDecoder-v5.7.1.tar.gz
# Extract the zip file, which will create a new folder in the project folder called TransDecoder-TransDecoder-v5.7.1
tar -xzf /path/to/project_folder/TransDecoder-v5.7.1.tar.gz
# Copy clustered assembly fasta file into Transdecoder folder
cp /path/to/cdhit/clustered_assembly.fasta /path/to/TransDecoder-TransDecoder-v5.7.1/