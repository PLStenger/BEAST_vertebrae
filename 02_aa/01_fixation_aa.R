library(readxl)
library(dplyr)
library(dplyr)
library(tidyr)
library(stringr)

save.image(file = "workspace_fixation_aa.RData")

# ----------- FONCTION PRINCIPALE -----------
process_aa_data <- function(OG.aa, LifeTraits, G1, OGid) {
  OG.aa.tr <- OG.aa %>% 
    data.table::transpose(keep.names = "ID", make.names = "Position") %>%
    mutate(
      Species = ifelse(grepl("_", ID), sub("_.*", "", ID), ID),
      .after = ID
    ) %>% 
    filter(Species %in% LifeTraits) %>% 
    arrange(match(Species, LifeTraits)) %>% 
    mutate(
      Group = ifelse(Species %in% G1, 'G1', 'G2'),
      .after = Species
    ) %>%
    select(ID:Group, everything())
  
  message("[", OGid, "] Après transposition : ", ncol(OG.aa.tr), " colonnes")

  # Suppression des colonnes avec trop de '-' ou peu de valeurs informatives
  OG.aa.tr <- OG.aa.tr %>%
    select(-which(colMeans(. == "-") >= 0.5 & !(1:ncol(.) %in% 1:3)))
  message("[", OGid, "] Après filtrage des '-' : ", ncol(OG.aa.tr), " colonnes")
  
  OG.aa.tr <- OG.aa.tr %>%
    select(where(~ {
      unique_values <- unique(.)[!unique(.) %in% c("-", "*", ".")]
      length(unique_values) >= 2
    }))
  message("[", OGid, "] Après filtrage des colonnes peu informatives : ", ncol(OG.aa.tr), " colonnes")
  message("[", OGid, "] Colonnes après filtrage : ", paste(colnames(OG.aa.tr), collapse=", "))

  if (ncol(OG.aa.tr) <= 3) {
    message("[", OGid, "] Trop peu de colonnes, mais je retourne quand même pour debug.")
    return(OG.aa.tr)
  }

  # Pivot longer
  OG.aa.tr <- OG.aa.tr %>%
    pivot_longer(
      cols = everything()[-(1:3)],
      names_to = "Pos",
      values_to = "AA"
    ) %>%
    mutate(Pos = as.numeric(Pos)) %>% 
    group_by(Group, Pos, AA) %>%
    summarize(
      Count = n(),
      Species = n_distinct(Species),
      .groups = 'drop'
    ) %>% 
    arrange(Pos, AA) %>% 
    filter(!str_detect(AA, "[-*\\.]")) %>% 
    mutate(Orthogroup = OGid, .after = Group)

  message("[", OGid, "] Résultat final : ", nrow(OG.aa.tr), " lignes.")
  return(OG.aa.tr)
}

