#!/home/jf/rakudo/bin/perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Migrer la collection Parties vers la collection Games
#     Migration of the Parties collection to the Games collection
#     Copyright (C) 2020, 2021 Jean Forget, all rights reserved
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;
use lib 'lib';
use BSON::Document;
use MongoDB::Client;
use MongoDB::Database;
use MongoDB::Collection;
use JSON::Class;
use access-mongodb;

my MongoDB::Client     $client  .= new(:uri('mongodb://'));
my MongoDB::Database   $database = $client.database('Ace_of_Aces');
my MongoDB::Collection $coups    = $database.collection('Coups');
my MongoDB::Collection $parties  = $database.collection('Parties');

my @list;

my $fhg = open("list-games.json", :w);
my $fhp = open("list-parties.json", :w);
my MongoDB::Cursor $cursor = $parties.find(
    criteria   => ( ),
  );
while $cursor.fetch -> BSON::Document $partie {
  my     $hits-g   = $partie<capacité_g>;
  my     $hits-b   = $partie<capacité_m>;
  my Num $nb-turns = $partie<nb_coups>.Num;
  my Str $key      = $partie<date-heure>;

  unless $hits-g.defined && $hits-b.defined {
    my MongoDB::Cursor $last = $coups.find(
      criteria   => ( 'date-heure' => $key, 'tour' => $nb-turns - 1 ),
    );
    while $last.fetch -> BSON::Document $coup {
      if $coup<identité> eq $partie<gentil> {
        $hits-g //= $coup<potentiel>;
      }
      if $coup<identité> eq $partie<méchant> {
        $hits-b //= $coup<potentiel>;
      }
    }
  }

  substr-rw($key, 10, 1) = 'T';
  substr-rw($key, 13, 1) = ':';
  substr-rw($key, 16, 1) = ':';
  my BSON::Document $game .= new(); 
  $game<dh-begin>   = $key;
  $game<good>       = $partie<gentil>;
  $game<bad>        = $partie<méchant>;
  $game<aircraft-g> = $partie<avion_g>;
  $game<aircraft-b> = $partie<avion_m>;
  $game<vp-g>       = $partie<résultat_g>;
  $game<vp-b>       = $partie<résultat_m>;
  $game<hits-g>     = $hits-g.Num if $hits-g.defined;
  $game<hits-b>     = $hits-b.Num if $hits-b.defined;
  $game<nb-turns>   = $partie<nb_coups>;
  $game<dh-end>     = $partie<dh_fin>;
  $fhg.say($game);
  $fhp.say($partie);
  access-mongodb::write-game($game);
}

$fhg.close();
$fhp.close();


=begin POD

=encoding utf8

=head1 NAME

migr-games.raku -- converting the 2018-vintage collection C<Parties> to up-to-date collection C<Games>

=head1 DESCRIPTION

This program  reads the  C<Parties> collection, with  French keywords,
and creates  corresponding documents  with English keyworrds  into the
C<Games> collection. Some additional attributes are initialised.

The  list  of  input  C<Parties>  documents  and  of  output  C<Games>
documents are printed in text files, respectively F<list-parties.json>
and F<list-games.json>.

=head1 USAGE

You  should  first delete  all  current  documents from  the  C<Games>
collection, this is not done by the program. Under the Mongo shell:

  use Ace_of_Aces
  db.Games.remove({'dh-begin':{'$gt':'2'}})

Then run the program with:

  raku migr-games.raku

=head2 Parameters

None

=head1 COPYRIGHT and LICENSE

Copyright 2020, 2021, Jean Forget, all rights reserved

This  program is  published under  the  same conditions  as Raku:  the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read it at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
