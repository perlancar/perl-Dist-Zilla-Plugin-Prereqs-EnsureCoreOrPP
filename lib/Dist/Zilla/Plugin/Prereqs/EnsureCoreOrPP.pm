package Dist::Zilla::Plugin::Prereqs::EnsureCoreOrPP;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Moose;
with 'Dist::Zilla::Role::AfterBuild';

use Module::XSOrPP qw(is_pp);
use namespace::autoclean;

sub after_build {
    my ($self) = @_;

    my $prereqs_hash = $self->zilla->prereqs->as_string_hash;
    my $rr_prereqs = $prereqs_hash->{runtime}{requires} // {};

    for my $mod (keys %$rr_prereqs) {

    }

    die;
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

Note: I put this plugin in after_build phase instead of before_release because
I don't always use "dzil release" (i.e. during offline deployment, I "dzil
build" and "pause upload" separately.)


=head1 SEE ALSO

L<App::FatPacker>, L<App::fatten>

L<Dist::Zilla::Plugin::Prereqs::EnsurePP>

Related plugins: L<Dist::Zilla::Plugin::CheckPrereqsIndexed>,
L<Dist::Zilla::Plugin::EnsurePrereqsInstalled>,
L<Dist::Zilla::Plugin::OnlyCorePrereqs>

L<App::lcpan>, L<lcpan>
