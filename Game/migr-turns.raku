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
  my Str $key      = $coup<date-heure>;
  my Int $turn-nb  = $coup<tour>;
  my Str $page     = $coup<page>;
  my     $choix    = $coup<choix>;
  my @choice =  map { translate $_ }, $choix[*];

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
  $turn<maneuver>   = translate($coup<manoeuvre>);
  $turn<random>     = $coup<tirage>    if $coup<tirage>:exists;
  $turn<dh2>        = $coup<dh2>       if $coup<dh2>:exists;
  $turn<result>     = $coup<résultat>  if $coup<résultat>:exists;
  $turn<delay>      = $coup<délai>     if $coup<délai>:exists;
  $turn<end>        = $coup<fini> // 0;
  $fht.say($turn);
  $fhc.say($coup);
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
