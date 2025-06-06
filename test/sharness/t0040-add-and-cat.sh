#!/usr/bin/env bash
#
# Copyright (c) 2014 Christian Couder
# MIT Licensed; see the LICENSE file in this repository.
#

test_description="Test add and cat commands"

. lib/test-lib.sh

test_add_cat_file() {
  test_expect_success "ipfs add --help works" '
    ipfs add --help 2> add_help_err1 > /dev/null
  '

  test_expect_success "stdin reading message doesn't show up" '
    test_expect_code 1 grep "ipfs: Reading from" add_help_err1 &&
    test_expect_code 1 grep "send Ctrl-d to stop." add_help_err1
  '

  test_expect_success "ipfs help add works" '
    ipfs help add 2> add_help_err2 > /dev/null
  '

  test_expect_success "stdin reading message doesn't show up" '
    test_expect_code 1 grep "ipfs: Reading from" add_help_err2 &&
    test_expect_code 1 grep "send Ctrl-d to stop." add_help_err2
  '

  test_expect_success "ipfs add succeeds" '
    echo "Hello Worlds!" >mountdir/hello.txt &&
    ipfs add mountdir/hello.txt >actual
  '

  test_expect_success "ipfs add output looks good" '
    HASH="QmVr26fY1tKyspEJBniVhqxQeEjhF78XerGiqWAwraVLQH" &&
    echo "added $HASH hello.txt" >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs add --only-hash succeeds" '
    ipfs add --only-hash mountdir/hello.txt > oh_actual
  '

  test_expect_success "ipfs add --only-hash output looks good" '
    test_cmp expected oh_actual
  '

  test_expect_success "ipfs cat succeeds" '
    ipfs cat "$HASH" >actual
  '

  test_expect_success "ipfs cat output looks good" '
    echo "Hello Worlds!" >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs cat with offset succeeds" '
    ipfs cat --offset 10 "$HASH" >actual
  '

  test_expect_success "ipfs cat from offset output looks good" '
    echo "ds!" >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs cat multiple hashes with offset succeeds" '
    ipfs cat --offset 10 "$HASH" "$HASH" >actual
  '

  test_expect_success "ipfs cat from offset output looks good" '
    echo "ds!" >expected &&
    echo "Hello Worlds!" >>expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs cat multiple hashes with offset succeeds" '
    ipfs cat --offset 16 "$HASH" "$HASH" >actual
  '

  test_expect_success "ipfs cat from offset output looks good" '
    echo "llo Worlds!" >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs cat from negative offset should fail" '
    test_expect_code 1 ipfs cat --offset -102 "$HASH" > actual
  '

  test_expect_success "ipfs cat with length succeeds" '
    ipfs cat --length 8 "$HASH" >actual
  '

  test_expect_success "ipfs cat with length output looks good" '
    printf "Hello Wo" >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs cat multiple hashes with offset and length succeeds" '
    ipfs cat --offset 5 --length 15 "$HASH" "$HASH" "$HASH" >actual
  '

  test_expect_success "ipfs cat multiple hashes with offset and length looks good" '
    printf " Worlds!\nHello " >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs cat with exact length succeeds" '
    ipfs cat --length $(ipfs cat "$HASH" | wc -c) "$HASH" >actual
  '

  test_expect_success "ipfs cat with exact length looks good" '
    echo "Hello Worlds!" >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs cat with 0 length succeeds" '
    ipfs cat --length 0 "$HASH" >actual
  '

  test_expect_success "ipfs cat with 0 length looks good" '
    : >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs cat with oversized length succeeds" '
    ipfs cat --length 100 "$HASH" >actual
  '

  test_expect_success "ipfs cat with oversized length looks good" '
    echo "Hello Worlds!" >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs cat with negative length should fail" '
    test_expect_code 1 ipfs cat --length -102 "$HASH" > actual
  '

  test_expect_success "ipfs cat /ipfs/file succeeds" '
    ipfs cat /ipfs/$HASH >actual
  '

  test_expect_success "output looks good" '
    echo "Hello Worlds!" >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs add -t succeeds" '
    ipfs add -t mountdir/hello.txt >actual
  '

  test_expect_success "ipfs add -t output looks good" '
    HASH="QmUkUQgxXeggyaD5Ckv8ZqfW8wHBX6cYyeiyqvVZYzq5Bi" &&
    echo "added $HASH hello.txt" >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs add --chunker size-32 succeeds" '
    ipfs add --chunker rabin mountdir/hello.txt >actual
  '

  test_expect_success "ipfs add --chunker size-32 output looks good" '
    HASH="QmVr26fY1tKyspEJBniVhqxQeEjhF78XerGiqWAwraVLQH" &&
    echo "added $HASH hello.txt" >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs add --chunker size-64 succeeds" '
    ipfs add --chunker=size-64 mountdir/hello.txt >actual
  '

  test_expect_success "ipfs add --chunker size-64 output looks good" '
    HASH="QmVr26fY1tKyspEJBniVhqxQeEjhF78XerGiqWAwraVLQH" &&
    echo "added $HASH hello.txt" >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs add --chunker=size-0 failed" '
    test_expect_code 1 ipfs add -Q --chunker=size-0 mountdir/hello.txt
  '

  test_expect_success "ipfs add --chunker rabin-36-512-1024 succeeds" '
    ipfs add --chunker rabin-36-512-1024 mountdir/hello.txt >actual
  '

  test_expect_success "ipfs add --chunker rabin-36-512-1024 output looks good" '
    HASH="QmVr26fY1tKyspEJBniVhqxQeEjhF78XerGiqWAwraVLQH" &&
    echo "added $HASH hello.txt" >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs add --chunker rabin-12-512-1024 failed" '
    test_expect_code 1 ipfs add -Q --chunker rabin-12-512-1024 mountdir/hello.txt
  '

  test_expect_success "ipfs add --chunker buzhash succeeds" '
    ipfs add --chunker buzhash mountdir/hello.txt >actual
  '

  test_expect_success "ipfs add --chunker buzhash output looks good" '
    HASH="QmVr26fY1tKyspEJBniVhqxQeEjhF78XerGiqWAwraVLQH" &&
    echo "added $HASH hello.txt" >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs add on hidden file succeeds" '
    echo "Hello Worlds!" >mountdir/.hello.txt &&
    ipfs add mountdir/.hello.txt >actual
  '

  test_expect_success "ipfs add on hidden file output looks good" '
    HASH="QmVr26fY1tKyspEJBniVhqxQeEjhF78XerGiqWAwraVLQH" &&
    echo "added $HASH .hello.txt" >expected &&
    test_cmp expected actual
  '

  test_expect_success "add zero length file" '
    touch zero-length-file &&
    ZEROHASH=$(ipfs add -q zero-length-file) &&
    echo $ZEROHASH
  '

  test_expect_success "zero length file has correct hash" '
    test "$ZEROHASH" = QmbFMke1KXqnYyBBWxB74N4c5SBnJMVAiMNRcGu6x1AwQH
  '

  test_expect_success "cat zero length file" '
    ipfs cat $ZEROHASH > zero-length-file_out
  '

  test_expect_success "make sure it looks good" '
    test_cmp zero-length-file zero-length-file_out
  '

  test_expect_success "ipfs add --stdin-name" '
    NAMEHASH="QmdFyxZXsFiP4csgfM5uPu99AvFiKH62CSPDw5TP92nr7w" &&
    echo "IPFS" | ipfs add --stdin-name file.txt > actual &&
    echo "added $NAMEHASH file.txt" > expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs add --stdin-name -w" '
    NAMEHASH="QmdFyxZXsFiP4csgfM5uPu99AvFiKH62CSPDw5TP92nr7w" &&
    echo "IPFS" | ipfs add -w --stdin-name file.txt | head -n1> actual &&
    echo "added $NAMEHASH file.txt" > expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs cat with stdin-name" '
    NAMEHASH=$(echo "IPFS" | ipfs add -w --stdin-name file.txt -Q) &&
    ipfs cat /ipfs/$NAMEHASH/file.txt > expected &&
    echo "IPFS" > actual &&
    test_cmp expected actual
  '

  test_expect_success "ipfs add -r ." '
    mkdir test_current_dir &&
    echo "Hey" > test_current_dir/hey &&
    mkdir test_current_dir/hello &&
    echo "World" > test_current_dir/hello/world &&
    ( cd test_current_dir &&
    ipfs add -r -Q . > ../actual && cd ../ ) &&
    rm -r test_current_dir
  '

  test_expect_success "ipfs add -r . output looks good" '
    echo "QmZQWnfcqJ6hNkkPvrY9Q5X39GP3jUnUbAV4AbmbbR3Cb1" > expected
    test_cmp expected actual
  '

  test_expect_success "ipfs add -r ./" '
    mkdir test_current_dir &&
    echo "Hey" > test_current_dir/hey &&
    mkdir test_current_dir/hello &&
    echo "World" > test_current_dir/hello/world &&
    ( cd test_current_dir &&
    ipfs add -r -Q ./ > ../actual && cd ../ ) &&
    rm -r test_current_dir
  '

  test_expect_success "ipfs add -r ./ output looks good" '
    echo "QmZQWnfcqJ6hNkkPvrY9Q5X39GP3jUnUbAV4AbmbbR3Cb1" > expected
    test_cmp expected actual
  '

  # --cid-base=base32

  test_expect_success "ipfs add --cid-base=base32 succeeds" '
    echo "base32 test" >mountdir/base32-test.txt &&
    ipfs add --cid-base=base32 mountdir/base32-test.txt >actual
  '
  test_expect_success "ipfs add --cid-base=base32 output looks good" '
    HASHb32="bafybeibyosqxljd2eptb4ebbtvk7pb4aoxzqa6ttdsflty6rsslz5y6i34" &&
    echo "added $HASHb32 base32-test.txt" >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs add --cid-base=base32 --only-hash succeeds" '
    ipfs add --cid-base=base32 --only-hash mountdir/base32-test.txt > oh_actual
  '
  test_expect_success "ipfs add --cid-base=base32 --only-hash output looks good" '
    test_cmp expected oh_actual
  '

  test_expect_success "ipfs add --cid-base=base32 --upgrade-cidv0-in-output=false succeeds" '
    echo "base32 test" >mountdir/base32-test.txt &&
    ipfs add --cid-base=base32 --upgrade-cidv0-in-output=false mountdir/base32-test.txt >actual
  '
  test_expect_success "ipfs add --cid-base=base32 --upgrade-cidv0-in-output=false output looks good" '
    HASHv0=$(cid-fmt -v 0 -b z %s "$HASHb32") &&
    echo "added $HASHv0 base32-test.txt" >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs add --cid-base=base32 --upgrade-cidv0-in-output=false --only-hash succeeds" '
    ipfs add --cid-base=base32 --upgrade-cidv0-in-output=false --only-hash mountdir/base32-test.txt > oh_actual
  '
  test_expect_success "ipfs add --cid-base=base32 --upgrade-cidv0-in-output=false --only-hash output looks good" '
    test_cmp expected oh_actual
  '

  test_expect_success "ipfs cat with base32 hash succeeds" '
    ipfs cat "$HASHb32" >actual
  '
  test_expect_success "ipfs cat with base32 hash output looks good" '
    echo "base32 test" >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs cat using CIDv0 hash succeeds" '
    ipfs cat "$HASHv0" >actual
  '
  test_expect_success "ipfs cat using CIDv0 hash looks good" '
    echo "base32 test" >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs add with multiple files succeeds" '
    echo "Helloo Worlds!" >mountdir/hello2.txt &&
    ipfs add mountdir/hello.txt mountdir/hello2.txt >actual
  '

  test_expect_success "ipfs add with multiple files output looks good" '
    echo "added QmVr26fY1tKyspEJBniVhqxQeEjhF78XerGiqWAwraVLQH hello.txt" >expected &&
    echo "added Qmf35k66MZNW2GijohUmXQEWKZU4cCGTCwK6idfnt152wJ hello2.txt" >> expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs add with multiple files of same name and import dir succeeds" '
    ipfs add mountdir/hello.txt mountdir/hello.txt >actual
  '

  test_expect_success "ipfs add with multiple files of same name output looks good" '
    echo "added QmVr26fY1tKyspEJBniVhqxQeEjhF78XerGiqWAwraVLQH hello.txt" >expected &&
    test_cmp expected actual
  '

    test_expect_success "ipfs add with multiple files of same name but different dirs fails" '
      mkdir -p mountdir/same-file/ &&
      cp mountdir/hello.txt mountdir/same-file/hello.txt &&
      test_expect_code 1 ipfs add mountdir/hello.txt mountdir/same-file/hello.txt >actual &&
      rm mountdir/same-file/hello.txt  &&
      rmdir mountdir/same-file
    '

  ## --to-files with single source

  test_expect_success "ipfs add --to-files /mfspath succeeds" '
    mkdir -p mountdir && echo "Hello MFS!" > mountdir/mfs.txt &&
    ipfs add mountdir/mfs.txt --to-files /ipfs-add-to-files >actual
  '

  test_expect_success "ipfs add --to-files output looks good" '
    HASH_MFS="QmVT8bL3sGBA2TwvX8JPhrv5CYZL8LLLfW7mxkUjPZsgBr" &&
    echo "added $HASH_MFS mfs.txt" >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs files read succeeds" '
    ipfs files read /ipfs-add-to-files >actual &&
    ipfs files rm /ipfs-add-to-files
  '

  test_expect_success "ipfs cat output looks good" '
    echo "Hello MFS!" >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs add --to-files requires argument" '
    test_expect_code 1 ipfs add mountdir/mfs.txt --to-files >actual 2>&1 &&
    test_should_contain "Error: missing argument for option \"to-files\"" actual
  '

  test_expect_success "ipfs add --to-files / (MFS root) works" '
    echo "Hello MFS!" >expected &&
    ipfs add mountdir/mfs.txt --to-files / &&
    ipfs files read /mfs.txt >actual &&
    test_cmp expected actual &&
    ipfs files rm /mfs.txt &&
    rm mountdir/mfs.txt
  '

  ## --to-files with multiple sources

  test_expect_success "ipfs add file1 file2 --to-files /mfspath0 (without trailing slash) fails" '
    mkdir -p test &&
    echo "file1" > test/mfs1.txt &&
    echo "file2" > test/mfs2.txt &&
    test_expect_code 1 ipfs add test/mfs1.txt test/mfs2.txt --to-files /mfspath0 >actual 2>&1 &&
    test_should_contain "MFS destination is a file: only one entry can be copied to \"/mfspath0\"" actual &&
    ipfs files rm -r --force /mfspath0
  '

  test_expect_success "ipfs add file1 file2 --to-files /mfsfile1 (without trailing slash + with preexisting file) fails" '
    echo test | ipfs files write --create /mfsfile1 &&
    test_expect_code 1 ipfs add test/mfs1.txt test/mfs2.txt --to-files /mfsfile1 >actual 2>&1 &&
    test_should_contain "Error: to-files: cannot put node in path \"/mfsfile1\"" actual &&
    ipfs files rm -r --force /mfsfile1
  '

  test_expect_success "ipfs add file1 file2 --to-files /mfsdir1 (without trailing slash + with preexisting dir) fails" '
    ipfs files mkdir -p /mfsdir1 &&
    test_expect_code 1 ipfs add test/mfs1.txt test/mfs2.txt --to-files /mfsdir1 >actual 2>&1 &&
    test_should_contain "Error: to-files: cannot put node in path \"/mfsdir1\"" actual &&
    ipfs files rm -r --force /mfsdir1
  '

  test_expect_success "ipfs add file1 file2 --to-files /mfsdir2/ (with trailing slash) succeeds" '
    ipfs files mkdir -p /mfsdir2 &&
    test_expect_code 0 ipfs add --cid-version 1 test/mfs1.txt test/mfs2.txt --to-files /mfsdir2/ > actual 2>&1 &&
    test_should_contain "added bafkreihm3rktn5z33luic3youqdsn326toaq3ekesmdvsa53sbrd3f5r3a mfs1.txt" actual &&
    test_should_contain "added bafkreidh5zkhr2vnwa2luwmuj24xo6l3jhfgvkgtk5cyp43oxs7owzpxby mfs2.txt" actual &&
    test_should_not_contain "Error" actual &&
    ipfs files ls /mfsdir2/ > lsout &&
    test_should_contain "mfs1.txt" lsout &&
    test_should_contain "mfs2.txt" lsout &&
    ipfs files rm -r --force /mfsdir2
  '

  test_expect_success "ipfs add file1 file2 --to-files /mfsfile2/ (with  trailing slash + with preexisting file) fails" '
    echo test | ipfs files write --create /mfsfile2 &&
    test_expect_code 1 ipfs add test/mfs1.txt test/mfs2.txt --to-files /mfsfile2/ >actual 2>&1 &&
    test_should_contain "Error: to-files: MFS destination \"/mfsfile2/\" is not a directory" actual &&
    ipfs files rm -r --force /mfsfile2
  '

  ## --to-files with recursive dir

  # test MFS destination without trailing slash
  test_expect_success "ipfs add with --to-files /mfs/subdir3 fails because /mfs/subdir3 exists" '
    ipfs files mkdir -p /mfs/subdir3 &&
    test_expect_code 1 ipfs add -r test --to-files /mfs/subdir3 >actual 2>&1 &&
    test_should_contain "cannot put node in path \"/mfs/subdir3\": directory already has entry by that name" actual &&
    ipfs files rm -r --force /mfs
  '

  # test recursive import of a dir  into MFS subdirectory
  test_expect_success "ipfs add -r dir --to-files /mfs/subdir4/ succeeds (because of trailing slash)" '
    ipfs files mkdir -p /mfs/subdir4 &&
    ipfs add --cid-version 1 -r test --to-files /mfs/subdir4/ >actual 2>&1 &&
    test_should_contain "added bafkreihm3rktn5z33luic3youqdsn326toaq3ekesmdvsa53sbrd3f5r3a test/mfs1.txt" actual &&
    test_should_contain "added bafkreidh5zkhr2vnwa2luwmuj24xo6l3jhfgvkgtk5cyp43oxs7owzpxby test/mfs2.txt" actual &&
    test_should_contain "added bafybeic7xwqwovt4g4bax6d3udp6222i63vj2rblpbim7uy2uw4a5gahha test" actual &&
    test_should_not_contain "Error" actual
    ipfs files ls /mfs/subdir4/ > lsout &&
    test_should_contain "test" lsout &&
    test_should_not_contain "mfs1.txt" lsout &&
    test_should_not_contain "mfs2.txt" lsout &&
    ipfs files rm -r --force /mfs
  '

  # confirm -w and --to-files are exclusive
  # context: https://github.com/ipfs/kubo/issues/10611
  test_expect_success "ipfs add -r -w dir --to-files /mfs/subdir5/ errors (-w and --to-files are exclusive)" '
    ipfs files mkdir -p /mfs/subdir5 &&
    test_expect_code 1 ipfs add -r -w test --to-files /mfs/subdir5/ >actual 2>&1 &&
    test_should_contain "Error" actual &&
    ipfs files rm -r --force /mfs
  '

}

