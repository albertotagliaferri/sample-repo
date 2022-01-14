#!/bin/sh
#  $Revision: 1.2.214.2 $ $Date: 96/11/25 11:28:01 $ $Author:    $
set -v
VERSION=1.2.214.2.tocadoAT

# Copyright Synchro Technologies S.A., 2005-2012
#
# SG: encontrar los archivos de configuracion aun con ubicaciones no standard
#     (x ej., usar "cmviewconf" para localizar los archivos o

# Cabios 1.2.214 (versionado SVN)
# -Uso de cmgetconf para obtener los ".conf" de cluster y pkg
# 
# Cambios 2.0.26
# -Relevamiento info VxVM
# -Mejora muestra de files bajo /etc/cmcluster
# -Mostrar "ioscan -m dsf"
# -Manejar mejor discos con secciones al mostrar diskinfo(1m)
# -Informacion de Virtual Machines, agreado de /opt/hpvm/bin a PATH
#
# Cambios 2.0.25
# -Mostrar procesos AIO
#
# Cambios 2.0.24
# -Se movio la definicion de las funciones de apoyo a la documentacion para
#  que estuvieran junto con el resto de las funciones de apoyo (fuera del
#  subshell de ejecucion: (...)|gzip >$OUT
# -Mostrar valores de TIMEZONE
# -Diskinfo mostraba solo la ultima particion en discos IA con secciones
#  y tambien sinonimos no estandar de /rdsk/
# -Mostrar links simbolicos bajo /usr/sap/SID (util para relevar el
#  layout de fs a nivel SAP)
# -Mostrar /etc/cmcluster/sap.functions en caso de existir
# -
#  
# Cambios 2.0.23
# -Correccion que hacia que se colgara el mostrado de files
#  bajo /etc/cmcluster
# -Se movieron los agregados para documentacion al final del script
#
# Cambios 2.0.22
# -Mostrar ultimas lineas de los logs bajo /etc/cmcluster
#
# Cambios 2.0.21
# -Mejora scripting para relevar SAP, Oracle e Informix
# -Luego de informar valor de umask, ajustar a un valor seguro para proteger
#  los temporales de la ejecucion de este script.
# -landisp seteaba TMP con mktemp(1) y afectaba los temporales del resto
#  del script: no se borraban al terminar. Comente el seteo, landisp
#  debe usar la variable TMP global que viene seteada
# -se elije fcmsutil / tdutil de acuerdo al driver involucrado.
#  faltaba incluir el /dev en los pedidos de estado vpd / stat
#
# Cambios 2.0.20
# -Actualizo el landisp 
#
# cambios 2.0.19
# -Agrego soporte para informes de EMC similar al xpinfo
#
# cambios 2.0.18
# -mostrar /var/opt/perf/parm
# -mostrar version VPAR
#
# cambios 2.0.17
# -habilitacion de varios comandos cstm en "cstm_cmds"
# -agregado "set -x" a los comandos sqlplus y demas que relevan Oracle	
#
# cambios 2.0.16
# -relevamiento configuracion TCP/IP stack
# -relevamiento oracle: listado de datafiles, redo y cf
#
# cambios 2.0.15
# -detalles de bancos y SIMS
# -mostar actividad con algunos sar(1m)
# -buscar informacion de SAP, Informix y Oracle: versiones y configuracion
#
# cambios 2.0.14
# - informacion de DP: clientes, devices
#
# cambios 2.0.13
# - landisp comtempla 'RAD' no definido
# - "lvdisplay -v" - correccion detalle distribucion LE
# - "cpumodel" comentado (Ale Scrina reporta colgada en un equipo rp)
# - test "spmgr" corregido ("spmgr display" no se mostraba nunca)
#
# cambios 2.0.12
# - "contar_procesadores": reescrita (top dejo de ser fiable)
# - "lvdisplay -v" incluye mejor detalle de distribución LE
# - "xpinfo -i" previo es reusado en "xplibre"
#
# cambios 2.0.11
#  - relevamiento SG: mostrar todo en directorios de paquete salvo *.log.
#
# cambios 2.0.10
#  - relevamiento FC con tdutil, fcmsutil
#  - xpinfo full
#  - funcion "printpass" para mostrar /etc/passwd suprimiendo las claves

# cambios 2.0.9
#  - echodotmout: ejecutar con timeout
#  - relevamiento LP
#  - modelo procesadores
#  - grep "smart relay" en sendmail.cf

