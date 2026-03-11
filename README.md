# PeTTSy 1.0.3 - Perturbation Theory Toolbox for Systems

**PeTTSy** (Perturbation Theory Toolbox Software for Systems) is a MATLAB-based tool for performing sensitivity analysis on systems of ordinary differential equations (ODEs). It applies perturbation theory and singular value decomposition (SVD) to decompose how parameter changes affect system dynamics, including limit cycles and signal responses.

## Authors

Mirela Domijan, Paul Brown, Boris Shulgin & David Rand
University of Warwick, 2015

v1.0.3 updates by [@tomjf](https://github.com/tomjf) (Tom Fletcher) and [Claude](https://claude.ai) (Anthropic), 2025

## License

GNU General Public License v3.0 - see the [LICENSE](LICENSE) file.

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
```
## Features

- **Model Management**: Install, create, and manage ODE models (oscillators and signal systems)
- **Time Series Generation**: Compute numerical solutions with configurable parameters
- **Perturbation Theory**: Compute infinitesimal response curves (IRCs), phase derivatives, and period sensitivities
- **SVD Sensitivity Analysis**: Decompose parameter sensitivities using singular value decomposition
- **Plotting**: Time series, derivatives, IRC plots, phase plots, sensitivity composites, scatter plots
- **Data Export**: Export results to MATLAB workspace
- **SBML Support**: Import/export models in Systems Biology Markup Language format (requires libSBML)

---

## What's New in 1.0.3

Version 1.0.3 is a comprehensive modernization of the PeTTSy codebase, updating it from MATLAB R2015a-era APIs to full R2025a compatibility. This release was produced by [@tomjf](https://github.com/tomjf) (Tom Fletcher) and [Claude](https://claude.ai) (Anthropic). Every change is listed below.

---

### 1. Deprecated Function Replacements

These functions were removed or deprecated in modern MATLAB and have been replaced throughout the codebase:

#### `textread` → `textscan` (8 files, ~17 call sites)

`textread` was removed in R2019a. All calls have been replaced with the equivalent `textscan` pattern: opening the file with `fopen`, reading with `textscan`, and closing with `fclose`. Affected files:
- `pettsy.m` - reading settings/ini files
- `sagui.m` - reading settings/ini files
- `models/make.m` - reading `.par` and `.varn` model definition files
- `SDS/sa_leftpanel.m` - reading saved settings
- `SDS/tppgui.m` - reading saved settings
- `theory/th_leftpanel.m` - reading saved settings
- `shared/getlistofmodels.m` - reading model info files
- `lcycle/newcyclegui.m` - reading parameter files

#### `strread` → `strsplit` (1 file)

`strread` was removed in R2019a. The single usage in `shared/getlistofmodels.m`, which parsed comma-separated force type strings, was replaced with `strsplit`.

#### `lasterror`/`lasterr` → `MException` catch syntax (4 files)

The `lasterror` and `lasterr` functions were removed in R2022b. All `try/catch` blocks that used `lasterror` to retrieve error information after the fact have been replaced with the modern `try ... catch ME` pattern, where `ME` is an `MException` object. The error message is then accessed via `ME.message` instead of `lasterror.message`. Affected files:
- `pettsy.m`
- `lcycle/find_oscillator_cycle.m`
- `theory/theory_oscillator.m`
- `theory/theory_signal.m`

#### `str2num` → `str2double`/`sscanf` (~100+ call sites across ~30 files)

`str2num` uses `eval` internally, making it a security risk and slower than alternatives. Every call site was replaced with the appropriate modern alternative:
- **Scalar values**: `str2num(x)` → `str2double(x)` (the vast majority of cases)
- **Vector values**: `str2num(x)` → `sscanf(x, '%f')` (where the input is a space-separated list of numbers)

This affected virtually every GUI file that reads numeric values from edit controls, including all files in `SDS/`, `theory/`, `force/`, `lcycle/`, `sbml/`, and `shared/`.

#### `matlabpool` → `parpool` (1 file)

`matlabpool` was removed in R2014a. Dead `matlabpool` code in `theory/newtheorygui.m` was removed. The file already had working `parpool`/`delete(gcp('nocreate'))` code, so the dead `matlabpool` branch was simply deleted.

---

### 2. Java Swing Removal

MATLAB R2025a issues warnings for all Java Swing interop and will remove support entirely in a future release. All Java Swing dependencies have been replaced with native MATLAB UI components:

#### HTML Text Panels: `javacomponent`/`javaObjectEDT` → `uihtml` (10 files)

PeTTSy used `javacomponent` to embed `javax.swing.JEditorPane` and `javaObjectEDT` to create Java HTML panels for displaying rich text (model information, help text, status messages). These have all been replaced with MATLAB's native `uihtml` component via a new shared helper function `create_html_panel.m`. The helper creates a `uihtml` control backed by an HTML template file (`shared/resources/html_template.html`) that supports styled text, auto-scrolling, and dynamic content updates via the `Data` property. A fallback to plain `uicontrol('Style','edit')` is included for environments where `uihtml` is unavailable.

Affected files:
- `theory/th_rightpanel.m` - theory results info panel
- `theory/th_tippanel.m` - theory tips/status panel
- `theory/th_leftpanel.m` - theory left panel info
- `SDS/sa_rightpanel.m` - SDS results info panel
- `SDS/sa_leftpanel.m` - SDS left panel info
- `SDS/tppgui.m` - TPP GUI info panel
- `sbml/showModelPanel.m` - SBML model info display
- `sbml/showSavePanel.m` - SBML save panel info
- `sbml/showExportModelPanel.m` - SBML export info
- `shared/aboutgui.m` - about dialog

#### Tree Controls: JIDE `CheckBoxTree` → Multi-Select Listbox (1 file)

`shared/createTree.m` used the JIDE `com.jidesoft.swing.CheckBoxTree` Java component, which provided a tree view with checkboxes for selecting model variables and parameters. This has been completely rewritten to use a native MATLAB `uicontrol('Style','listbox')` with `'Max'` set to allow multi-select. Tree hierarchy is represented visually through indented string prefixes. The `createTree` function now returns a struct with the same interface (`getSelectedItems`, `setSelectedItems`, etc.) so all callers continue to work without modification.

#### Table Sorting: `findjobj` → Native `uitable` (1 file)

`shared/create_sortable_table.m` used the `findjobj` utility to obtain the underlying Java `javax.swing.JTable` object from a MATLAB `uitable`, then called Java methods to enable column sorting. This has been replaced with MATLAB's native `uitable` `ColumnSortable` property (available since R2021a), which provides built-in column sorting without any Java interop.

#### `findjobj.m` Stubbed (1 file)

`shared/findjobj.m` was a 3200-line utility for finding Java objects underlying MATLAB UI components. Since all callers have been updated to use native alternatives, `findjobj.m` has been replaced with a stub that returns an empty array. The original file (`findjobj_legacy.m`) has been removed from the repository.

#### `javaaddpath` Removed from Startup (1 file)

`pettsy.m` previously called `javaaddpath` at startup to load the `java/` directory containing Java JAR files (used for HTML rendering and the JIDE tree component). Since all Java dependencies have been removed, these `javaaddpath` calls have been deleted. The `java/` directory still exists in the repository but is no longer loaded.

#### `MJLabel` → `uihtml` (1 file)

`theory/th_rightpanel.m` used `com.mathworks.mwswing.MJLabel` (an internal MathWorks Java class) for rendering HTML-formatted labels. This has been replaced with a `uihtml` component.

---

### 3. Symbolic Math Toolbox Modernization

The `findsym` function was removed from the Symbolic Math Toolbox in R2019a. It returned symbolic variable names as a comma-separated string (e.g. `'CP,t,x1'`). Its replacement, `symvar`, returns a symbolic vector (e.g. `[CP t x1]`). Every call site required adapting the downstream parsing logic.

#### `findsym` → `symvar` (6 files)

Each file had `findsym` calls followed by `strtok` or `strsplit` comma-parsing loops to iterate over the variable names. These have been replaced with `symvar` calls followed by `for` loops using `char(s(n))` to convert each symbolic element to a string.

**`symbolic/fastsubs.m`** (lines 23-38): The `fastsubs` function finds which symbolic variables in an expression need substitution, then substitutes only those. The `findsym` call followed by a `while length(rem)` / `strtok(rem,',')` parsing loop was replaced with `symvar` followed by `for n = 1:length(s)` / `char(s(n))`.

**`symbolic/myfindsym.m`** (lines 22-37): Identical pattern to `fastsubs.m` - same `findsym`→`symvar` and `strtok`→`for` loop replacement.

**`symbolic/get_force_expr.m`** (line 92): The check `isempty(strfind(findsym(f), 't1'))` which tested whether the force expression contains the time variable `t1` was replaced with `~any(symvar(f) == str2sym('t1'))`, which compares the symbolic variable vector directly.

**`sbml/ODEToMathML.m`** (lines 95-100): The `findsym(sym(eqn))` call followed by `textscan(sym_names, '%s', 'delimiter', ',')` to parse the comma-separated string into a cell array was replaced with a `symvar(eqn)` call followed by a simple `for` loop converting each element to a char with `char(sym_vars(ii))`.

**`models/make.m`** (lines 177-184 and 411-416): Two separate usages. The first (line 177) found force names in model equations using `findsym(rhs(d))` + `strtok` comma parsing; replaced with `symvar(rhs(d))` + `for` loop with `char(svars(s))`. The second (line 411) found variable/parameter names in each equation for the equation info struct; `findsym(rhs(i))` + `strsplit(sym_names,',')'` replaced with `symvar(rhs(i))` and `char(sym_names(s))`.

**`force/saveForcePanel.m`** (lines 244-251): The user-defined force equation validation function used `findsym(sym(force_eqn))` + `strsplit(vars, ',')` to find variables in the equation and check for invalid names. Replaced with `symvar(force_eqn)` and a `for` loop using `char(vars(vi))` to check each variable name.

#### `subs` with `str2sym` Wrapping (8 files)

In modern MATLAB's Symbolic Math Toolbox, the `subs` function no longer accepts plain strings as variable names - they must be symbolic expressions. All `subs` calls that passed string cell arrays as the "old variable" or "new variable" arguments have been wrapped with `str2sym()` to convert them to symbolic form.

**`symbolic/fastsubs.m`** (line 42): `subs(dif1,t1,s1)` → `subs(dif1,str2sym(t1),str2sym(s1))` where `t1` and `s1` are cell arrays of variable name strings.

**`symbolic/get_force_expr.m`** (line 120): `subs(expr,tsym,tstr)` → `subs(expr,str2sym(tsym),str2sym(tstr))` where `tsym` and `tstr` are cell strings representing the time variable substitution (e.g. `'t1'` → `'t-floor(t/CP)*CP'`).

**`symbolic/savedifpar.m`** (line 16): `subs(rhs, varsym, vari)` → `subs(rhs, str2sym(varsym), str2sym(vari))` where `varsym` contains symbolic names like `{'y1','y2'}` and `vari` contains runtime names like `{'y(1)','y(2)'}`.

**`symbolic/savesystem.m`** (lines 19, 22): Two `subs` calls updated. Line 19: `subs(rhs,[parsym forcesym], [pari forcei])` → `subs(rhs,[str2sym(parsym) str2sym(forcesym)], [str2sym(pari) str2sym(forcei)])`. Line 22: `subs(rhsp, varsym, vari)` → `subs(rhsp, str2sym(varsym), str2sym(vari))`.

**`models/make.m`** (lines 455-457): Three `subs` calls for displaying symbolic matrices to users. Line 455: `subs(rhs, varsym, varnames)` → wrapped both args. Line 456: `subs(dydtdk_tmp, vari, varnames)` → wrapped both args. Line 457: `subs(dydtdy_tmp, [varsym pari forcei], [varnames parn' forcesym])` → wrapped all string arrays with `str2sym` and concatenated the symbolic results.

**`force/saveForcePanel.m`** (lines 154, 265, 267): Line 154: `subs(force_eqn, 't', 't1')` → `subs(str2sym(force_eqn), 't', 't1')` to convert the user-entered equation string to a symbolic expression before substitution. Lines 265, 267: `diff(sym(force_eqn), varname)` → `diff(str2sym(force_eqn), varname)` to use `str2sym` instead of the deprecated `sym` string-to-symbolic conversion.

---

### 4. Solver and Algorithm Improvements

These changes improve the robustness of the limit cycle finder, particularly for models with long periods or difficult convergence.

#### Increased Maximum Period Search Range (`find_oscillator_cycle.m`)

`MAX_PER` was increased from 1000 to 10000. This constant defines the maximum period the solver will search for. Models with periods longer than 1000 time units (e.g. some plant circadian clock models operating in minutes) would previously fail to find an oscillation. The 10x increase accommodates these long-period models.

#### Extended Initial Relaxation Run (`find_oscillator_cycle.m`)

The initial ODE integration that relaxes the system toward the limit cycle previously used a hardcoded time span of `[t0, t0+400]`. This was changed to `[t0, t0+MAX_PER]`, ensuring the relaxation run is always long enough relative to the expected period. With `MAX_PER=10000`, this gives the system much more time to settle onto the attractor.

#### Best Period Tracking (`find_oscillator_cycle.m`)

The relaxation loop that iteratively refines the limit cycle previously tracked only `besteps` (the best boundary error) and `bestt`/`besty` (the corresponding time/state vectors). However, it did not track the corresponding period. If the best solution came from an earlier iteration, the period from the final (possibly worse) iteration would be used instead. A new `bestper` variable is now maintained alongside `besteps`, ensuring the period is always consistent with the best solution found.

#### Dynamic BVP NMax Scaling (`find_oscillator_cycle.m`)

The boundary value problem (BVP) solver `bvp4c` has an `NMax` parameter controlling the maximum number of mesh points. This was previously set to `floor(10000000/size(y,2))`, a fixed formula that could be either too large (wasting memory) or too small (causing convergence failures) depending on the solution. It has been changed to `floor(10*length(t)*size(y,2))`, which scales proportionally to the actual solution size - 10 times the number of time points multiplied by the number of state variables.

#### Period Update from BVP Solution (`find_oscillator_cycle.m`)

After a successful BVP solve, the period is now updated from the BVP solution's time span: `per = sol.x(end)-sol.x(1)`. Previously the period from the initial cycle detection was used throughout, even if the BVP solver refined the solution to a slightly different period. This ensures downstream calculations (phase analysis, time series interpolation) use the most accurate period available.

#### Default Solver Changed (`limitcycle.m`)

The default non-stiff ODE solver was changed from `ode113` (Adams-Bashforth-Moulton multi-step method) to `ode45` (Dormand-Prince Runge-Kutta method). `ode45` is MATLAB's recommended general-purpose solver, tends to be more robust for the initial relaxation phase, and handles event detection more reliably. The stiff solver (`ode15s`) is unaffected.

---

### 5. Force Formula Corrections

The force functions in `force/get_force.m` are auto-generated by `symbolic/writeforce.m` from the symbolic definitions in `symbolic/get_force_expr.m`. The symbolic source defines each force as a product of step functions, e.g. for the '60' case:

```matlab
f = (1/2*(tanh(c*(t1-a))+1)) .* (1/2*(1-tanh(c*(t1-b))))
```

This represents a pulse that turns on at time `a` and off at time `b`, using tanh as a smooth step function. When `writeforce.m` expands and simplifies these expressions for runtime evaluation (substituting `t1` with `t-floor(t/CP)*CP` for oscillators, or plain `t` for signals), the previous version of `get_force.m` had sign errors in the expanded tanh expressions for cases '60', '100', and '200'.

**The problem**: The old formulas for the three long-period oscillator cases had the form:

```matlab
% OLD (incorrect):
-(tanh(25*t - 25*CP*floor(t/CP))/2 + 1/2) * (tanh(25*t - 25*CP*floor(t/CP) - 7500)/2 - 1/2)
```

The arguments to the second tanh factor had the wrong sign convention. When `tanh(x)` is large and positive, `tanh(x)/2 - 1/2` approaches 0, but the pulse-off step should approach 1 at that point. The signs inside the tanh arguments were effectively negated relative to the correct symbolic expansion.

**The fix**: The corrected formulas use the proper expansion where the "off" step has the time offset subtracted from the constant (not the other way around), and uses `+1/2` instead of `-1/2`:

```matlab
% NEW (correct):
(tanh(25*t - 25*CP*floor(t/CP))/2 + 1/2) * (tanh(25*CP*floor(t/CP) - 25*t + 7500)/2 + 1/2)
```

This matches the correct symbolic expansion of `(1/2*(tanh(c*(t1-a))+1)) * (1/2*(1-tanh(c*(t1-b))))` after the substitution `t1 = t - floor(t/CP)*CP`. Both the oscillator and signal subfunctions were corrected for all three cases ('60', '100', '200').

#### Sinewave Derivative Term Ordering (`get_dforce_ddawn.m`)

In the signal (non-oscillator) version of the sinewave derivative, the term `(2*pi*t)/CP` was rewritten as `(2*t*pi)/CP`. This is algebraically identical but makes the expression consistent with the form used in `get_force_expr.m`'s symbolic source definition, reducing confusion when comparing the generated code against the source.

---

### 6. Bug Fixes

#### `th_rightpanel` Typo (`theory/th_rightpanel.m`)

The file contained a callback string referencing `sa_rightpanel` (the SDS right panel function) instead of `th_rightpanel` (the theory right panel function). This meant clicking certain controls in the theory GUI would call the wrong function, likely causing errors or unexpected behaviour. Fixed by changing the callback to reference the correct function name.

#### Trailing Semicolon After `if` (`pettsy.m`)

An `if` statement had a semicolon immediately after the condition: `if condition;`. In MATLAB, the semicolon after `if` is syntactically valid but causes the `if` block to behave as though the condition is always followed by an empty statement, which can lead to subtle logic errors depending on the MATLAB version. The semicolon was removed.

#### Unescaped Bracket in Regex (`models/makegui.m`)

A regular expression pattern contained an unescaped `[` character, which MATLAB's regex engine could interpret as the start of a character class rather than a literal bracket. This was fixed by escaping it as `\[`. Without the fix, the regex could fail to match or match incorrectly when parsing model definition files.

#### `CellEditCallback` Property Name Casing (3 SDS files)

Three files in `SDS/` set the `uitable` callback for cell editing using the wrong property name casing. MATLAB's `uitable` uses `CellEditCallback` (camelCase), but the code used a different casing that worked in older MATLAB versions due to case-insensitive property matching, which was tightened in modern releases. Fixed in:
- `SDS/sa_plotcomposite.m`
- `SDS/sa_plotsensitivity.m`
- `SDS/sa_plotstrengths.m`

#### Missing `fclose` in `writeforce.m` (`symbolic/writeforce.m`)

After writing the `get_dforce_ddawn.m` file, the code called `disp('done')` but failed to call `fclose(file)` to close the file handle. This meant the file handle remained open, which could cause issues on Windows (file locking) or lead to resource leaks if `writeforce` was called repeatedly. A `fclose(file)` call was added before the `disp('done')` line.

#### Hardcoded Font Size in Bar Plot Labels (`theory/th_plotperiod.m`)

When the period derivative bar plot has more than 12 parameters, vertical text labels are drawn using the `text()` function. The font size was hardcoded to `12` instead of using the global `plot_font_size` variable that all other text in the plot uses. This caused inconsistent label sizing. Changed `'fontsize', 12` to `'fontsize', plot_font_size`.

#### Path Resolution via `which` (`force/saveForcePanel.m`)

The function used `fileparts(which('pettsy.m'))` to find the PeTTSy installation directory, then constructed the path to `symbolic/get_force_expr.m` from there. The `which` function searches the MATLAB path, which can return unexpected results if multiple copies of `pettsy.m` exist on the path, or if the path order changes. This was replaced with `fileparts(mfilename('fullpath'))` which reliably returns the directory of the currently executing file, then navigates to the correct relative path using `fullfile(sassydir, '..', 'symbolic', 'get_force_expr.m')`.

---

### 7. New Model Definitions

9 new models were added from the upstream repository, and 9 existing local models were preserved, bringing the total to 20 built-in model definitions:

| Model | Type | Files | Source |
|-------|------|-------|--------|
| abo | oscillator | `_model.m`, `.par` | local |
| becker | oscillator | `_model.m`, `.par` | local |
| forger | oscillator | `_model.m`, `.par`, `.varn` | upstream |
| jolley | oscillator | `_model.m`, `.par` | local |
| leloup | oscillator | `_model.m`, `.par` | local |
| mammalian | oscillator | `_model.m`, `.par`, `.varn`, `.zip` | local (with Rev bit modifications) |
| mirsky | oscillator | `_model.m`, `.par` | local |
| modmirsky | oscillator | `_model.m`, `.par` | local |
| NFkB | signal | `_model.m`, `.par`, `.varn`, `.zip` | upstream |
| neurospora | oscillator | `_model.m`, `.par`, `.varn` | upstream |
| novaktyson | oscillator | `_model.m`, `.par` | upstream |
| PlantClock | oscillator | `_model.m`, `.par`, `.varn`, `.zip` | upstream |
| Relogio2 | oscillator | `_model.m`, `.par`, `.varn`, `.info` + 6 generated files | upstream |
| relogio | oscillator | `_model.m`, `.par` | local |
| tyson | oscillator | `_model.m`, `.par` | upstream |
| ueda | oscillator | `_model.m`, `.par` | upstream |
| updatedMirsky | oscillator | `_model.m`, `.par` | local |
| updatedMirskyextrapar | oscillator | `_model.m`, `.par` | local |
| Zhang_Andersen | oscillator | `_model.m`, `.par` | upstream |
| zeilinger | oscillator | `_model.m`, `.par` | upstream |

---

### 8. New Files Added

- **`shared/create_html_panel.m`** - Helper function for creating HTML-capable display panels. Uses `uihtml` with an HTML template for rich text display, with automatic fallback to a plain `uicontrol('Style','edit')` if `uihtml` is unavailable. Returns `[handle, isHtml]` so callers can update content appropriately (`handle.Data = htmlStr` for uihtml, `set(handle, 'String', text)` for fallback).
- **`shared/resources/html_template.html`** - HTML template used by `create_html_panel.m`. Provides a styled container with auto-scroll support, accepting content updates via the MATLAB `uihtml` Data property.
- **`LICENSE`** - Full text of the GNU General Public License v3.0.

### 9. Files Removed

- **`shared/findjobj_legacy.m`** - The original 3200-line `findjobj` utility for finding Java objects underlying MATLAB UI components. No longer needed since all Java interop has been replaced with native MATLAB components.
- **`MODERNIZATION_PLAN.md`** - Internal planning document used during the modernization process. Not needed in the published repository.
- **`pettsy.ini`** (root) - Runtime-generated configuration file that stores GUI state. Should not be version-controlled as it is created automatically when PeTTSy runs.
- **`models/definitions/pettsy.ini`** - Same as above, in the definitions directory.
- **`models/definitions/Copy_of_relogio_model.m`** - Accidental copy of the relogio model definition.
- **`lcycle/find_oscillator_cycle 2.m`** - Accidental backup file with a space in the name.

---

## Citation

If you use PeTTSy in your research, please cite:

> Domijan M, Brown P, Shulgin B, Rand DA. PeTTSy: Perturbation Theory Toolbox for Systems. *In preparation*.

## Release History

- **1.0.2** (September 2017) - Original release by Domijan, Brown, Shulgin & Rand
- **1.0.3** (2025) - Modernized for MATLAB R2025a by Tom Fletcher & Claude (Anthropic)
