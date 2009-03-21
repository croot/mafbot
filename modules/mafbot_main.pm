package mafbot_main;

########################################################################
# Основной модуль. Инклудить его надо во всех остальных модулях.
#
# Здесь объявляются основные перменные и основные функции
########################################################################

use strict;
use warnings;
use diagnostics;

use utf8;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(mafbot_get_chatjid %settings $client $presense);

# Хэш для хранения настроек
our %settings;

# Определяем основные перменные
our $client   = new Net::Jabber::Client();
our $presense = Net::Jabber::Presence->new();

########################################################################
# Функции на вход даётся строковый тип чата.
# Возвращает JID чата
sub mafbot_get_chatjid {
	my $chat_type = $_[0];
	my $chat_jid = $settings{'muc_'.$chat_type.'_room'}.'@'.$settings{'muc_'.$chat_type.'_server'};
	return $chat_jid;
}
########################################################################


########################################################################
# Функции на вход даётся JID чата.
# Возвращает строковый тип чата
sub mafbot_get_chattype {
	my $chat_jid = $_[0];
	# По умолчанию тип чата не известен
	my $chat_type;
	
	# Перебираем возможные типы чата
	foreach my $tmp_type ('main', 'mafia', 'peaceful') {
		# Формируем временную переменную - имя чата
		my $tmp_jid = $settings{'muc_'.$tmp_type.'_room'}.'@'.$settings{'muc_'.$tmp_type.'_server'};
		
		# Сравниваем временный JID с тем что на выходе функции
		if ((defined($tmp_jid)) && ($tmp_jid eq $chat_jid)) {
			# Если совпадает - значит нашли то что надо
			# Запоминаем результат
			$chat_type = $tmp_type;
			# И завершаем цикл
			last;
		}
		
	}
	return $chat_type;
}
########################################################################

1;
