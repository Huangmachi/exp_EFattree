#!/bin/bash
# Copyright (C) 2016 Huang MaChi at Chongqing University
# of Posts and Telecommunications, China.

k=$1
cpu=$2
flows_num_per_host=$3   # number of iperf flows per host.
duration=$4

# Exit on any failure.
set -e

# Check for uninitialized variables.
set -o nounset

ctrlc() {
	killall python
	killall -9 ryu-manager
	mn -c
	exit
}

trap ctrlc INT

# Traffic patterns.
# "stag_0.2_0.3" means 20% under the same Edge switch,
# 30% between different Edge switches in the same Pod,
# and 50% between different Pods.
# "random" means choosing the iperf server randomly.
# Change it if needed.
traffics="stag1_0.5_0.3 stag2_0.5_0.3 stag1_0.6_0.2 stag2_0.6_0.2 stag1_0.7_0.2 stag2_0.7_0.2 stag1_0.8_0.1 stag2_0.8_0.1"
# traffics="stag_0.2_0.3 stag_0.3_0.3 stag_0.4_0.3 stag_0.5_0.3 stag_0.6_0.2 stag_0.7_0.2 stag_0.8_0.1 random"
# Output directory.
out_dir="./results"
rm -f -r ./results
mkdir -p $out_dir

# Run experiments.
for traffic in $traffics
do
	# Create iperf peers.
	sudo python ./create_peers.py --k $k --traffic $traffic --fnum $flows_num_per_host
	sleep 1

	# EFattree
	dir=$out_dir/$traffic/EFattree
	mkdir -p $dir
	mn -c
	sudo python ./EFattree/fattree.py --k $k --duration $duration --dir $dir --cpu $cpu

	# ECMP
	dir=$out_dir/$traffic/ECMP
	mkdir -p $dir
	mn -c
	sudo python ./ECMP/fattree.py --k $k --duration $duration --dir $dir --cpu $cpu

	# PureSDN
	dir=$out_dir/$traffic/PureSDN
	mkdir -p $dir
	mn -c
	sudo python ./PureSDN/fattree.py --k $k --duration $duration --dir $dir --cpu $cpu

	# Hedera
	dir=$out_dir/$traffic/Hedera
	mkdir -p $dir
	mn -c
	sudo python ./Hedera/fattree.py --k $k --duration $duration --dir $dir --cpu $cpu

done


# Plot results.
sudo python ./plot_results.py --k $k --duration $duration --dir $out_dir
