################################################################################
#
# This file provides a basic wrapper to use git directly from the tcl console in
# Vivado.
# It requires the write_project_tcl_git.tcl script to work properly.
# Unversioned files will be put in the work/ folder
#
# Ricardo Barbedo
#
################################################################################

namespace eval ::git_wrapper {
    namespace export git
    namespace import ::custom::write_project_tcl_git
    namespace import ::current_project
    namespace import ::common::get_property

    proc git {args} {
        set command [lindex $args 0]

        switch $command {
            "init" {git_init {*}$args}
            "commit" {git_commit {*}$args}
            "default" {exec git {*}$args}
        }
    }

    proc git_init {args} {
        # Generate gitignore file
        set file [open ".gitignore" "w"]
        puts $file "work/*"
        close $file

        # Initialize the repo
        exec git {*}$args
    }

    proc git_commit {args} {
        # Get project name
        set proj_file [current_project].tcl

        # Generate project and add it
        write_project_tcl_git -no_copy_sources -force $proj_file
        puts $proj_file
        exec git add $proj_file

        # Now commit everything
        exec git {*}$args
    }
}