# cambios 2.0.8
#  -relevamiento SG: mostrar primera parte de los cntl
#  -incorporar "mount" (opciones de montado)
#
# cambios 2.0.7
#  -detalles tarjetas red (lanadmin(1m)): velocidad, mtu, errores
#  -"lanscan -v" (para mostrar driver)
#  -inclusion "inq" para relevar EMC
#
# cambios 2.0.6.1
#  -relevar EVA: "spmgr display"
#  -ps -efH con UNIX95=""
#
# cambios 2.0.5
#  -mostrar procesos (ps -ef)
#  -mostrar contenido areas LIF de discos boot
#
# cambios 2.0.4
#   -mostrar shutdownlog, crontab
#
# cambios 2.0.3
#   -seteo de PATH (util para remsh: no da el PATH seteado)
#   -echodo: marcar con "\t#" el final de las lineas
#   -lifcp autofile: se revisaban los discos de vg00 (podia contener discos no
#    booteables que daban errores) cambie "vgdisplay -v vg00" por
#    "lvlnboot -v vg00" que es mas adecuado para buscar los discos booteables.
#   -el "vgdisplay -v" para buscar LVs y hacer "lvdisplay" podia arrojar errores
#    "vg no activado": redirigi stderr a /dev/null
#
# cambios 2.0.2
#   -inclusion condicional de inf. hw. particionable, icod, config. MC/SG,
#    xpinfo
#   -inclusion de distribucion de LV en PV en lvdisplays
#   -eliminacion de filestes en estado "configured" del swlist -a state
#   -reemplazar "cat syslog.log" por head y tail si es muy grande
#   -archivo de salida comprimido
#   -cantidad de procedadores contados con "top"

OUT=/tmp/$(hostname)-$(date +%d%b).out.gz
TMP=/tmp/$$.tmp
TMP2=/tmp/$$.tmp2
export PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/contrib/bin:/opt/fcms/bin:/opt/hpvm/bin
# CATSYSLOG='grep -v -e "su: " -e "ftpd\[.*\]: " -e "sshd\[.*\]: " /var/adm/syslog/syslog.log'
CATSYSLOG='cat /var/adm/syslog/syslog.log'

VERBOSE=0
trap "rm -f /tmp/$$.*" 0
if test "$1" = -v; then
	export VERBOSE=1
fi


RAD=""
if rad -q >/dev/null 2>&1; then
	RAD=rad
elif olrad -q >/dev/null 2>&1; then
	RAD=olrad
fi

KCTUNE=""
if kctune >/dev/null 2>&1; then
	KCTUNE=kctune
elif kmtune >/dev/null 2>&1; then
	KCTUNE=kmtune
fi

echodo ()
{
        test "$VERBOSE" = 1 && echo "## $*" >/dev/tty
        echo "\n## $*	#"
        eval "$@" 2>&1
	return $?
}

echodotmout ()
{
	export TIEMPO=5	# 5 segundos por defecto
	if [ "$1" = "-t" ]; then
		TIEMPO="$2"
		shift 2
		echo "echodotmout: '$*'"
	fi
        echodo "$*" & P=$!
        (sleep $TIEMPO; kill -0 $P 2>/dev/null && echo "$*" ha excedido los $TIEMPO segundos: se matara el proceso; kill $P 2>/dev/null) &
        wait $P
}

unfold ()
{
        case "$1" in
        [0-9]*) lines=$1
                shift 1
                ;;
        *)      echo "uso: $0 lines" 1>&2
                exit 1
                ;;
        esac

        awk -v lines=$lines '{if (n == lines) {print "" ; n = 0;} n++; printf "%s ", $0}' $*
}

contar_procesadores()
{
   # parse_top=`TERM=adm3a top -d1 -n1 | awk '/^Cpu /,/^$/ {print;}' | wc -l`
   parse_sar=`sar -M 1 1|grep -v -e %usr -e system -e HP-UX -e '^$' |wc -l`
   parse_ioscan=`ioscan -kC processor|grep -i processor|wc -l`

   echo $parse_sar[sar] $parse_ioscan[ioscan]
}

##
## xplibre: muestra discos XP no asignados a ningun VG
xplibre()
{
	xpinfodata=$1
	existe=/tmp/$$.xplibre.xpinfo
	uso=/tmp/$$.xplibre.uso

	grep /dev $xpinfodata|awk '{print $1}' |sed 's,$,-,' >$existe
	strings /etc/lvmtab |grep /dev/dsk|sed -e 's,dsk,rdsk,' -e 's,$,-,' >$uso

	grep -v -f $uso $existe | sed 's,-$,,'
	rm $existe $uso
}

##
## cpumodel:
cpumodel ()
{
	# echo "$(grep $(model|awk -F/ '{print $NF}') /usr/sam/lib/mo/sched.models) \c"
	# echo "$(echo itick_per_usec/D | adb -k /stand/vmunix /dev/mem | cut -d: -f2) Mhz"
	:
}

