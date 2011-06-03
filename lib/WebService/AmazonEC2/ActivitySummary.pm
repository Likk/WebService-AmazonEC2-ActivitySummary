package WebService::AmazonEC2::ActivitySummary;


=head1 NAME

WebService::AmazonEC2::ActivitySummary - Account Activity report scraper for perl.

=head1 SYNOPSIS

  use WebService::AmazonEC2::ActivitySummary;
  WebService::AmazonEC2::ActivitySummary->new(
    mail => q{your mailaddress},
    pass => q{your password},
  );

  my $report = $waa->run();
  print YAML::Dump $report;

=head1 DESCRIPTION

WebService::AmazonEC2::ActivitySummary is Bill Summary report of AmazonEC2 Account Activity.

=cut

use strict;
use warnings;

use WWW::Mechanize;
use Web::Scraper;
use HTTP::Cookies;

=head1 Package::Global::Variable

=over

=item B<VERSION>

=back

=cut

our $VERSION = '0.01';

=head1 CONSTRUCTOR AND STARTUP

=head2 new

Creates and returns a new Board object.:

=cut

sub new {
    my $class = shift;
    my %args  = @_;

    my $self = bless {%args}, $class;

    my $mech = WWW::Mechanize->new(
        agent => q{Mozilla/5.0 (Windows; U; Windows NT 6.1; ja; rv:1.9.2.10) Gecko/20100914},
    );
    $mech->cookie_jar( HTTP::Cookies->new(autosave => 1) );
    $self->{mech} = $mech;
    $self->{login_url} = 'http://aws-portal.amazon.com/gp/aws/developer/account/index.html?ie=UTF8&action=activity-summary';

    return $self;
}

=head1 METHODS

=head2 run

login amazon and get contents.

=cut
sub run {
    my $self = shift;
    my $mech = $self->{mech};
    $mech->get($self->{login_url});
    $mech->field('email'    => $self->{mail});
    $mech->field('create'   => '0');
    $mech->field('password' => $self->{pass});

    $mech->click_button( input => $mech->current_form()->find_input(undef, 'image') );

    my $report = $self->_perse($mech->content);
}

=head1 PRIVATE METHODS

=over

=item B<_perse>

scrape at contents.

=cut

sub _perse {
    my $self = shift;
    my $html = shift;
    my $scraper = scraper {
        process '//td[@class="bordgreybot txtxsm"]', 'descriptions[]' => 'TEXT';
        process '//td[@class="bordgreybot txtxsm alignrt"]', 'prices[]' => 'TEXT';
        result qw/descriptions prices/
    };
    my $result = $scraper->scrape($html);
    my $report = [];
    for my $i (0..$#{$result->{prices}}) {
        my $line = {
            value   => $result->{descriptions}->[$i*2 + 1],
            prices  => $result->{prices}->[$i],
        };
        push @$report, { $result->{descriptions}->[$i] => $line };
    }
    return $report;
}

=back

=head1 AUTHOR

Likkradyus E<lt>perl{at}likk.jpE<gt>

=head1 SEE ALSO

Web::Scraper;
L<http://aws.amazon.com/jp/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

__END__
