#!/bin/bash

# Задаем переменные для удобства
#PATH2LOG="/var/log/nginx/"
PATH2LOG="/home/beholder/OTUS-HW/HW-5/"
LOCK="/var/tmp/HW.lock"
LOG="HW.log"
AC_LOG="acces*.log"
ERR_LOG="error*.log"
EMAIL="antrekotik@yandex.ru"
LANG="en:en_GB" # специально, в логах локаль импортная

TIMESTAMP=`date +%d" "%b" "%Y" "%T` #
START=$TIMESTAMP 
# время старта скрипта

# Количество адресов в топе
X=10
Y=10

check_last_run()
{
#    LASTRUNTIME=`tac HW.log | grep -m1 STOP | awk -F" " '{ print $1, $2, $3, $4 }'`
    LASTRUNTIME="08 Nov 2018 09:16:09"
    echo $LASTRUNTIME
    str=`date -d "$LASTRUNTIME" +%s`
    echo "str= "$str
}

check_acc_log()
{
#set -x
    # Добываем IPшки, сортируем, складываем в кучку и считаем. Выдаем нужных Х штук с топа
    echo "Список "$X "самых часто используемых IP за заданный промежуток"
#    awk 'BEGIN { FS=" \\[?"} { print $1}' $AC_LOG | sort | uniq -c | sort -nr | head -n $X
    awk -v start="$str" 'BEGIN { FS=" \\[?"} { 
	cmd = "echo "$4" | awk -f ./date2sec.awk"; cmd | getline sec; if (sec > start) print $1 }' $AC_LOG | sort | uniq -c | sort -nr | head -n $X
    echo "Список "$Y "самых часто используемых запросов" # ~ проверка на паттерн, убираем см. ниже
    awk -v start="$str" 'BEGIN { FS=" \\[?"} { 
	cmd = "echo "$4" | awk -f ./date2sec.awk"; cmd | getline sec; if (sec > start && $6 ~ "\"[[:upper:]]?") print $7}' $AC_LOG | sort | uniq -c | sort -nr | head -n $Y
    echo "Список кодов возврата" # Убираем долбаные артефакты от попыток взлома или типо того, когда самого запроса формально нет, а есть хвосты типа /x00... Пока не знаю что это
    awk -v start="$str" 'BEGIN { FS=" \\[?"} { 
	cmd = "echo "$4" | awk -f ./date2sec.awk"; cmd | getline sec; if (sec > start && $6 ~ "\"[A-Z]+" ) print $9}' $AC_LOG | sort | uniq -c | sort -nr | head -n $Y
}

check_err_log()
{
    echo "111"
}

# Проверка на наличие лок-файла. Работает ли еще скрипт
if [ -f $LOCK ]; then
    echo "Lock file $LOCK exists! Script is running. Exit "
    exit 6
fi

# Вешаем лок-файл и отлавливаем сигнал на завершение
touch $LOCK
trap 'rm -f $LOCK; exit $?' INT TERM EXIT

echo $START " - START - Запущен скрипт" >> $LOG

check_last_run

check_acc_log

# Подчищаем за собой
echo $TIMESTAMP " - STOP - Остановлен скрипт" >> $LOG
rm -f $LOCK
trap - INT TERM EXIT
