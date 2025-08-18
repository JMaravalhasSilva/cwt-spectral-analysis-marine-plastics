## Knaeps Dataset Info

### Dataset Paper
**Title:** Hyperspectral-reflectance dataset of dry, wet and submerged marine litter

**DOI:** [10.5194/essd-13-713-2021](https://doi.org/10.5194/essd-13-713-2021)

### Dataset
**DOI:** [10.4121/12896312.v2](https://doi.org/10.4121/12896312.v2)

### Processing
The original data was copied to a single .csv file, `Knaeps.csv`, containing the spectra from the original `HYPER_mean.txt` file. This file was then processed by the `splice_correction_knaeps.m` script, which applies splice correction as suggested by the authors of the paper (see quote below), resulting in the `Knaeps_corrected.csv` file.

Quote from the paper:
> The difference at 1000 and 1001 nm can be used to correct the VNIR data, whilst the difference at 1800 and 1801 nm can be used to correct the SWIR-2 data.

### License

The files `Knaeps.csv` and `Knaeps_corrected.csv` are distributed under the [Creative Commons Zero license (CC0)](https://creativecommons.org/public-domain/cc0/).

All .txt files under the `Original` directory are distributed under the [Creative Commons Zero license (CC0)](https://creativecommons.org/public-domain/cc0/).

The `Knaeps_dataset_paper.pdf` file under the `Original` directory is distributed under the [Creative Commons Attribution 4.0 License (CC-BY-4.0)](https://creativecommons.org/licenses/by/4.0/).

**Attribution for files in the `Original` directory:** Els Knaeps, Sindy Sterckx, Gert Strackx, Johan Mijnendonckx, Mehrdad Moshtaghi, Shungudzemwoyo P. Garaba, and Dieter Meire.

**Changes Made:** 
- The files `Knaeps.csv` and `Knaeps_corrected.csv` are derivative works based on the files in the `Original` directory.
- Files in the `Original` directory are unmodified from their respective sources.
