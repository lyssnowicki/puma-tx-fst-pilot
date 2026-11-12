#### Manhattan Plot for TX Fst Pilot ####
# Adapted from Evelien's scripts and modified to fix contig order using Claude

# Load packages
library(tidyverse)
library(qqman)

# Set working directory
setwd("~/Desktop/PUMA_R/tx_fst_pilot")

# Data input
fst_input <- "merged_edg_rwh_intersect.qualityfiltered_edg_tx2013_vs_rwh_tx2024_25k.windowed.weir.fst"

# Read in data
fst <- read.table(fst_input, header=T) #fst data
scafs <- read.csv("BARS_PUMA_alignment.csv") #scaffold/chr info provided by Rachael
scafs$id <- 1:nrow(scafs)
seq_lengths <- read.csv("seq_lengths.csv") # made from NCBI documentation sheet

# Make column for numeric chromosome numbers
scafs <- scafs %>%
  mutate(bars_chr_num = suppressWarnings(as.numeric(sub("chromosome_", "", BARS_chrom))))

# Number Z and W after the highest autosome
max_auto <- max(scafs$bars_chr_num, na.rm = TRUE)
scafs <- scafs %>%
  mutate(chr_plot = case_when(
    BARS_chrom == "chromosome_Z" ~ max_auto + 1,
    BARS_chrom == "chromosome_W" ~ max_auto + 2,
    TRUE ~ bars_chr_num
  ))
# Z=38, W=39

# Lay out contigs along each BARS chromosome
layout <- scafs %>%
  filter(!is.na(chr_plot)) %>%
  inner_join(seq_lengths, by = "PUMA_contig") %>%
  arrange(chr_plot, local_order) %>%
  group_by(chr_plot) %>%
  mutate(offset = cumsum(lag(len, default = 0))) %>%
  ungroup() %>%
  select(PUMA_contig, chr_num = chr_plot, local_order, orientation, len, offset)

# Add the layout to the Fst data and calculate plotting positions
fst_plot <- fst %>%
  filter(N_VARIANTS >= 2, !is.na(WEIGHTED_FST)) %>%
  inner_join(layout, by = c("CHROM" = "PUMA_contig")) %>%
  mutate(
    midpoint = pmin((BIN_START + BIN_END) / 2, len),
    pos_in_contig = ifelse(orientation == -1, len - midpoint, midpoint),
    bp = offset + pos_in_contig
  )

# write.csv(fst_plot, "edg_tx2013_vs_rwh_tx2024_ZWin_5k.windowed.weir.fst.orderedchr.csv",
#           row.names = FALSE)

manhattan(fst_plot, main = "EDG TX 2013 vs. RWH TX 2024 (25k)", chr = "chr_num", bp = "bp",
          p = "WEIGHTED_FST", snp = "CHROM", logp = FALSE,
          ylab = "Weir and Cockerham", ylim = c(-0.1, 1), cex.axis = 0.9,
          suggestiveline = FALSE, genomewideline = FALSE)


# Now, just chr 3
fst_chr3_ordered <- filter(fst_plot, chr_num == "3", bp <= 2e7)

manhattan(fst_chr3_ordered, main = "Fst by BARS contig order", chr = "chr_num", bp = "bp",
          p = "WEIGHTED_FST", snp = "CHROM", logp = FALSE,
          ylab = "Weir and Cockerham", ylim = c(-0.1, 1), cex.axis = 0.9,
          suggestiveline = FALSE, genomewideline = FALSE)

##################################################################################
# plot locations of contigs in Chr3 regions of interest 

# ---- settings ----
chr_to_plot <- 3
xmax <- 2e7            # raise to 4.25e7 to include all of the 29.6 Mb contig
label_min_width <- 3e5 # only label blocks at least this wide (bp)

# ---- contigs in the region ----
ctg <- layout %>%
  filter(chr_num == chr_to_plot, offset < xmax) %>%
  arrange(local_order) %>%
  mutate(end   = pmin(offset + len, xmax),
         shade = ifelse(row_number() %% 2 == 1, "grey25", "grey65"),
         mid   = (offset + end) / 2,
         lab   = sub("^JAKJHU010*", "", sub("\\.1$", "", PUMA_contig)),
         arrow = ifelse(orientation == -1, "<", ">"))

# ---- windows in the region, colored to match their contig ----
pts <- fst_plot %>%
  filter(chr_num == chr_to_plot, bp <= xmax) %>%
  mutate(col = ctg$shade[match(CHROM, ctg$PUMA_contig)])

# contigs with no windows
no_data <- ctg %>% filter(!PUMA_contig %in% pts$CHROM)
if (nrow(no_data) > 0) {
  message("Contigs in this region with NO windows:")
  print(no_data %>% select(local_order, PUMA_contig, offset, end, len), width = Inf)
}

# ---- plot ----
layout(matrix(1:2, ncol = 1), heights = c(4, 1))

par(mar = c(0.5, 4.5, 3, 1))
plot(pts$bp, pts$WEIGHTED_FST, pch = 20, cex = 0.6, col = pts$col,
     xlim = c(0, xmax), ylim = c(-0.1, 1), xaxt = "n",
     xlab = "", ylab = "Weir and Cockerham",
     main = paste0("Chr ", chr_to_plot, " (0 to ", xmax / 1e6, " Mb)"))
abline(v = ctg$offset, col = "grey85", lty = 3)

par(mar = c(4, 4.5, 0.5, 1))
plot(NA, xlim = c(0, xmax), ylim = c(0, 1), yaxt = "n",
     xlab = paste0("Position along chr ", chr_to_plot, " (bp)"), ylab = "")
rect(ctg$offset, 0, ctg$end, 1, col = ctg$shade, border = "white")
wide <- (ctg$end - ctg$offset) >= label_min_width
text(ctg$mid[wide], 0.5, paste0(ctg$lab[wide], " ", ctg$arrow[wide]),
     srt = 90, cex = 0.6, col = "white")

layout(1)   # reset layout

# optional: save a high-resolution version
# png("chr3_contigs.png", width = 2400, height = 1200, res = 200); <run the plot code>; dev.off()















