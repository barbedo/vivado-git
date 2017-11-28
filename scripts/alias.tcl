# Aliases

# Interface
namespace eval ::alias {
    namespace export wproj
    namespace import ::custom_projutils::write_project_tcl_git
    namespace import ::current_project
    namespace import ::common::get_property
}

# Define
namespace eval ::alias {
    proc wproj {} {

        # Change directory project directory if not in it yet
        set proj_dir [regsub {\/vivado_project$} [get_property DIRECTORY [current_project]] {}]
        set current_dir [pwd]
        if {
            [string compare -nocase $proj_dir $current_dir]
        } then {
            puts "Not in project directory"
            puts "Changing directory to: ${proj_dir}"
            cd $proj_dir
        }

        # Generate project
        set proj_file [current_project].tcl
        puts $proj_file
        write_project_tcl_git -no_copy_sources -force $proj_file
    }
}
