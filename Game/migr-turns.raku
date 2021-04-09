#!/home/jf/rakudo/bin/perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Migrer la collection Coups vers la collection Turns
#     Migration of the Coups collection to the Turns collection
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

my $fht = open("list-turns.json", :w);
my $fhc = open("list-coups.json", :w);
my MongoDB::Cursor $cursor = $coups.find(
    criteria   => ( ),
  );
while $cursor.fetch -> BSON::Document $coup {
  $fhc.say($coup);
  my Str $key      = $coup<date-heure>;
  my Int $turn-nb  = $coup<tour>;
  my Str $page     = $coup<page>;
  my     $choix    = $coup<choix> // [];
  my @choice =  map { translate $_ }, $choix[*];

  my $dh-end = '';
  my MongoDB::Cursor $cursor-p = $parties.find(
      criteria   => ( 'date-heure' => $key, ),
    );
  my BSON::Document $partie;
  while $cursor-p.fetch -> BSON::Document $d {
    $partie = $d;
    $dh-end = $d<dh_fin>  if $d<dh_fin>:exists;
  }

  substr-rw($key, 10, 1) = 'T';
  substr-rw($key, 13, 1) = ':';
  substr-rw($key, 16, 1) = ':';
  $page ~~ s/G/L/;
  $page ~~ s/A/C/;
  $page ~~ s/D/R/;


  my BSON::Document $turn .= new(); 
  $turn<dh-begin>   = $key;
  $turn<identity>   = $coup<identité>;
  $turn<turn>       = $turn-nb;
  $turn<page>       = $page;
  $turn<choice>     = [ @choice ];
  $turn<hits>       = $coup<potentiel>;
  $turn<dh1>        = $coup<dh1>;
  $turn<maneuver>   = translate($coup<manoeuvre> // 'Fini');
  $turn<random>     = $coup<tirage>    if $coup<tirage>:exists;
  $turn<dh2>        = $coup<dh2>       if $coup<dh2>:exists;
  $turn<result>     = $coup<résultat>  if $coup<résultat>:exists;
  $turn<delay>      = $coup<délai>     if $coup<délai>:exists;
  $turn<end>        = $coup<fini> // 0;
  $turn<dh-end>     = $dh-end          if $dh-end;
  $fht.say($turn);
  access-mongodb::write-turn($turn);
}

$fht.close();
$fhc.close();

# translate "attaque" and "fuite", in "manoeuvre" and in "choix"
sub translate(Str $manoeuvre --> Str) {
  if $manoeuvre eq 'Attaque' {
    return 'Attack';
  }
  if $manoeuvre eq 'Fuite' {
    return 'Flee';
  }
  if $manoeuvre eq 'Fini' {
    return 'End';
  }
  return $manoeuvre;
}

=begin POD

=encoding utf8

=head1 NAME

migr-turns.raku -- converting the 2018-vintage collection C<Coups> to up-to-date collection C<Turns>

=head1 DESCRIPTION

This program reads the C<Coups>  collection, with French keywords, and
creates  corresponding  documents  with  English  keyworrds  into  the
C<Turns> collection. Some additional attributes are initialised.

The list of input C<Coups>  documents and of output C<Turns> documents
are  printed  in  text   files,  respectively  F<list-coups.json>  and
F<list-turns.json>.

=head1 USAGE

You  should  first delete  all  current  documents from  the  C<Turns>
collection, this is not done by the program. Under the Mongo shell:

  use Ace_of_Aces
  db.Turns.remove({'dh-begin':{'$gt':'2'}})

Then run the program with:

  raku migr-turns.raku

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
