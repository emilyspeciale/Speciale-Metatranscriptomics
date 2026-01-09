BiocManager::install('tximport')
library(tximport)
library(DESeq2)
library(tidyverse)
library(dplyr)
library(stringr)


samples<-list.files(path="/path/to/salmon_quant", full.names=T)

files<-file.path(samples,"quant.sf")

names(files)<-str_replace(samples, "/path/to/salmon_quant", "")%>%str_replace(".salmon","")

txi_obj <- tximport(files, type = "salmon", txOut = TRUE)

txi_obj.rds <- saveRDS(txi_obj, file = "/path/to/txi_obj.rds")