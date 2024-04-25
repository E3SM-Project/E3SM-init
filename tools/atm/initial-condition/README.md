# Generate atmosphere initial condition
Generate initial condition file for atmosphere. This will remap an existing
initial condition and apply surface adjustment for differences in topography
to mitigate spurious gravity waves at initialization. The surface adjustment
uses the HICCUP utility (https://github.com/E3SM-Project/HICCUP). The script
assumes that HICCUP is installed as a library, which can be done by cloning
the repo and running `./setup.py install` from the root of the repo.

## Scripts in this folder:

    - `adjust_surface.py`: utility function to call HICCUP routines. Requires HICCUP, xarray, numpy, and plac python libraries.
    - `generate_atm_initial_condition.sh`: script to handle remapping and calling `adjust_surface.py`

## Dependencies:

    - TempestRemap
    - NCO
    - Python libraries: HICCUP, numpy, xarray, plac
