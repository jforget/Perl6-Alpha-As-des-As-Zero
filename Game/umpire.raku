#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Programme arbitre pour jouer à l'As des As
#     Program to act as an Ace of Aces umpire
#     Copyright (C) 2018, 2020 Jean Forget
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

my MongoDB::Client     $client       .= new(:uri('mongodb://'));
my MongoDB::Database   $database      = $client.database('Ace_of_Aces');
my MongoDB::Collection $turns         = $database.collection('Turns');
my MongoDB::Collection $pilots        = $database.collection('Pilots');
my MongoDB::Collection $aircraft-coll = $database.collection('Aircraft');

sub MAIN (Str :$date-hour, Str :$good, Str :$bad, Bool :$no-fleeing) {
  my Pilot     $pilot_g     = init-pilot($good);
  my Pilot     $pilot_b     = init-pilot($bad);
  my Aircraft  $aircraft_g  = init-aircraft($pilot_g.aircraft);
  my Aircraft  $aircraft_b  = init-aircraft($pilot_b.aircraft);
  #say "Reference $date-hour";
  say "Fight by $good against $bad, ", $pilot_g.aircraft, " against ", $pilot_b.aircraft, $no-fleeing ?? ' no fleeing' !! '';

  my Int $num          =   0;
  my Int $game-in-progress =   1;
  my Int $num_page     = 170;
  my Num $damage-pts_g = $pilot_g.hits;
  my Num $damage-pts_b = $pilot_b.hits;
  while $game-in-progress {
    my (@choice_g, @choice_b, $pursuit_g, $pursuit_b, $man_g, $man_b);
    my (Int $num_page_g , Int $num_page_b );  # intermediate pages
    my (Int $num_page_gf, Int $num_page_bf);  # final pages
    if $num_page == 223 {
      if $no-fleeing {
        @choice_g     = <Attack Attack Attack Attack Attack Flee>;
      }
      else {
        @choice_g     = <Attack Flee>;
      }
      @choice_b     = @choice_g;
      $pursuit_g = '';
      $pursuit_b = '';
      #say join ' ', @choice_g, '/', @choice_b;
    }
    else {
      @choice_g     = $aircraft_g.pages[$num_page]<transition>.keys.sort;
      @choice_b     = $aircraft_b.pages[$num_page]<transition>.keys.sort;
      if $no-fleeing {
        #say join ' ', @choice_g, '/', @choice_b;
        my @choice = grep { $aircraft_g.pages[$num_page]<transition>{$_} != 223 }, @choice_g;
        if @choice.elems > 0 {
          @choice_g = @choice;
        }
        @choice = grep { $aircraft_b.pages[$num_page]<transition>{$_} != 223 }, @choice_b;
        if @choice.elems > 0 {
          @choice_b = @choice;
        }
        #say join ' ', @choice_g, '/', @choice_b;
      }

      $pursuit_g     = $aircraft_g.pages[$num_page]<pursuit>;
      $pursuit_b     = $aircraft_b.pages[$num_page]<pursuit>;
      $damage-pts_b -= $aircraft_g.pages[$num_page]<shoot>;
      $damage-pts_g -= $aircraft_b.pages[$num_page]<shoot>;
      if $damage-pts_g ≤ 0 or $damage-pts_b ≤ 0 {
        # at least one aircraft shot down
        $game-in-progress = 0;
      }
    }
    my BSON::Document $turn_g;
    my BSON::Document $turn_b;
    if $game-in-progress {
      ++ $num;
      if $pursuit_g eq 'T' {
        $turn_b .= new: (
             dh-begin   => $date-hour,
             identity   => $bad,
             turn       => $num,
             page       => ~ $num_page,
             choice     => [ @choice_b ],
             hits       => $damage-pts_b,
             end        =>   0,
             dh1        => time-stamp,
        );
        write-turn($turn_b);
        $turn_b  = read_turn($date-hour, $bad, $num);
        $man_b   = $turn_b<maneuver>;
        $turn_g .= new: (
             dh-begin   => $date-hour,
             identity   => $good,
             turn       => $num,
             page       => $num_page ~ $aircraft_b.maneuvers{$man_b}<turn>,
             choice     => [ @choice_g ],
             hits       => $damage-pts_g,
             end        =>   0,
             dh1        => time-stamp,
        );
        write-turn($turn_g);
        $turn_g     = read_turn($date-hour, $good , $num);
      }
      elsif $pursuit_b eq 'T' {
        $turn_g .= new: (
             dh-begin   => $date-hour,
             identity   => $good,
             turn       => $num,
             page       => ~ $num_page,
             choice     => [ @choice_g ],
             hits       => $damage-pts_g,
             end        =>   0,
             dh1        => time-stamp,
        );
        write-turn($turn_g);
        $turn_g  = read_turn($date-hour, $good , $num);
        $man_g   = $turn_g<maneuver>;
        $turn_b .= new: (
             dh-begin   => $date-hour,
             identity   => $bad,
             turn       => $num,
             page       => $num_page ~ $aircraft_g.maneuvers{$man_g}<turn>,
             choice     => [ @choice_b ],
             hits       => $damage-pts_b,
             end        =>   0,
             dh1        => time-stamp,
        );
        write-turn($turn_b);
        $turn_b     = read_turn($date-hour, $bad, $num);
      }
      else {
        $turn_g .= new: (
             dh-begin   => $date-hour,
             identity   => $good,
             turn       => $num,
             page       => ~ $num_page,
             choice     => [ @choice_g ],
             hits       => $damage-pts_g,
             end        =>   0,
             dh1        => time-stamp,
        );
        $turn_b .= new: (
             dh-begin   => $date-hour,
             identity   => $bad,
             turn       => $num,
             page       => ~ $num_page,
             choice     => [ @choice_b ],
             hits       => $damage-pts_b,
             end        =>   0,
             dh1        => time-stamp,
        );
        write-turn($turn_g);
        write-turn($turn_b);
        $turn_g     = read_turn($date-hour, $good, $num);
        $turn_b     = read_turn($date-hour, $bad , $num);
      }
      $man_g   = $turn_g<maneuver>;
      $man_b   = $turn_b<maneuver>;
      if $num_page == 223 {
        if $man_g eq 'Attack' && $man_b eq 'Attack' {
          $num_page_gf = 170;
          $num_page_bf = 170;
          $num_page_g  =   0; # so a numeric test below will not cause trouble
          $num_page_b  =   0; # idem
        }
        else {
          # au moins un aircraft en flee
          $game-in-progress =   0;
          $num_page    = 223;
          $num_page_g  = 223;
          $num_page_b  = 223;
        }
      }
      else {
        $num_page_g  = $aircraft_g.pages[$num_page]<transition>{$man_g};
        $num_page_b  = $aircraft_b.pages[$num_page]<transition>{$man_b};
      }
      if $num_page_b == 223 {
        $num_page_gf = 223;
      }
      elsif $num_page != 223 {
        $num_page_gf = $aircraft_g.pages[$num_page_b]<transition>{$man_g};
      }
      if $num_page_g == 223 {
        $num_page_bf = 223;
      }
      elsif $num_page != 223 {
        $num_page_bf = $aircraft_b.pages[$num_page_g]<transition>{$man_b};
      }
    }
    if $game-in-progress == 0 {
      $turn_g .= new: (
           dh-begin   => $date-hour,
           identity   => $good,
           turn       => $num + 1,
           page       => ~ $num_page,
           choice     => [  ],
           hits       => $damage-pts_g,
           end        =>   1,
           dh1        => time-stamp,
           maneuver   => 'End',
           dh2        => time-stamp,
      );
      $turn_b .= new: (
           dh-begin   => $date-hour,
           identity   => $bad,
           turn       => $num + 1,
           page       => ~ $num_page,
           choice     => [  ],
           hits       => $damage-pts_b,
           end        =>   1,
           dh1        => time-stamp,
           maneuver   => 'End',
           dh2        => time-stamp,
      );
      if $damage-pts_g ≤ 0 and $damage-pts_b ≤ 0 {
        say "Game is a draw, both pilots shot each other simultaneously";
        $turn_g<result> = 0e0;
        $turn_b<result> = 0e0;
      }
      elsif $damage-pts_b ≤ 0 {
        say "Victory for $good !";
        $turn_g<result> =  1e0;
        $turn_b<result> = -1e0;
      }
      elsif $damage-pts_g ≤ 0 {
        say "Victory for $bad !";
        $turn_g<result> = -1e0;
        $turn_b<result> =  1e0;
      }
      elsif $man_g eq 'Attack' {
        say "$good holds on, $bad flees";
        $turn_g<result> =  0.5e0;
        $turn_b<result> = -0.5e0;
      }
      elsif $man_b eq 'Attack' {
        say "$bad holds on, $good flees";
        $turn_g<result> = -0.5e0;
        $turn_b<result> =  0.5e0;
      }
      else {
        say "Game is a draw, both pilots flee";
        $turn_g<result> = 0e0;
        $turn_b<result> = 0e0;
      }

      write-turn($turn_g);
      write-turn($turn_b);
      my BSON::Document $summary;
      $summary .= new: (
           dh-begin   => $date-hour,
           good       => $good,
           bad        => $bad,
           aircraft-g => $pilot_g.aircraft,
           aircraft-b => $pilot_b.aircraft,
           vp-g       => $turn_g<result>,
           vp-b       => $turn_b<result>,
           hits-g     => $damage-pts_g,
           hits-b     => $damage-pts_b,
           nb-turns   => $num + 1e0,
           dh-end     => time-stamp,
      );
      write-game($summary);
      say "Finished!";
      last;
    }
    say join ' ', "$num:", $num_page, '->', $man_g, $num_page_g, $man_b, $num_page_b, '->', $num_page_gf, $num_page_bf, "($damage-pts_g $damage-pts_b)";
    $num_page = min($num_page_gf, $num_page_bf);
  }
}

