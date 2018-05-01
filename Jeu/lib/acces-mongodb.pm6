#!/home/jf/rakudo-star-2018.01/bin/perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#     Accès à MongoDB pour l'As des As
#     Access to the Ace of Aces MongoDB database
#     Copyright (C) 2018 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

unit module acces-mongodb;

use v6;
use BSON::Document;
use MongoDB::Client;
use MongoDB::Database;
use MongoDB::Collection;
use JSON::Class;

my MongoDB::Client     $client  .= new(:uri('mongodb://'));
my MongoDB::Database   $database = $client.database('Ace_of_Aces');
my MongoDB::Collection $coups    = $database.collection('Coups');
my MongoDB::Collection $parties  = $database.collection('Parties');


our sub liste-parties($dh) {
  my @liste;
  my MongoDB::Cursor $cursor = $parties.find(
      criteria   => ( 'date-heure' => ( '$gt' => $dh, ),
                       ),
      projection => ( _id => 0, )
    );
  while $cursor.fetch -> BSON::Document $d {
    @liste.push($d);
  }
  return @liste;
}

sub écrire-coup(BSON::Document $coup) {
  my BSON::Document $req .= new: (
    insert => 'Coups',
    documents => [ $coup ],
  );
  my BSON::Document $result = $database.run-command($req);
  #say "Création coup ok : ", $result<ok>, " nb : ", $result<n>;

}

sub écrire-partie(BSON::Document $partie) {
  my BSON::Document $req .= new: (
    insert => 'Parties',
    documents => [ $partie ],
  );
  my BSON::Document $result = $database.run-command($req);
  #say "Création partie ok : ", $result<ok>, " nb : ", $result<n>;
}


=begin POD

=encoding utf8

=head1 NOM

acces-mongodb.pm6 -- module regroupant les fonctions d'accès à MongoDB

=head1 DESCRIPTION

Ce module regroupe les fonctions d'accès à MongoDB pour lire les parties
et les coups de l'As des As et les mettre à jour.

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
