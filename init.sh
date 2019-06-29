#/bin/bash
if [ ! -e ./files/id_rsa ]; then ssh-keygen -f ./files/id_rsa  -N ''; fi ;
vagrant destroy -f;
vagrant up vpn-hub;
vpn_conf=0;
for file in files/vpn/{ca.{crt,key},dh2048.pem,{client{1,2},vpn-hub}.{key,crt}} 
  do
  if [ ! -e $file  ]
    then
      vpn_conf=1
      break
  fi
done
if [ 1 = $vpn_conf ]
  then
    for file in {ca.{crt,key},dh2048.pem,{client{1,2},vpn-hub}.{key,crt}} 
    do
      vagrant scp vpn-hub:~/$file files/vpn/
    done
fi
vagrant destroy -f;