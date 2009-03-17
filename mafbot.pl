#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;

use HTML::Entities;
use Net::XMPP;
use Net::Jabber;
use utf8;

use lib './modules';

use game;

# Список файлов конфигурации для перебора
my @configs = (
    $ENV{'HOME'}.'/.mafbot',   # Пользовательский файл конфигурации
    '/etc/mafbot.conf',        # Системный конфиг
);

# Хэш для хранения настроек
my %settings;

# Перебираем все файлы конфигурации
foreach my $config (@configs) {
    # Если файл существует и доступен для чтения
    if ( ( -e $config ) && ( -r $config) ) {
	# Читаем конфигурацию
	open(CONFIG, '<'.$config);
	local $/ = undef;
	my $config_data = <CONFIG>;
	close(CONFIG);
	%settings = eval($config_data);
	# Выходим из цикла
	last;
    }
}

# Если не удалось прочитать настройки - завершаем работу
if (!%settings) {
    die("Can't read settings!");
}

# Определяем основные перменные
my $client   = new Net::Jabber::Client();
my $presense = Net::Jabber::Presence->new();

# Определяем обработчики событий
$client->SetCallBacks(
    'message' => \&on_message,
);

# Подключаемся к сети
# TODO: Обрабатывать ошибки подключения
$client->Connect(
    'hostname'        => $settings{'server'},
    'port'            => $settings{'port'},
);

my @connect = $client->AuthSend(
    'username'        => $settings{'username'},
    'password'        => $settings{'password'},
    'resource'        => $settings{'resource'},
);

# Устанавливаем статус
$presense->SetType("available");
$presense->SetStatus("");
$client->Send($presense);

# Входим в конференции
foreach my $conf ('mafia', 'main', 'peaceful') {
    print $conf."\n";
    $client->MUCJoin(
	'room'     => $settings{'muc_'.$conf.'_room'},
        'server'   => $settings{'muc_'.$conf.'_server'},
	'nick'     => $settings{'muc_'.$conf.'_nick'},
        'password' => $settings{'muc_'.$conf.'_password'},
    );
}

# Функция обработки сообщений
sub on_message {
    my $mid = shift || return;
    my $msg = shift || return;

    # Получаем ник отправителя
    my $sender_nick = new Net::XMPP::JID($msg->GetFrom)->GetResource;
    # Получаем имя конференции, где оно было сказано
    my $sender_chat = new Net::XMPP::JID($msg->GetFrom)->GetJID("base");
    # Получаем тело сообщения
    my $msg_body = $msg->GetBody;
    # Получаем тип сообщения
    my $msg_type = $msg->GetType;
    

}

# Цикл обработки сообщений
while (defined($client->Process)) {
}

# На всякий случай закрываем соединение
$client->Disconnect();
