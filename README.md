# PeTTSy - Perturbation Theory Toolbox for Systems

**PeTTSy** (Perturbation Theory Toolbox Software for Systems) is a MATLAB-based tool for performing sensitivity analysis on systems of ordinary differential equations (ODEs). It applies perturbation theory and singular value decomposition (SVD) to decompose how parameter changes affect system dynamics, including limit cycles and signal responses.

## Authors

Mirela Domijan, Paul Brown, Boris Shulgin & David Rand
University of Warwick, 2015

## License

GNU General Public License v3.0 - see the [LICENSE](http://www.gnu.org/licenses/gpl-3.0.en.html).

## Requirements

- **MATLAB R2022a or later** (tested with R2025a)
- **Symbolic Math Toolbox** (required for model creation)
- **Parallel Computing Toolbox** (optional, for parallel theory computation)
- **libSBML + SBML Toolbox** (optional, for SBML model import/export)

## Installation and Launch

1. Place the PeTTSy directory on your filesystem
2. Open MATLAB and navigate to the PeTTSy directory (`cd` to it)
3. Run `pettsy` from the MATLAB command window

PeTTSy must be launched from its installation directory.

## Directory Structure

```bash
pettsy.m            - Main entry point
sagui.m             - SDS (Sensitivity Decomposition of Systems) GUI entry point

SDS/                - SVD-based sensitivity analysis GUI and plotting
theory/             - Perturbation theory analysis GUI and plotting
lcycle/             - Limit cycle computation
force/              - External forcing functions
models/             - Model definitions and installation
  definitions/      - Built-in oscillator and signal model definitions
symbolic/           - Symbolic math code generation
sbml/               - SBML model import/export
shared/             - Shared utilities (HTML panels, tree controls, tables, error handling)
xpp/                - XPP (XPPAUT) integration
sundialsTB/         - SUNDIALS/CVode solver interface
docs/               - Documentation
java/               - Legacy Java resources (no longer loaded)
```
## Features

- **Model Management**: Install, create, and manage ODE models (oscillators and signal systems)
- **Time Series Generation**: Compute numerical solutions with configurable parameters
- **Perturbation Theory**: Compute infinitesimal response curves (IRCs), phase derivatives, and period sensitivities
- **SVD Sensitivity Analysis**: Decompose parameter sensitivities using singular value decomposition
- **Plotting**: Time series, derivatives, IRC plots, phase plots, sensitivity composites, scatter plots
- **Data Export**: Export results to MATLAB workspace
- **SBML Support**: Import/export models in Systems Biology Markup Language format (requires libSBML)

## Modernization Changelog (2025)

The codebase has been updated from MATLAB R2015a-era APIs to work with MATLAB R2025a. Changes include GUI infrastructure modernization, deprecated API replacements, Symbolic Math Toolbox updates, solver improvements, and bug fixes.

### Removed Deprecated Functions
- `textread` replaced with `textscan` (8 files, ~17 call sites)
- `strread` replaced with `strsplit` (1 file)
- `lasterror`/`lasterr` replaced with `MException` catch syntax (4 files)
- `str2num` replaced with `str2double`/`sscanf` (~100+ call sites across ~30 files)
- Dead `matlabpool` code removed, keeping only `parpool`/`delete(gcp('nocreate'))` (1 file)

### Removed Java Swing Interop
- `javacomponent` and `javaObjectEDT` calls for HTML text panels replaced with `uihtml` + HTML template via new `shared/create_html_panel.m` helper (10 files)
- JIDE `CheckBoxTree` in `shared/createTree.m` replaced with multi-select `uicontrol('Style','listbox')` with indented field display
- `findjobj`-based table sorting in `shared/create_sortable_table.m` replaced with native `uitable` `ColumnSortable` property
- `findjobj.m` stubbed to a no-op (legacy version removed)
- `javaaddpath` calls removed from `pettsy.m` startup (the `java/` directory is no longer loaded)
- `com.mathworks.mwswing.MJLabel` replaced with `uihtml` in `theory/th_rightpanel.m`

### Modernized Symbolic Math Toolbox Calls
- `findsym` replaced with `symvar` in 6 files (`fastsubs.m`, `myfindsym.m`, `get_force_expr.m`, `ODEToMathML.m`, `make.m`, `saveForcePanel.m`)
- `subs` calls updated to wrap string arguments with `str2sym` for compatibility with modern Symbolic Math Toolbox (8 files)
- Downstream parsing adapted: `strtok` comma-parsing loops replaced with `for` loops over `symvar` output

### Solver and Algorithm Improvements
- `find_oscillator_cycle.m`: Increased `MAX_PER` from 1000 to 10000 for long-period oscillators
- `find_oscillator_cycle.m`: Initial relaxation run now uses `MAX_PER` instead of hardcoded 400
- `find_oscillator_cycle.m`: Best period now tracked alongside best epsilon for robust recovery
- `find_oscillator_cycle.m`: BVP NMax scaled dynamically based on solution size
- `find_oscillator_cycle.m`: Period updated from BVP solution on success
- `limitcycle.m`: Default non-stiff solver changed from `ode113` to `ode45`

### Force Formula Corrections
- Corrected oscillator tanh expressions for cases '60', '100', '200' in `get_force.m` (sign corrections)
- Consistent `2*t*pi` ordering in sinewave signal derivative (`get_dforce_ddawn.m`)

### Bug Fixes
- Fixed `sa_rightpanel` typo in `theory/th_rightpanel.m` (should have been `th_rightpanel`)
- Fixed trailing semicolon after `if` condition in `pettsy.m`
- Fixed unescaped bracket in regex pattern in `models/makegui.m`
- Fixed `CellEditCallback` property name casing in 3 SDS files
- Added missing `fclose` in `writeforce.m` after writing `get_dforce_ddawn.m`
- Replaced hardcoded `fontsize` 12 with `plot_font_size` variable in `th_plotperiod.m`
- Replaced `fileparts(which('pettsy.m'))` with `fileparts(mfilename('fullpath'))` in `saveForcePanel.m`

### New Models
- NFkB, PlantClock, Relogio2, Zhang_Andersen, neurospora, novaktyson, tyson, ueda, zeilinger

### New Files
- `shared/create_html_panel.m` - Helper for creating HTML-capable display panels using `uihtml` with fallback to plain `uicontrol`
- `shared/resources/html_template.html` - HTML template for `uihtml` components with auto-scroll support
- `LICENSE` - GNU General Public License v3.0

## Citation

If you use PeTTSy in your research, please cite:

> Domijan M, Brown P, Shulgin B, Rand DA. PeTTSy: Perturbation Theory Toolbox for Systems. *In preparation*.

## Release History

- **1.0.2** (September 2017) - Original release
- **1.0.2-modern** (2025) - Modernized for MATLAB R2025a compatibility