test_add_cat_5MB() {
  ADD_FLAGS="$1"
  EXP_HASH="$2"

  test_expect_success "generate 5MB file using random-data" '
    random-data -size=5242880 -seed=41 >mountdir/bigfile
  '

  test_expect_success "sha1 of the file looks ok" '
    echo "11145b8c4bc8f87ea2fcfc3d55708b8cac2aadf12862" >sha1_expected &&
    multihash -a=sha1 -e=hex mountdir/bigfile >sha1_actual &&
    test_cmp sha1_expected sha1_actual
  '

  test_expect_success "'ipfs add $ADD_FLAGS bigfile' succeeds" '
    ipfs add $ADD_FLAGS mountdir/bigfile >actual ||
    test_fsh cat daemon_err
  '

  test_expect_success "'ipfs add bigfile' output looks good" '
    echo "added $EXP_HASH bigfile" >expected &&
    test_cmp expected actual
  '
  test_expect_success "'ipfs cat' succeeds" '
    ipfs cat "$EXP_HASH" >actual
  '

  test_expect_success "'ipfs cat' output looks good" '
    test_cmp mountdir/bigfile actual
  '

  test_expect_success FUSE "cat ipfs/bigfile succeeds" '
    cat "ipfs/$EXP_HASH" >actual
  '

  test_expect_success FUSE "cat ipfs/bigfile looks good" '
    test_cmp mountdir/bigfile actual
  '

  test_expect_success "remove hash" '
    ipfs pin rm "$EXP_HASH" &&
    ipfs block rm "$EXP_HASH"
  '

  test_expect_success "get base32 version of CID" '
    ipfs cid base32 $EXP_HASH > base32_cid &&
    BASE32_HASH=`cat base32_cid`
  '

  test_expect_success "ipfs add --cid-base=base32 bigfile' succeeds" '
    ipfs add $ADD_FLAGS --cid-base=base32 mountdir/bigfile >actual ||
    test_fsh cat daemon_err
  '

  test_expect_success "'ipfs add bigfile --cid-base=base32' output looks good" '
    echo "added $BASE32_HASH bigfile" >expected &&
    test_cmp expected actual
  '

  test_expect_success "'ipfs cat $BASE32_HASH' succeeds" '
    ipfs cat "$BASE32_HASH" >actual
  '
}

