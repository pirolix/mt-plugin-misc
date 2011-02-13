package MT::Plugin::OMV::Anchors;

use strict;
use MT 3;

use vars qw( $MYNAME $VERSION );
$MYNAME = (split /::/, __PACKAGE__)[-1];
$VERSION = '0.00_01';

use base qw( MT::Plugin );
my $plugin = __PACKAGE__->new ({
        id => $MYNAME,
        key => $MYNAME,
        name => $MYNAME,
        version => $VERSION,
        author_name => 'Open MagicVox.net',
        author_link => 'http://www.magicvox.net/',
        doc_link => 'http://www.magicvox.net/archive/2011/02131853/',
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
        sprintf qq{<a name="$anchor">$format</a>}, $tag,$num, $num;
    }->($1)!ige;

    # Replace with link
    $text =~ s!<(?:$tag)\s+href="#?(.+?)"\s*/?>!sub {
        my ($name) = @_;
        my $num = $items{$name} || 0;
        sprintf qq{<a href="#$anchor">$format</a>}, $tag,$num, $num;
    }->($1)!ige;

    $text;
}

1;