# ----------- PARAMÈTRES ET LISTES -----------
G2 = c("Acipenser_ruthenus",
       "Polyodon_spathula",
       "Anabas_testudineus",
       "Betta_splendens",
       "Anguilla_anguilla",
       "Melanotaenia_boesemani",
       "Thalassophryne_amazonica",
       "Oryzias_latipes",
       "Salarias_fasciatus",
       "Gouania_willdenowi",
       "Seriola_aureovittata",
       "Echeneis_naucrates",
       "Micropterus_dolomieu",
       "Siniperca_chuatsi",
       "Chelmon_rostratus",
       "Astyanax_mexicanus",
       "Pygocentrus_nattereri",
       "Archocentrus_centrarchus",
       "Astatotilapia_calliptera",
       "Oreochromis_niloticus",
       "Maylandia_zebra",
       "Alosa_alosa",
       "Clupea_harengus",
       "Denticeps_clupeoides",
       "Myxocyprinus_asiaticus",
       "Xyrauchen_texanus",
       "Misgurnus_anguillicaudatus",
       "Cyprinus_carpio",
       "Puntigrus_tetrazona",
       "Labeo_rohita",
       "Carassius_auratus",
       "Onychostoma_macrolepis",
       "Danio_rerio",
       "Triplophysa_rosa",
       "Ctenopharyngodon_idella",
       "Megalobrama_amblycephala",
       "Fundulus_heteroclitus",
       "Girardinichthys_multiradiatus",
       "Gambusia_affinis",
       "Poecilia_reticulata",
       "Xiphophorus_hellerii",
       "Kryptolebias_marmoratus",
       "Nematolebias_whitei",
       "Megalops_cyprinoides",
       "Esox_lucius",
       "Gadus_morhua",
       "Periophthalmus_magnuspinnatus",
       "Chanos_chanos",
       "Electrophorus_electricus",
       "Myripristis_murdjan",
       "Xiphias_gladius",
       "Sphaeramia_orbicularis",
       "Cheilinus_undulatus",
       "Notolabrus_celidotus",
       "Lampris_incognitus",
       "Mugil_cephalus",
       "Hypomesus_transpacificus",
       "Brienomyrus_brachyistius",
       "Scleropages_formosus",
       "Parambassis_ranga",
       "Anoplopoma_fimbria",
       "Cottoperca_gobio",
       "Lates_calcarifer",
       "Pseudochaenichthys_georgianus",
       "Cyclopterus_lumpus",
       "Gasterosteus_aculeatus_aculeatus",
       "Pseudoliparis_swirei",
       "Perca_fluviatilis",
       "Etheostoma_cragini",
       "Sander_lucioperca",
       "Amphiprion_ocellaris",
       "Acanthochromis_polyacanthus",
       "Scatophagus_argus",
       "Larimichthys_crocea",
       "Sebastes_umbrosus",
       "Epinephelus_fuscoguttatus",
       "Plectropomus_leopardus",
       "Toxotes_jaculatrix",
       "Cynoglossus_semilaevis",
       "Hippoglossus_hippoglossus",
       "Pleuronectes_platessa",
       "Scophthalmus_maximus",
       "Solea_senegalensis",
       "Salvelinus_namaycush",
       "Oncorhynchus_kisutch",
       "Coregonus_clupeaformis",
       "Salmo_trutta",
       "Scomber_japonicus",
       "Thunnus_maccoyii",
       "Lepisosteus_oculatus",
       "Hemibagrus_wyckioides",
       "Tachysurus_fulvidraco",
       "Clarias_gariepinus",
       "Ictalurus_punctatus",
       "Pangasianodon_hypophthalmus",
       "Silurus_meridionalis",
       "Sparus_aurata",
       "Acanthopagrus_latus",
       "Mastacembelus_armatus",
       "Synchiropus_splendidus",
       "Hippocampus_zosterae",
       "Doryrhamphus_excisus",
       "Syngnathus_acus",
       "Dunckerocampus_dactyliophorus",
       "Corythoichthys_intestinalis",
       "Takifugu_rubripes",
       "Bombina_bombina",
       "Bufo_bufo",
       "Hyla_sarda",
       "Spea_bombifrons",
       "Xenopus_laevis",
       "Rana_temporaria",
       "Geotrypetes_seraphini",
       "Rhinatrema_bivittatum",
       "Microcaecilia_unicolor",
       "Harpia_harpyja",
       "Accipiter_gentilis",
       "Aquila_chrysaetos_chrysaetos",
       "Gymnogyps_californianus",
       "Cygnus_olor",
       "Oxyura_jamaicensis",
       "Aythya_fuligula",
       "Anas_platyrhynchos",
       "Apus_apus",
       "Calypte_anna",
       "Rissa_tridactyla",
       "Cuculus_canorus",
       "Falco_peregrinus",
       "Numida_meleagris",
       "Gallus_gallus",
       "Coturnix_japonica",
       "Lagopus_muta",
       "Meleagris_gallopavo",
       "Grus_americana",
       "Corvus_cornix_cornix",
       "Taeniopygia_guttata",
       "Lonchura_striata_domestica",
       "Vidua_macroura",
       "Serinus_canaria",
       "Hirundo_rustica",
       "Molothrus_ater",
       "Agelaius_phoeniceus",
       "Motacilla_alba_alba",
       "Ficedula_albicollis",
       "Oenanthe_melanoleuca",
       "Poecile_atricapillus",
       "Parus_major",
       "Melospiza_georgiana",
       "Ammospiza_caudacuta",
       "Chiroxiphia_lanceolata",
       "Camarhynchus_parvulus",
       "Catharus_ustulatus",
       "Indicator_indicator",
       "Dryobates_pubescens",
       "Strigops_habroptila",
       "Melopsittacus_undulatus",
       "Scyliorhinus_canicula",
       "Carcharodon_carcharias",
       "Chiloscyllium_plagiosum",
       "Rhincodon_typus",
       "Stegostoma_fasciatum",
       "Leucoraja_erinacea",
       "Amblyraja_radiata",
       "Pristis_pectinata",
       "Polypterus_senegalus",
       "Erpetoichthys_calabaricus",
       "Petromyzon_marinus",
       "Ahaetulla_prasina",
       "Thamnophis_elegans",
       "Hemicordylus_capensis",
       "Anolis_carolinensis",
       "Eublepharis_macularius",
       "Zootoca_vivipara",
       "Podarcis_muralis",
       "Lacerta_agilis",
       "Sceloporus_undulatus",
       "Sphaerodactylus_townsendi",
       "Euleptes_europaea",
       "Ornithorhynchus_anatinus",
       "Tachyglossus_aculeatus",
       "Caretta_caretta",
       "Chelonia_mydas",
       "Dermochelys_coriacea",
       "Malaclemys_terrapin_pileata",
       "Trachemys_scripta_elegans",
       "Chrysemys_picta_bellii",
       "Mauremys_mutica",
       "Gopherus_flavomarginatus",
       "Protopterus_annectens")





