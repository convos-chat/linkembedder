package Mojolicious::Plugin::LinkEmbedder::Link::Text;
use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link';
use Mojo::Util ();

sub raw_url { shift->url->clone }

sub to_embed {
  return $_[0]->SUPER::to_embed unless $_[0]->{text};

  my $self     = shift;
  my $media_id = $self->media_id;
  my $text     = $self->{text};

  return <<"  HTML";
<div class="link-embedder text-paste">
  <div class="paste-meta">
    <span>Hosted by</span>
    <a href="http://@{[$self->url->host_port]}">@{[$self->provider_name]}</a>
    <span>-</span>
    <a href="@{[$self->raw_url]}" target="_blank">View raw</a>
  </div>
  <pre>$text</pre>
</div>
  HTML
}

1;
