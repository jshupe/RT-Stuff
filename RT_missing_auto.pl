#!/usr/bin/perl

# Copyright (c) 2015, James Shupe <j@jamesshupe.com>
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# 
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

use strict;
use RT -init;
use RT::Handle;
use MIME::Lite;

my $TO = 'support@esc13.net';
my $FROM = 'auto@esc13.net';
my $SUBJECT_PASS = "All expected emails found - " . localtime();
my $SUBJECT_FAIL = "MISSING EMAILS - " . localtime();

# Read in expected subjects, one per line, from .cfg file
my $CFG="RT_missing_auto.cfg";
open (CFG, "<$CFG");
my @EXPECTED_SUBS = <CFG>;
close CFG;

# Grab all subjects from last 24h and assign to @SUBJECT
my @SUBJECT;
my $LIST1 = $RT::Handle->dbh;
my $QUERY = "SELECT Subject from Tickets where Created > DATE_SUB(NOW(),
INTERVAL 24 HOUR)";
my $LIST2 = $LIST1->prepare($QUERY);
$LIST2->execute();
while (my @SUB1 = $LIST2->fetchrow_array) {
    push @SUBJECT, $SUB1[0];
}
$LIST2->finish;

# Search the database for each expected subject and add it to
my $OUTPUT_BODY_MID;
foreach my $EXPECTED_SUB (@EXPECTED_SUBS) {
    chomp $EXPECTED_SUB;
    if (!grep /^$EXPECTED_SUB/, @SUBJECT) {
        $OUTPUT_BODY_MID .= "$EXPECTED_SUB ...\n";
    }
}

# Construct email with missing messages
my $BODY;
if (length $OUTPUT_BODY_MID > 1) {
    $BODY = "The following emails were expected, but not received, in
            the last 24 hours:\n\n" .  $OUTPUT_BODY_MID;

    my $MSG = MIME::Lite->new(
        From    => $FROM,
        To      => $TO,
        Subject => $SUBJECT_FAIL,
        Data    => $BODY
    );
    $MSG->send;
} else {
    $BODY = "All expected emails found.";

    my $MSG = MIME::Lite->new(
        From    => $FROM,
        To      => $TO,
        Subject => $SUBJECT_PASS,
        Data    => $BODY
    );
}