sub read_turn ($dh, $id, $n) {
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
      if $d<turn> == $n && ($d<maneuver> // '') ne '' {
        $turn = $d;
        last SONDER;
      }
    }
    $cursor.kill;
    sleep 1;
  }
  if $attempt ≥ $attempt_max {
    die "No answer from player $id, we stop there";
  }

  return $turn;
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

sub write-turn(BSON::Document $turn) {
  my BSON::Document $req .= new: (
    insert    => 'Turns',
    documents => [ $turn ],
  );
  my BSON::Document $result = $database.run-command($req);
  #say "Création turn ok : ", $result<ok>, " nb : ", $result<n>;

}

sub write-game(BSON::Document $game) {
  my BSON::Document $req .= new: (
    insert    => 'Games',
    documents => [ $game ],
  );
  my BSON::Document $result = $database.run-command($req);
  #say "Creation game ok : ", $result<ok>, " nb : ", $result<n>;
}

sub time-stamp {
  return sprintf "%04d-%02d-%02dT%02d:%02d:%02d", .year, .month, .day, .hour, .minute, .whole-second given DateTime.now.utc;
}

=begin POD

=encoding utf8

=head1 NAME

umpire.raku -- program used as an umpire in an I<Ace of Aces> game.

=head1 DESCRIPTION

This program acts  as an umpire in  a I<Ace of Aces>  game between two
player programs.

=head1 COMMAND-LINE

  raku umpire.raku --date-hour=2018-04-04_21-42-10 --good=Plume-Noire --bad=Kevin &

=head2 Parameters

=item date-hour

Date and hour at  the start of the game. Used as a  unique key for the
game and all its player turns.

=item good, bad

Names of the simulated players. Must exist in the C<Pilots> collection
of the database.

=item no-fleeing

Boolean,  used in  training games.  If  C<True>, the  aircraft do  not
choose  223 for  their intermediate  pages. It  may happen  that their
final page  is 223, in  which case  the probabilities are  adjusted to
favor an attacking mood.

Exception: if  all the available  maneuvers point to  the intermediate
page 223, the C<no-fleeing> parameter is disregarded for this turn and
this aircraft.  This cannot  happen with the  standard I<Ace  of Aces>
aircraft and  other published  games, but it  may happen  with bespoke
booklets. It may happen with the I<Epervier> booklet.

=head1 COPYRIGHT and LICENCE

Copyright (C) 2018, 2020, 2021, Jean Forget, all rights reserved

This program  is published under  the same conditions as  Raku: the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read them at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
