# vivado-git

Trying to make Vivado more git-friendly on Windows.

### Requirements

[Git for Windows.](https://git-scm.com/download/win)

### Installation

Append/replace/add `init.tcl` and the `scripts` directory to `%APPDATA%\Roaming\Xilinx\Vivado`.

### How it works

Vivado is a pain in the ass to source control decently, so these scripts provide:

  - A modified `write_project_tcl_git` script to generate a project generator script without absolute paths.

  - A git wrapper that will regenerate the project script and add it before commiting.

### Workflow

When first starting with a project, create it at a folder like `C:/.../PROJECT_NAME/work`. All the untracked files will be under this directory.

Place your source files anywhere you want in your project folder.

Then go to your project directory using the Tcl Console with `cd C:/.../PROJECT_NAME` before adding or committing you files.

When you are done, just add your files and `git commit` your project. A `PROJECT_NAME.tcl` script will be created in your `PROJECT_NAME` folder and added to your commit.

When reopening the project, make sure to do it by using `Tools -> Run Tcl Script...`. The Tcl Console will change the directory to your project folder automatically.