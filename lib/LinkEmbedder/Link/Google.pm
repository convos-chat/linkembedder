package LinkEmbedder::Link::Google;
use Mojo::Base 'LinkEmbedder::Link';

has provider_name => 'Google';
has provider_url => sub { Mojo::URL->new('https://google.com') };

has _query => '';

sub learn {
  my ($self, $cb) = @_;
  my $url  = $self->url;
  my @path = @{$url->path};
  my @query;

  push @query, $url->query->param('q') if $url->query->param('q');

  while (my $path = shift @path) {
    if ($path =~ /^\@\d+/) {
      $path =~ s!,\w+[a-z]$!!;    # @59.9195858,10.7633821,17z
      push @query, $path;
    }
    elsif ($path eq 'place' and @path) {
      push @query, shift @path;
      my $title = $query[-1];
      $title = Mojo::Util::url_unescape($query[-1]);
      $title =~ s!\+! !g;
      $self->title($title);
    }
  }

  return $self->SUPER::learn($cb) unless @query;
  $self->_query(join ' ', @query);
  $self->type('rich');
  $self->$cb if $cb;
  $self;
}

sub _template {
  my $self = shift;
  return $self->SUPER::_template unless $self->_query;
  return __PACKAGE__, sprintf 'rich.html.ep';
}

1;

__DATA__
@@ rich.html.ep
<iframe width="600" height="400" style="border:0;width:100%" frameborder="0" allowfullscreen
  src="https://www.google.com/maps?q=<%= Mojo::Util::url_escape($l->_query) %>&output=embed">
</iframe>
