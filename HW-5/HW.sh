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
TIMESTAMP=`date +%d/%b/%Y:%T`
START=$TIMESTAMP

X=10
Y=10

check_last_run()
{
#    LASTRUNTIME=`tac HW.log | grep -m1 STOP | awk -F" " '{ print $1 }'`
    LASTRUNTIME="09\/Nov\/2018:03:16:09"
    echo $LASTRUNTIME
#    echo `date -d $LASTRUNTIME +%s`

}

check_acc_log()
{
set -x
    # Добываем IPшки, сортируем, складываем в кучку и считаем. Выдаем нужных Х штук с топа

#    sed -n '/09\/Nov\/2018:03:16:09/,$'p test | awk 'BEGIN { FS=" \\[?" } { print $4}'
    sed -n "/$LASTRUNTIME/,$"p test | awk 'BEGIN { FS=" \\[?" } { print $4}'

    echo "Список "$X "самых часто используемых IP"
    awk 'BEGIN { FS=" \\[?"} { print $1}' $AC_LOG | sort | uniq -c | sort -nr | head -n $X
    echo "Список "$Y "самых часто используемых запросов" # ~ проверка на паттерн, убираем см. ниже
    awk 'BEGIN { FS=" \\[?"} { if ($6 ~ "\"[[:upper:]]?") print $7}' $AC_LOG | sort | uniq -c | sort -nr | head -n $Y
    echo "Список кодов возврата" # Убираем долбаные артефакты от попыток взлома или типо того, когда самого запроса формально нет, а есть хвосты типа /x00... Пока не знаю чтоно что это
    awk 'BEGIN { FS=" \\[?"} { if ($6 ~ "\"[A-Z]+" ) print $9}' $AC_LOG | sort | uniq -c | sort -nr | head -n $Y
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

