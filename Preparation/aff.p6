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
use lib '.';
use BSON::Document;
use MongoDB::Client;
use MongoDB::Database;
use MongoDB::Collection;
use Depl;

my MongoDB::Client     $client  .= new(:uri('mongodb://'));
my MongoDB::Database   $database = $client.database('aoa_prep');
my MongoDB::Collection $pages    = $database.collection('Pages');
my MongoDB::Collection $manv     = $database.collection('Manoeuvres');

my MongoDB::Cursor $cursor = $manv.find( projection => ( _id => 0, ) );
my @manoeuvres;
while $cursor.fetch -> BSON::Document $d {
  @manoeuvres.push(  $d<code>  );
}
@manoeuvres .= sort;

my Str @dessin = dessin().split("\n");

$cursor = $pages.find( projection => ( _id => 0, ) );
my @pages;
while $cursor.fetch -> BSON::Document $d {
  @pages.push(  $d  );
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

my @dx-virage = ( 0,  3, 3, 0, -3, -3); # écart par rapport au centre de l'hexagone en fonction du cap
my @dy-virage = (-2, -1, 1, 2,  1, -1); # idem en hauteur
my @dx-chemin = 3 «×» @dx-virage; # écart par rapport à l'hexagone central en fonction du déplacement élémentaire
my @dy-chemin = 3 «×» @dy-virage; # idem en hauteur
my @attributs;

for (sort { $^a<numero> <=> $^b<numero> }, @pages) -> $d {
  print "<tr><td>", $d<numero>, "</td>";
  if $d<numero> != 223 {
    print "<td>", $d<chemin_GM> // '??', "</td>";
    print "<td>", $d<chemin_MG> // '??', "</td>";
    my $attribut = 'certain';
    my $num_min  = 3;
    for @manoeuvres -> $manv {
      my ($case, $attr, $num) = case($manv, $d{$manv});
      print $case;
      if $num < $num_min {
        $num_min  = $num;
        $attribut = $attr;
      }
    }
    my Depl $depl .= new(chemin => $d<chemin_GM>);
    my $x = 37 + @dx-virage[$depl.virage] + [+] @dx-chemin «×» $depl.avance;
    my $y = 21 + @dy-virage[$depl.virage] + [+] @dy-chemin «×» $depl.avance;
    my $etiquette;
    if $d<numero> < 10 {
      $etiquette = sprintf(" %d ", $d<numero>);
    }
    else {
      $etiquette = sprintf("%3d", $d<numero>);
    }
    
    @dessin[$y].substr-rw($x, 3) = $etiquette;
    @attributs.push([$x, $y, $attribut]);
  }
  say "</tr>";
}

# Coloriage des numéros de page dans la carte en fonction de leur certitude
for (sort { -$_[0] }, @attributs) -> $triplet {
  my ($x, $y, $attr) = $triplet[*];
  @dessin[$y].substr-rw($x + 3, 0) = '</span>';
  @dessin[$y].substr-rw($x    , 0) = "<span class='$attr'>";
}

my $dessin = @dessin.join("\n");
print qq:to/EOF/;
</table>
<pre>
$dessin
</pre>
</body>
</html>
EOF

sub case {
  my ($k, $v)   = @_;
  my @style     = <inconnu hypoth certain>;
  my $num_style = +($v<certain> // 0);
  my $style     = @style[$num_style];
  return ("<td class='$style'>$k ", $v<numero> // '??', "</td>"), $style, $num_style;
}

sub dessin {
  return q:to/EOF/;
  .                                  -------
  .                                 /       \
  .                                /         \
  .                        --------           --------
  .                       /        \         /        \
  .                      /          \       /          \
  .               -------            -------            -------
  .              /       \          /       \          /       \
  .             /         \        /         \        /         \
  .     --------           --------           --------           --------
  .    /        \         /        \         /        \         /        \
  .   /          \       /          \       /          \       /          \
  .  (            -------            -------            -------            )
  .   \          /       \          /       \          /       \          /
  .    \        /         \        /         \        /         \        /
  .     --------           --------           --------           --------
  .    /        \         /        \         /        \         /        \
  .   /          \       /          \       /          \       /          \
  .  (            -------            -------            -------            )
  .   \          /       \          /       \          /       \          /
  .    \        /         \        /         \        /         \        /
  .     --------           --------           --------           --------
  .    /        \         /        \         /        \         /        \
  .   /          \       /          \       /          \       /          \
  .  (            -------            -------            -------            )
  .   \          /       \          /       \          /       \          /
  .    \        /         \        /         \        /         \        /
  .     --------           --------           --------           --------
  .    /        \         /        \         /        \         /        \
  .   /          \       /          \       /          \       /          \
  .  (            -------            -------            -------            )
  .   \          /       \          /       \          /       \          /
  .    \        /         \        /         \        /         \        /
  .     --------           --------           --------           --------
  .             \         /        \         /        \         /
  .              \       /          \       /          \       /
  .               -------            -------            -------
  .                      \          /       \          /
  .                       \        /         \        /
  .                        --------           --------
  .                                \         /
  .                                 \       /
  .                                  -------
  EOF
}

=begin POD

=encoding utf8

=head1 NOM

aff.p6 -- programme affichant les pages de l'As des As pendant la construction de la cartographie

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
