# Speciale-Metatranscriptomics
This GitHub describes the reproducible metatranscriptomics workflow used by Speciale et al. (in prep, 2026) for California Current System iron incubation experiment samples from 2023. All code can be found in this GitHub repository. Code was run primarily through the UNC Research Computing Longleaf Cluster, thus software installation reflects modules and packages made available (or unavailable) through the cluster. We encourage others to use and adapt this pipeline to their own work, so please cite accordingly (this citation is currently for my master’s thesis but will be updated once manuscript is published):

Speciale, E. (2025). The Molecular Physiology of Mixotrophic Phytoplankton Under Iron-Limited Upwelling Conditions (Master's thesis, The University of North Carolina at Chapel Hill).

If you have any questions, please reach out to me at speciale@unc.edu. Steps for running the pipeline are listed below, as well as references for all software/databases used.

## TRIMMING AND QUALITY CONTROL

To trim adapters from raw reads, we used Trim Galore v0.6.10 [1]. First, create the file ``trimgalore.sh`` in your desired directory, then run ``trimgalore-all.sh``. This will run an individual job for the trimming of each sample. Trimmed samples will be deposited into a new directory. To quality control samples after trimming, we used FastQC v0.12.1, which can be run using ``fastqc.sh``. This will output a multiqc.html file which shows many quality control variables and should be checked before proceeding with the rest of the pipeline. 

## ASSEMBLY

Assembly refers to the process of reconstructing longer sequences (aka contigs) from the short reads. Given this is a large microbial community and not a single organism with one reference genome, we conducted a de novo assembly for each sample. We used rna-SPAdes v3.15.5 [2] to create these de novo assemblies by running ``rna_spades.sh``. We ran this code for each individual sample – it creates an individual fasta file for each assembly. We then used CD-HIT v4.8.1 [3] to combine all individual assemblies into one large clustered assembly (aka coassembly, grand assembly, etc.). CD-HIT also looks for contigs that are redundant between individual assemblies and clusters them together, thus simplifying the analysis. CD-HIT can be run using ``cdhit.sh``. 

## PROTEIN PREDICTION 

To gain more accurate annotations, we used TransDecoder v5.7.1 [4] to identify the best candidate open reading frame (ORF) for each contig. TransDecoder can be run in three steps: 1) ``transdecoder_setup.sh``, used to download the software, as it was not available through Longleaf, 2) ``transdecoder_longorfs.sh``, used to screen the contigs for potential ORFs, and 3) ``transdecoder_predict.sh``, used to filter for the most likely ORF. 

## ANNOTATION

We use multiple annotation databases to try to maximize coverage and accuracy of our contig annotation assignments. We used MarFERReT v1.1.1 [5] as our primary annotator for taxonomy and function (via Pfam). We choose to rely on this annotator because 1) it has the most updated and expansive list of genomes for marine eukaryotes, 2) Pfam tends to produce the highest amount of annotations compared to other functional databases, and 3) it is very user friendly. However, there are some drawbacks to MarFERRet, being that 1) it does not include many reference genomes for bacteria/viruses and 2) Pfam annotations are typically for broader protein domains rather than specific genes. Thus, we used MarFERReT in conjunction with EUKulele [6] for taxonomic annotation and eggNOG [7] for functional annotation. 

MarFERReT can be run using ``marferret.sh``. Instructions on how to download and use MarFERReT can be found on their github (https://github.com/armbrustlab/marferret).

We then used PhyloDB v1076 using EUKulele to taxonomically annotate our contigs, which can be run using ``eukulele_phylodb.sh``. Instructions on how to download and use EUKulele can be found on their website (https://eukulele.readthedocs.io/en/latest/index.html). The PhyloDB database contains many reference genomes for bacteria and viruses, and we used these annotations to filter non-eukaryotes from the data for downstream analysis.

We finally used eggNOG-mapper v2.1.12 to obtain additional functional annotations for our contigs, which can be run using ``eggnog.sh``. Instructions on how to download and use eggNOG can be found on their github (https://github.com/eggnogdb/eggnog-mapper). We primarily used eggNOG to obtain KEGG gene and pathway annotations for our contigs. 

To wrangle and combine all of these annotation results into one big table, we ran ``combine_annotations.R``. This R file contains code for 1) extracting annotations from the MarFERReT m8 file, 2) filtering MarFERReT annotations for non-eukaryotes using PhyloDB annotations, 3) combining MarFERReT annotations with corresponding eggNOG KEGG annotations, and 4) filtering for any duplicates along the way. The final result is a tab-separated dataframe with taxonomic, Pfam, and KEGG annotations for contigs that mapped to eukaryotes. 

