
#!/bin/bash

echo "If return is simillar to '[Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]' and no errors reported. The installation of cross compailer is successful."

echo 'int main(){}' | $LFS_TGT-gcc -xc -
readelf -l a.out | grep ld-linux

rm -v a.out
