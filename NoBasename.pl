package MT::Plugin::Editing::OMV::NoBasename;
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
    doc_link => 'http://lab.magicvox.net/trac/mt-plugins/wiki/NoBasename', # trac
    description => <<'HTMLHEREDOC',
<__trans phrase="Hide and fill with the unique value into the basename field.">
HTMLHEREDOC
    registry => {
        callbacks => {
            'MT::App::CMS::template_source.edit_entry' => \&_hdlr_source_edit_entry,
        },
    },
});
MT->add_plugin ($plugin);



###
sub _hdlr_source_edit_entry {
    my ($cb, $app, $tmpl) = @_;

    my $old = quotemeta (<<'MTMLHEREDOC');
<mt:include name="include/footer.tmpl" id="footer_include">
MTMLHEREDOC

    my $new = <<'MTMLHEREDOC';
<mt:setvarblock name="jq_js_include" append="1">
<mt:if name="object_type" eq="entry">
    // 
    jQuery('#basename-field').hide();
<mt:unless name="id">
    // 
    jQuery('#entry_form').submit(function () {
        this.basename.value = (new Date()).getTime();
        return true;
    });
</mt:unless></mt:if>
</mt:setvarblock>
MTMLHEREDOC
    $$tmpl =~ s/($old)/$new$1/;
}

1;