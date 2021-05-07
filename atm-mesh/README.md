# Generate atmosphere mesh files
Generate different different descriptions of atmosphere physics mesh. This
generates both an exodus-format file describing the physics grid quadrilaterals
and a SCRIP-formatted version (used by tradiational remapping tools like ESMF).

## Dependencies

    1. TempestRemap

You will also need to set the following environment variables, or modify the script to set them:

    1. `output_root`: path to which to save generated files.
    2. `atm_grid_res`: numerical resolution of grid, in number of elements (i.e., 1024)
    3. `atm_grid_name`: name for this grid, without "pg" suffix (i.e., ne1024).
    4. `tempest_root`: path to TempestRemap build.

Step 2) is only needed for *uniform* grids; you will skip this step for RRM grids,
as you should already have a mesh file generated using SQuadGen.