test_add_cat_raw() {
  test_expect_success "add a small file with raw-leaves" '
    echo "foobar" > afile &&
    HASH=$(ipfs add -q --raw-leaves afile)
  '

  test_expect_success "cat that small file" '
    ipfs cat $HASH > afile_out
  '

  test_expect_success "make sure it looks good" '
    test_cmp afile afile_out
  '

  test_expect_success "add zero length file with raw-leaves" '
    touch zero-length-file &&
    ZEROHASH=$(ipfs add -q --raw-leaves zero-length-file) &&
    echo $ZEROHASH
  '

  test_expect_success "zero length file has correct hash" '
    test "$ZEROHASH" = bafkreihdwdcefgh4dqkjv67uzcmw7ojee6xedzdetojuzjevtenxquvyku
  '

  test_expect_success "cat zero length file" '
    ipfs cat $ZEROHASH > zero-length-file_out
  '

  test_expect_success "make sure it looks good" '
    test_cmp zero-length-file zero-length-file_out
  '
}

test_add_cat_derefargs() {
  test_expect_success "create and hash zero length file" '
    touch zero-length-file &&
    ZEROHASH=$(ipfs add -q -n zero-length-file)
  '

  test_expect_success "create symlink and add with dereferenced arguments" '
    ln -s zero-length-file symlink-to-zero &&
    HASH=$(ipfs add -q -n --dereference-args symlink-to-zero) &&
    test $HASH = $ZEROHASH
  '
}

