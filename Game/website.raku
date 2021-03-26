#!/home/jf/rakudo/bin/perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Serveur web permettant de consulter la base MongoDB des parties de l'As des As
#     Web server to display the MongoDB database where Ace of Aces games are stored
#     Copyright (C) 2018, 2020, 2021 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6.c;
use lib 'lib';
use BSON::Document;
use MongoDB::Client;
use MongoDB::Database;
use MongoDB::Collection;
use JSON::Class;
use Bailador;

use access-mongodb;
use game-list-page;
use game-page;
#use turn-page;
use Pilot;

my @languages = ( 'en', 'fr' );

get '/' => sub {
  redirect "/en/list/";
}

get '/:ln/list' => sub ($lng) {
  redirect "/$lng/list/";
}

get '/:ln/list/' => sub ($lng) {
  if $lng !~~ /^ @languages $/ {
    return slurp('html/unknown-lang.html');
  }
  my @list = access-mongodb::list-games('');
  return game-list-page::render(~ $lng, '', @list);
}

get '/:ln/list/:dh' => sub ($lng, $dh) {
  if $lng !~~ /@languages/ {
    return slurp('html/unknown-lang.html');
  }
  my @list = access-mongodb::list-games(~ $dh);
  return game-list-page::render(~ $lng, ~ $dh, @list);
}

get '/:lng/game/:dh' => sub ($lng, $dh) {
  if $lng !~~ /@languages/ {
    return slurp('html/unknown-lang.html');
  }
  my $game  = access-mongodb::game(~ $dh);
  my @turns = access-mongodb::turns-of-game(~ $dh);
  return game-page::render(~ $lng, ~ $dh, $game, @turns);
}

#get '/:lng/turn/:dh/:num/:id' => sub ($lng, $dh, $num, $id) {
#  my BSON::Document $game  = access-mongodb::game(~ $dh);
#  my BSON::Document $doc-p = access-mongodb::pilot(~ $id);
#  my Pilot         $pilot .= from-json($doc-p<json>);
#  my @turn4  = access-mongodb::turn4(~ $dh, + $num, ~ $id);
#  my $page;
#  for @turn4 -> BSON::Document $turn {
#    if $turn<turn> == $num &&$turn<identity> eq $id {
#      $page = $turn<page>;
#      last;
#    }
#  }
#  my @similar; # similar turns, from the same start page
#  my @id = ~ $id;
#  if $id ne $game<aircraft_g> && $id ne $game<aircraft_m> {
#    if $id eq $game<good> {
#      @id.push($game<aircraft_g>);
#    }
#    if $id eq $game<bad> {
#      @id.push($game<aircraft_b>);
#    }
#  }
#  @similar = access-mongodb::turns-of-page(~ $page, @id, ~ $dh);
#  return turn-page::render($lng, ~ $dh, + $num, ~ $id, $game, @turn4, @similaires, $pilot);
#}

baile();


=begin POD

=encoding utf8

=head1 NAME

website.raku -- web server which gives a user-friendly view of the Ace of Aces database

=head1 DESCRIPTION

This program is a web server which manages a website showing games
stored in the Ace of Aces database.

=head1 USAGE

On a command-line:

  raku website.raku

On a web browser:

  http://localhost:3000

To stop  the webserver, hit  C<Ctrl-C> on  the command line  where the
webserver was lauched.

=head1 COPYRIGHT and LICENSE

Copyright 2018, 2020, 2021, Jean Forget, all rights reserved

This program  is published under  the same conditions as  Raku: the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read them at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
