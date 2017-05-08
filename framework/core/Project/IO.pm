#-------------------------------------------------------------------------------
# Copyright (c) 2014-2015 René Just, Darioush Jalali, and Defects4J contributors.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#-------------------------------------------------------------------------------

=pod

=head1 NAME

Project/IO.pm -- Concrete project instance for commons-io.

=head1 DESCRIPTION

This module provides all project-specific configurations and methods for the
commons-io project.

=cut
package Project::IO;

use strict;
use warnings;

use Constants;
use Vcs::Git;
use XML::Twig::XPath; 

our @ISA = qw(Project);
my $PID  = "IO";

sub new {
    my $class = shift;
    my $work_dir = shift // "$SCRIPT_DIR/projects";
    my $name = "commons-io";
    my $vcs  = Vcs::Git->new($PID,
                             "$REPO_DIR/$name.git",
                             "$work_dir/$PID/commit-db",
                             \&_post_checkout);

    return $class->SUPER::new($PID, $name, $vcs, $work_dir);
}

#
# Determine the project layout for the checked-out version.
#
sub determine_layout {
    @_ == 2 or die $ARG_ERROR;
    my ($self, $revision_id) = @_;
    my $dir = $self->{prog_root};

    # Add additional layouts if necessary
    my $result = _layout1($dir) // _layout2($dir);
    die "Unknown layout for revision: ${revision_id}" unless defined $result;
    return $result;
}

sub _post_checkout {
    my ($vcs, $revision, $work_dir) = @_;
    my $name = $vcs->{prog_name};

    #
    # Post-checkout tasks include, for instance, providing proper build files,
    # fixing compilation errors, etc.
    #
}

#
# Distinguish between project layouts and determine src and test directories.
# Each _layout subroutine returns undef if it doesn't match the layout of the
# checked-out version. Otherwise, it returns a hash that provides the src and
# test directory, relative to the working directory.
#

# Existing build.xml and default.properties
sub _layout1 {
    my $dir = shift;
    my $src  = `grep "source.home" $dir/project.properties 2>/dev/null`;
    my $test = `grep "test.home" $dir/project.properties 2>/dev/null`;

    # Check whether this layout applies to the checked-out version
    return undef if ($src eq "" || $test eq "");

    $src =~ s/\s*source.home\s*=\s*(\S+)\s*/$1/;
    $test=~ s/\s*test.home\s*=\s*(\S+)\s*/$1/;

    return {src=>$src, test=>$test};
}

# Another project layout goes here
sub _layout2 {
    my $dir = shift;
    my $twig= new XML::Twig();
    $twig->parsefile("$dir/build.xml");
    my $src; 
    my $test;
    my $prop;  
    my $name=""; 
    foreach $prop ($twig->root()->children('property')) {
        $name = $prop->att('name'); 
        if ($name eq "source.home") {
            $src = $prop->att('value'); 
        }
    }
    foreach $prop ($twig->root()->children('property')) {
        $name = $prop->att('name');
        if ($name eq "test.home") {
            $test = $prop->att('value'); 
        }
    }

    if ($src eq "") {
        $src = "src/java"
    }
    if ($test eq "") {
        $test = "src/test"
    }

    # Check whether this layout applies to the checked-out version
    return undef if ($src eq "" || $test eq "");

    return {src=>$src, test=>$test};
}


1;

=pod

=head1 SEE ALSO

F<Project.pm>

=cut