test_add_cat_expensive() {
  ADD_FLAGS="$1"
  HASH="$2"

  test_expect_success EXPENSIVE "generate 100MB file using random-data" '
    random-data -size=104857600 -seed=42 >mountdir/bigfile
  '

  test_expect_success EXPENSIVE "sha1 of the file looks ok" '
    echo "11141e8c04d7cd019cc0acf0311a8ca6cf2c18413c96" >sha1_expected &&
    multihash -a=sha1 -e=hex mountdir/bigfile >sha1_actual &&
    test_cmp sha1_expected sha1_actual
  '

  test_expect_success EXPENSIVE "ipfs add $ADD_FLAGS bigfile succeeds" '
    ipfs add $ADD_FLAGS mountdir/bigfile >actual
  '

  test_expect_success EXPENSIVE "ipfs add bigfile output looks good" '
    echo "added $HASH bigfile" >expected &&
    test_cmp expected actual
  '

  test_expect_success EXPENSIVE "ipfs cat succeeds" '
    ipfs cat "$HASH" | multihash -a=sha1 -e=hex >sha1_actual
  '

  test_expect_success EXPENSIVE "ipfs cat output looks good" '
    ipfs cat "$HASH" >actual &&
    test_cmp mountdir/bigfile actual
  '

  test_expect_success EXPENSIVE "ipfs cat output hashed looks good" '
    echo "11141e8c04d7cd019cc0acf0311a8ca6cf2c18413c96" >sha1_expected &&
    test_cmp sha1_expected sha1_actual
  '

  test_expect_success FUSE,EXPENSIVE "cat ipfs/bigfile succeeds" '
    cat "ipfs/$HASH" | multihash -a=sha1 -e=hex >sha1_actual
  '

  test_expect_success FUSE,EXPENSIVE "cat ipfs/bigfile looks good" '
    test_cmp sha1_expected sha1_actual
  '
}

