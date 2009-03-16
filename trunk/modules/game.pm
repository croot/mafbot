package game;

use strict;
use warnings;
use diagnostics;

use utf8;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(process_game);

# Хэш для хранения данных игры
my %game_data;

sub process_game {
    my $sender_nick = $_[0];
    my $msg_body = $_[1];

    $msg_body =~ s!^game !!;
    
    # Возвращаемое сообщение
    my $return_msg = "$sender_nick: ";
    
    # Если команда start - начинаем игру
    if ( (defined($msg_body)) && ($msg_body eq 'start') ) {
        # Нижняя граница
	my $min = 1+int(rand(10));
	my $max = 2+int(rand(10));
	# Случайное число
	my $rnd = $min+int(rand($max));
	
	# Верхняя граница диапазона
	$max = $min+$max;
	$game_data{$sender_nick} = $rnd;
	$return_msg .= "Я загадал число. Оно принадлежит интервалу от $min до $max.";
    }
    # Если команда end - заканчиваем игру
    elsif ( (defined($msg_body)) && ($msg_body eq 'end') && (defined($game_data{$sender_nick})) ) {
	$return_msg .= "Эх ты. Я загадал ".$game_data{$sender_nick}."\n";
        # Обнуляем данные игры
        delete $game_data{$sender_nick};
    }

    # Если команда число - проверяем определённость необходимых перменых
    # И если всё существует - проверяем ответ
    elsif ( (defined $msg_body) && ($msg_body =~ m{^\d+$}) && (defined($game_data{$sender_nick})) ) {
	# Если угадано верно
	if ( $game_data{$sender_nick} == $msg_body ) {
	    $return_msg .= "Ты угадал:)";
	    # Обнуляем данные игры
	    delete $game_data{$sender_nick};

	}
	# Если неугадано
	else {
	    $return_msg .= "Неправильно:)";
	}
	
    }
    # Если любая другая команда - выдаём справку
    else {
	$return_msg .= "В игре тебе будет предложено угадать загаданое мной число.\n";
	$return_msg .= "Для начала игры введи команду \"!game start\".\n";
	$return_msg .= "В ответ я скажу тебе в каком диапазоне я загадал число.\n";
	$return_msg .= "Чтобы назвать свой варианте введи команду \"!game твоё_число\"  и я скажу прав ты или нет:)";
	$return_msg .= "Чтобы закончить игру введи команду \"!game end\"\n";
    }
    return $return_msg;
}

1;
