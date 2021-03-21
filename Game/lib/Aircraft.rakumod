#!/home/jf/rakudo/bin/perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Classe décrivant un avion dans l'As des As
#     Class to implement aircraft in Ace of Aces
#     Copyright (C) 2020, 2021 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;
use BSON::Document;
use JSON::Class;

class Aircraft does JSON::Class {
  has Str $.identity;
  has Str $.name;
  has Str $.side;
  has     @.pages;
  has     $.maneuvers;
  has Int $.hits;
}

=begin POD

=encoding utf8

=head1 NOM

Aircraft.rakumod -- class descibing an aircraft

=head1 DESCRIPTION

This class contains  the attributes necessary to play  I<Ace of Aces>:
the list  of maneuvers  with their characteristics  (speed, direction,
shoot), the list of transitions (start  page, maneuver) → end page and
the hit points capacity.

There are  also a  few decoration  attributes, such  as the  name, the
identity (name, but simplified and used as an access key) and the side
to which the aircraft belongs: C<G>  for "Good guys" and C<B> for "Bad
guys".

=head1 COPYRIGHT and LICENSE

Copyright 2020, 2021, Jean Forget, all rights reserved

This program  is published under  the same conditions as  Raku: the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read them at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