test_add_named_pipe() {
  test_expect_success "Adding named pipes explicitly works" '
    mkfifo named-pipe1 &&
    ( echo foo > named-pipe1 & echo "added $( echo foo | ipfs add -nq ) named-pipe1" > expected_named_pipes_add ) &&
    mkfifo named-pipe2 &&
    ( echo bar > named-pipe2 & echo "added $( echo bar | ipfs add -nq ) named-pipe2" >> expected_named_pipes_add ) &&
    ipfs add -n named-pipe1 named-pipe2 >actual_pipe_add &&
    rm named-pipe1 &&
    rm named-pipe2 &&
    test_cmp expected_named_pipes_add actual_pipe_add
  '

  test_expect_success "useful error message when recursively adding a named pipe" '
    mkdir -p named-pipe-dir &&
    mkfifo named-pipe-dir/named-pipe &&
    STAT=$(generic_stat named-pipe-dir/named-pipe) &&
    test_expect_code 1 ipfs add -r named-pipe-dir 2>actual &&
    printf "Error: unrecognized file type for named-pipe-dir/named-pipe: $STAT\n" >expected &&
    rm named-pipe-dir/named-pipe &&
    rmdir named-pipe-dir &&
    test_cmp expected actual
  '
}

test_add_pwd_is_symlink() {
  test_expect_success "ipfs add -r adds directory content when ./ is symlink" '
    mkdir hellodir &&
    echo "World" > hellodir/world &&
    ln -s hellodir hellolink &&
    ( cd hellolink &&
    ipfs add -r . > ../actual ) &&
    grep "added Qma9CyFdG5ffrZCcYSin2uAETygB25cswVwEYYzwfQuhTe" actual &&
    rm -r hellodir
  '
}

