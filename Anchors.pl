package MT::Plugin::Filter::OMV::Anchors;
# Anchors (C) 2013 Piroli YUKARINOMIYA (Open MagicVox.net)
# This program is distributed under the terms of the GNU Lesser General Public License, version 3.
# $Id: Anchors.pl 344 2013-07-20 07:49:34Z pirolix $

use strict;
use warnings;
use MT 3;

use vars qw( $VENDOR $MYNAME $FULLNAME $VERSION );
$FULLNAME = join '::',
        (($VENDOR, $MYNAME) = (split /::/, __PACKAGE__)[-2, -1]);
(my $revision = '$Rev: 344 $') =~ s/\D//g;
$VERSION = 'v0.10'. ($revision ? ".$revision" : '');

use base qw( MT::Plugin );
my $plugin = __PACKAGE__->new ({
    id => $FULLNAME,
    key => $FULLNAME,
    name => $MYNAME,
    version => $VERSION,
    author_name => 'Open MagicVox.net',
    author_link => 'http://www.magicvox.net/',
    plugin_link => 'http://www.magicvox.net/archive/2011/02131853/', # Blog
    doc_link => "http://lab.magicvox.net/trac/mt-plugins/wiki/$MYNAME", # tracWiki
    description => <<HTMLHEREDOC,
<__trans phrase="Easy way to refer and arrange the items in the article.">
HTMLHEREDOC
});
MT->add_plugin ($plugin);

my $anchor = '%s-%d';

### Filter
MT::Template::Context->add_global_filter (figure => sub { _filter_anchors ('figure', @_); });
MT::Template::Context->add_global_filter (table => sub { _filter_anchors ('table', @_); });
MT::Template::Context->add_global_filter (picture => sub { _filter_anchors ('picture', @_); });

sub _filter_anchors {
    my ($tag, $text, $format, $ctx) = @_;

    # Gather items
    my (%items, $num);
    $text =~ s!<(?:$tag)\s+name="(.+?)"\s*/?>!sub {
        my ($name) = @_;
        $items{$name} = ++$num;
        sprintf qq{<a name="$anchor">$format</a>}, $tag,$num, $num, $name;
    }->($1)!ige;

    # Replace with link
    $text =~ s!<(?:$tag)\s+href="#?(.+?)"\s*/?>!sub {
        my ($name) = @_;
        my $num = $items{$name} || 0;
        sprintf qq{<a href="#$anchor">$format</a>}, $tag,$num, $num, $name;
    }->($1)!ige;

    $text;
}

1;