##
## landisp:
landisp ()
{
# TMP=$(mktemp -c -p landisp)
olrad -q >$TMP 2>/dev/null || rad -q >$TMP 2>/dev/null
lanscan | grep 0x | awk '{print $1,$5}' |
while read hw lan; do
        ip=$(netstat -in|grep "^$lan "|awk '{print $4}')
        set $(echo $hw|sed 's,/, ,g')
        h=$1; shift 1
	slot=""
        for i in $*; do
                h="$h/$i"
                if test $(grep " $h " $TMP | wc -l) -eq 1; then
                        slot=$(grep " $h " $TMP | awk '{print $1}')
                        break
                fi
        done
	if $(lanadmin -x ${lan#lan} | grep -q -e "The link is down" -e "NO LINK"); then
		lan_state="no_link"
	else
		lan_state=$(lanadmin -x ${lan#lan} 2>/dev/null)
		if $(echo $lan_state | grep -q Speed ) ;then
			lan_state=$(echo $lan_state | grep Speed| awk '{print $3 $4}')
		else
			lan_state=$(echo $lan_state | cut -d= -f2|sed 's/ //g')
		fi
	fi
	if [ x$slot = "x" ]; then
		slot="NA"
	fi
        echo $lan $hw $slot $lan_state $ip
done |
awk '{printf "%-5s %-20s %-10s %-15s %s\n", $1, $2, $3, $4 ,$5}'
rm $TMP
}


##
## printpasswd
printpass ()
{
	awk -F: '{printf "%s:<suprimido>:%s:%s:%s:%s:%s\n", $1, $3, $4, $5, $6, $7}' /etc/passwd
}

##
## bdf: evitar que renglones largos se partan en dos
bdf ()
{
	/usr/bin/bdf|
	awk '{printf "%s", $0; if (NF > 1) printf "\n"}'|
	awk '{printf "%-25s %10s %10s %10s %6s %s\n", $1, $2, $3, $4, $5, $6, $7}'
}

cstm_cmds ()
{
#	echo "HBA"
#	echodo echodo cstm <<-END | grep -i tachyon | awk '{ print $3 }'
#	map
#	selall
#	wait
#	cds
#	wait
#	done
#END

	# Esto es otra forma de hacer lo mismo que arriba
	echo "HBA2"
	echodo cstm <<-END
	map
	selall
	wait
	cds
	wait
	done
END

	echo procinfo
	echodo cstm <<-END
	selclass qualifier cpu
	info
	wait
	infolog
END

	echo memory
	echodo cstm <<-END
	selclass qualifier memory
	info
	wait
	infolog
END
}

tcpipconf ()
{
	for m in tcp udp ip sockets arp; do
		modulo=/dev/$m
		ndd $modulo \?|awk '{print $1}'|
		sed -e 's/(.*//'|
		grep -v -e '^?' -e ip_ire_hash -e status -e report|
		while read p; do
			echo "# ndd $modulo $p \c"
			ndd $modulo $p
		done
	done|
	awk '{printf "%s %s %-10s %-40s %d\n", $1, $2, $3, $4, $5}'
	# Ejemplo:
	#     1	#
	#     2	ndd
	#     3	/dev/tcp
	#     4	tcp_time_wait_interval
	#     5	60000
}

discos_locales (){
disloc=`echo "map" |  cstm |  grep -i disk | awk '{print $2}'`
for f in $disloc
do
	 ioscan -kfnC disk | awk  -v HWP=$f ' $3  ~ HWP  {print;getline;print }'
 done

	}

landisp2(){
TMP=$(mktemp -c -p landisp)
get_driver(){
lanscan -v > /tmp/lanscanv.txt
awk -v search="$1" ' BEGIN { RS="---"; FS="---" }
 $0 ~ search  { print  }' /tmp/lanscanv.txt
 }

olrad -q >$TMP 2>/dev/null || rad -q >$TMP 2>/dev/null
lanscan | grep 0x | awk '{print $1,$5,$2}' |
while read hw lan mac; do
        ip=$(netstat -in|grep "^$lan "|awk '{print $4}')
        red=$(netstat -in|grep "^$lan "|awk '{print $3}')
        set $(echo $hw|sed 's,/, ,g')
        h=$1; shift 1
	slot=""
        for i in $*; do
                h="$h/$i"
                if test $(grep " $h " $TMP | wc -l) -eq 1; then
                        slot=$(grep " $h " $TMP | awk '{print $1}')
                        break
                fi
        done
	if $(lanadmin -x ${lan#lan} 2>/dev/null | grep -q -e "The link is down" -e "NO LINK"); then
		lan_state="no_link"
	else
		lan_state=$(lanadmin -x ${lan#lan} 2>/dev/null)
		if $(echo $lan_state | grep -q Speed ) ;then
			lan_state=$(echo $lan_state | grep Speed| awk '{print $3 $4}')
		else
			lan_state=$(echo $lan_state | cut -d= -f2 ) # |sed 's/ //g')
		fi
	fi
	if [ x$slot = "x" ]; then
		slot="NA"
	fi
        echo "$lan,$mac,$hw,$ip,$red,$lan_state,\c"
	echo $lan | get_driver $lan  | sed  -e '1,/Driver/d' -e 'N;s/\n//'
done 
rm $TMP /tmp/lanscanv.txt
} # landisp2


discosboot(){
pbp_hwp=`setboot | grep "Primary boot" | awk '{print $4}'`
pbp_dev=`ioscan -kfnH $pbp_hwp | awk ' $1 ~ /dev/ { getline;print $2}'`
pbp_size=` diskinfo $pbp_dev | grep size | awk '{ printf "%d GB", $2/1024/1024 }'`

abp_hwp=`setboot | grep "Alternate boot" | awk '{print $4}'`
abp_dev=`ioscan -kfnH $abp_hwp | awk ' $1 ~ /dev/ { getline;print $2}'`
abp_size=` diskinfo $abp_dev | grep size | awk '{ printf "%d GB\n", $2/1024/1024 }'`
echo "primary_bootHWP="$pbp_hwp",primary_bootDEV="$pbp_dev ",primary_bootSIZE="$pbp_size
echo "alternate_bootHWP="$abp_hwp ",alternate_bootDEV=" $abp_dev ",alternate_bootSIZE="$abp_size
} # discosboot

discos_externos(){
if  [  -x /sbin/spmgr  ]
then
        ## Discos EVA con Secure Path
        for f in `ioscan -kfnC disk | awk '{ print $3}' | grep "255/255" `
        do
        ioscan -kfnC disk | awk -v HWP="$f" '$3 ~ HWP {print;getline;print  }'
        done
else

        ### Discos de Fibra sin Secure Path
        for f in `ioscan -kfC fc | grep "^fc" | awk '{ print $3}'`
        do
        ioscan -kfnC disk | awk -v HWP="$f" '$3 ~ HWP {print;getline;print  }'
        done
fi
} # discos_externos

lvsize() {
	grep -e   "LV Name" -e "LV Size" $*		|
	sed     -e 's/LV Size[^0-9]*//'			\
        	-e 's,LV Name.*./dev/,/dev/,'		|
	awk '/dev/ {printf "\n"} { printf "%s ", $1}'	|
	grep -v '^$'					|
	awk '{printf "%-30s\t%6d\n", $1, $2}'
}

getvgid() {
    typeset RDEV="$(echo $1|sed -e 's,/dsk,/rdsk,' -e 's,/disk,/rdisk,')"

    KIND=`xd -An -j 8192 -N8 -tc ${RDEV} 2> /dev/null | xargs`

    if [ "$KIND" = "L V M R E C 0 1" ]; then
        INFO=`xd -An -j8200 -N16 -tx ${RDEV}`
        PVID=`echo ${INFO} | awk '{print $1 $2}'`
        VGID=`echo ${INFO} | awk '{print $3 $4}'`
        echo "${RDEV} pvid = ${PVID} vgid = ${VGID}" 
    fi
}

showvgids() {
    strings /etc/lvmtab|grep /dev/|awk '{
        if ( $1 ~ "^/dev/vg" ) {
            flag=1;
            printf "%s ", $1
            continue
        }
        if (flag == 1) {
        	flag=0;
        	print $0
        }
    }' |
    while read vg dsk; do
	echo "vg $vg \c"
	getvgid $dsk
    done
}

psfuser() {
    P=`fuser $*`
    if test ! -z "$P"; then 
        ps -fp `echo $P| sed -e 's/  */,/g' -e 's/^,//'`
    fi
}

# listar procesos ordenados por consumo de CPU
pscpu() {
if [ $# -gt 0 ]
then
   TOPPROCS=$1
else
   TOPPROCS=20
fi

TEMPFILE=/tmp/$$.pscpu

UNIX95= ps -eo pcpu,pid,args | sort -rn >$TEMPFILE
grep -e COMMAND $TEMPFILE
echo "-------------------------------------------"
grep -v "COMMAND" $TEMPFILE     \
     | sort -rn                 \
     | head -${TOPPROCS}	\
     | cut -c-80
}

# listar procesos ordenados por consumo de MEMORIA
psmem() {
set -u
if [ $# -gt 0 ]
then
   TOPPROCS=$1
else
   TOPPROCS=80
fi

TEMPFILE=/tmp/$$.psmem

UNIX95= ps -e -o ruser,vsz=vss_KB -o sz=rss_KB -o pid,args=Command-Line > $TEMPFILE
head -1 $TEMPFILE
DASH5="-----"
DASH25="$DASH5$DASH5$DASH5$DASH5$DASH5"
echo "$DASH5---- $DASH5- $DASH5 $DASH25$DASH25"
grep -v "VSZ COMMAND" $TEMPFILE \
     | cut -c -100      \
     | sort -rn -k 2 \
     | head -${TOPPROCS}

}

(
echodo 'echo generado por $0 $VERSION'
echodo date
echodo uname -a
echodo hostname
echodo model
echodo contar_procesadores
echodo grep Phys /var/adm/syslog/syslog.log
echodo "swlist|grep -e Operating -e OE"
echodo /sbin/fs/vxfs/subtype -v
echodo 'swlist -l product |grep -i "base vxfs"'
echodo id
echodo uptime
echodo "swlist -l fileset -a revision Ignite-UX"
if test -x /usr/contrib/bin/machinfo; then
	echodo /usr/contrib/bin/machinfo
fi
echodo getconf KERNEL_BITS
if echodo hpvminfo >$TMP 2>&1; then
	cat $TMP
	echodo hpvminfo -S
	echodo hpvminfo -V
	echodo hpvminfo -v
	if echodo hpvmstatus; then
		echodo hpvmstatus -r
		echodo hpvmstatus -m
		hpvmstatus -M|cut -d: -f1|while read i; do
			echodo hpvmstatus -D -P $i
			echodo hpvmstatus -A -P $i
		done
		echodo hpvmnet
		echodo hpvmstatus -r
		echodo hpvmstatus -s
		echodo hpvmstatus -M
		echodo hpvmstatus -C
		echodo hpvmstatus -V
		echodo hpvmstatus -S
		echodo hpvmstatus -R
		echodo hpvmdevinfo
		echodo vparhwmgmt -p cpu -l
		echodo vparhwmgmt -p memory -l
		echodo vparhwmgmt -p dio -l
		echodo cat /var/opt/hpvm/common/command.log
	fi
fi
# echodo "sc product cpu;il | /usr/sbin/cstm"
echodo 'echo $PATH' | tr : '\n'
echodo 'echo $HISTFILE'
echodo 'echo $TZ'
echodo cat ~root/.profile
echodo cat /etc/TIMEZONE
echodo what /usr/lib/tztab

# relevar hw.
echodotmout 'echo "sel path system\ninfolog"|cstm|grep "System Serial Number"'
echodotmout 'echo "sel path system\ninfolog"|cstm"'
echodotmout 'echo "map;wait;exit" | cstm"'
echodotmout -t 30 'echo "selclass qualifier memory\ninfo\nwait\ninfolog"|cstm'
echodotmout -t 50 cstm_cmds
# /etc/opt/resmon/lbin/moncheck

echodo ioscan -kfnC lan
echodo landisp
echodo lanscan
for i in $(lanscan -i| awk '{print $1}'); do
	echo "## datos $i"
	n=${i#lan}
        yes|lanadmin -g mibstats $n | grep -e Description
        ifconfig $i
        lanadmin -s $n
        lanadmin -m $n
        lanadmin -x $n
        lanadmin -x cko $n
        lanadmin -x vmtu $n
        lanadmin -x vpd $n
        yes|lanadmin -g mibstats $n | grep -e Error | grep -v '= *0$'
done 2>&1
echodo nwmgr
echodo nwmgr -S apa
test -f /etc/lanmon/lanconfig.ascii && echodo cat /etc/lanmon/lanconfig.ascii
echodo nwmgr -S vlan
echodo nwmgr --get
nwmgr --get |sed '1,/===/d' |while read i x; do
	echodo nwmgr -g -A all -c $i
done
echodo cat /etc/rc.config.d/netconf
echodo lanscan -v	# show driver

echodo "ioscan -kf | grep ext_bus"
echodo ioscan -kf
echodo ioscan -kfnC fc
for i in $(ioscan -kfnC fc|grep /dev); do
	if echo $i|grep -q /dev/td; then
		FCUTIL=tdutil
	else
		FCUTIL=fcmsutil
	fi
	echodo $FCUTIL $i
	echodo $FCUTIL $i npiv_info
	echodo $FCUTIL $i get fabric
	echodo $FCUTIL $i get remote all
	echodo $FCUTIL $i vpd
	echodo $FCUTIL $i stat
done
if [ -x /usr/sbin/mptconfig ] ; then
  for i in /dev/mpt*
  do
   if [ -c $i ] ; then
   	echodo mptutil $i
   	echodo mptconfig $i
   fi
  done
fi

echodo ioscan -kfnC tape
echodo ioscan -kfnC disk
if echodo ioscan -m dsf; then
	echodo ioscan -kfnNC disk
	echodo ioscan -m lun
	echodo ioscan -m hwpath
	echodo ioscan -t
fi
echodo dadm -e

if whence scsimgr >/dev/null; then
	echodo scsimgr get_attr -N /escsi/esdisk -a path_fail_secs -a load_bal_policy -a max_q_depth
fi

if whence iscsiutil >/dev/null; then
	echodo iscsiutil -l
	echodo iscsiutil -p
	echodo iscsiutil -pS
	echodo iscsiutil -pD
	echodo iscsiutil -pO
	echodo iscsiutil -s
fi

if uname -r|grep -q 11.31; then
	IOSCAN_DISK="ioscan -kfnNC disk"
else
	IOSCAN_DISK="ioscan -kfnC disk"
fi

$IOSCAN_DISK|sed 's,  *,\
,g'|grep -e /rdsk/ -e /rdisk/ |while read i;do
	echodo diskinfo $i
	if whence scsimgr >/dev/null; then
		echodo scsimgr get_attr -D $i	-a load_bal_policy 	\
						-a scsi_protocol_rev	\
						-a uniq_name		\
						-a max_q_depth		\
						;
	fi
done
if echodo spmgr display >$TMP 2>&1; then
	cat $TMP
fi

for i in syminq 	\
	/usr/symcli/bin/syminq	\
	inq 	\
	/usr/emc/bin/inq \
	;do
	INQ=$(whence $i) && break
done

if test "$INQ" && echodo $INQ >$TMP 2>&1; then
	cat $TMP
	echodo $INQ -no_dots
	echodo $INQ -no_dots -et
	echodo $INQ -no_dots -compat
	echodo $INQ -hba
	grep -q OPEN $TMP && ($INQ -f_hds; $INQ -hds_wwn)
	grep -q DGC  $TMP && ($INQ -clar_wwn; $INQ -f_clariion)
	grep -q SYMMETRIX  $TMP && ($INQ -f_emc; $INQ -sym_wwn)
fi

if echodo powermt display >$TMP 2>&1; then
    cat $TMP
    echodo powermt display ports
    echodo powermt display paths
    echodo powermt display dev=all
fi

if echodo xpinfo -i >$TMP 2>&1; then
	cat $TMP
	echodo xpinfo -c
	echodo xpinfo
	echodo xpinfo -d
	echodo xplibre $TMP
	if ps -ef|grep horcm|grep -v grep; then
		# hay al menos una instancia RM corriendo:
		# documentar variables de ambiente y tratar de localizar
		# el archivo de configuracion
		echodo "set|grep HOR"
		if test ! "$HORCMINST"; then
			typeset -i HORCMINST
			export HORCMINST=$(ps -ef|grep " horcmd_[0-9]"|grep -v grep |sed 's/.*horcmd_//')
			echo "\n## HORCMINST no seteando, seteando HORCMINST='$HORCMINST'"
		fi
		echodo 'raidqry -l'
		echodo 'horcctl -D'
		echodo "ll -t /etc/horcm*conf"
		echodo 'cat /etc/horcm$HORCMINST.conf'
		if test ! "$HORCM_CONF"; then
			HORCM_CONF=/etc/horcm$HORCMINST.conf
			echo "\n## HORCM_CONF no seteado, eligiendo $HORCM_CONF"
		fi
		echodo "cat $HORCM_CONF"
		if test -f "$HORCMPER"; then
			echodo 'll $HORCMPER'
			echodo 'cat $HORCMPER'
		fi

		for i in $(sed -e "1,/HORCM_DEV/d" $HORCM_CONF |
			   sed -n "1,/^HORCM_/p" |
			   grep -v -e "^#" -e '^[ 	]*$' -e '^HORCM_' |
			   awk '{print $1}'	|
			   sort -u)
		do
			echodo pairdisplay -g $i -fxc -fd
		done
	fi
fi

if echodo evainfo -a >$TMP 2>&1; then
	cat $TMP
fi

echodo icod_stat
echodo icapstatus
echodo cat /var/adm/icod.log
if test "$RAD"; then
	echodo $RAD -q
fi
if parstatus -w >/dev/null 2>&1; then
	echodo parstatus -w
	echodo parstatus
	parstatus -V -p0|grep ^cab.,cell|sed -e 's,^cab..cell,,' -e 's, .*,,'|while read i; do
		echodo parstatus -V -c$i
	done
fi
if echodo vparstatus >$TMP 2>&1; then
	echodo vparstatus -w
	echodo "swlist -l fileset|grep -i vpar|grep -v "^#""
	cat $TMP
	echodo vparstatus -P
	echodo vparstatus -w
	echodo vparstatus
	echodo vparstatus -v
	echodo vparstatus -d
	echodo vparstatus -e
	echodo vparstatus -m
	echodo vparenv
	echodo vparefiutil
fi

echodo netstat -in
echodo netstat -rn
echodo netstat -an
echodo ll  /etc/rc.config.d/nddconf
echodo cat /etc/rc.config.d/nddconf
echodo tcpipconf
echodo arp -an
echodo lpstat -p
echodo lpstat -s
echodo cat /etc/hosts
echodo cat /etc/nsswitch.conf
echodo cat /etc/resolv.conf
echodo grep "^DS" /etc/mail/sendmail.cf
echodo swapinfo -t
echodo swapinfo -tm
echodo crashconf -v
if test -f /var/adm/crash/*/INDEX; then
	echodo head -40 /var/adm/crash/*/INDEX
fi
echodo swlist
echodo swlist -l product
echodo "swlist -l fileset -a state	# filesets desconfigurados" |
	grep -v -e '	configured *$' -e '^#[^#]'
for i in /opt/java*/bin/java; do
	echodo $i -version
done
echodo type java
echodo "ll /dev/*/group"
ls /dev/*/group | cut -d/ -f3 | while read i; do
    echodo "vgexport -p -s -m /tmp/$$.map $i; cat /tmp/$$.map; rm /tmp/$$.map"
done

echodo vgdisplay -v
test -f /etc/lvmpvg && echodo cat /etc/lvmpvg
vgdisplay -v 2>/dev/null|echodo lvsize
for i in $(vgdisplay -v 2>/dev/null| grep "LV Name" | awk '{print $3}'); do
	echodo lvdisplay -v $i |tee $TMP| grep -v -e current -e free
	sed '1,/--- Logical ex/d' <$TMP |awk '{print $2,$5}'|grep -v -e "^PV" -e '^ *$'|uniq -c
done
(
	vgdisplay -v 2>/dev/null| grep "LV Name" | awk '{print $3}'	# lista de LVs existentes
	mount | awk '{print $3}'|grep -v :/				# lista de volumenes montados (LVM/VxVM)
) | sort -u | while read i; do
	echodo "fstyp -v $i"
	echodo "mkfs -m $i"
done
if test -f /etc/vx/tunefstab; then
    echodo cat /etc/vx/tunefstab
fi
echodo vxlicense -p
if mount|grep -q /dev/.*dg/; then
	echodo vxprint		# Layout de todos los disk groups
	echodo vxdisk list	# Discos en uso bajo Veritas
	echodo vxdisk path	# Discos en uso bajo Veritas
	echodo vxdisk -o alldgs list # DG definidos
	echodo vxdg free	# Espacio libre en el Disk Group
	echodo vxdisk -s list	
	echodo vxdisk list	
	echodo vxdmpadm listctlr all
	echodo vxdmpadm listenclosure all
	echodo vxdctl license
	echodo vxdctl -c mode
fi

# temperatura
rm -f $TMP.*
echodo sar 1 10         >$TMP.1 &
echodo sar -b 1 10      >$TMP.2 &
echodo sar -d 10 1      >$TMP.3 &
echodo sar -v 1 10      >$TMP.4 &
echodo iostat 10 1      >$TMP.5 &
echodo vmstat 1 10      >$TMP.6 &
wait
cat $TMP.*
echodo cat /var/opt/perf/parm
#
echodo cat /stand/bootconf
echodo "ll -d /stand/*vmunix*"
echodo what /stand/vmunix
echodo lvlnboot -v vg00
echodo setboot
for i in $(lvlnboot -v vg00| grep -i "/dev/dsk.*boot disk" | awk '{print $1}'); do
	echodo lifls $i
	echodo lifcp $i:AUTO -
done
echodo setboot -v
echodo ll /etc/lvmtab
echodo "strings /etc/lvmtab|grep /dev"
echodo "strings /etc/lvmtab_p"
echodo showvgids
echodo mount
echodo bdf
echodo 'UNIX95=x ps -efxH' | tee $TMP
if test $(wc -l <$TMP) -lt 20; then
	echodo 'UNIX95=x ps -efH' | tee $TMP
fi
echodo ps -ef
echodo ps -elP
if test $(wc -l <$TMP) -lt 20; then
	echodo 'ps -ef'
fi
echodo pscpu
echodo psmem
echodo ls -l /dev/async
echodo fuser /dev/async
echodo psfuser /dev/async
echodo ll /etc/privgroup && echodo cat /etc/privgroup
echodo getprivgrp
echodo ipcs
echodo ipcs -ma
echodo 'ps -ef|grep logd'
echodo showmount -e
echodo exportfs -v
echodo nfsstat -m
echodo cat /etc/fstab
echodo cat /etc/exports
echodo cat /etc/auto_master
echodo cat /etc/auto.direct
echodo cat /etc/rc.log
echodo cat /etc/shutdownlog
echodo who -b
echodo who -r
echodo cat /etc/inittab
echodo printpass
echodo listusers
echodo /usr/sbin/userdbget -ai
echodo cat /etc/default/security
echodo cat /etc/group
echodo crontab -l
echodo ll /var/spool/cron/crontabs
echodo head -500 /var/spool/cron/crontabs/*
echodo ntpq -p
echodo grep -v "^#" /etc/ntp.conf
echodo grep -i -e error -e scsi /var/adm/syslog/syslog.log|tail -100
echodo ll -t /var/adm/syslog/
n=$(eval $CATSYSLOG|wc -l)
echo "# $(wc -l </var/adm/syslog/syslog.log) lineas en syslog"
echo "# $n en '$CATSYSLOG'"
if test $n -gt 500; then
	echodo "eval $CATSYSLOG|head -200"
	echodo "eval $CATSYSLOG|tail -300"
else
	echodo eval $CATSYSLOG
fi
echodo $KCTUNE
echodo $KCTUNE -S
if test -f /var/adm/kc.log; then echodo cat /var/adm/kc.log; fi
echodo kclog 20
echodo kmsystem
echodo vxfsstat /
echodo vxfsstat -v /
echodo lsdev

# algo sobre el nivel de seguridad
echodo umask
echodo ulimit -a
umask 077	# segurizar los temporales que se usan
echodo ll -d  ~root ~root/.profile /etc /etc/hosts /etc/passwd /etc/group /etc/inetd.conf /etc/resolv.conf /etc/services ~root/.rhosts
echodo 'll /dev/vg*/r*|grep -v -e "root  *root" -e "root  *sys"'
cut -d: -f6 /etc/passwd|sort -u|while read i; do
	for f in $i/.rhosts $i/.ssh/authorized_keys $i/.ssh/authorized_keys2; do
		if [ -f $f ]; then
			echodo ll $f
			echodo cat $f
		fi
	done
done
echodo cat /etc/inetd.conf
echodo cat /etc/services
echodo cat /etc/shells
echodo cat ~root/.rhosts
echodo head -200 /etc/*.allow
echodo ll /tcb/files/auth/r/root

echodo cat /etc/lvmrc
if test -f /etc/cmcluster/cmclconfig; then
	echo "\n## relevando configuracion MC/SG"
	echodotmout cmviewcl
	echodotmout cmviewcl -v
	echodotmout cmviewconf|tee $TMP
	cmd="grep -e 'network interface name:' -e 'Node name:' -e 'bridged net ID' $TMP"
	echo "## cmshowlan"
	eval $cmd|
	sed 's/Node name.*/&\
/g'|unfold 2; echo

        echodo cmgetconf
		if cmviewconf >$TMP; then
			grep -i "package name" $TMP|awk '{print $NF}' >$TMP2
		fi

		if [ -z $TMP2 ]; then
			cmviewcl -l package -f line|grep name=|sed 's,.*=,,' >$TMP2
		fi

		for i in $(cat $TMP2); do
			echodo cmgetconf -p $i >/tmp/$$.$i
			echodo cat /tmp/$$.$i
		done

		
#		grep -v "^#" $TMP|grep /|grep -e external_script -e PEV_ACTION_SCRIPT -e script_log_file -e service_cmd|
#				while read x i x; do
#					if echo $i|grep -q '\.log$'; then
#						echodo tail -1000 $i
#					else
#						echodo cat $i
#					fi
#				done
#			done
#		else
	echodo ls -lR /etc/cmcluster
	# mostrar todo en el dir pkg, evitar binarios
	for i in $(find /etc/cmcluster/* -type f -o -type l); do
		if echo $i|grep -q '\.log$'; then
			echodo tail -1000 $i
		elif echo $i|grep -q -e '\.cntl$' -e '\.control.script' ; then
			echodo "sed '/END OF CUSTOMER DEFINED FUNCTION/q' $i"
		elif file $i|grep -q text; then
			echodo cat $i
		else
			echodo file $i
		fi
	done
	test -f /etc/cmcluster/sap.functions && echodo cat /etc/cmcluster/sap.functions
	test -x /opt/cmcluster/sap/bin/sapverify.pl && /opt/cmcluster/sap/bin/sapverify.pl -i 2>&1
	echodo cfscluster status
	echodo cfsmntadm display
else
	echo "\n## No SG binary cluster config found"
fi
if test $(omnicellinfo 2>&1|wc -l) -gt 1; then
	echodo omnicellinfo -version
	echodo omnicellinfo -cell brief
	echodo omnicellinfo -dev
	echodo omnicellinfo -dlinfo
	echodo omnicellinfo -dev -detail
	echodo omnicheck -patches -host $(hostname)
fi

test -f /etc/opt/samba/smb.conf && echodo cat /etc/opt/samba/smb.conf

# relevamiento Oracle
rm -f $TMP.ora; >$TMP.ora; chmod +x $TMP.ora
test -f /etc/oratab && echodo cat /etc/oratab
echo "set -x"							>>$TMP.ora
echo "ps -ef|grep pmon"						>>$TMP.ora
echo "oifcfg getif"						>>$TMP.ora
echo "sqlplus '/ as sysdba' <<'_fin_'"				>>$TMP.ora
echo "select * from v\$instance;"				>>$TMP.ora
echo "select * from v\$version;"				>>$TMP.ora
echo "select name     datafile        from sys.v\$datafile;"	>>$TMP.ora
echo "select member   online_redo     from sys.v\$logfile;"	>>$TMP.ora
echo "select name     controlfile     from sys.v\$controlfile;"	>>$TMP.ora
echo "show parameter log_archive_dest_%"			>>$TMP.ora
echo "exit"  							>>$TMP.ora
echo "_fin_"  							>>$TMP.ora
echo ""  							>>$TMP.ora
echo "cd \$ORACLE_HOME/dbs"					>>$TMP.ora
echo "ll -t init*.ora"						>>$TMP.ora
echo "head -500 init*.ora"					>>$TMP.ora
chmod a+r $TMP.ora

# relevamiento Informix
rm -f $TMP.inf; >$TMP.inf; chmod +x $TMP.inf
echo "echo"							>>$TMP.inf
echo "set -x"							>>$TMP.inf
echo "onstat -"							>>$TMP.inf
echo "onstat -c"						>>$TMP.inf
echo "onstat -d"						>>$TMP.inf
chmod a+r $TMP.inf

# relevamiento SAP
rm -f $TMP.sap; >$TMP.sap; chmod +x $TMP.sap
echo "disp+work -V"						>>$TMP.sap
chmod a+r $TMP.sap

# relevar SAP
for i in $(ls /sapmnt/*/exe/disp+work 2>/dev/null); do
        set $(echo $i|sed 's,/, ,g') x
	SID=$2
        sid=$(echo $SID|tr '[A-Z]' '[a-z]')
	echodo cat $TMP.sap
        echodo "su - ${sid}adm -c 'sh $TMP.sap'" </dev/null

	echodo ll -t /sapmnt/$SID/profile
	echodo "head -500 /sapmnt/$SID/profile/*"
	echodo "find /usr/sap/$SID/ -type l -xdev|xargs ll -d"
done

# relevar Oracle
for i in $(grep -e "^oracle" -e "^ora...:" /etc/passwd|cut -d: -f1); do
        echodo cat $TMP.ora
        # echodo cp -p $TMP.ora /tmp/releva-$i.sh
        echodo "su - $i -c 'sh $TMP.ora'" </dev/null
done

# relevar informix
if grep -q "^informix:" /etc/passwd; then
	echodo cat $TMP.inf
	echodo su - informix -c $TMP.inf	</dev/null
fi
# agregados para facilitar la documentacion
# echodo discosboot
# echodo discos_locales
# echodo landisp2
# echodo discos_externos
echo "finalizacion $(date)"
) 2>&1 |gzip >$OUT
chmod +r $OUT
echo "$0: salida en $OUT (usar ftp modo binario)"
# chmod a+r $OUT
ll $OUT
