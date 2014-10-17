package Mojolicious::Plugin::LinkEmbedder::Link::Text::Github;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Link::Text::Github - github.com link

=head1 DESCRIPTION

This class inherit from L<Mojolicious::Plugin::LinkEmbedder::Link::Text::HTML>.

=cut

use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Text::HTML';

sub _learn_from_dom {
  my ($self, $dom) = @_;
  my $e;

  $self->SUPER::_learn_from_dom($dom);

  if ($e = $dom->at('title')) {
    $self->title($e->text);
  }

  for my $e ($dom->find('#readme p')->each) {
    my $text = $e->text || '';
    $text =~ /\w/ or next;
    $self->title($self->description);
    $self->description($text);
    last;
  }

  if ($e = $dom->at('.js-issue-title')) {
    $self->title($e->text);
  }
  if ($e = eval { $dom->at('#partial-discussion-header a.author')->parent }) {
    $self->description($e->all_text);
  }
}

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
