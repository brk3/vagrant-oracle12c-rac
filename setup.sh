#!/bin/sh

# convert into Oracle Linux 6
curl -O https://linux.oracle.com/switch/centos2ol.sh
sh centos2ol.sh
yum upgrade -y

# fix locale warning
echo LANG=en_US.utf-8 >> /etc/environment
echo LC_ALL=en_US.utf-8 >> /etc/environment

# install Oracle Database prereq packages
yum install -y oracle-rdbms-server-12cR1-preinstall

# install UEK kernel
yum install -y kernel-uek-devel
grubby --set-default=/boot/vmlinuz-2.6.39*

# fix /etc/hosts
HOST=`hostname`
cat > /etc/hosts << EOF
127.0.0.1   localhost localhost.localdomain $HOST
192.168.101.11  node1
192.168.101.12  node2
192.168.101.21  node1-vip
192.168.101.22  node2-vip
192.168.101.100 scan
192.168.102.11  node1-priv
192.168.102.12  node2-priv
EOF

# add user/groups
groupadd -g 54318 asmdba
groupadd -g 54319 asmoper
groupadd -g 54320 asmadmin
# 54321 oinstall
# 54322 dba
groupadd -g 54323 oper

useradd -u 54320 -g oinstall -G asmdba,asmoper,asmadmin,dba grid
usermod -a -g oinstall -G dba,oper,asmdba oracle

echo oracle | passwd --stdin grid
echo oracle | passwd --stdin oracle

# setup users
cat >> /home/grid/.bash_profile << 'EOF'
export ORACLE_HOME=/u01/12.1.0.1/grid
export ORACLE_SID=`hostname | sed "s/node/+ASM/g"`
export PATH=$PATH:$ORACLE_HOME/bin
EOF

cat >> /home/oracle/.bash_profile << 'EOF'
export ORACLE_HOME=/u01/oracle/product/12.1.0.1/dbhome_1
export ORACLE_SID=`hostname | sed "s/node/orcl/g"`
export PATH=$PATH:$ORACLE_HOME/bin
EOF

cat >> /etc/security/limits.conf << EOF
oracle   soft   nofile   1024
grid     soft   nofile   1024
oracle   hard   nofile   65536
grid     hard   nofile   65536
oracle   soft   nproc    2047
grid     soft   nproc    2047
oracle   hard   nproc    16384
grid     hard   nproc    16384
oracle   soft   stack    10240
grid     soft   stack    10240
oracle   hard   stack    32768
grid     hard   stack    32768
EOF

# add directories, setup permissions
mkdir -p /u01/grid /u01/oraInventory /u01/12.1.0.1/grid /u01/oracle/product/12.1.0.1/dbhome_1
chown -R oracle:oinstall /u01
chown -R grid:oinstall /u01/grid
chown -R grid:oinstall /u01/oraInventory
chown -R grid:oinstall /u01/12.1.0.1
chmod -R ug+rw /u01

# set shared disk permission
chown grid:asmadmin /dev/sdb
cat > /etc/udev/rules.d/99-sdb.rules << EOF
KERNEL=="sdb", OWNER="grid", GROUP="asmadmin", MODE="0666"
EOF

# setup ssh equivalence (node1 only)
if [ `hostname` == "node1" ]
then
  yum install -y expect
  expect /vagrant/ssh.expect grid oracle
  expect /vagrant/ssh.expect oracle oracle
fi

# confirm
cat /etc/oracle-release
