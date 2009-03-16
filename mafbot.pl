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

# Входим в конференцию
$client->MUCJoin(
    'room'     => $settings{'muc_room'},
    'server'   => $settings{'muc_server'},
    'nick'     => $settings{'muc_nick'},
    'password' => $settings{'muc_password'},
);

# Функция получения ответа на сообщение
sub GetReplyMsg {
    my $sender_nick = $_[0];
    my $msg_body = $_[1];
    
    # Если сообщение адресовано конкретно боту или начинается с восклицательного знака
    if ($msg_body =~ s!^$settings{'muc_nick'}(?:: | )!! || $msg_body =~ s!^\!(\w+\.*)!$1!) {
	# Если команда help
	if ( $msg_body =~ m{^help$}i ) {
	    my $help_message = "$sender_nick: \n";
	    $help_message .= "Я пока почти ничего не умею:(\n";
	    $help_message .= "Сейчас можете попробовать следующие команды:\n";
	    $help_message .= "game - простая игра с ботом\n";
	    $help_message .= "help - вывод этой справки\n";
	    $help_message .= "rand - генерация случайного числа от 1 до 6\n";
	    #$help_message .= "whois - получением информации об указанном домене\n";
	    return $help_message;
	}
	# Если команда rand
	if ( $msg_body =~ m{^rand$}i ) {
	    return "$sender_nick: ".int(rand(6)+1);
	}
	# Если команда game
	if ( $msg_body =~ m{^game}i ) {
	    return process_game( $sender_nick, $msg_body);
	}
    }
    return undef;
};

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
    
    
    if (
	( $sender_chat eq $settings{'muc_room'}.'@'.$settings{'muc_server'} ) # Если сообщение сказано в чате
	&& ( $msg_type eq 'groupchat' ) # Сказанно именно в чате, а не в привате
	) {
	
	# Обрабатываем сообщение и возвращаем ответ
	my $reply_text = GetReplyMsg($sender_nick, $msg_body);
	
	# Если ответ определён
	if ($reply_text) {
	    my $reply = Net::Jabber::Message->new();
    	    $reply->SetMessage(
		    'to'   => $sender_chat,
	    	    'body' => $reply_text,
	    	    'type' => 'groupchat',
	    );
	    $client->Send($reply);
	}
    }
    
}

# Цикл обработки сообщений
while (defined($client->Process)) {
}

# На всякий случай закрываем соединение
$client->Disconnect();
