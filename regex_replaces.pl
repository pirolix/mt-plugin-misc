package MT::Plugin::Filter::OMV::regex_replaces;
# $Id$

use strict;
use MT 4;

use vars qw( $VENDOR $MYNAME $VERSION );
($VENDOR, $MYNAME) = (split /::/, __PACKAGE__)[-2, -1];
(my $revision = '$Rev$') =~ s/\D//g;
$VERSION = '0.10'. ($revision ? ".$revision" : '');

use base qw( MT::Plugin );
my $plugin = __PACKAGE__->new ({
    id => $MYNAME,
    key => $MYNAME,
    name => $MYNAME,
    version => $VERSION,
    author_name => 'Open MagicVox.net',
    author_link => 'http://www.magicvox.net/',
    plugin_link => 'http://www.magicvox.net/archive/2012/05251625/', # blog
    doc_link => 'http://lab.magicvox.net/trac/mt-plugins/wiki/regex_replaces', # trac
    description => <<'HTMLHEREDOC',
<__trans phrase="Apply regex_replace modifier one after another continuously.">
HTMLHEREDOC
    registry => {
        tags => {
            modifier => {
                regex_replaces => \&_hdlr_regex_replaces,
            },
        },
    },
});
MT->add_plugin ($plugin);



###
sub _hdlr_regex_replaces {
    my ($str, $val, $ctx) = @_;

    # The value must be an array
    return $str unless ref $val eq 'ARRAY';

    # Retrieve the original code of regex_replace modifier
    my $code = $ctx->{__filters}{regex_replace}
        or return $str;
    if (!ref $code) {
        $code = MT->handler_to_coderef ($code)
            or return $str;
    }

    # Apply the original regex_replace modifier one after another
    my @val = @$val;
    while (defined($val[0]) && defined($val[1])) {
        $str = $code->($str, \@val, $ctx)
            or return;
        shift @val;
        shift @val;
    }
    $str;
}

1;