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

Project/Collections.pm -- Concrete project instance for collections.

=head1 DESCRIPTION

This module provides all project-specific configurations and methods for the
collections project.

=cut
package Project::Collections;

use strict;
use warnings;

use Constants;
use Vcs::Git;

our @ISA = qw(Project);
my $PID  = "Collections";

sub new {
    my $class = shift;
    my $work_dir = shift // "$SCRIPT_DIR/projects";
    my $name = "collections";
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
    my $src  = `grep "source.home" $dir/default.properties 2>/dev/null`;
    my $test = `grep "test.home\|source.test" $dir/default.properties 2>/dev/null`;

    # Check whether this layout applies to the checked-out version
    return undef if ($src eq "" || $test eq "");

    $src =~ s/\s*source.home\s*=\s*(\S+)\s*/$1/;
    $test=~ s/\s*test.home\s*=\s*(\S+)\s*/$1/ // s/\s*source.test\s*=\s*(\S+)\s*/$1/;

    return {src=>$src, test=>$test};
}

# Existing build.xml 
sub _layout2 {
    my $dir = shift;
    my $src  = "src/main/java";
    my $test = "src/test/java";
    
    #
    # Determine src and test directory and return hash
    # return {src=>$src, test=>$test};

    # Check whether this layout applies to the checked-out version
    #return undef if ($src eq "" || $test eq "");
    
    #$src =~ s/\s*source.home\s*=\s*(\S+)\s*/$1/;
    #$test=~ s/\s*test.home\s*=\s*(\S+)\s*/$1/ // s/\s*source.test\s*=\s*(\S+)\s*/$1/;
    
    return {src=>$src, test=>$test};
}

1;

=pod

=head1 SEE ALSO

F<Project.pm>

=cut
