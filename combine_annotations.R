# Load required packages
library(data.table)
library(dplyr)
library(readxl)


# PART 1: MARFERRET TAXONOMIC AND FUNCTIONAL ANNOTATIONS
# Make sure to download all required files for pfam, taxonomy, and metadata from the marferret software!

# Specify the path to your .m8 file
m8_file <- "path/to/marferret.m8"

# Read the .m8 file into a data.table
m8_data <- fread(m8_file, header = FALSE, quote = "")

# Add column names
colnames(m8_data) <- c("qseqid", "sseqid", "pident", "length", "mismatch", "gapopen", "qstart", "qend", "sstart", "send", "evalue", "bitscore")

# Download Pfam functional annotation file
pfam_file <- "path/to/MarFERReT.v1.1.1.best_pfam_annotations.csv"
pfam <- read.csv(pfam_file)

# Download NCBI taxonomic annotation file
taxonomy_file <- "path/to/MarFERReT.v1.1.1.taxonomies.tab"
taxonomy <- read.table(taxonomy_file, header = TRUE, sep = "\t")

# Download metadata with taxa ID and organism information
metadata_file <- "path/to/MarFERReT.v1.1.1.metadata.csv"
metadata <- read.csv(metadata_file)

# Combine the m8 data with the Pfam annotation file
# Change the column names so they match
colnames(m8_data)[colnames(m8_data) == "sseqid"] <- "mft_id"
colnames(pfam)[colnames(pfam) == "aa_id"] <- "mft_id"
# Merge together by mft id
annot_mft <- left_join(m8_data, pfam, by = c("mft_id"))
sum(complete.cases(annot_mft))

# Merge the taxonomy file with annotation
# Filter blank columns in taxonomy and change its column name to match 
taxonomy <- subset(taxonomy, select = -accession)
taxonomy <- subset(taxonomy, select = -gi)
# Change column names so they match annotation and metadata files
colnames(taxonomy)[colnames(taxonomy) == "accession.version"] <- "mft_id"
colnames(taxonomy)[colnames(taxonomy) == "taxid"] <- "tax_id"
# Merge together by mft id
annot_mft <- left_join(annot_mft, taxonomy, by = c("mft_id"))

# Merge annotation file with metadata so we can get the organism associated to each taxa id
# Deleting rows in metadata with duplicate taxa id
metadata <- distinct(metadata, tax_id, .keep_all = TRUE)
# Merge together by taxa id
annot_mft <- left_join(annot_mft, metadata, by = c("tax_id"))

# Cleaning up annotation so it only includes wanted columns
annot_filt <- subset(annot_mft, select = c(qseqid, mft_id, pfam_name, pfam_id,
                                           tax_id, marferret_name, pr2_taxonomy,
                                           evalue, bitscore, pident, length, mismatch))
# Remove .p extension from qseqid names
annot_filt$qseqid <- gsub("\\.p[0-9]+$", "", annot_filt$qseqid)
annot_filt <- as.data.frame(annot_filt)
# Check for duplicates
duplicate_counts <- as.data.frame(table(annot_filt$qseqid))
duplicate_counts <- duplicate_counts[duplicate_counts$Freq > 1, ]
# For any duplicate, only keep the qseqid with the highest bitscore, then the lowest evalue, then the highest pident
annot_filt <- annot_filt %>%
  group_by(qseqid) %>%
  filter(bitscore == max(bitscore)) %>% 
  filter(evalue == min(evalue)) %>%
  filter(pident == max(pident)) %>%
  ungroup() %>%
  distinct(qseqid, .keep_all = TRUE)
# Check for duplicates again
duplicate_counts <- as.data.frame(table(annot_filt$qseqid))
duplicate_counts <- duplicate_counts[duplicate_counts$Freq > 1, ]

# PART 2: PHYLODB TAXONOMIC ANNOTATION, FILTERING FOR BACTERIA/VIRUS

