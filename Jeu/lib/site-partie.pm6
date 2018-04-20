# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Module appelé par un programme Bailador pour afficher une partie de l'As des As
#     Module called by a Bailador program to display an "Ace of Aces" game
#     Copyright (C) 2018 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

unit module site-partie;

our sub affichage($dh) {
  return qq:to/EOF/;
  <html>
  <head>
  <title>
  Partie $dh
  </title>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  </head>
  <body>Partie {$dh} <br />L'avertissement traditionnel : site en travaux</body>
  </html>
  EOF
}


=begin POD

=encoding utf8

=head1 NOM

site-partie.pm6 -- module Bailador pour afficher une partie de l'As des As

=head1 DESCRIPTION

Ce programme génère un fichier HTML énumérant les coups successifs d'une partie de l'As des As.

=head1 COPYRIGHT et LICENCE

Copyright 2018, Jean Forget

Ce programme est diffusé avec les mêmes conditions que Perl 5.16.3 :
la licence publique GPL version 1 ou ultérieure, ou bien la
licence artistique Perl.

Vous pouvez trouver le texte en anglais de ces licences dans le
fichier <LICENSE> joint ou bien aux adresses
L<http://www.perlfoundation.org/artistic_license_1_0>
et L<http://www.gnu.org/licenses/gpl-1.0.html>.

Résumé en anglais de la GPL :

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 1, or (at your option)
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software Foundation,
Inc., L<http://www.fsf.org/>.

=end POD
