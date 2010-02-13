package MT::Plugin::OMV::Template;

use strict;
use MT 4;
use MT::Template::Context;

use vars qw( $MYNAME $VERSION );
$MYNAME = 'Template';
$VERSION = '0.01';

### BuildPage callback
MT->add_callback ('BuildFileFilter', 9, undef, sub {
    my (undef, %args) = @_;
    $args{Context}->stash ($MYNAME. '::template', $args{Template});
    1;
});

### Functional tag
MT::Template::Context->add_tag ($MYNAME => sub {
    my ($finfo, $column);

    ($finfo = $_[0]->stash ($MYNAME. '::template'))
        && ($column = $_[1]->{column} || 'name')
        && $finfo->can ($column)
        && $finfo->$column || '';
});

1;