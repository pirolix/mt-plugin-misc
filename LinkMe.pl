package MT::Plugin::OMV::LinkMe;

use strict;
use MT 4;
use MT::Template::Context;

use vars qw( $MYNAME $VERSION );
$MYNAME = 'LinkMe';
$VERSION = '0.01';

### BuildPage callback
MT->add_callback ('BuildFileFilter', 9, undef, sub {
    my (undef, %args) = @_;
    $args{Context}->stash ($MYNAME. '::file_info', $args{FileInfo});
    1;
});

### Functional tag
MT::Template::Context->add_tag ($MYNAME => sub {
    my $finfo = $_[0]->stash ($MYNAME. '::file_info')
        or return '';
    $finfo->url || '';
});

1;