test_launch_ipfs_daemon_and_mount

test_expect_success "'ipfs add --help' succeeds" '
  ipfs add --help >actual
'

test_expect_success "'ipfs add --help' output looks good" '
  egrep "ipfs add.*<path>" actual >/dev/null ||
  test_fsh cat actual
'

test_expect_success "'ipfs help add' succeeds" '
  ipfs help add >actual
'

test_expect_success "'ipfs help add' output looks good" '
  egrep "ipfs add.*<path>" actual >/dev/null ||
  test_fsh cat actual
'

test_expect_success "'ipfs cat --help' succeeds" '
  ipfs cat --help >actual
'

test_expect_success "'ipfs cat --help' output looks good" '
  egrep "ipfs cat.*<ipfs-path>" actual >/dev/null ||
  test_fsh cat actual
'

test_expect_success "'ipfs help cat' succeeds" '
  ipfs help cat >actual
'

test_expect_success "'ipfs help cat' output looks good" '
  egrep "ipfs cat.*<ipfs-path>" actual >/dev/null ||
  test_fsh cat actual
'

test_add_cat_file

test_expect_success "ipfs cat succeeds with stdin opened (issue #1141)" '
  cat mountdir/hello.txt | while read line; do ipfs cat "$HASH" >actual || exit; done
'

test_expect_success "ipfs cat output looks good" '
  cat mountdir/hello.txt >expected &&
  test_cmp expected actual
'

test_expect_success "ipfs cat accept hash from built input" '
  echo "$HASH" | ipfs cat >actual
'

test_expect_success "ipfs cat output looks good" '
  test_cmp expected actual
'

test_expect_success FUSE "cat ipfs/stuff succeeds" '
  cat "ipfs/$HASH" >actual
'

test_expect_success FUSE "cat ipfs/stuff looks good" '
  test_cmp expected actual
'

test_expect_success "'ipfs add -q' succeeds" '
  echo "Hello Venus!" >mountdir/venus.txt &&
  ipfs add -q mountdir/venus.txt >actual
'

test_expect_success "'ipfs add -q' output looks good" '
  HASH="QmU5kp3BH3B8tnWUU2Pikdb2maksBNkb92FHRr56hyghh4" &&
  echo "$HASH" >expected &&
  test_cmp expected actual
'

test_expect_success "'ipfs add -q' with stdin input succeeds" '
  echo "Hello Jupiter!" | ipfs add -q >actual
'

test_expect_success "'ipfs add -q' output looks good" '
  HASH="QmUnvPcBctVTAcJpigv6KMqDvmDewksPWrNVoy1E1WP5fh" &&
  echo "$HASH" >expected &&
  test_cmp expected actual
'

test_expect_success "'ipfs cat' succeeds" '
  ipfs cat "$HASH" >actual
'

test_expect_success "ipfs cat output looks good" '
  echo "Hello Jupiter!" >expected &&
  test_cmp expected actual
'

test_expect_success "'ipfs add' with stdin input succeeds" '
  printf "Hello Neptune!\nHello Pluton!" | ipfs add >actual
'

