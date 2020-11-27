#!/home/jf/rakudo/bin/perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Classe décrivant un avion dans l'As des As
#     Class to implement aircraft in Ace of Aces
#     Copyright (C) 2020 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;
use BSON::Document;
use JSON::Class;

class Avion does JSON::Class {
  has     $.identité;
  has     $.nom;
  has     $.camp;
  has     @.pages;
  has     $.manoeuvres;
  has Int $.capacité;
}

=begin POD

=encoding utf8

=head1 NOM

Avion.pm6 -- classe décrivant un avion

=head1 DESCRIPTION

Cette classe contient  les attributs permettant de jouer  à S<l'As des
As  :> la  liste  des manœuvres  et  leurs caractéristiques  (vitesse,
direction, tir), la liste des  transitions (page de début, manœuvre) →
page de fin et la capacité en points de dégâts.

Il y  a également des  attributs informatifs,  comme le nom  en clair,
l'identité  (nom simplifié  servant de  clé d'accès)  et le  camp dans
lequel  se  trouve  l'avion  (C<G>   pour S<« gentil »>,   C<M>   pour
S<« méchant »>).

=head1 COPYRIGHT et LICENCE

Copyright 2020, Jean Forget

Ce programme est  diffusé avec les mêmes conditions que  Perl 5.16.3 :
la licence  publique GPL version 1  ou ultérieure, ou bien  la licence
artistique Perl.

Vous  pouvez trouver  le  texte en  anglais de  ces  licences dans  le
fichier <LICENSE> joint ou bien aux adresses suivantes :

  L<http://www.perlfoundation.org/artistic_license_1_0>
  L<http://www.gnu.org/licenses/gpl-1.0.html>.

Résumé en anglais de la GPL :

This program is  free software; you can redistribute  it and/or modify
it under the  terms of the GNU General Public  License as published by
the Free  Software Foundation; either  version 1, or (at  your option)
any later version.

This program  is distributed in the  hope that it will  be useful, but
WITHOUT   ANY  WARRANTY;   without  even   the  implied   warranty  of
MERCHANTABILITY  or FITNESS  FOR  A PARTICULAR  PURPOSE.  See the  GNU
General Public License for more details.

You should  have received  a copy  of the  GNU General  Public License
along  with  this  program;  if   not,  write  to  the  Free  Software
Foundation, Inc., L<http://www.fsf.org/>.

=end POD
