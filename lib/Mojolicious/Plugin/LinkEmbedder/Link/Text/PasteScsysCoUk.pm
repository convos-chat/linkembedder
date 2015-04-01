package Mojolicious::Plugin::LinkEmbedder::Link::Text::PasteScsysCoUk;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Link::Text::PasteScsysCoUk - paste.scsys.co.uk link

=head1 DESCRIPTION

This class inherit from L<Mojolicious::Plugin::LinkEmbedder::Link::Text>.

=head1 OUTPUT HTML

This is an example output:

  <pre class="link-embedder text-paste">$txt</pre>

=cut

use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Text';
use Mojo::Util ();

=head1 ATTRIBUTES

=head2 media_id

  $str = $self->media_id;

=cut

has media_id => sub {
  shift->url->path =~ m!^/?(\d+)! ? $1 : '';
};

=head2 provider_name

=cut

sub provider_name {'scsys.co.uk'}

=head1 METHODS

=head2 learn

=cut

sub learn {
  my ($self, $c, $cb) = @_;
  my $media_id = $self->media_id or return $self->SUPER::learn($c, $cb);
  my $url = Mojo::URL->new('http://paste.scsys.co.uk');

  $url->path($media_id)->query(tx => 'on');

  $self->ua->get(
    $url,
    sub {
      my ($ua, $tx) = @_;
      $self->{text} = Mojo::Util::xml_escape($tx->res->body) if $tx->success;
      $self->$cb;
    },
  );
}

=head2 to_embed

Returns the HTML code for a script tag that writes the gist.

=cut

sub to_embed {
  my $self = shift;

  return $self->SUPER::to_embed unless $self->{text};
  return $self->tag(pre => class => 'link-embedder text-paste', sub { $self->{text} });
}

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
