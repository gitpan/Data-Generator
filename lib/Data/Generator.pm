package Data::Generator;

use Moose;

use Data::Dumper;
use SQL::Translator;

use DateTime;
use DateTime::Format::MySQL;
use String::Random;

with qw/
	MooseX::Getopt
/;

our $VERSION = "0.01_1";

has 'ddl'      	=> (is => 'rw', isa => 'Str', required => 1);
has 'lines'    	=> (is => 'rw', isa => 'Int', required => 1);

$| = 1;

sub BUILD {
   my ($self, $opt) = (@_);
   
   # ...
   
}


sub run {
   my ($self, $opt) = (@_);

   my $t = SQL::Translator->new(        
      show_warnings     => 1,
      add_drop_table    => 1,      
      quote_table_names => 1,
      quote_field_names => 1,
      parser            => 'MySQL',
      producer          => 'MySQL',
   );

   $t->filters( sub { $self->_filter(@_) }) or die $t->error;
   
   print $self->ddl."\n";
   
   $t->translate( $self->ddl );

}


sub _filter {        
   my ($self, $schema) = (@_);

   for my $table ( $schema->get_tables ) {   

      my @fields_func;
      
      print $table->name.":\n";

      foreach my $field ($table->get_fields) {
         $field->name(lc($field->name));
         $field->data_type(lc($field->data_type));
         
         print $field->name.' / '.$field->data_type.' / '.$field->size.' / '.$field->comments."\n";
         
         if ($field->comments =~ /^rand_/) {
            push @fields_func, $field->comments;
         }
         else {
            
            if ($field->data_type eq 'varchar') {
               push @fields_func, "rand_varchar({size => ".$field->size.", regex => '\\w\\w\\w\\w'})";
            }
            elsif ($field->data_type eq 'longblob') {
               push @fields_func, "rand_int()";
            }
            elsif ($field->data_type eq 'datetime') {
               push @fields_func, "rand_datetime({ year_start => 2000, year_end => 2010,})";
            }
            elsif ($field->data_type eq 'char') {
               push @fields_func, "chr(int(rand_int()))";
            }
            elsif ($field->data_type eq 'int') {
               push @fields_func, "rand_int()";
            }
            elsif ($field->data_type eq 'float') {
               push @fields_func, "rand_float()";
            }
            
         }
      }
      
      open (F, '>', './'.$table->name.'.csv');
                  
      for (1 .. $self->lines) {
         foreach my $func (@fields_func) {
            print F eval($func).";";
            print $@ if $@;
         }
         print F "\n";
      }
      close (F);
      

      print "\n\n";

   }

}



sub rand_datetime {
   my ($opt) = @_;
   
   my $dt = DateTime->new( 
      year   => $opt->{year_start} + int(rand($opt->{year_end} - $opt->{year_start})),
      month  => 1 + int(rand(11)),
      day    => 1 + int(rand(30)),
   );
   
   return DateTime::Format::MySQL->format_datetime($dt);
   
   
}




sub rand_varchar {
   my ($opt) = @_;
   
   my $str_random = String::Random->new;
   
   $opt->{size} = 10 unless defined($opt->{size});
   
   my $string;
   
   while (length($string) < $opt->{size}) {
      $string .= $str_random->randregex($opt->{regex}).' ';
   }
   
   chop($string);
   
   return $string;
   
}

sub rand_int {
   
   return int(rand(10))
   
}

sub rand_float {
   
   return int(rand(10))
   
}

1;


__END__

=head1 NAME

Data::Generator - A small data generator

=head1 STATUS

This module is experimental.

=head1 DESCRIPTION

Data::Generator's goal is to ease the task of creating a sample
data set based on a database schema.

It uses SQL::Translator and creates CSV files.


=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 AUTHOR

Eriam Schaffter C<< <eriam@cpan.org> >>


=cut


