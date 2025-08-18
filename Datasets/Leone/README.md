## Leone Dataset Info

> :warning: **First, uncompress the `Data.7zip` archive. Make sure to place the uncompressed files directly under the `Datasets/Leone` directory!**

### Dataset Paper
**Title:** Hyperspectral reflectance dataset of pristine, weathered, and biofouled plastics

**DOI:** [10.5194/essd-15-745-2023](https://doi.org/10.5194/essd-15-745-2023)

### Dataset
**DOI:** [10.14284/709](https://doi.org/10.14284/709)

> :warning: **We make use of the most recent version of the dataset (DOI 10.14284/709), not the original one (DOI 10.14284/530)!**



### Processing
The original data was copied to a single .csv file, `Leone.csv`, containing the spectra from the original `Leone et al.,2021 hyperspectral data_updated_version.xlsx` file. This file was then processed by the `splice_correction_leone.m` script, which applies splice correction, resulting in the `Leone_corrected.csv` file. We noted that the splicing was inconsistent across the dataset, specifically in the 1800nm region, where some spectra present splicing between 1800nm and 18001nm, and other spectra present slicing between 1830nm and 1831nm. For instance, in `Leone.csv`, in column 630, the splicing is clearly at 1800nm, whereas in column 634 it occurs at 1830nm. For this reason, the script compares the differences between 1800–1801nm and 1830–1831nm, and, if necessary, applies the correction at the location with the greater difference.

### License

The files `Leone.csv` and `Leone_corrected.csv` are distributed under the [Creative Commons Attribution 4.0 License (CC-BY-4.0)](https://creativecommons.org/licenses/by/4.0/).

All files under the `Original` directory are distributed under the [Creative Commons Attribution 4.0 License (CC-BY-4.0)](https://creativecommons.org/licenses/by/4.0/).

**Attribution for files in the `Original` directory:** Giulia Leone, Ana I. Catarino, Liesbeth De Keukelaere, Mattias Bossaer, Els Knaeps, and Gert Everaert 

**Changes Made:** 
- The files `Leone.csv` and `Leone_corrected.csv` are derivative works based on the files in the `Original` directory.
- Files in the `Original` directory are unmodified from their respective sources.
