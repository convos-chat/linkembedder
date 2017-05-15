package Mojolicious::Plugin::LinkEmbedder::Link::Text::HTML;
use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Text';

has audio       => '';
has canon_url   => sub { shift->url };
has description => '';
has image       => '';
has title       => '';
has type        => '';
has video       => '';

sub learn {
  my ($self, $c, $cb) = @_;

  $self->ua->get(
    $self->url,
    sub {
      my ($ua, $tx) = @_;
      my $dom = $tx->success ? $tx->res->dom : undef;
      $self->_tx($tx)->_learn_from_dom($dom) if $dom;
      $self->$cb;
    },
  );

  $self;
}

sub to_embed {
  my $self = shift;

  if ($self->image) {
    return $self->tag(
      div => class => 'link-embedder text-html',
      sub {
        return join(
          '',
          $self->tag(
            div => class => 'link-embedder-media',
            sub { $self->tag(img => src => $self->image, alt => $self->title) }
          ),
          $self->tag(h3 => $self->title),
          $self->tag(p  => $self->description),
          $self->tag(
            div => class => 'link-embedder-link',
            sub {
              $self->tag(a => href => $self->canon_url, title => $self->canon_url, $self->canon_url);
            }
          )
        );
      }
    );
  }

  return $self->SUPER::to_embed(@_);
}

sub _learn_from_dom {
  my ($self, $dom) = @_;
  my $e;

  $self->audio($e->{content}) if $e = $dom->at('meta[property="og:audio"]');

  $self->description($e->{content} || $e->{value})
    if $e = $dom->at('meta[property="og:description"]') || $dom->at('meta[name="twitter:description"]');

  $self->image($e->{content} || $e->{value})
    if $e
    = $dom->at('meta[property="og:image"]')
    || $dom->at('meta[property="og:image:url"]')
    || $dom->at('meta[name="twitter:image"]');

  $self->title($e->{content} || $e->{value} || $e->text || '')
    if $e = $dom->at('meta[property="og:title"]') || $dom->at('meta[name="twitter:title"]') || $dom->at('title');

  $self->type($e->{content}) if $e = $dom->at('meta[property="og:type"]') || $dom->at('meta[name="twitter:card"]');
  $self->video($e->{content}) if $e = $dom->at('meta[property="og:video"]');
  $self->canon_url($e->{content} || $e->{value})
    if $e = $dom->at('meta[property="og:url"]') || $dom->at('meta[name="twitter:url"]');
  $self->media_id($self->canon_url) if $self->canon_url and !defined $self->{media_id};
}

1;
