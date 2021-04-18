#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Programme autodidacte pour jouer à l'As des As
#     Self-learning program to play Ace of Aces
#     Copyright (C) 2018, 2020, 2021 Jean Forget
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
use Pilot;
use Aircraft;
use access-mongodb;

my MongoDB::Client     $client       .= new(:uri('mongodb://'));
my MongoDB::Database   $database      = $client.database('Ace_of_Aces');
my MongoDB::Collection $turns         = $database.collection('Turns');
my MongoDB::Collection $pilots        = $database.collection('Pilots');
my MongoDB::Collection $aircraft-coll = $database.collection('Aircraft');

sub MAIN (Str :$date-hour, Str :$identity) {
  #say "Fight by $identity";
  #say "Reference $date-hour";
  my Pilot     $pilot     = init-pilot($identity);
  my Aircraft  $aircraft  = init-aircraft($pilot.aircraft);
  say "fight by ", $pilot.name, " on ", $pilot.aircraft, " perspicacity ", $pilot.perspicacity, ", stiffness ", $pilot.stiffness;
  my Bool $play-in-progress = True;
  my Int  $turn-number = 1;

  # Game proper
  while $play-in-progress {
    my BSON::Document $turn = read-turn($date-hour, $identity, $turn-number);
    #say $turn.perl;
    if $turn<end> {
      $turn<maneuver> = 'End';
      $turn<dh2>      = time-stamp;
      upd-turn($turn);
      lesson-learned($date-hour, $identity, $turn-number, $turn<result>);
      last;
    }
    my $choice = $turn<choice>;

    if $pilot.stiffness == 1E0 {
      $turn<maneuver> = $choice.pick;
    }
    else {
      my @similar; # similar turns, from the same start page
      my @id = ~ $pilot.identity;
      @id.push($pilot.aircraft);
      @similar = access-mongodb::turns-of-page(~ $turn<page>, @id, ~ $date-hour);
      if @similar.elems == 0 {
        $turn<maneuver> = $choice.pick;
      }
      else {
        my %maneuver-value;
        for $turn<choice>[*] -> $man {
          %maneuver-value{$man} = 0;
        }

        @similar ==> grep { $_<maneuver>:exists } \
                 ==> sort { $^a<maneuver> leg $^b<maneuver> } \
                 ==> my @simil;
        my $cumul = 0;
        my $previous-maneuver = '';
        for @simil -> BSON::Document $sim {
          my $result = $sim<result> // '';
          my $delay  = $sim<delay>  // '';

          if $sim<maneuver> ne $previous-maneuver {
            $cumul = 0;
            $previous-maneuver = $sim<maneuver>;
          }

          my $value;
          if $result && $delay {
            $value  = $result × $pilot.perspicacity ** $delay;
            $cumul += $value;
            if %maneuver-value{$sim<maneuver>}:exists {
              %maneuver-value{$sim<maneuver>} = $cumul;
            }
          }
        }
        my @maneuvers   = %maneuver-value.keys.sort;
        my @values      = %maneuver-value{ @maneuvers };
        my @coef        = $pilot.stiffness «**» @values;
        my @prob        = @coef «/» ([+] @coef);
        my @cumul-prob  = [\+] @prob;
        my $random      = 1.rand;
        my $i = @cumul-prob.first( * > $random):k;
        $turn<maneuver> = @maneuvers[$i];
        $turn<random>   = $random;
      }
    }
    $turn<dh2>       = time-stamp;
    upd-turn($turn);
    ++ $turn-number;
  }
}

# Lessons learned
sub lesson-learned($dh, $id, $n_c, $res) {
  for 1..$n_c -> $n {
    #say "Lesson learned on ", $n;
    my BSON::Document $turn = read-turn($dh, $id, $n);
    $turn<result> = $res;
    $turn<delay>  = $n_c - $n;
    $turn<dh-end> = time-stamp;
    upd-turn($turn);
  }

}

sub init-pilot(Str $id) {
  my Pilot $pilot;

  my MongoDB::Cursor $cursor = $pilots.find(
    criteria   => ( 'identity' => $id, ),
    );
  while $cursor.fetch -> BSON::Document $d {
    #say $d.perl;
    $pilot .= from-json($d<json>);
    last;
  }
  $cursor.kill;

  #say $pilot.perl;
  return $pilot;
}

sub init-aircraft(Str $id) {
  my Aircraft $aircraft;

  my MongoDB::Cursor $cursor = $aircraft-coll.find(
    criteria   => ( 'identity' => $id, ),
    );
  while $cursor.fetch -> BSON::Document $d {
    #say $d.perl;
    $aircraft .= from-json($d<json>);
    last;
  }
  $cursor.kill;

  #say $aircraft.perl;
  return $aircraft;
}

sub read-turn ($dh, $id, $n) {
  my BSON::Document $turn;

  my $attempt_max = 50;
  my $attempt     =  0;
SONDER:
  while $attempt ≤ $attempt_max {
    ++ $attempt;
    my MongoDB::Cursor $cursor = $turns.find(
      criteria   => ( 'dh-begin' => $dh,
                      'identity' => $id,
                      'turn'     => +$n, ),
    );
    while $cursor.fetch -> BSON::Document $d {
      #say $d.perl;
      if $d<turn> == $n {
        $turn = $d;
        last SONDER;
      }
    }
    $cursor.kill;
    sleep 1;
  }
  if $attempt ≥ $attempt_max {
    die "No answers from umpire, we stop (dh-begin = {$dh}, identity = {$id}, turn = {$n}";
  }

  return $turn;
}

sub upd-turn(BSON::Document $turn) {
   my BSON::Document $req .= new: (
    update => 'Turns',
    updates => [ (
        q =>  ( 'dh-begin' =>  $turn<dh-begin>,
                'identity' =>  $turn<identity>,
                'turn'     => +$turn<turn>, ),
        u => $turn,
      ),
    ],
  );
  my BSON::Document $doc = $database.run-command($req);
  if $doc<ok> == 0 {
    say "update ok : ", $doc<ok>, " nb : ", $doc<n>;
  }
}

sub time-stamp {
  return sprintf "%04d-%02d-%02dT%02d:%02d:%02d", .year, .month, .day, .hour, .minute, .whole-second given DateTime.now.utc;
}

=begin POD

=encoding utf8

=head1 NAME

player.raku -- self-learning program to play Ace of Aces

=head1 DESCRIPTION

This program  exchanges data with an  umpire program to play  I<Ace of
Aces>  and  stores the  result  of  the  various  games in  a  MongoDB
database, in order to learn from past experiences, good or bad, during
the future games.

=head1 LANCEMENT

  raku player.raku --date-hour=2018-04-04_21-42-10 --identity=Kevin &

=head2 Parameters

=item date-hour

Date and hour of the beginning of the game, which are used as a unique
key for the game and its player turns.

=item identity

Name of  the simulated player,  stored in the C<Pilots>  collection of
the database.

=head1 COPYRIGHT and LICENCE

Copyright (C) 2018, 2020, 2021, Jean Forget, all rights reserved

This program  is published under  the same conditions as  Raku: the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read them at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