# Use phyloDB to filter out any bacteria or viruses
# Read in phyloDB file, however, this only includes the max score
phylodb_annot <- read.delim("path/to/clustered_assembly.fasta.transdecoder-estimated-taxonomy.out", header = TRUE)
# Rename to qseqid
phylodb_annot <- phylodb_annot %>%
  rename(qseqid = transcript_name)
# Remove .p extension from qseqid
phylodb_annot$qseqid <- gsub("\\.p[0-9]+$", "", phylodb_annot$qseqid)
# Check for duplicates
duplicate_counts <- phylodb_annot %>%
  count(qseqid) %>% 
  filter(n > 1) 
# For any duplicate, only keep the qseqid with the highest max_score
phylodb_annot <- phylodb_annot %>%
  group_by(qseqid) %>%
  filter(max_score == max(max_score)) %>%
  ungroup() %>%
  distinct(qseqid, .keep_all = TRUE)
# Check for duplicates again
duplicate_counts <- phylodb_annot %>%
  count(qseqid) %>%            
  filter(n > 1)
  
# Merge with marferret
taxonomy <- merge(annot_filt, phylodb_annot, by="qseqid", all.x=TRUE, all.y=FALSE)
# Filter for likely matches to bacteria and viruses
filtered_taxonomy <- taxonomy %>%
       mutate(keep = if_else(grepl("Bacteria", full_classification) & max_score > bitscore, FALSE, TRUE)) %>%
       filter(keep) %>%
       select(-keep)
filtered_taxonomy <- filtered_taxonomy %>%
  mutate(keep = if_else(grepl("Virus", full_classification) & max_score > bitscore, FALSE, TRUE)) %>%
  filter(keep) %>%
  select(-keep)

taxonomy_final <- subset(filtered_taxonomy, select=c(qseqid, pfam_name, pfam_id, tax_id,
                                                           marferret_name, pr2_taxonomy))

# PART 3: EGGNOG FUNCTIONAL ANNOTATION

# Import eggnog file for extra functional annotation, might have to edit headers in excel before importing
eggnog_annot <- read_excel("path/to/eggnog_annot.emapper.annotations.xlsx")

# Rename columns accordingly
colnames(eggnog_annot)[colnames(eggnog_annot) == "query"] <- "qseqid"
colnames(eggnog_annot)[colnames(eggnog_annot) == "Description"] <- "Eggnog_Description"
colnames(eggnog_annot)[colnames(eggnog_annot) == "PFAMs"] <- "Eggnog_Pfam"
# Remove p extension off qseqid
eggnog_annot$qseqid <- gsub("\\.p[0-9]+$", "", eggnog_annot$qseqid)
# Check for duplicates
duplicate_counts <- eggnog_annot %>%
  dplyr::count(qseqid) %>%            
  filter(n > 1) 
# For any duplicate, only keep the qseqid with the highest bitscore, then the lowest evalue
eggnog_annot <- eggnog_annot %>%
  group_by(qseqid) %>%
  filter(score == max(score)) %>% 
  filter(evalue == min(evalue)) %>%
  ungroup() %>%
  distinct(qseqid, .keep_all = TRUE)
# Check for duplicates
duplicate_counts <- eggnog_annot %>%
  dplyr::count(qseqid) %>%            
  filter(n > 1) 
# Only keep relevant annotation columns
eggnog_annot_filt <- subset(eggnog_annot, select=c(qseqid, COG_category, Eggnog_Description,
                                                                     GOs, KEGG_ko, KEGG_Pathway, KEGG_Module, 
                                                                     Eggnog_Pfam))

# Merging marferret and eggnog dataframes
annot_final <- merge(taxonomy_final, eggnog_annot_filt, by="qseqid", all.x=TRUE, all.y=FALSE)

# Write table for it
write.table(annot_final, file = 'path/to/annotations_final.tsv', 
            sep = "\t", quote = FALSE, row.names = FALSE)