G1 = c("Balaenoptera_musculus",
       "Ovis_aries",
       "Bos_taurus",
       "Capra_hircus",
       "Budorcas_taxicolor",
       "Bubalus_bubalis",
       "Camelus_dromedarius",
       "Cervus_elaphus",
       "Tursiops_truncus",
       "Orcinus_orca",
       "Hippopotamus_amphibius_kiboko",
       "Phocoena_sinus",
       "Physeter_catodon",
       "Phacochoerus_africanus",
       "Sus_scrofa",
       "Canis_lupus_familiaris",
       "Vulpes_lagopus",
       "Acinonyx_jubatus",
       "Lynx_canadensis",
       "Felis_catus",
       "Panthera_tigris",
       "Neofelis_nebulosa",
       "Leopardus_geoffroyi",
       "Prionailurus_bengalensis",
       "Suricata_suricatta",
       "Musta_erminea",
       "Neogale_vison",
       "Meles_meles",
       "Lutra_lutra",
       "Zalophus_californianus",
       "Neomonachus_schauinslandi",
       "Mirounga_angustirostris",
       "Ailuropoda_melanoleuca",
       "Desmos_rotundus",
       "Phyllostomus_discolor",
       "Rhinolophus_ferrumequinum",
       "Eptesicus_fuscus",
       "Dasypus_novemcinctus",
       "Sarcophilus_harrisii",
       "Antechinus_flavipes",
       "Gracilinanus_alis",
       "Monodelphis_domestica",
       "Trichosurus_vulpecula",
       "Sorex_araneus",
       "Suncus_etruscus",
       "Oryctolagus_cuniculus",
       "Ochotona_princeps",
       "Dromiciops_gliroides",
       "Equus_cabaus",
       "Diceros_bicornis_minor",
       "Manis_pentadactyla",
       "Choloepus_didactylus",
       "Callithrix_jacchus",
       "Theropithecus_gelada",
       "Rhinopithecus_roxellana",
       "Papio_anubis",
       "Macacaulatta",
       "Piliocolobus_tephrosceles",
       "Microcebus_murinus",
       "Homo_sapiens",
       "Gorilla_gorilla_gorilla",
       "Pongo_abelii",
       "Pan_troglodytes",
       "Nomascus_leucogenys",
       "Symphalangu_syndactylus",
       "Lemur_catta",
       "Nycticebus_coucang",
       "Elephas_maximus_indicus",
       "Arvicola_amphibius",
       "Cricetulus_griseus",
       "Microtus_ochrogaster",
       "Chionomys_nivalis",
       "Onychys_torridus",
       "Peromyscus_leucopus",
       "Jaculus_jaculus",
       "Perognathus_longimembris_pacificus",
       "Mus_musculus",
       "Rattus_norvegicus",
       "Apodemus_sylvaticus",
       "Acomys_russatus",
       "rvicanthis_niloticus",
       "Sciurus_carolinensis")

