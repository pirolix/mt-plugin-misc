package MT::Plugin::OMV::Filter::Abbr;

use strict;
use MT::Util;

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
        doc_link => 'http://www.magicvox.net/archive/2011/01161521/',
        description => <<HTMLHEREDOC,
<__trans phrase="Convert abbreviations to ABBR HTML tag along the dictionary.">
HTMLHEREDOC
        system_config_template => \&_system_config_template,
        settings => new MT::PluginSettings([
            [ 'file',       { Default => undef, Scope => 'system' } ],
            [ 'dictionary', { Default => undef, Scope => 'system' } ],
        ]),
        registry => {
            tags => {
                modifier => {
                    lc $MYNAME => \&_hdlr_abbr,
                },
            },
        },
});
MT->add_plugin ($plugin);

### System configuration
sub _system_config_template {
    <<PERLHEREDOC;
<mtapp:setting
    id="file"
    label="Dictionary File">
<input type="text" class="full-width" value="<TMPL_VAR NAME=FILE ESCAPE=HTML>" />
</mtapp:setting>

<mtapp:setting
    id="dictionary"
    label="Dictionary"
    hint="<__trans phrase="Separate with ',' (a comma)">"
    show_hint="1">
<textarea name="dictionary" rows="10" class="full-width"><TMPL_VAR NAME=DICTIONARY ESCAPE=HTML></textarea>
</mtapp:setting>
PERLHEREDOC
}

### Modifier - abbr
sub _hdlr_abbr {
    my ($text, $args, $ctx) = @_;

    my $dictionary;
    if (!$ctx->stash ($MYNAME. qq{::dictionary})) {
        # Read dictionary from file
        if (defined (my $file = $plugin->get_config_value ('file'))) {
            if (open (my $fh, "<$file")) {
                $dictionary = do { local $/ = undef; <$fh>; };
                close $fh;
            }
        }
        # Add the additional dictionary
        $dictionary .= "\n". $plugin->get_config_value ('dictionary') || '';
        # do cache
        $ctx->stash ($MYNAME. qq{::dictionary}, $dictionary);
    }

    my %map;
    map {
        next if /^\s*#/; # comment
        my ($src, $dst) = split /\|/;
        $src =~ s/^\s|\s+$//g;
        $dst =~ s/^\s|\s+$//g;
        $map{quotemeta $src} = MT::Util::encode_html ($dst)
            if $src =~ /\S+/ && $dst =~ /\S+/;
    } split /[\r\n]/, $dictionary;

    my $src = join '|', keys %map;
    $text =~ s!($src)!sub {
        if (defined $map{$1}) {
            my $out = qq{<abbr title="$map{$1}">$1</abbr>};
            delete $map{$1} unless $args eq 'all';
            return $out;
        }
        return $1;
    }->()!ge;
    $text;
}

1;