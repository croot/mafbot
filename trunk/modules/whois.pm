package whois;

use strict;
use warnings;
use diagnostics;

use utf8;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(process_whois);

use Net::Whois::Raw;

# Обрабатываем whois
sub process_whois {
    my $sender_nick = $_[0];
    my $msg_body = $_[1];
    
    $msg_body =~ s!^whois !!;
    
    my $result = "$sender_nick: ";
    
    # Если есть что определять
    if ($msg_body && $msg_body =~ m{^[\d\w+\._-]+$}i) {
	# Определяем
    	$result .= get_whois($msg_body);
    }
    # Если нет
    else {
	# Сообщаем об ошибке
    	$result .= "Использование: \"!whois domian_name\"";
    }
    return $result;
}
                        	    	        