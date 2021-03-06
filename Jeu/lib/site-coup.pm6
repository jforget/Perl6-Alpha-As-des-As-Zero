# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Module appelé par un programme Bailador pour afficher un coup dans une partie de l'As des As
#     Module called by a Bailador program to display a turn in an "Ace of Aces" game
#     Copyright (C) 2018, 2020 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use BSON::Document;

unit module site-coup;

our sub affichage(Str $dh, Int $tour, Str $id, BSON::Document $partie, @coup, @similaires, $pilote) {
  my BSON::Document $coup_1;   # coup affiché
  my BSON::Document $coup_2;   # coup suivant
  my BSON::Document $coup_e;   # coup de l'ennemi
  my BSON::Document $coup_f;   # coup suivant de l'ennemi

  my $dégâts;   # points de dégâts encaissés
  my $dégâts_e; # points de dégâts infligés à l'ennemi
  my $pot_2;    # potentiel au coup suivant
  my $pot_f;    # potentiel de l'ennemi au coup suivant

  for @coup -> BSON::Document $coup {
    if $coup<tour> == $tour && $coup<identité> eq $id {
      $coup_1 = $coup;
    }
    elsif  $coup<identité> eq $id {
      $coup_2 = $coup;
      $pot_2  = $coup<potentiel>;
    }
    elsif $coup<tour> == $tour {
      $coup_e = $coup;
    }
    else {
      $coup_f = $coup;
      $pot_f  = $coup<potentiel>;
    }
  }

  if $id eq $partie<gentil> {
    $pot_2 //= $partie<capacité_g> // 0;
    $pot_f //= $partie<capacité_m> // 0;
  }
  else {
    $pot_f //= $partie<capacité_g> // 0;
    $pot_2 //= $partie<capacité_m> // 0;
  }

  $dégâts   = $coup_1<potentiel> - $pot_2;
  $dégâts_e = $coup_e<potentiel> - $pot_f;

  my Str $tirage = '';
  if $coup_1<tirage>:exists {
    $tirage = " (tirage $coup_1<tirage>)";
  }

  my Num $perspicacité;
  my Num $psycho-rigidité;
  my Str $qualificatif;
  if defined $pilote {
    $perspicacité    = $pilote.perspicacité;
    $psycho-rigidité = $pilote.psycho-rigidité;
    $qualificatif    = ''
  }
  else {
    $perspicacité    = (-1).exp.round(0.001).Num;
    $psycho-rigidité =    1.exp.round(0.001).Num;
    $qualificatif    = '(simulée)'
  }
  my @critères;
  my %note_manoeuvre;
  for $coup_1<choix>[*] -> $man {
    %note_manoeuvre{$man} = 0;
  }

  @similaires ==> grep { $_<manoeuvre>:exists } \
              ==> sort { $^a<manoeuvre> leg $^b<manoeuvre> } \
              ==> my @simil;
  my $cumul = 0;
  my $manoeuvre-précédente = '';
  for @simil -> BSON::Document $sim {
    next unless $sim<manoeuvre>:exists;
    
    my $résultat = $sim<résultat> // '';
    my $délai    = $sim<délai>    // '';

    if $sim<manoeuvre> ne $manoeuvre-précédente {
      $cumul = 0;
      $manoeuvre-précédente = $sim<manoeuvre>;
    }

    my $note;
    my Str $note_aff;
    my Str $cumul_aff;
    if $résultat && $délai {
      $note   = $résultat × $perspicacité ** $délai;
      $cumul += $note;
      $note_aff  = sprintf('%.4g', $note);
      if %note_manoeuvre{$sim<manoeuvre>}:exists {
        %note_manoeuvre{$sim<manoeuvre>} = $cumul;
      }
    }
    else {
      $note_aff = '';
    }
    $cumul_aff = sprintf('%.4g', $cumul);
    my $l = qq:to/EOF/;
    <tr><td><a href='/partie/{$sim<date-heure>}'>{$sim<date-heure>}</a></td>
        <td align='center'><a href='/coup/{$sim<date-heure>}/{$sim<tour>}/{$sim<identité>}'> $sim<tour> </a></td>
        <td align='center'> $sim<manoeuvre> </td>
        <td align='center'> $résultat       </td>
        <td align='center'> $délai          </td>
        <td align='center'> $note_aff       </td>
        <td align='center'> $cumul_aff      </td></tr>
    EOF
    @critères.push($l);
  }
  my $critères = join "\n", @critères;

  my @manoeuvres = %note_manoeuvre.keys.sort;
  my @notes = %note_manoeuvre{ @manoeuvres };
  my @coef = $psycho-rigidité «**» @notes;
  my @prob = @coef «/» ([+] @coef);
  my @rép  = [\+] @prob;
  my @choix;
  for @manoeuvres.kv -> $i, $man {
    my $coef = @coef[$i];
    my $note_aff = sprintf("%.4g", %note_manoeuvre{$man});
    my $coef_aff = sprintf("%.4g", @coef[$i]);
    my $prob_aff = sprintf("%.4g", @prob[$i]);
    my $rép_aff  = sprintf("%.4g", @rép[ $i]);
    my $l = "<tr><td> $man </td><td> $note_aff </td><td> $coef_aff </td><td> $prob_aff </td><td> $rép_aff </td></tr>";
    @choix.push($l);
  }
  my $choix = join "\n", @choix;

  return qq:to/EOF/;
  <html>
  <head>
  <title>
  Coup $dh $tour $id
  </title>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  </head>
  <body>
  <p><a href='/'>Liste des parties</a> <a href='/liste/$dh'>depuis la partie courante</a> <a href='/partie/$dh'>partie courante</a>
  </p>
  <h2>Coup $dh $tour $id </h2>
  <p>Page de départ $coup_1<page> </a>
  <p>Manœuvre de $coup_1<identité>&nbsp;: $coup_1<manoeuvre>$tirage, de $coup_e<identité>&nbsp;: $coup_e<manoeuvre> </p>
  <p>Page d'arrivée $coup_2<page> </a>
  <p>Dégâts encaissés&nbsp;: $dégâts sur $id ($coup_1<potentiel> -&gt; $pot_2), $dégâts_e sur $coup_e<identité>  ($coup_e<potentiel> -&gt; $pot_f)</p>
  <h2>Choix</h2>
  <p>Psycho-rigidité $qualificatif : $psycho-rigidité </p>
  <table>
  <tr><th>Manœuvre</th><th>Note</th><th>Coefficient</th><th>Probabilité</th><th>Répartition</th><tr>
  $choix
  </table>
  <h2>Critères</h2>
  <p>Perspicacité $qualificatif : $perspicacité </p>
  <table>
  <tr><th>Partie</th><th>Tour</th><th>Manœuvre</th><th>Résultat</th><th>Délai</th><th>Note</th><th>Note cumulée</th></tr>
  $critères
  </table>
  </body>
  </html>
  EOF
}


=begin POD

=encoding utf8

=head1 NOM

site-coup.pm6 -- module Bailador pour afficher un coup dans une partie de l'As des As

=head1 DESCRIPTION

Ce programme génère un fichier HTML détaillant un coup d'une partie de l'As des As.

=head1 COPYRIGHT et LICENCE

Copyright (c) 2018, 2020 Jean Forget

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
