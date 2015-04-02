package Mojolicious::Plugin::LinkEmbedder::Link::Text;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Link::Text - Text URL

=head1 DESCRIPTION

This class inherit from L<Mojolicious::Plugin::LinkEmbedder::Link>.

=cut

use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link';
use Mojo::Util ();

=head1 METHODS

=head2 raw_url

=cut

sub raw_url { shift->url->clone }

=head2 to_embed

Returns the HTML code for a script tag that writes the gist.

=cut

sub to_embed {
  return $_[0]->SUPER::to_embed unless $_[0]->{text};

  my $self     = shift;
  my $media_id = $self->media_id;
  my $text     = Mojo::Util::xml_escape($self->{text});

  return <<"  HTML";
<div class="link-embedder text-paste" data-paste-provider="@{[$self->provider_name]}" data-paste-id="@{[$self->media_id]}">
  <pre>$text</pre>
  <div class="paste-meta">
    <a href="@{[$self->raw_url]}" target="_blank">view raw</a>
    hosted by <a href="@{[$self->pretty_url]}">@{[$self->provider_name]}</a>
  </div>
</div>
  HTML
}

=head1 AUTHOR

Jan Henning Thorsen - C<jhthorsen@cpan.org>

=cut

1;
