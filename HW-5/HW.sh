#!/bin/bash

# Задаем переменные для удобства
PATH2LOG="/var/log/nginx/"
LOCK="/var/tmp/HW.lock"
LOG="HW.log"
AC_LOG="access.log"
EMAIL="antrekotik@yandex.ru"
LANG="en:en_GB" # специально, в логах локаль импортная
TIMESTAMP=`date +%d/%b/%y:%T`
START=$TIMESTAMP

X=10
Y=10

check_last_run()
{
#    LASTRUNTIME=`tac HW.log | grep -m1 STOP | awk -F" " '{ print $1 }'`
    LASTRUNTIME="20/Sep/2018:04:34:47"
}

check_acc_log()
{
    # Добываем IPшки, сортируем, складываем в кучку и считаем. Выдаем нужных Х штук с топа
    echo "Список "$X "самых часто используемых IP"
    awk 'BEGIN { FS = " \[?"} { if ($4>="'$LASTRUNTIME'") print $1}' $AC_LOG | sort | uniq -c | sort -nr | head -n $X
    echo "Список "$Y "самых часто используемых запросов"
    awk 'BEGIN { FS = " \[?"} { if ($4>="'$LASTRUNTIME'" && $11~"http:*") print $11}' $AC_LOG | sort | uniq -c | sort -nr | head -n $Y
    echo "Список кодов возврата"
    awk 'BEGIN { FS = " \[?"} { if ($4>="'$LASTRUNTIME'") print $9}' $AC_LOG | sort | uniq -c | sort -nr | head -n $Y
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

