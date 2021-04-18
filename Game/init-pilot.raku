#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Insertion d'un nouveau pilote dans la base MongoDB
#     Creating a new pilot into the MongoDB database
#     Copyright (C) 2018, 2020, 2021 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;
use lib 'lib';
use BSON::Document;
use JSON::Class;
use access-mongodb;
use Pilot;

sub MAIN (Str $identity) {
  my Str    $json    = slurp "$identity.json";
  my Pilot  $pilot  .= from-json($json);
  my BSON::Document $doc .= new: (
       identity        => $pilot.identity,
       name            => $pilot.name,
       avion           => $pilot.aircraft,
       perspicacity    => $pilot.perspicacity,
       stiffness       => $pilot.stiffness,
       ref             => $pilot.ref,
       json            => $json,
       );
  access-mongodb::write-pilot($doc);
}

=begin POD

=encoding utf8

=head1 NAME

init-pilot.raku -- loading a pilot into the MongoDB database

=head1 DESCRIPTION

This program read a JSON file describing a pilot and writes a document
similar to this file into the database, so the following programs will
access only the database, they will not process JSON text files.

=head1 USAGE

  raku init-pilot.raku Kevin

=head2 Parameters

=item identity

Name of the simulated pilot, described in a JSON file, which gives all
his characteristics.

=head1 COPYRIGHT and LICENSE

Copyright 2020, 2021, Jean Forget, all rights reserved

This  program is  published under  the  same conditions  as Raku:  the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read it at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
