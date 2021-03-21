#!/home/jf/rakudo/bin/perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#     Classe décrivant un pilote dans l'As des As
#     Class to implement pilots in Ace of Aces
#     Copyright (C) 2020, 2021 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;
use BSON::Document;
use JSON::Class;

class Pilot does JSON::Class {
  has Str $.identity;
  has Str $.name;
  has Str $.aircraft;
  has Num $.perspicacity;
  has Num $.stiffness;
  has Num $.hits;
  has     @.ref;
}

=begin POD

=encoding utf8

=head1 NOM

Pilot.rakumod -- class implementing a pilot

=head1 DESCRIPTION

This class provides  the attributes necessary to play  I<Ace of Aces>:
the aircraft that the pilot flies, his perspicacity (capability to see
through the  mists of time),  mental stiffness (propensity to  keep on
trodden paths  or capability to leave  them) and the list  of aircraft
and pilots he uses as an inspiration for his flying skills.

There are also  a few decorative attributes, such as  the pilot's name
and identity (simplified name used for access keys and for URLs).

=head1 COPYRIGHT and LICENSE

Copyright 2020, 2021, Jean Forget, all rights reserved

This program  is published under  the same conditions as  Raku: the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read them at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
