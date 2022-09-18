source('/.Rprofile')
print("Inside R script!")
print(args)
installed.packages()
library(dplyr)
library(Seurat)
library(patchwork)

args <- commandArgs(TRUE)
datadir <- args[2]
sampleid <- args[4]
print(datadir)
print(sampleid)

# replace with own dataset processed through cellranger - data.dir = "filtered_gene_bc_matrices/hg19/"
sc.data <- Read10X(data.dir = datadir)

# these are probably decent defaults
sc <- CreateSeuratObject(counts = sc.data, project = sampleid, min.cells = 3, min.features = 200)

# assumes MT annotation in gtf file
sc[["percent.mt"]] <- PercentageFeatureSet(sc, pattern = "^MT-")

# Violin plot - 1) # features per cell, 2) UMI counts per cell, 3) % mitochondrial per cell
jpeg('singlecell_qc1.jpg')
VlnPlot(sc, features = c("nFeature_RNA", "nCount_RNA", "percent.mt"), ncol = 3)
dev.off()

# Filter cells based on QC filters
sc <- subset(sc, subset = nFeature_RNA > 300 & nFeature_RNA < 3000 & percent.mt < 6)

# Normalize data (log normalize)
sc <- NormalizeData(sc, normalization.method = "LogNormalize", scale.factor = 10000)

# find variable features
sc <- FindVariableFeatures(sc, selection.method = "vst", nfeatures = 2000)
top10 <- head(VariableFeatures(sc), 10)

# plot variable features - 1) MA-like plot (mean vs variance) 2) labeled top 10 - top 2000 used for dimensionality reduction, colored in red
plot1 <- VariableFeaturePlot(sc)
plot2 <- LabelPoints(plot = plot1, points = top10, repel = TRUE)
jpeg('singlecell_mean_vs_variance.jpg')
plot2
dev.off()

# Next, we apply a linear transformation (‘scaling’) that is a standard pre-processing step prior to dimensional reduction techniques like PCA.
all.genes <- rownames(sc)
sc <- ScaleData(sc, features = all.genes)

# Run PCA to get prinicpal components (dimensions)
sc <- RunPCA(sc, features = VariableFeatures(object = sc))

# PCA Dim heatmap
jpeg('singlecell_pca_dim_heatmap.jpg')
DimHeatmap(sc, dims = 1:15, cells = 500, balanced = TRUE)
dev.off()

# Elbow plot to find best dim
jpeg('singlecell_elbowplot.jpg')
ElbowPlot(sc)
dev.off()

# cluster cells (dim = 10)
sc <- FindNeighbors(sc, dims = 1:10)
sc <- FindClusters(sc, resolution = 0.5)

# visualize clusters with UMAP
sc <- RunUMAP(sc, dims = 1:10)
jpeg('singlecell_umap.jpg')
DimPlot(sc, reduction = "umap")
dev.off()

# save workspace file for future use
saveRDS(sc, file = "singlecell_sc_workspace.rds")

# find markers for every cluster compared to all remaining cells, report only the positive ones
sc.markers <- FindAllMarkers(sc, only.pos = TRUE, min.pct = 0.25, logfc.threshold = 0.25)
sc.markers %>% group_by(cluster) %>% slice_max(n = 2, order_by = avg_log2FC)

# heatmap - DoHeatmap() generates an expression heatmap for given cells and features. In this case, we are plotting the top 20 markers (or all markers if less than 20) for each cluster.

jpeg('singlecell_cluster_heatmap.jpg')
sc.markers %>% group_by(cluster) %>% top_n(n = 10, wt = avg_log2FC) -> top10
DoHeatmap(sc, features = top10$gene) + NoLegend()
dev.off()

# output results as CSV
# write.csv(res, file=paste(odir, "deseq2.group1-vs-group2-results.csv", sep=''))

# volcano plots
# jpeg(paste(odir,'deseq2.group1-vs-group2-volcano-plot.jpg', sep=''))
#reset par
# par(mfrow=c(1,1))
# Make a basic volcano plot
# with(res, plot(log2FoldChange, -log10(pvalue), pch=20, main="Volcano plot", xlim=c(-3,3)))

# Add colored points: blue if padj<0.01, red if log2FC>1 and padj<0.05) - change to pvalue for now
# with(subset(res, pvalue<.01 ), points(log2FoldChange, -log10(pvalue), pch=20, col="blue"))
# with(subset(res, pvalue<.05 & abs(log2FoldChange)>2), points(log2FoldChange, -log10(pvalue), pch=20, col="red"))
# dev.off()
