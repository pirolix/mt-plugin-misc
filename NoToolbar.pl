package MT::Plugin::Editing::OMV::NoToolbar;
# $Id$

use strict;
use MT 5;

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
    doc_link => 'http://lab.magicvox.net/trac/mt-plugins/wiki/NoToolbar', # trac
    description => <<'HTMLHEREDOC',
<__trans phrase="Hide the default toolbars of the textarea">
HTMLHEREDOC
    registry => {
        callbacks => {
            'MT::App::CMS::template_source.edit_entry' => \&_hdlr_template_source_archetype_editor,
        },
    },
});
MT->add_plugin ($plugin);



###
sub _hdlr_template_source_archetype_editor {
    my ($cb, $app, $tmpl) = @_;

    my $old = quotemeta (<<'MTMLHEREDOC');
<mt:include name="include/header.tmpl" id="header_include">
MTMLHEREDOC

    my $new = <<'MTMLHEREDOC';
<mt:setvarblock name="html_head" append="1">
<style type="text/css">
#editor-content-toolbar {
    padding: 0px;
    border-bottom: none;
}
#editor-content-toolbar div.field-buttons-formatting {
    display: none;
}
</style>
</mt:setvarblock>
MTMLHEREDOC
    $$tmpl =~ s/($old)/$new$1/;
}

1;