LifeTraits = c(G1, G2)

data <- read.table("/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/02_aa/OG_count_counts_G1G2_metatheriens_summed.tsv", sep = '\t', header = TRUE)
dim(data)
#path <- "~/Documents/INRAE_PaleoLab/05_Vertebrae/05_fixation_aa/test/"
path <- "/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/99_raw_data/MultipleSequenceAlignments/"

# Read the file
#aa_file <- paste0(path, OGid, "_amino_acid_positions.csv")
#OG.aa <- read.csv(aa_file)


########################################################################################################
# for whole dataset
# Loop through each Orthogroup from 8001 to the end

# ----------- INITIALISATION -----------
log_con <- file("erreurs_fixation_aa.log", open = "wt")
sink(log_con, type = "message")
results_list <- list()

print(dim(OG.aa_filtre))
print(colnames(OG.aa_filtre))

# ----------- TRAITEMENT PRINCIPAL -----------
for (i in seq_along(data$Orthogroup)) {
  OGid <- data$Orthogroup[i]
  aa_file <- paste0(path, OGid, "_amino_acid_positions.csv")
  
  if (file.exists(aa_file)) {
    result <- tryCatch({
      OG.aa <- read.csv(aa_file)
      # 1. Extraire l'espèce de chaque colonne (hors "Position")
      extraire_espece <- function(nom_colonne) {
        paste(strsplit(nom_colonne, "_")[[1]][1:2], collapse = "_")
      }
      noms_colonnes <- colnames(OG.aa)
      if ("Position" %in% noms_colonnes) {
        noms_colonnes <- setdiff(noms_colonnes, "Position")
      }
      especes_colonnes <- sapply(noms_colonnes, extraire_espece, USE.NAMES = FALSE)
      # 2. Colonnes à garder
      colonnes_a_garder <- which(especes_colonnes %in% G1)
      if ("Position" %in% colnames(OG.aa)) {
        colonnes_a_garder <- c(which(colnames(OG.aa) == "Position"), colonnes_a_garder + 1)
        colonnes_a_garder <- unique(colonnes_a_garder)
      } else {
        colonnes_a_garder <- colonnes_a_garder + 1
      }
      colonnes_a_garder <- c(which(colnames(OG.aa) == "Position"), which(especes_colonnes %in% G1) + 1)
      colonnes_a_garder <- unique(sort(colonnes_a_garder))
      # 3. Filtrer OG.aa
      OG.aa_filtre <- OG.aa[, colonnes_a_garder, drop = FALSE]
      print(dim(OG.aa_filtre))
      print(colnames(OG.aa_filtre))
      # 4. Appeler process_aa_data
      result <- process_aa_data(OG.aa_filtre, LifeTraits, G1, OGid)
      if (!is.null(result)) {
        print(head(result))
        results_list[[i]] <- result
      } else {
        message("[", OGid, "] Aucun résultat pour cet orthogroupe.")
      }
      result
    }, error = function(e) {
      message(paste("Failed to process file:", aa_file, ":", e$message))
      return(NULL)
    })
    if (!is.null(result)) {
      results_list[[i]] <- result
    }
  } else {
    warning(paste("File does not exist:", aa_file))
  }
}

