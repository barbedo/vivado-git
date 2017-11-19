# vivado-git

Trying to make Vivado more git-friendly.

### Requirements

- Tested on Vivado 2017.3

#### Windows
- [Git for Windows](https://git-scm.com/download/win)
- Add `C:\Program Files\Git\bin` (or wherever you have your `git.exe`) to your `PATH`

#### Linux
- Git

### Installation

Add `Vivado_init.tcl` (or append the relevant lines if you already have something in it) along with the `scripts` directory to:

- `%APPDATA%\Roaming\Xilinx\Vivado` on Windows
- `~/.Xilinx/Vivado` on Linux

### How it works

Vivado is a pain in the ass to source control decently, so these scripts provide:

  - A modified `write_project_tcl_git.tcl` script to generate the project script without absolute paths.

  - A git wrapper that will recreate the project script and add it before committing.

  - A Tcl script (`wproj`) to just create the project generator script without using git.

### Workflow

 1. When first starting with a project, create it in a folder called `vivado_proj` (e.g. `PROJECT_NAME/vivado_proj`) . All the untracked files will be under this directory.

 2. Place your source files anywhere you want in your project folder (usually in the `PROJECT_NAME/src`).

    Here is an example of a possible project structure:
    ```
    PROJECT_NAME
        ├── .git
        ├── .gitignore
        ├── project_name.tcl         # Project generator script
        ├── src/                     # Tracked source files
        │   ├── design
        │   │    ├── *.v
        │   │    └── *.vhd
        │   ├── testbench
        │   │    ├── *.v
        │   │    └── *.vhd
        │   └── ...
        └── vivado_proj/             # Untracked generated files
            ├── project_name.xpr
            ├── project_name.cache/
            ├── project_name.hw/
            ├── project_name.sim/
            └── ...
    ```

 3. Initiate the git repository with `git init` on the Tcl Console. This will create the repository, automatically change to your project directory (`PROJECT_NAME`), generate the `.gitignore` file and stage it.

 4. Stage your source files with `git add`.

 5. When you are done, `git commit` your project. A `PROJECT_NAME.tcl` script will be created in your `PROJECT_NAME` folder and added to your commit.

 6. When opening the project after a cloning, do it by using `Tools -> Run Tcl Script...` and selecting the `PROJECT_NAME.tcl` file created earlier. This will regenerate the project so that you can continue working.
