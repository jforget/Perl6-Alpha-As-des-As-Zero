#!/home/jf/rakudo-star-2018.01/bin/perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Programme autodidacte pour jouer à l'As des As
#     Self-learning program to play Ace of Aces
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

my MongoDB::Client     $client  .= new(:uri('mongodb://'));
my MongoDB::Database   $database = $client.database('Ace_of_Aces');
my MongoDB::Collection $coups    = $database.collection('Coups');

class Pilote does JSON::Class {
  has Str $.id;
  has Str $.nom;
  has Str $.avion           is rw;
  has Num $.perspicacité    is rw;
  has Num $.psycho-rigidité is rw;
  has     @.ref             is rw;
}

class Avion does JSON::Class {
  has Str $.id;
  has Str $.nom;
}
sub MAIN (Str :$date-heure, Str :$identité) {
  say "Combat de $identité";
  say "Référence $date-heure";
  my Pilote $pilote .= from-json(slurp "$identité.json");
  my Avion  $avion;
  if $pilote.avion {
    # véritable pilote
    $avion .= from-json(slurp "{$pilote.avion}.json");
  }
  else {
    # pilote anonyme, on ne connaît que l'avion
    # également, c'est pour l'entraînement
    $avion .= from-json(slurp "$identité.json");
    $pilote.perspicacité    = 0.Num;
    $pilote.psycho-rigidité = 1.Num;
    $pilote.avion           = $identité;
  }
  say "combat de ", $pilote.nom, " sur ", $pilote.avion, " perspicacité ", $pilote.perspicacité, ", psycho-rigidité ", $pilote.psycho-rigidité;
  my Bool $on_joue = True;
  my Int  $numéro_coup = 1;

  # Partie proprement dite
  while $on_joue {
    my BSON::Document $coup = lire_coup($date-heure, $identité, $numéro_coup);
    #say $coup.perl;
    if $coup<fini> {
      retour_d'expérience($date-heure, $identité, $numéro_coup, $coup<résultat>);
      last;
    }
    my $choix = $coup<choix>;
    $coup<manoeuvre> = $choix.pick;
    maj_coup($coup);
    ++ $numéro_coup;
  }
}

# Retour d'expérience
sub retour_d'expérience($dh, $id, $n_c, $res) {
  for 1..^$n_c -> $n {
say "retour  d'expérience sur ", $n;
    my BSON::Document $coup = lire_coup($dh, $id, $n);
    $coup<résultat> = $res;
    $coup<délai>    = $n_c - $n;
    $coup<dh2>      = DateTime.now.Str;
    maj_coup($coup);
  }

}

sub lire_coup ($dh, $id, $n) {
  my BSON::Document $coup;

  my $tentative_max = 50;
  my $tentative     =  0;
SONDER:
  while $tentative ≤ $tentative_max {
    ++ $tentative;
    my MongoDB::Cursor $cursor = $coups.find(
      criteria   => ( 'date-heure' => $dh,
                      'identité'   => $id,
                      'numéro'     => +$n, ),
      projection => ( _id => 0, )
    );
    while $cursor.fetch -> BSON::Document $d {
      #say $d.perl;
      if $d<numéro> == $n {
        $coup = $d;
        last SONDER;
      }
    }
    $cursor.kill;
    sleep 1;
  }
  if $tentative ≥ $tentative_max {
    die "Plus de réponse de l'arbitre, on arrête";
  }

  return $coup;
}

sub maj_coup(BSON::Document $coup) {
   my BSON::Document $req .= new: (
    update => 'Coups',
    updates => [ (
        q =>  ( 'date-heure' =>  $coup<date-heure>,
                'identité'   =>  $coup<identité>,
                'numéro'     => +$coup<numéro>, ),
        u => $coup,
      ),
    ],
  );
  my BSON::Document $doc = $database.run-command($req);
  if $doc<ok> == 0 {
    say "update ok : ", $doc<ok>, " nb : ", $doc<n>;
  }
}

=begin POD

=encoding utf8

=head1 NOM

joueur.p6 -- programme auto-didacte pour jouer à l'As des As

=head1 DESCRIPTION

Ce programme communique avec un programme arbitre pour jouer à l'As des As
et mémorise le résultat de ses parties dans une base MongoDB pour pouvoir
tirer partie de ses expériences, bonnes ou mauvaises, dans les parties ultérieures.

=head1 LANCEMENT

  perl6 joueur.p6 --date-heure=2018-04-04_21-42-10 --identité=Kevin &

=head2 Paramètres

=item date-heure

Date et heure de début de la partie, sert de clé unique pour la partie et
pour tous les coups de cette partie.

=item identité

Nom du joueur simulé, associé à un fichier JSON donnant les caractéristiques de ce joueur.


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
