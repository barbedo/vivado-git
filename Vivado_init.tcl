set init_dir [file dirname [info script]]

source $init_dir/scripts/write_project_tcl_git.tcl
namespace import ::custom::write_project_tcl_git

source $init_dir/scripts/git_wrapper.tcl
namespace import ::git_wrapper::git

source $init_dir/scripts/alias.tcl
namespace import ::alias::wproj