sink(type = "message")
close(log_con)

# ----------- COMBINAISON ET ÉCRITURE -----------
# Combine all results into a single data frame, filtering out NULLs
final_results <- do.call(rbind, results_list)
print(dim(final_results))
str(final_results)

save(G1, G2,final_results, file = "resultats_fixation_aa.RData")

# Optionally, print the final results
dim(final_results)

write.table(final_results, "final_results.txt", sep = "\t", row.names = FALSE, quote = FALSE)

woodherb.cbd.aa <- final_results
max((woodherb.cbd.aa %>% filter(Group=="G1"))$Species)
max((woodherb.cbd.aa %>% filter(Group=="G2"))$Species)



woodherb.cbd.aa.v2 <- woodherb.cbd.aa %>% 
  mutate(OGid = paste(Orthogroup, Pos, sep = "_"), .before = Group, .keep = "unused") %>% 
  group_by(OGid, Group) %>% # Calculate AA freq by position
  mutate(across(starts_with("Count"), ~ . / sum(.x, na.rm = TRUE), .names = "{.col}_freq")) %>%
  ungroup() %>% 
  arrange(Group) %>% 
  pivot_wider(names_from = Group,
              values_from = c(Count, Count_freq, Species),
              values_fill = list(Count=0, Count_freq=0, Species=0)) %>%
  mutate(AA = as.factor(AA)) %>% 
  as.data.frame() %>%
  mutate(delta_freq= Count_freq_G1 - Count_freq_G2, .after = Count_freq_G2) %>% 
  group_by(OGid) %>% # remove if less than 17 species in G1 and G2
  filter(sum(Species_G1, na.rm = TRUE) >= 5 & sum(Species_G2, na.rm = TRUE) >= 5) %>%
  ungroup()

save(woodherb.cbd.aa.v2, file = "woodherb.cbd.aa.v2.RData")


# Extract differentiated AA  1|0
woodherb.diff <- woodherb.cbd.aa.v2 %>% 
  filter((Count_freq_G1 >= 1 & Count_freq_G2 <= 0) | (Count_freq_G2 >= 1 & Count_freq_G1 <= 0))
dim(woodherb.diff)

# Remove differentiated AA that capture less then 50% of species in a group
woodherb.diff.v2 <- woodherb.diff %>% 
  filter(Species_G1 >= 5 | Species_G2 >= 5)
dim(woodherb.diff.v2)

dim(woodherb.diff.v2 %>% filter(delta_freq== 1))
dim(woodherb.diff.v2 %>% filter(delta_freq== -1))

woodherb.diff.v2.dup <- woodherb.diff.v2[duplicated(woodherb.diff.v2$OGid),]
dim(woodherb.diff.v2.dup)

save(woodherb.diff.v2.dup, file = "woodherb.diff.v2.dup.RData")


head(woodherb.diff.v2.dup)

# Remove duplicated positions corresponding to differentiated AA in both groups
woodherb.diff.v2.nodup <- woodherb.diff.v2[!duplicated(woodherb.diff.v2$OGid),]
dim(woodherb.diff.v2.nodup)

woodherb.diff.v3 <- woodherb.diff.v2.nodup %>% 
  tidyr::separate(OGid, c("Orthogroup", "Pos")) %>% 
  group_by(Orthogroup) %>% 
  summarise(OG_count= n())
dim(woodherb.diff.v3)

dim(woodherb.diff.v3 %>% filter(OG_count >=5))

sum(woodherb.diff.v3$OG_count[woodherb.diff.v3$OG_count >= 5], na.rm = TRUE)

save(woodherb.diff.v3, file = "woodherb.diff.v3.RData")


