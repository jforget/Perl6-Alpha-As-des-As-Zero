#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Insertion d'un nouvel avion dans la base MongoDB
#     Creating a new aircraft into the MongoDB database
#     Copyright (C) 2020, 2021 Jean Forget, all rights reserved
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;
use lib 'lib';
use BSON::Document;
use JSON::Class;
use access-mongodb;
use Aircraft;
use Pilot;

sub MAIN (Str $identity) {
  my Str $filename = "$identity.json";
  unless $filename.IO.e {
    $filename = "{$identity}-en.json";
  }
  my Str $json            = slurp $filename;
  my Aircraft $aircraft  .= from-json($json);
  my BSON::Document $doc .= new: (
       identity    => $aircraft.identity,
       name        => $aircraft.name,
       side        => $aircraft.side,
       hits        => $aircraft.hits,
       json        => $json,
       );
  access-mongodb::write-aircraft($doc);
  # JSON for the anonymous pilot. I would have prefered to use a better presentation
  # with a proper vertical alignment, but this would have wasted database space.
  $json = qq:to/EOF/;
  \{
  "identity": "{$aircraft.identity}",
  "name": "{$aircraft.name}",
  "aircraft": "{$aircraft.identity}",
  "perspicacity": {(-1).exp.round(0.001).Num},
  "stiffness": {1.Num},
  "hits": {$aircraft.hits},
  "ref": [ "{$aircraft.identity}" ]
  \}
  EOF
  #say $json;
  my Pilot $pilot .= from-json($json);
  $doc            .= new: (
       identity        => $pilot.identity,
       name            => $pilot.name,
       aircraft        => $pilot.aircraft,
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

init-aircraft.raku -- loading an aircraft data into the MongoDB base

=head1 DESCRIPTION

This program  reads a JSON file  describing an aircraft and  write the
data into the MongoDB base, so the following programs will be simpler,
just reading  the database and  no longer  any JSON file.  For another
simplification purpose, the program initialises a anonymous pilot with
the same identity as the aircraft (used in the training games).

=head1 USAGE

  raku init-aircraft.raku --identity=Drone

=head2 Parameter

=item identity

Name of the simulated aircraft, associated with a JSON file giving the
characteristics of this aircraft.

If the aircraft  name is I<Drone> such as in  the USAGE paragraph, the
JSON file is  either F<Drone.json> or F<Drone-en.json>.  If both files
exist, the file without the language code is used.

=head1 COPYRIGHT and LICENSE

Copyright 2020, 2021, Jean Forget, all rights reserved

This program  is published under  the same conditions as  Raku: the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read it at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD
