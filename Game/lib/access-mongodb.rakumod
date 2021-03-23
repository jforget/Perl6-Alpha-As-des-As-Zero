#!/home/jf/rakudo/bin/perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#     Accès à MongoDB pour l'As des As
#     Access to the Ace of Aces MongoDB database
#     Copyright (C) 2018, 2020, 2021 Jean Forget, all rights reserved
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

unit module access-mongodb;

#use v6;
use BSON::Document;
use MongoDB::Client;
use MongoDB::Database;
use MongoDB::Collection;
use JSON::Class;

my MongoDB::Client     $client  .= new(:uri('mongodb://'));
my MongoDB::Database   $database = $client.database('Ace_of_Aces');
my MongoDB::Collection $turns    = $database.collection('Turns');
my MongoDB::Collection $games    = $database.collection('Games');
my MongoDB::Collection $pilots   = $database.collection('Pilots');
my MongoDB::Collection $aircraft = $database.collection('Aircraft');

our sub game($dh) {
  my $result;
  my MongoDB::Cursor $cursor = $games.find(
      criteria   => ( 'date-heure' => $dh,
                       ),
      projection => ( _id => 0, )
    );
  while $cursor.fetch -> BSON::Document $d {
    $result = $d;
  }
  return $result;
}

our sub pilot(Str $id) {
  my $result;
  my MongoDB::Cursor $cursor = $pilots.find(
      criteria   => ( 'identity' => $id,
                       ),
      projection => ( _id => 0, )
    );
  while $cursor.fetch -> BSON::Document $d {
    $result = $d;
  }
  return $result;
}

our sub aircraft(Str $id) {
  my $result;
  my MongoDB::Cursor $cursor = $aircraft.find(
      criteria   => ( 'identity' => $id,
                       ),
      projection => ( _id => 0, )
    );
  while $cursor.fetch -> BSON::Document $d {
    $result = $d;
  }
  return $result;
}

our sub list-games($dh) {
  my @liste;
  my MongoDB::Cursor $cursor = $games.find(
      criteria   => ( 'date-heure' => ( '$gte' => $dh, ),
                       ),
      projection => ( _id => 0, )
    );
  while $cursor.fetch -> BSON::Document $d {
    @liste.push($d);
  }
  return @liste;
}

# List of all turns from a game
our sub turns-of-game($dh) {
  my @liste;
  my MongoDB::Cursor $cursor = $turns.find(
      criteria   => ( 'date-heure' => $dh,
                       ),
      projection => ( _id => 0, )
    );
  while $cursor.fetch -> BSON::Document $d {
    @liste.push($d);
  }
  return @liste;
}

# List of all turns from a start page
our sub turns-of-page(Str $page, @id, Str $dh) {
  my @liste;

  my MongoDB::Cursor $cursor = $turns.find(
      criteria   => ( 'page'       => $page,
                      'identity'   => ( '$in' => [ @id ] ),
                      'date-heure' => ( '$lt' =>  $dh ),
                      'fini'       => ( '$ne' => 1 ),
                       ),
      projection => ( _id => 0, )
    );
  while $cursor.fetch -> BSON::Document $d {
    @liste.push($d);
  }
  return @liste;
}

# Turn for a given game, a given player and a given number
our sub turn-game($dh, Int $num, $id) {
  my @liste;
  my $result;
  my MongoDB::Cursor $cursor = $turns.find(
      criteria   => ( 'date-heure' => $dh,
                      'tour'       => $num,
                      'identity'   => $id,
                       ),
      projection => ( _id => 0, )
    );
  while $cursor.fetch -> BSON::Document $d {
    $result = $d;
  }
  return $result;
}

# Turns for a given game, both players and a given number plus the next number
our sub turn4($dh, Int $num, $id) {
  my @liste;
  my $result;
  my MongoDB::Cursor $cursor = $turns.find(
      criteria   => ( 'date-heure' => $dh,
                      'tour'       => ( '$in' => [ $num, $num + 1 ] ),
                       ),
      projection => ( _id => 0, )
    );
  while $cursor.fetch -> BSON::Document $d {
    @liste.push($d);
  }
  return @liste;
}

our sub write-turn(BSON::Document $turn) {
  my BSON::Document $req .= new: (
    insert    => 'Turns',
    documents => [ $turn ],
  );
  my BSON::Document $result = $database.run-command($req);
  #say "Création turn ok : ", $result<ok>, " nb : ", $result<n>;

}

our sub write-pilot(BSON::Document $pilot) {
  my BSON::Document $req .= new: (
    insert    => 'Pilots',
    documents => [ $pilot ],
  );
  my BSON::Document $result = $database.run-command($req);
  say "Creation pilot ok : ", $result<ok>, " nb : ", $result<n>;
}

our sub write-aircraft(BSON::Document $aircraft) {
  my BSON::Document $req .= new: (
    insert    => 'Aircraft',
    documents => [ $aircraft ],
  );
  my BSON::Document $result = $database.run-command($req);
  say "Creation aircraft ok : ", $result<ok>, " nb : ", $result<n>;

}

our sub write-game(BSON::Document $game) {
  my BSON::Document $req .= new: (
    insert    => 'Games',
    documents => [ $game ],
  );
  my BSON::Document $result = $database.run-command($req);
  #say "Creation game ok : ", $result<ok>, " nb : ", $result<n>;
}


=begin POD

=encoding utf8

=head1 NOM

acces-mongodb.rakumod -- regrouping the functions accessing the MongoDB base.

=head1 DESCRIPTION

This module regroups all the functions accessing the MongoDB database,
to read the games and game turns and to update them.

=head1 COPYRIGHT and LICENSE

Copyright 2018, 2020, 2021, Jean Forget, all rights reserved

This  program is  published under  the  same conditions  as Raku:  the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read them at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