test_expect_success "'ipfs add' output looks good" '
  HASH="QmZDhWpi8NvKrekaYYhxKCdNVGWsFFe1CREnAjP1QbPaB3" &&
  echo "added $HASH $HASH" >expected &&
  test_cmp expected actual
'

test_expect_success "'ipfs cat' with built input succeeds" '
  echo "$HASH" | ipfs cat >actual
'

test_expect_success "ipfs cat with built input output looks good" '
  printf "Hello Neptune!\nHello Pluton!" >expected &&
  test_cmp expected actual
'

add_directory() {
  EXTRA_ARGS=$1

  test_expect_success "'ipfs add -r $EXTRA_ARGS' succeeds" '
    mkdir mountdir/planets &&
    echo "Hello Mars!" >mountdir/planets/mars.txt &&
    echo "Hello Venus!" >mountdir/planets/venus.txt &&
    ipfs add -r $EXTRA_ARGS mountdir/planets >actual
  '

  test_expect_success "'ipfs add -r $EXTRA_ARGS' output looks good" '
    echo "added $MARS planets/mars.txt" >expected &&
    echo "added $VENUS planets/venus.txt" >>expected &&
    echo "added $PLANETS planets" >>expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs cat accept many hashes from built input" '
    { echo "$MARS"; echo "$VENUS"; } | ipfs cat >actual
  '

  test_expect_success "ipfs cat output looks good" '
    cat mountdir/planets/mars.txt mountdir/planets/venus.txt >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs cat accept many hashes as args" '
    ipfs cat "$MARS" "$VENUS" >actual
  '

  test_expect_success "ipfs cat output looks good" '
    test_cmp expected actual
  '

  test_expect_success "ipfs cat with both arg and stdin" '
    echo "$MARS" | ipfs cat "$VENUS" >actual
  '

  test_expect_success "ipfs cat output looks good" '
    cat mountdir/planets/venus.txt >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs cat with two args and stdin" '
    echo "$MARS" | ipfs cat "$VENUS" "$VENUS" >actual
  '

  test_expect_success "ipfs cat output looks good" '
    cat mountdir/planets/venus.txt mountdir/planets/venus.txt >expected &&
    test_cmp expected actual
  '

  test_expect_success "ipfs add --quieter succeeds" '
    ipfs add -r -Q $EXTRA_ARGS mountdir/planets >actual
  '

  test_expect_success "ipfs add --quieter returns only one correct hash" '
    echo "$PLANETS" > expected &&
    test_cmp expected actual
  '

  test_expect_success "cleanup" '
    rm -r mountdir/planets
  '
}

PLANETS="QmWSgS32xQEcXMeqd3YPJLrNBLSdsfYCep2U7CFkyrjXwY"
MARS="QmPrrHqJzto9m7SyiRzarwkqPcCSsKR2EB1AyqJfe8L8tN"
VENUS="QmU5kp3BH3B8tnWUU2Pikdb2maksBNkb92FHRr56hyghh4"
add_directory

PLANETS="QmfWfQfKCY5Ukv9peBbxM5vqWM9BzmqUSXvdCgjT2wsiBT"
MARS="bafkreibmlvvgdyihetgocpof6xk64kjjzdeq2e4c7hqs3krdheosk4tgj4"
VENUS="bafkreihfsphazrk2ilejpekyltjeh5k4yvwgjuwg26ueafohqioeo3sdca"
add_directory '--raw-leaves'

PLANETS="bafybeih7e5dmkyk25up5vxug4q3hrg2fxbzf23dfrac2fns5h7z4aa7ioi"
MARS="bafkreibmlvvgdyihetgocpof6xk64kjjzdeq2e4c7hqs3krdheosk4tgj4"
VENUS="bafkreihfsphazrk2ilejpekyltjeh5k4yvwgjuwg26ueafohqioeo3sdca"
add_directory '--cid-version=1'

PLANETS="bafybeif5tuep5ap2d7zyhbktucey75aoacxufgt6i3v4gebmixyipnyp7y"
MARS="bafybeiawta2ntdmsy24aro35w3homzl4ak7svr3si7l7gesvq4erglyye4"
VENUS="bafybeicvkvhs2fr75ynebtdjqpgm4g2fc63abqbmysupwpmcjl4gx7mzrm"
add_directory '--cid-version=1 --raw-leaves=false'

PLANETS="bafykbzaceaptbcs7ik5mdfpot3b4ackvxlwh7loc5jcrtkayf64ukl7zyk46e"
MARS="bafk2bzaceaqcxw46uzkyd2jmczoogof6pnkqt4dpiv3pwkunsv4g5rkkmecie"
VENUS="bafk2bzacebxnke2fb5mgzxyjuuavvcfht4fd3gvn4klkujz6k72wboynhuvfw"
add_directory '--hash=blake2b-256'

test_expect_success "'ipfs add -rn' succeeds" '
  mkdir -p mountdir/moons/jupiter &&
  mkdir -p mountdir/moons/saturn &&
  echo "Hello Europa!" >mountdir/moons/jupiter/europa.txt &&
  echo "Hello Titan!" >mountdir/moons/saturn/titan.txt &&
  echo "hey you are no moon!" >mountdir/moons/mercury.txt &&
  ipfs add -rn mountdir/moons >actual
