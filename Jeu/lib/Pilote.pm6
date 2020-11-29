#!/home/jf/rakudo/bin/perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#     Classe décrivant un pilote dans l'As des As
#     Class to implement pilots in Ace of Aces
#     Copyright (C) 2020 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;
use BSON::Document;
use JSON::Class;

class Pilote does JSON::Class {
  has Str $.id;
  has Str $.nom;
  has Str $.avion           is rw;
  has Num $.perspicacité    is rw;
  has Num $.psycho-rigidité is rw;
  has     @.ref             is rw;
}

=begin POD

=encoding utf8

=head1 NOM

Pilote.pm6 -- classe décrivant un pilote

=head1 DESCRIPTION

Cette classe contient  les attributs permettant de jouer  à S<l'As des
As :>  l'avion sur lequel vole  le pilote, sa perspicacité  (faculté à
voir à travers les brumes  du temps), sa psycho-rigidité (propension à
rester dans  les sentiers battus  ou à s'en  écarter) et la  liste des
avions ou pilotes dont il s'inspire pour sa maîtrise du combat aérien.

Il y a  également des attributs informatifs, comme le  nom en clair et
l'identité (nom simplifié servant de clé d'accès).

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