## ALIGNMENT

To quantify the number of reads to each contig, we used Salmon v1.10.3 [8], which can be run in two parts. We first ran ``salmon_assemindex.sh`` to create the assembly index, then ran ``salmon_align.sh`` to align reads to the created assembly index. This created individual folders for each sample inside salmon_quant that contain a quant.sf file. To merge the results from each sample’s alignment into an R object, we used the package tximport v1.38.2 [9] by running ``tximport.R``. The final R object contains four dataframes with contigs as row names and sample IDs as the column names, with associated values for abundance, counts, length, and countsFromAbundance. 

## DIFFERENTIAL EXPRESSION 

There are many different downstream analyses one can do with the read quantification results from alignment and mapped annotations. We created a guide to how we began to analyze these results using DESeq2 [10] within ``DESeq2_Guide.Rmd``, which includes code with detailed descriptions on processing steps. This includes how to filter dataframes for mixotrophs based on the Mixoplankton Database by Mitra et al. (2023) [11]. We hope this guide can provide a starting point to others who are also doing metaT microbial analyses!

## REFERENCES

[1] M. Martin, Cutadapt removes adapter sequences from high-throughput sequencing reads. EMBnet j. 17, 10 (2011).

[2] E. Bushmanova, D. Antipov, A. Lapidus, A. D. Prjibelski, rnaSPAdes: a de novo transcriptome assembler and its application to RNA-Seq data. GigaScience 8, giz100 (2019).

[3] W. Li, A. Godzik, Cd-hit: a fast program for clustering and comparing large sets of protein or nucleotide sequences. Bioinformatics 22, 1658–1659 (2006)

[4] B. Hass, TransDecoder v5.7.1. (2023). Deposited 2023.

[5] R. D. Groussman, S. Blaskowski, S. N. Coesel, E. V. Armbrust, MarFERReT, an open-source, version-controlled reference library of marine microbial eukaryote functional genes. Sci Data 10, 926 (2023).

[6] A. I. Krinos, S. K. Hu, N. R. Cohen, H. Alexander, EUKulele: Taxonomic annotation of the unsung eukaryotic microbes. [Preprint] (2020). Available at: https://arxiv.org/abs/2011.00089 [Accessed 2 September 2025].

[7] C. P. Cantalapiedra, A. Hernández-Plaza, I. Letunic, P. Bork, J. Huerta-Cepas, eggNOG-mapper v2: Functional Annotation, Orthology Assignments, and Domain Prediction at the Metagenomic Scale. Molecular Biology and Evolution 38, 5825–5829 (2021).

[8] R. Patro, G. Duggal, M. I. Love, R. A. Irizarry, C. Kingsford, Salmon provides fast and bias-aware quantification of transcript expression. Nat Methods 14, 417–419 (2017).

[9] C. Soneson, M. I. Love, M. D. Robinson, Differential analyses for RNA-seq: transcript-level estimates improve gene-level inferences. F1000Res 4, 1521 (2016).

[10] M. I. Love, W. Huber, S. Anders, Moderated estimation of fold change and dispersion for RNA-seq data with DESeq2. Genome Biol 15, 550 (2014).

[11] A. Mitra, et al., The Mixoplankton Database (MDB): Diversity of photo‐phago‐trophic plankton in form, function, and distribution across the global ocean. J Eukaryotic Microbiology 70, e12972 (2023).