'

test_expect_success "'ipfs add -rn' output looks good" '
  MOONS="QmbGoaQZm8kjYfCiN1aBsgwhqfUBGDYTrDb91Mz7Dvq81B" &&
  EUROPA="Qmbjg7zWdqdMaK2BucPncJQDxiALExph5k3NkQv5RHpccu" &&
  JUPITER="QmS5mZddhFPLWFX3w6FzAy9QxyYkaxvUpsWCtZ3r7jub9J" &&
  SATURN="QmaMagZT4rTE7Nonw8KGSK4oe1bh533yhZrCo1HihSG8FK" &&
  TITAN="QmZzppb9WHn552rmRqpPfgU5FEiHH6gDwi3MrB9cTdPwdb" &&
  MERCURY="QmRsTB5CpEUvDUpDgHCzb3VftZ139zrk9zs5ZcgYh9TMPJ" &&
  echo "added $EUROPA moons/jupiter/europa.txt" >expected &&
  echo "added $MERCURY moons/mercury.txt" >>expected &&
  echo "added $TITAN moons/saturn/titan.txt" >>expected &&
  echo "added $JUPITER moons/jupiter" >>expected &&
  echo "added $SATURN moons/saturn" >>expected &&
  echo "added $MOONS moons" >>expected &&
  test_cmp expected actual
'

test_expect_success "random-data is installed" '
  type random-data
'

test_add_cat_5MB "" "QmapAfmzmeWYTNztMQEhUXFcSGrsax22WRG7YN9xLdMeQq"

test_add_cat_5MB --raw-leaves "QmabWSFaPusmiZaaVZLhEUtHcj8CCvVeUfkBpKqAkKVMiS"

# note: the specified hash implies that internal nodes are stored
# using CidV1 and leaves are stored using raw blocks
test_add_cat_5MB --cid-version=1 "bafybeifwdkm32fmukqwh3jofm6ma76bcqvn6opxstsnzmya7utboi4cb2m"

# note: the specified hash implies that internal nodes are stored
# using CidV1 and leaves are stored using CidV1 but using the legacy
# format (i.e. not raw)
test_add_cat_5MB '--cid-version=1 --raw-leaves=false' "bafybeifq4unep5w4agr3nlynxidj2rymf6dzu6bf4ieqqildkboe5mdmne"

# note: --hash=blake2b-256 implies --cid-version=1 which implies --raw-leaves=true
# the specified hash represents the leaf nodes stored as raw leaves and
# encoded with the blake2b-256 hash function
test_add_cat_5MB '--hash=blake2b-256' "bafykbzacebxcnlql4oc3mtscqn32aumqkqxxv3wt7dkyrphgh6lc2gckiq6bw"

# the specified hash represents the leaf nodes stored as protoful nodes and
# encoded with the blake2b-256 hash function
test_add_cat_5MB '--hash=blake2b-256 --raw-leaves=false' "bafykbzacearibnoamkfmcagpfgk2sbgx65qftnsrh4ttd3g7ghooasfnyavme"

test_add_cat_expensive "" "Qma1WZKC3jad7e3F7GEDvkFdhPLyMEhKszBF4nBUCBGh6c"

# note: the specified hash implies that internal nodes are stored
# using CidV1 and leaves are stored using raw blocks
test_add_cat_expensive "--cid-version=1" "bafybeibdfw7nsmb3erhej2k6v4eopaswsf5yfv2ikweqa3qsc5no4jywqu"

# note: --hash=blake2b-256 implies --cid-version=1 which implies --raw-leaves=true
# the specified hash represents the leaf nodes stored as raw leaves and
# encoded with the blake2b-256 hash function
test_add_cat_expensive '--hash=blake2b-256' "bafykbzaceduy3thhmcf6ptfqzxberlvj7sgo4uokrvd6qwrhim6r3rgcb26qi"

test_add_named_pipe

test_add_pwd_is_symlink

test_add_cat_raw

test_expect_success "ipfs add --cid-version=9 fails" '
  echo "context" > afile.txt &&
  test_must_fail ipfs add --cid-version=9 afile.txt 2>&1 | tee add_out &&
  grep -q "unknown CID version" add_out
'

test_kill_ipfs_daemon

# should work offline

test_add_cat_file

test_add_cat_raw

test_expect_success "ipfs add --only-hash succeeds" '
  echo "unknown content for only-hash" | ipfs add --only-hash -q > oh_hash
'

test_add_cat_derefargs

#TODO: this doesn't work when online hence separated out from test_add_cat_file
test_expect_success "ipfs cat file fails" '
  test_must_fail ipfs cat $(cat oh_hash)
'

test_add_named_pipe

test_add_pwd_is_symlink

# Test daemon in offline mode
test_launch_ipfs_daemon_without_network

test_add_cat_file

test_kill_ipfs_daemon

test_done
