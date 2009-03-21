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

1;
