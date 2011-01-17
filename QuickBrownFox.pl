package MT::Plugin::OMV::QuickBrownFox;

use strict;

use vars qw( $MYNAME $VERSION );
$MYNAME = (split /::/, __PACKAGE__)[-1];
$VERSION = '0.00_01';

use base qw( MT::Plugin );
my $plugin = new MT::Plugin ({
        id => $MYNAME,
        key => $MYNAME,
        name => $MYNAME,
        version => $VERSION,
        author_name => 'Open MagicVox.net',
        author_link => 'http://www.magicvox.net/',
        doc_link => 'http://ja.wikipedia.org/wiki/The_quick_brown_fox_jumps_over_the_lazy_dog',
        description => <<HTMLHEREDOC,
<__trans phrase="The quick brown fox jumps over the lazy dog.">
HTMLHEREDOC
        registry => {
            callbacks => {
                'cms_pre_save.entry' => \&_cb_cms_pre_save,
                'cms_pre_save.page' => \&_cb_cms_pre_save,
                'cms_pre_save.template' => \&_cb_cms_pre_save,
            },
        },
});
MT->add_plugin ($plugin);

my $phrase_ja = '色は匂へど 散りぬるを 我が世誰ぞ 常ならん 有為の奥山 今日越えて 浅き夢見じ 酔ひもせず ';
my $phrase_en = 'The quick brown fox jumps over the lazy dog. 1234567890 ';

if (5.0 <= $MT::VERSION) {
    $phrase_ja = Encode::decode ('utf-8', $phrase_ja);
}

### Callback - cms_pre_save.*
sub _cb_cms_pre_save {
    my ($cb, $app, $obj) = @_;

    foreach (qw/ title text text_more keywords name /) {
        next unless $obj->can ($_);
        my $data = $obj->$_ || '';
        # ja
        $data =~ s!=iroha\s*\(\s*(\d*)\s*\)!sub {
            (my $count = shift) ||= 10; return join '', $phrase_ja x $count;
        }->($1)!gei;
        # en
        $data =~ s!=rand\s*\(\s*(\d*)\s*\)!sub {
            (my $count = shift) ||= 10; return join '', $phrase_en x $count;
        }->($1)!gei;
        $obj->$_ ($data);
    }

    1; # success
}

1;