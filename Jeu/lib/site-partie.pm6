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

our sub affichage($dh, $partie, @coups) {
  my $liste-coups = '';
  my $format = q:to/EOF/;
  <tr><td align='right'>%3d</td>
      <td align='center'>%s</td>
      <td align='center'>%d</td>
      <td>%s</td>
      <td align='center'>%d</td>
      <td>%s</td>
      <td align='center'>%s</td></tr>
  EOF

  my $gentil  = $partie<gentil>;
  my $méchant = $partie<méchant>;
  my @coups_g;
  my @coups_m;
  for @coups -> $coup {
    if $coup<identité> eq $gentil {
      @coups_g[$coup<tour>] = $coup;
    }
    else {
      @coups_m[$coup<tour>] = $coup;
    }
  }
  for 1..$partie<nb_coups> -> $n {
    my $coup_g = @coups_g[$n];
    my $coup_m = @coups_m[$n];
    my $page_d = min($coup_g<page>, $coup_m<page>); # min pour remplacer, par exemple, 1G par 1
    my $man_g  = $coup_g<manoeuvre> // ''; # vide pour le coup final
    my $man_m  = $coup_m<manoeuvre> // '';
    my $pot_g  = $coup_g<potentiel> // $partie<capacité_g> // 0;
    my $pot_m  = $coup_m<potentiel> // $partie<capacité_m> // 0;
    my $page_a = '';
    if $coup_g<page> ~~ /(<[ADG]>)$/ {
      $man_g = "($0) $man_g";
      $man_m =  "(T) $man_m";
    }
    if $coup_m<page> ~~ /(<[ADG]>)$/ {
      $man_m = "($0) $man_m";
      $man_g =  "(T) $man_g";
    }

    if $man_g ne '' {
      $man_g = "<a href='/coup/$dh/$n/$gentil'>{$man_g}</a>";
    }
    if $man_m ne '' {
      $man_m = "<a href='/coup/$dh/$n/$méchant'>{$man_m}</a>";
    }

    if $n != $partie<nb_coups> {
      $page_a = min(@coups_g[$n+1]<page>, @coups_m[$n + 1]<page>);
    }
    $liste-coups ~= sprintf $format, $n, $page_d, + $pot_g, $man_g, + $pot_m, $man_m, $page_a;
  }
  return qq:to/EOF/;
  <html>
  <head>
  <title>
  Partie $dh
  </title>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  </head>
  <body>
  <p><a href='/'>Liste des parties</a> <a href='/liste/$dh'>depuis la partie courante</a>
  </p>
  <h2>Partie {$dh}</h2>
  <table border='1'>
  <tr><th>Tour</th><th>Page de départ</th><th colspan='2'>{$gentil}     </th><th colspan='2'>{$méchant}    </th><th>Page d'arrivée</th></tr>
  <tr><th>    </th><th>              </th><th>Potentiel</th><th>Manœuvre</th><th>Potentiel</th><th>Manœuvre</th><th>              </th></tr>
  $liste-coups
  </table>
  </body>
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
