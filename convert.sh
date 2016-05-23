#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "usage: ./convert.sh filename.irr"
  exit
fi

input="$1"
folder=maps/`basename $PWD`
output=c_$1
line_modif=""

rm -f $output
first=0
tmp_ifs=$IFS
IFS=''

animated=0

# We convert the file.irr file by moving pathnames from pathname to levelX/pathname
echo "========== Creating and converting c_$input from $input"
while read -r line
do
  if [[ $line =~ .*\"Mesh\".* ]]; then
    line_modif=$line
    if [[ $animated == 1 ]]; then
      line_modif=`echo $line_modif | sed -e 's/\\\/\//g'`
      part_one=`echo $line | cut -d\" -f1-3`
      part_three=`echo $line | cut -d\" -f5-`
      name=`echo $line_modif | cut -d\" -f4`
      name=`basename $name`
      line_modif=`echo $part_one\"maps/textures/$name\"$part_three`
      animated=0
    else
      line_modif=`echo $line_modif | cut -d\" -f-3`\"$folder/c_$input.meshes/`echo $line_modif | awk -F'\' '{ print $NF }'`
    fi
    echo $line_modif >> $output
  elif [[ $line =~ .*animatedMesh.* ]]; then
    animated=1
    echo $line >> $output
  elif [[ $line =~ .*Texture.* ]]; then
    part_one=`echo $line | cut -d\" -f1-3`
    part_two=`echo $line | cut -d\" -f4`
    part_three=`echo $line | cut -d\" -f5-`
    filename=`echo $part_two | awk -F'\' '{ print $NF }' | awk -F'/' '{ print $NF }'`
    line_modif=$part_one\"maps/textures/$filename\"$part_three
    echo $line_modif >> $output
  else
    if [ $first == 0 ]; then
      echo ${line:2} >> $output
      first=1
    else
      echo $line >> $output
    fi
  fi
done < "$input"
IFS=$tmp_ifs

# Now we convert each file in file.irr.meshes from absolute/path/texture to
# textures/
dir=c_$input.meshes

mkdir -p $dir
cd $input.meshes
files=`ls . | cut -d" " -f1-`

echo ""
echo "========== Going through c_$input.meshes and convert all files inside"
for f in $files
do
  rm -f ../$dir/$f
  IFS=''
  first=0
  while read -r line
  do
    if [[ $line =~ .*Texture.* ]]; then
      part_one=`echo $line | cut -d\" -f1-3`
      part_two=`echo $line | cut -d\" -f4`
      part_three=`echo $line | cut -d\" -f5-`
      if [[ $part_two =~ .*\.* ]]; then
        part_two=`echo $part_two | cut -d\\\ -f2-`
        xpath=${part_two%\\*}
        xbase=${part_two##*\\}
        xfext=${xbase##*.}
        xpref=${xbase%.*}
        filename="$xpref.$xfext"
      else
        filename=`basename $part_two`
      fi
    line_modif=$part_one\"maps/textures/$filename\"$part_three
    echo $line_modif >> ../$dir/$f
    else
      if [ $first == 0 ]; then
        echo ${line:2} >> ../$dir/$f
        first=1
      else
        echo $line >> ../$dir/$f
      fi
    fi
  done < $f
done

# We move all potential lights
cd ..
rm -rf ../textures/$input.lightmaps
cp -R $input.lightmaps/* ../textures

# We need to lowercase all texture name because IrrEdit is doing some shit with it =D
cd ../textures/
IFS=''
files=`ls . | cut -d" " -f1-`
IFS=$tmp_ifs
echo ""
echo "=========== Lowercasing ...."
for f in $files
do
  echo -e "\t$f  --> ${f,,}"
  if [[ "$f" != "${f,,}" ]]; then
    mv $f ${f,,}
  fi
done

echo "============================="
echo "========== FINISHED ========="
echo "============================="
