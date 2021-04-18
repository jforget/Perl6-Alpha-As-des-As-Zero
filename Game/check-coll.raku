#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Vérification des attributs d'une collection MongoDB
#     Checking the attributes from a MongoDB collection
#     Copyright (C) 2021 Jean Forget, all rights reserved
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

sub MAIN(Str $coll) {

  my MongoDB::Client     $client    .= new(:uri('mongodb://'));
  my MongoDB::Database   $database   = $client.database('Ace_of_Aces');
  my MongoDB::Collection $collection = $database.collection($coll);

  my %count;

  my $fh-cr;
  if $coll eq 'Turns' {
    $fh-cr = open("incomplete-turns", :w);
  }

  my MongoDB::Cursor $cursor = $collection.find(
      criteria   => ( ),
    );
  while $cursor.fetch -> BSON::Document $doc {
    if $coll eq 'Turns' {
      #unless $doc<result>:exists and $doc<delay>:exists {
      unless $doc<maneuver>:exists and $doc<dh2>:exists {
        $fh-cr.say("$doc<dh-begin> {sprintf('%03d', $doc<turn>)} $doc<identity> incomplete");
      }
    }
    for $doc.keys -> $key {
      %count{$key}++;
    }
  }
  %count.keys ==> sort { - %count{$_} } \
              ==> my @keys;

  if $fh-cr {
    $fh-cr.close();
  }

  for @keys -> $key {
    say "$key %count{$key}";
  }

}

=begin POD

=encoding utf8

=head1 NAME

check-coll.raku -- utility program to check the existence of keys in a MongoDB collection

=head1 DESCRIPTION

This program scans a MongoDB collection and tabulates the keys present
in each  document. At  the end,  it gives  the counts  of the  keys it
found.

Generally, all  the keys should be  present in all the  documents of a
given collection. There are some exception. For example, the C<random>
key  is not  present  in all  C<Turns> documents,  it  is absent  from
training games and present only in fighting games.

When  checking  the  C<Turns>  collection,  the  program  checks  some
criteria (the  absence of such  or such  key) and stores  the matching
documents in a text file F<incomplete-turns> for further checks.

=head1 USAGE

  raku check-coll.raku Games

or

  raku check-coll.raku Turns

=head1 COPYRIGHT and LICENSE

Copyright 2021, Jean Forget, all rights reserved

This program  is published under  the same conditions as  Raku: the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read them at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
