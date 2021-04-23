#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Programme initialisant la base de données permettant de cartographier l'As des As
#     Program initialising the database containing a map for Ace of Aces
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
my MongoDB::Database   $database = $client.database('aoa_prep');
my MongoDB::Collection $pages    = $database.collection('Pages');
my MongoDB::Collection $manv     = $database.collection('Manoeuvres');

class Avion does JSON::Class {
  has     %.manoeuvres;
}

my $fic-init = 'fr/Drone-init.json';

my BSON::Document $result_supp = $database.run-command: (
  delete => 'Pages',
  deletes => [ (
      q => ( numero => ( '$gt' => 0), ),
      limit => 0,
    ),
  ],
);
say "suppression pages ok : ", $result_supp<ok>, " nb : ", $result_supp<n>;

$result_supp = $database.run-command: (
  delete => 'Manoeuvres',
  deletes => [ (
      q => ( code => ( '$gte' => 'A'), ),
      limit => 0,
    ),
  ],
);
say "suppression manœuvres ok : ", $result_supp<ok>, " nb : ", $result_supp<n>;


my BSON::Document $req .= new: (
  insert => 'Pages',
  documents => [ (
    numero    => 187,
    chemin_GM => ';0',
    chemin_MG => ';0',
    ), (
    numero => 223,
    ) ],
);
my BSON::Document $result = $database.run-command($req);
say "Création pages ok : ", $result<ok>, " nb : ", $result<n>;

my Avion $avion .= from-json(slurp $fic-init);
#$avion.say;
my @manoeuvres;
for $avion.manoeuvres.kv -> $code, $info {
  my BSON::Document $man .= new: ( code => $code, chemin => $info<chemin> );
  @manoeuvres.push( $man );
}
#@manoeuvres.say;

$req .= new: (
  insert => 'Manoeuvres',
  documents => [ @manoeuvres[*] ],
);
$result = $database.run-command($req);
say "Création manœuvres ok : ", $result<ok>, " nb : ", $result<n>;


=begin POD

=encoding utf8

=head1 NOM

init.p6 -- programme initialisant la base de données pour cartographier l'As des As

=head1 DESCRIPTION

Ce programme initialise la base MongoDB utilisée pour établir la cartographie
de l'As des As et, ultérieurement, générer les livrets de jeux

=head1 LANCEMENT

  perl6 init.p6

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