ggplot(woodherb.diff.v3, aes(OG_count, fill = as.factor(OG_count))) +
  geom_histogram(binwidth = 1, show.legend = FALSE) +
  #geom_vline(xintercept = 2, linetype="dashed", color = "blue") +
  #annotate("text", x = 2.8, y = 150, label = "2 AA", colour = "blue") +
  #geom_vline(xintercept = 4, linetype="dashed", color = "red") +
  #annotate("text", x = 5, y = 100, label = "4 AA", colour = "red") +
  labs(title = "Woody vs. Herbaceous", x="Number of differentiated AA in an OG", y="Number of OG") +
  theme(panel.background = element_rect(fill = "white", colour = "grey50"))

ggsave("plot_01.pdf", width = 12,  height = 12)

woodherb.diff.v3 %>%
  group_by(OG_count) %>%
  summarise(n=n()) %>%
  ggplot(aes(x = n, y = OG_count, color = OG_count)) +
  scale_color_gradient(low="blue", high="darkred") +
  geom_point(aes(size = as.factor(OG_count)), show.legend = FALSE) +
  labs(title = "Woody vs. Herbaceous", x="Number of OGs", y="Differentiated AA in OG") +
  theme(panel.background = element_rect(fill = "white", colour = "grey50"))


# Define the Orthogroup with most differentiated AA
OGid <- woodherb.diff.v3$Orthogroup[which.max(woodherb.diff.v3$OG_count)]




# Read the file
OG.aa <- read.csv(aa_file)


OGid.cols <- woodherb.diff.v2.nodup%>% 
  dplyr::select(OGid) %>% 
  tidyr::separate(OGid, c('Orthogroup', 'Pos')) %>% 
  filter(Orthogroup==OGid)
dim(OGid.cols)


#library(tidyverse)
library(data.table)
OG.aa.wh <- OG.aa %>% data.table::transpose(keep.names = "ID", make.names = "Position") %>% 
  mutate(Species = ifelse(grepl("_", ID), sub("_.*", "", ID), ID), .after = ID) %>% 
  filter(Species %in% woodherb) %>% 
  arrange(match(Species, woodherb)) %>% 
  mutate(Group= ifelse(Species %in% tree, 'woody', 'herbaceous'), .after = Species) %>% 
  filter(rowSums(dplyr::select(., all_of(OGid.cols$Pos)) == "-") <= ncol(dplyr::select(., all_of(OGid.cols$Pos))) / 2) %>%  
  dplyr::select(ID:Group, all_of(OGid.cols$Pos))

dim(OG.aa.wh)


library(ComplexHeatmap)
library(RColorBrewer)

unique_aa <- OG.aa.wh %>%
  dplyr::select(-ID:-Group) %>%  # Exclude the first 5 columns
  unlist() %>%       # Convert to a vector
  unique() %>% 
  sort()

# Check the number of unique values
num_unique <- length(unique_aa)

# Create a color vector for the unique values
if (num_unique <= 12) {
  color_vector <- setNames(brewer.pal(num_unique, "Paired"), unique_aa)
} else {
  # Use a different palette that supports more colors or create a custom palette
  color_vector <- setNames(brewer.pal(12, "Set3"), unique(unique_aa[1:12]))
  # If there are more than 12 unique values, you can add more colors manually
  additional_colors <- rainbow(num_unique - 12)  # Generate additional colors
  color_vector <- c(color_vector, setNames(additional_colors, unique_aa[13:num_unique]))
}


mat.wh <- OG.aa.wh %>% 
  column_to_rownames(var = "ID") %>% 
  arrange(Group) %>% 
  dplyr::select(-Species:-Group) %>% 
  as.matrix()

Heatmap(mat.wh, name = "AA",
        col = color_vector[as.vector(mat.wh)],
        show_row_names = T,
        show_column_names = F,
        layer_fun = function(j, i, x, y, width, height, fill) {
          grid.text(sprintf("%s", pindex(mat.wh, i, j)), x, y, gp = gpar(col = "white", fontsize = 15))
          grid.rect(gp = gpar(fill = "transparent"))
        })

ggsave("plot_02.pdf", width = 12,  height = 12)



save.image(file = "workspace_fixation_aa.RData")
