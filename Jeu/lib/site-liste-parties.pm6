# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Serveur web permettant de consulter la base MongoDB des parties de l'As des As
#     Web server to display the MongoDB database where Ace of Aces games are stored
#     Copyright (C) 2018 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

unit module site-liste-parties;

our sub affichage {
  return q:to/EOF/;
  <html>
  <head><title>Liste des parties</title></head>
  <body>L'excuse habituelle : site en travaux</body>
  </html>
  EOF
}


=begin POD

=encoding utf8

=head1 NOM

site-liste-parties.pm6 -- module Bailador pour afficher la liste des parties de l'As des As

=head1 DESCRIPTION

Ce programme génère un fichier HTML énumérant les parties de l'As des As stockées en base de données.

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
