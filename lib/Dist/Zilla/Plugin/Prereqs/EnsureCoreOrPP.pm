package Dist::Zilla::Plugin::Prereqs::EnsureCoreOrPP;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use warnings;

use Moose;
with 'Dist::Zilla::Role::InstallTool';

use App::lcpan::Call qw(call_lcpan_script);
use Module::CoreList::More;
use Module::Path::More qw(module_path);
use Module::XSOrPP qw(is_pp);
use namespace::autoclean;

sub setup_installer {
    my ($self) = @_;

    my $prereqs_hash = $self->zilla->prereqs->as_string_hash;
    my $rr_prereqs = $prereqs_hash->{runtime}{requires} // {};

    $self->log(["Listing prereqs ..."]);
    my $res = call_lcpan_script(argv=>[
        "deps", "-R",
        grep {$_ ne 'perl'} map {("--module", "$_")} keys %$rr_prereqs]);
    $self->log_fatal(["Can't lcpan deps: %s - %s", $res->[0], $res->[1]])
        unless $res->[0] == 200;
    my $has_err;
    for my $entry (@{$res->[2]}) {
        my $mod = $entry->{module};
        $mod =~ s/^\s+//;
        next if $mod eq 'perl';
        if (!module_path(module=>$mod)) {
            $self->log_fatal(["Prerequisite %s is not installed", $mod]);
        }
        if (!is_pp($mod) && !Module::CoreList::More->is_still_core($mod)) {
            $has_err++;
            $self->log(["Prerequisite %s is not PP nor core", $mod]);
        }
    }

    if ($has_err) {
        $self->log_fatal(["There are some errors in prerequisites"]);
    }
}

__PACKAGE__->meta->make_immutable;
1;
# ABSTRACT: Make sure that prereqs (and their deps) are all core/PP modules

=for Pod::Coverage .+

=head1 SYNOPSIS

In dist.ini:

 [Prereqs::EnsureCoreOrPP]


=head1 DESCRIPTION

This plugin will check that all RuntimeRequires prereqs (and all their recursive
RuntimeRequires deps) are all core/PP modules. To do this checking, all prereqs
must be installed during build time and they all must be indexed by CPAN. Also,
a reasonably fresh local CPAN mirror indexed (produced by L<App::lcpan>) is
required.

I need this when building a dist that needs to be included in a fatpacked
script.

Note: I put this plugin in setup_installer phase instead of before_release
because I don't always use "dzil release" (i.e. during offline deployment, I
"dzil build" and "pause upload" separately.)


=head1 SEE ALSO

L<App::FatPacker>, L<App::depak>

L<Dist::Zilla::Plugin::Prereqs::EnsureCore>

L<Dist::Zilla::Plugin::Prereqs::EnsurePP>

Related plugins: L<Dist::Zilla::Plugin::CheckPrereqsIndexed>,
L<Dist::Zilla::Plugin::EnsurePrereqsInstalled>,
L<Dist::Zilla::Plugin::OnlyCorePrereqs>

L<App::lcpan>, L<lcpan>
