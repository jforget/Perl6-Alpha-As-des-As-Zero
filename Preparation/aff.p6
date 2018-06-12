#!/home/jf/rakudo-star-2018.01/bin/perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Programme affichant la cartographie partielle de l'As des As en HTML
#     Program displaying the partial map of Ace of Aces as an HTML file
#     Copyright (C) 2018 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#
use v6;
use BSON::Document;
use MongoDB::Client;
use MongoDB::Database;
use MongoDB::Collection;
use JSON::Class;

class Avion does JSON::Class {
  has %.manoeuvres;
}

my $fic-init     = 'Drone-init.json';
my Avion $avion .= from-json(slurp $fic-init);
my @manoeuvres   = $avion.manoeuvres.keys.sort;

my MongoDB::Client     $client  .= new(:uri('mongodb://'));
my MongoDB::Database   $database = $client.database('aoa_prep');
my MongoDB::Collection $pages    = $database.collection('Pages');

my MongoDB::Cursor $cursor = $pages.find( projection => ( _id => 0, ) );

my @pages;
while $cursor.fetch -> BSON::Document $d {
  #@pages.push( { numero => $d<numero>, chemin => $d<chemin> } );
  @pages.push(  $d  );
  #say $d<numero>;
}

print q:to/EOF/;
<html>
<head>
<title>Pages</title>
<style>
<!--
.certain { background-color: lightgreen }
.hypoth  { background-color: yellow }
.inconnu { background-color: pink }
-->
</style>
</head>
<body>
<table border='1'>
EOF

for (sort { $^a<numero> <=> $^b<numero> }, @pages) -> $d {
  print "<tr><td>", $d<numero>, "</td>";
  if $d<numero> != 223 {
    print "<td>", $d<chemin_GM> // '??', "</td>";
    print "<td>", $d<chemin_MG> // '??', "</td>";
    for @manoeuvres -> $manv {
      print case($manv, $d{$manv});
    }
  }
  say "</tr>";
}

print q:to/EOF/;
</table>
</body>
</html>
EOF

sub case {
  my ($k, $v) = @_;
  my @style = <inconnu hypoth certain>;
  my $style = @style[+($v<certain> // 0)];
  return "<td class='$style'>$k ", $v<numero> // '??', "</td>";
}


=begin POD

=encoding utf8

=head1 NOM

aff.p6 -- programme affichant les pagess de l'As des As pendant la construction de la cartographie

=head1 DESCRIPTION

Ce programme affiche le contenu de la base MongoDB dans laquelle on est en train d'alimenter
la cartographiede de l'As des As.

=head1 LANCEMENT

  perl6 aff.p6 > carte.html

=head2 Paramètres

Aucun paramètre

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
