# ESSE SCRIPT REALIZA A INSTALACAO DO BACULA.
# ANTES DA EXECUCAO LEIA AS LINHAS COMENTANDAS.

# link de referencia https://www.bacula.lat/community/comandos-de-compilacao/

#! /bin/bash

# REALIZA O DOWNLOAD DO BACULA,DESCOMPACTA E MOVE PARA PASTA /USR/SRC.

echo "[BAIXANDO PACOTE DO BACULA,DESCOMPACTANDO E MOVENDO PARA O DIRETORIO /USR/SRC]"

wget -qO- https://sitsa.dl.sourceforge.net/project/bacula/bacula/15.0.2/bacula-15.0.2.tar.gz?viasf=1 | tar -xzvf - -C /usr/src


# INSTALA AS DEPENDENCIAS E COMPILACOES DO SERVIDOR LINUX

echo "[INSTALANDO AS DEPENDENCIAS E COMPILACOES DO SERVIDOR LINUX]"

apt-get install -y build-essential libreadline6-dev zlib1g-dev liblzo2-dev mt-st mtx postfix libacl1-dev libssl-dev libmysql++-dev mysql-server

# CONFIGURA A COMPILACAO

echo "[CONFIGURANDO A COMPILACAO]"
read -p " DIGITE O JOB E-MAIL:" email
read -p " DIGITE O IP DO SERVIDOR BACULA:" ip
cd /usr/src/bacula*
./configure --with-readline=/usr/include/readline --disable-conio --bindir=/usr/bin --sbindir=/usr/sbin --with-scriptdir=/etc/bacula/scripts --with-working-dir=/var/lib/bacula --with-logdir=/var/log --enable-smartalloc --with-mysql --with-archivedir=/mnt/backup --with-job-email="$email" --with-hostname="$ip"

#PARA COMPILAR, INSTALAR E HABILITAR O INCIO AUTOMATICO DOS DAEMONS DO BACULA EM TEMPO DE BOOT

echo "[COMPILANDO, INSTALADNO E HABILITANDO O INICIO AUTOMATICO DO BACULA]"

make -j8 && make install && make install-autostart

#CRIANDO O BANCO DE DADOS
#SERA SOLICITADO A SENHA DE ROOT DO MYSQL, BASTA PRESSIONAR ENTER

echo "[CRIANDO O BANCO DE DADOS]"

chmod o+rx /etc/bacula/scripts/*
/etc/bacula/scripts/create_mysql_database -u root -p && \
/etc/bacula/scripts/make_mysql_tables -u root -p && \
/etc/bacula/scripts/grant_mysql_privileges -u root -p


#INICIE O SERVICO DO BACULA PELA PRIMEIRA VEZ.

echo "[INICIANDO O SERVIÇO DO BACULA PELA PRIMEIRA VEZ]"
service bacula-fd start && service bacula-sd start && service bacula-dir start

#ACESSO A CONSOLE.

bconsole
